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
[System.Boolean]$exchangeInstalled = IsSetupComplete

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
        [System.String[]]$expectedActiveComponentsList = 'ServerWideOffline',`
                                                         'HubTransport',`
                                                         'FrontendTransport',`
                                                         'Monitoring',`
                                                         'RecoveryActionsEnabled',`
                                                         'AutoDiscoverProxy',`
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
                                                         'UMCallRouter',`
                                                         'XropProxy',`
                                                         'HttpProxyAvailabilityGroup',`
                                                         'MapiProxy',`
                                                         'EdgeTransport',`
                                                         'HighAvailability',`
                                                         'SharedCache'

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
        Enabled = $false
        Credential = $Global:ShellCredentials
        AdditionalComponentsToActivate = 'AutoDiscoverProxy',`
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
                                            'UMCallRouter',`
                                            'XropProxy',`
                                            'HttpProxyAvailabilityGroup',`
                                            'MapiProxy',`
                                            'EdgeTransport',`
                                            'HighAvailability',`
                                            'SharedCache'
        MovePreferredDatabasesBack = $true
    }

    Set-TargetResource @testParams -Verbose
    $inMM = Test-TargetResource @testParams -Verbose

    if ($inMM -eq $false)
    {
        throw 'Failed to take server out of maintenance mode'
    }
    elseif ($WaitBetweenTests -eq $true)
    {
        Wait-ExchDscBetweenTests -Verbose
    }
}

function Wait-ExchDscBetweenTests
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Int32]
        $SleepSeconds = 60
    )

    Write-Verbose -Message "Sleeping $($SleepSeconds) between tests."
    Start-Sleep -Seconds $SleepSeconds
}

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
    }
   
    #Make sure server is a DAG member
    if ($null -eq $Global:IsDagMember)
    {
        GetRemoteExchangeSession -Credential $Global:ShellCredentials `
                                 -CommandsToLoad 'Get-MailboxServer','Get-MailboxDatabaseCopyStatus','Get-MailboxDatabase'

        $mbxServer = Get-MailboxServer $env:COMPUTERNAME

        [System.Boolean]$Global:IsDagMember = !([System.String]::IsNullOrEmpty($mbxServer.DatabaseAvailabilityGroup))
    }

    if ($Global:IsDagMember -eq $false)
    {
        Write-Verbose -Message 'Tests in this file require that this server be a member of a Database Availability Group'
        return
    }

    #Make sure server only has replicated DB's
    if ($null -eq $Global:HasNonReplicationDBs)
    {
        $nonReplicatedDBs = Get-MailboxDatabase -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            $_.ReplicationType -like 'None'
        }

        if ($null -ne $nonReplicatedDBs)
        {
            $Global:HasNonReplicationDBs = $true
        }
    }

    if ($Global:HasNonReplicationDBs -eq $true)
    {
        Write-Verbose -Message 'Tests in this file require that all databases on this server must have copies on other DAG members.'
        return
    }

    #Get Domain Controller
    if ($null -eq $Global:DomainController)
    {
        [System.String]$Global:DomainController = Read-Host -Prompt 'Enter Domain Controller to use for DC tests'
    }

    Write-Verbose -Message 'Ensuring server is out of maintenance mode before beginning tests'
    EnsureOutOfMaintenanceMode

    Describe 'Test Putting a Server in and out of Maintenance Mode' {
        #Put server in maintenance mode
        $testParams = @{
            Enabled = $true
            Credential = $Global:ShellCredentials
            AdditionalComponentsToActivate = 'AutoDiscoverProxy',`
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
                                             'UMCallRouter',`
                                             'XropProxy',`
                                             'HttpProxyAvailabilityGroup',`
                                             'MapiProxy',`
                                             'EdgeTransport',`
                                             'HighAvailability',`
                                             'SharedCache'
            MovePreferredDatabasesBack = $true
        }

        $expectedGetResults = @{
            Enabled = $true
            ActiveComponentCount = 2 #Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount = 0
            ActiveUMCallCount = 0
            ClusterState = 'Paused'
            QueuedMessageCount = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-ExchDscBetweenTests -Verbose

        #Take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled = $false            
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode
        Wait-ExchDscBetweenTests -Verbose

        #Test passing in UpgradedServerVersion that is lower than the current server version
        $testParams = @{
            Enabled = $true
            Credential = $Global:ShellCredentials
            MovePreferredDatabasesBack = $true
            UpgradedServerVersion = '15.0.0.0'
        }

        $expectedGetResults = @{
            Enabled = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Try to put server in maintenance mode using UpgradedServerVersion of an older server.' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-ExchDscBetweenTests -Verbose

        #Test using Domain Controller switch to put server in maintenance mode
        $testParams = @{
            Enabled = $true
            Credential = $Global:ShellCredentials
            MovePreferredDatabasesBack = $true
            DomainController = $Global:DomainController
        }

        $expectedGetResults = @{
            Enabled = $true
            ActiveComponentCount = 2 #Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount = 0
            ActiveUMCallCount = 0
            ClusterState = 'Paused'
            QueuedMessageCount = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-ExchDscBetweenTests -Verbose

        #Test using Domain Controller switch to take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode
        Wait-ExchDscBetweenTests -Verbose

        #Test SetInactiveComponentsFromAnyRequesterToActive Parameter
        #First put the server in maintenance mode
        $testParams = @{
            Enabled = $true
            Credential = $Global:ShellCredentials
            AdditionalComponentsToActivate = 'AutoDiscoverProxy',`
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
                                             'UMCallRouter',`
                                             'XropProxy',`
                                             'HttpProxyAvailabilityGroup',`
                                             'MapiProxy',`
                                             'EdgeTransport',`
                                             'HighAvailability',`
                                             'SharedCache'
            MovePreferredDatabasesBack = $true
            SetInactiveComponentsFromAnyRequesterToActive = $false
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
