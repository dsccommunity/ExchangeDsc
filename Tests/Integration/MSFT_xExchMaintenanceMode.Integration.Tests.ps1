<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchMaintenanceMode DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchMaintenanceMode'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean]$exchangeInstalled = Get-IsSetupComplete

#endregion HEADER
function Test-ServerIsOutOfMaintenanceMode
{
    [CmdletBinding()]
    param()

    Context 'Do additional Get-TargetResource verification after taking server out of maintenance mode' {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @testParams -Verbose

        It 'ActiveComponentCount is greater than 0' {
            $getResult.ActiveComponentCount -gt 0 | Should Be $true
        }

        <#
            Verify that all components in the following list are Active.
            This list comes from an Exchange 2013 CU9 machine with both the CAS and MBX roles.
        #>
        [System.String[]]$expectedActiveComponentsList = Get-VersionSpecificComponentsToActivate

        $expectedActiveComponentsList += 'ServerWideOffline','HubTransport','FrontendTransport','Monitoring','RecoveryActionsEnabled'

        foreach ($expectedActiveComponent in $expectedActiveComponentsList)
        {
            It "Component $($expectedActiveComponent) should be Active" {
                $getResult.ActiveComponentsList.Contains($expectedActiveComponent) | Should Be $true
            }
        }

        $status = $null
        $status = Get-MailboxDatabaseCopyStatus -Server $env:COMPUTERNAME | Where-Object {$_.Status -eq 'Mounted'}

        It 'Databases were failed back' {
            ($null -ne $status) | Should Be $true
        }
    }
}

function EnsureOutOfMaintenanceMode
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Boolean]
        $WaitBetweenTests = $true
    )

    Write-Verbose -Message 'Ensuring server is out of maintenance mode'

    #Put server in maintenance mode
    $testParams = @{
        Enabled                        = $false
        Credential                     = $shellCredentials
        AdditionalComponentsToActivate = Get-VersionSpecificComponentsToActivate
        MountDialOverride              = 'BestEffort'
        MovePreferredDatabasesBack     = $true
        SkipClientExperienceChecks     = $true
        SkipLagChecks                  = $true
        SkipMoveSuppressionChecks      = $true
    }

    Set-TargetResource @testParams -Verbose
    $inMM = Test-TargetResource @testParams -Verbose

    if ($inMM -eq $false)
    {
        throw 'Failed to take server out of maintenance mode'
    }
    elseif ($WaitBetweenTests -eq $true)
    {
        Wait-Verbose -Verbose
    }
}

function Wait-Verbose
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Int32]
        $SleepSeconds = 15
    )

    Write-Verbose -Message "Sleeping $($SleepSeconds) between tests."
    Start-Sleep -Seconds $SleepSeconds
}

function Get-VersionSpecificComponentsToActivate
{
    [CmdletBinding()]
    param()

    $serverVersion = Get-ExchangeVersion

    $componentsToActivate = 'AutoDiscoverProxy',`
                            'ActiveSyncProxy',`
                            'EcpProxy',`
                            'EwsProxy',`
                            'ImapProxy',`
                            'OabProxy',`
                            'OwaProxy',`
                            'PopProxy',`
                            'PushNotificationsProxy',`
                            'RpsProxy',`
                            'RwsProxy',`
                            'RpcProxy',`
                            'XropProxy',`
                            'HttpProxyAvailabilityGroup',`
                            'MapiProxy',`
                            'EdgeTransport',`
                            'HighAvailability',`
                            'SharedCache'

    if ($serverVersion -in '2013','2016')
    {
        $testParams.AdditionalComponentsToActivate += 'UMCallRouter'
    }
}

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    #Make sure server is a DAG member
    if ($null -eq $isDagMember)
    {
        GetRemoteExchangeSession -Credential $shellCredentials `
                                 -CommandsToLoad 'Get-MailboxServer','Get-MailboxDatabaseCopyStatus','Get-MailboxDatabase'

        $mbxServer = Get-MailboxServer $env:COMPUTERNAME

        [System.Boolean]$isDagMember = !([System.String]::IsNullOrEmpty($mbxServer.DatabaseAvailabilityGroup))
    }

    if ($isDagMember -eq $false)
    {
        Write-Warning -Message 'Tests in this file require that this server be a member of a Database Availability Group. Skipping testing.'
        return
    }

    #Make sure server only has replicated DB's
    if ($null -eq $hasNonReplicationDBs)
    {
        $nonReplicatedDBs = Get-MailboxDatabase -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.ReplicationType -like 'None'
        }

        if ($null -ne $nonReplicatedDBs)
        {
            $hasNonReplicationDBs = $true
        }
    }

    if ($hasNonReplicationDBs -eq $true)
    {
        Write-Warning -Message 'Tests in this file require that all databases on this server must have copies on other DAG members. Skipping testing.'
        return
    }

    #Get Domain Controller
    if ($null -eq $dcToTestAgainst)
    {
        [System.String]$dcToTestAgainst = Read-Host -Prompt 'Enter Domain Controller to use for DC tests'
    }

    Write-Verbose -Message 'Ensuring server is out of maintenance mode before beginning tests'
    EnsureOutOfMaintenanceMode

    Describe 'Test Putting a Server in and out of Maintenance Mode' {
        #Put server in maintenance mode
        $testParams = @{
            Enabled                        = $true
            Credential                     = $shellCredentials
            AdditionalComponentsToActivate = Get-VersionSpecificComponentsToActivate
            MountDialOverride              = 'BestEffort' #Copy queue can get behind when rapidly failing over DB's for tests, so set this to BestEffort
            MovePreferredDatabasesBack     = $true
            SkipClientExperienceChecks     = $true #Content Index takes a while to become healthy after failing over. Override for tests.
            SkipLagChecks                  = $true #Copy queue can get behind when rapidly failing over DB's for tests, so skip LAG checks just in case
            SkipMoveSuppressionChecks      = $true #Exchange 2016 only allows a DB to be failed over 4 times in an hour. Override for tests.
        }

        $expectedGetResults = @{
            Enabled              = $true
            ActiveComponentCount = 2 #Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount        = 0
            ActiveUMCallCount    = 0
            ClusterState         = 'Paused'
            QueuedMessageCount   = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-Verbose -Verbose

        #Take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled      = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode
        Wait-Verbose -Verbose

        #Test passing in UpgradedServerVersion that is lower than the current server version
        $testParams = @{
            Enabled                    = $true
            Credential                 = $shellCredentials
            MountDialOverride          = 'BestEffort'
            MovePreferredDatabasesBack = $true
            UpgradedServerVersion      = '15.0.0.0'
            SkipClientExperienceChecks = $true
            SkipLagChecks              = $true
            SkipMoveSuppressionChecks  = $true
        }

        $expectedGetResults = @{
            Enabled      = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Try to put server in maintenance mode using UpgradedServerVersion of an older server.' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-Verbose -Verbose

        #Test using Domain Controller switch to put server in maintenance mode
        $testParams = @{
            Enabled                    = $true
            Credential                 = $shellCredentials
            MountDialOverride          = 'BestEffort'
            MovePreferredDatabasesBack = $true
            DomainController           = $dcToTestAgainst
            SkipClientExperienceChecks = $true
            SkipLagChecks              = $true
            SkipMoveSuppressionChecks  = $true
        }

        $expectedGetResults = @{
            Enabled              = $true
            ActiveComponentCount = 2 #Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount        = 0
            ActiveUMCallCount    = 0
            ClusterState         = 'Paused'
            QueuedMessageCount   = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-Verbose -Verbose

        #Test using Domain Controller switch to take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled      = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode
        Wait-Verbose -Verbose

        #Test SetInactiveComponentsFromAnyRequesterToActive Parameter
        #First put the server in maintenance mode
        $testParams = @{
            Enabled                                       = $true
            Credential                                    = $shellCredentials
            AdditionalComponentsToActivate                = Get-VersionSpecificComponentsToActivate
            MountDialOverride                             = 'BestEffort'
            MovePreferredDatabasesBack                    = $true
            SetInactiveComponentsFromAnyRequesterToActive = $false
            SkipClientExperienceChecks                    = $true
            SkipLagChecks                                 = $true
            SkipMoveSuppressionChecks                     = $true
        }

        Set-TargetResource @testParams -Verbose
        $testResults = Test-TargetResource @testParams -Verbose

        It 'Server should be in maintenance mode' {
            $testResults | Should Be $true
        }

        if ($testResults -eq $true)
        {
            #Manually set a component to Inactive as the HealthApi
            Set-ServerComponentState -Identity $env:COMPUTERNAME -Component 'ImapProxy' -State 'Inactive' -Requester 'HealthApi'

            #Do a failed attempt to take server out of maintenance mode
            $testParams.Enabled = $false

            Set-TargetResource @testParams -Verbose
            $testResults = Test-TargetResource @testParams -Verbose

            It 'Test should fail' {
                $testResults | Should Be $false
            }

            #Now set SetInactiveComponentsFromAnyRequesterToActive to true and try again. This should succeed
            $testParams.SetInactiveComponentsFromAnyRequesterToActive = $true

            Set-TargetResource @testParams -Verbose
            $testResults = Test-TargetResource @testParams -Verbose

            It 'Test should succeed' {
                $testResults | Should Be $true
            }
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
