<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchMaintenanceMode DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchMaintenanceMode'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

<#
    .SYNOPSIS
        Runs tests to ensure that the server is fully out of maintenance mode

    .PARAMETER GetTargetResourceParameters
        The paramaters to pass to Get-TargetResource.
#>
function Test-ServerIsOutOfMaintenanceMode
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $GetTargetResourceParameters
    )

    Context 'Do additional Get-TargetResource verification after taking server out of maintenance mode' {
        [System.Collections.Hashtable] $getResult = Get-TargetResource @GetTargetResourceParameters -Verbose

        It 'ActiveComponentCount is greater than 0' {
            $getResult.ActiveComponentCount -gt 0 | Should Be $true
        }

        <#
            Verify that all components in the following list are Active.
            This list comes from an Exchange 2013 CU9 machine with both the CAS and MBX roles.
        #>
        [System.String[]] $expectedActiveComponentsList = Get-VersionSpecificComponentsToActivate

        $expectedActiveComponentsList += 'ServerWideOffline', 'HubTransport', 'FrontendTransport', 'Monitoring', 'RecoveryActionsEnabled'

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

<#
    .SYNOPSIS
        Performs steps to take the server out of maintenance mode, verifies
        that the server was fully taken out of maintenance mode, and throws
        an exception if it was not.

    .PARAMETER WaitBetweenTests
        Whether the script should sleep a predetermined amount of time after
        the server has been taken out of maintenance mode before exiting the
        function.
#>
function Set-ThenAssertOutOfMaintenanceMode
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Boolean]
        $WaitBetweenTests = $true
    )

    Write-Verbose -Message 'Ensuring server is out of maintenance mode'

    # Take server out of maintenance mode
    $testParams = @{
        Enabled                                       = $false
        Credential                                    = $shellCredentials
        AdditionalComponentsToActivate                = Get-VersionSpecificComponentsToActivate
        MountDialOverride                             = 'BestEffort'
        MovePreferredDatabasesBack                    = $true
        SetInactiveComponentsFromAnyRequesterToActive = $true
        SkipClientExperienceChecks                    = $true
        SkipLagChecks                                 = $true
        SkipMoveSuppressionChecks                     = $true
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

<#
    .SYNOPSIS
        Performs a Write-Verbose that the script is about to sleep for
        $SleepSeconds seconds, then sleeps for $SleepSeconds seconds.

    .PARAMETER SleepSeconds
        The number of seconds to sleep.
#>
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

<#
    .SYNOPSIS
        Returns a String Array of extra components to attempt to activate when
        taking a server out of maintenance mode. Ensures that the components
        returned are relevant to the installed version of Exchange.
#>
function Get-VersionSpecificComponentsToActivate
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param()

    $serverVersion = Get-ExchangeVersionYear

    [System.String[]] $componentsToActivate = @('AutoDiscoverProxy',
                                               'ActiveSyncProxy',
                                               'EcpProxy',
                                               'EwsProxy',
                                               'ImapProxy',
                                               'OabProxy',
                                               'OwaProxy',
                                               'PopProxy',
                                               'PushNotificationsProxy',
                                               'RpsProxy',
                                               'RwsProxy',
                                               'RpcProxy',
                                               'XropProxy',
                                               'HttpProxyAvailabilityGroup',
                                               'MapiProxy',
                                               'EdgeTransport',
                                               'HighAvailability',
                                               'SharedCache')

    if ($serverVersion -in '2013', '2016')
    {
        $componentsToActivate += 'UMCallRouter'
    }

    return $componentsToActivate
}

<#
    .SYNOPSIS
        Waits up to 15 minutes for the Content Index state of all database
        copies of Activation Preference 1 on this server to become healthy.
        Returns $true if all Indexes are healthy after the wait, else returns
        $false. Will force a reseed of each unhealthy Content Index if another
        server in the DAG has a healthy Content Index.
#>
function Wait-ForPrimaryHealthyIndexState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()

    $hasHealthyContentIndexes = $false

    [System.Object[]] $unhealthyDBs = Get-UnhealthyPrimaryIndexesOnServer

    if ($unhealthyDBs.Count -gt 0)
    {
        # See if we have a healthy DB partner we can reseed the content index from
        foreach ($db in $unhealthyDBs)
        {
            if ($null -ne (Get-MailboxDatabaseCopyStatus -Identity $db.DatabaseName | Where-Object {$_.MailboxServer -notlike "$($env:COMPUTERNAME)" -and $_.ContentIndexState -like "Healthy"}))
            {
                Write-Verbose -Message "Reseeding content index of copy $($db.Identity)"

                Update-MailboxDatabaseCopy -Identity $db.Identity -CatalogOnly -BeginSeed -Confirm:$false -Force
            }
        }

        # Now wait up to 15 minutes for the indexes to go healthy
        for ($i = 0; $i -lt 15 -and !$hasHealthyContentIndexes; $i++)
        {
            $hasHealthyContentIndexes = (Get-UnhealthyPrimaryIndexesOnServer).Count -eq 0

            if (!$hasHealthyContentIndexes)
            {
                Write-Warning -Message 'One or more databases on this server have a content index in an unhealthy state. Waiting up to 15 minutes for them to become healthy. Sleeping for 60 seconds.'
                Start-Sleep -Seconds 60
            }
        }
    }
    else
    {
        $hasHealthyContentIndexes = $true
    }

    return $hasHealthyContentIndexes
}

<#
    .SYNOPSIS
        Waits up to 15 minutes for the Content Index state of all database
        copy partners on other DAG members to become healthy.
        Returns $true if all Indexes are healthy after the wait, else returns
        $false. Will force a reseed of each unhealthy Content Index if the copy
        on this server has a healthy Content Index.
#>
function Wait-ForSecondaryHealthyIndexState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()

    $hasHealthyContentIndexes = $false

    [System.Object[]] $unhealthyDBs = Get-UnhealthySecondaryPartnerIndexesInDAG

    if ($unhealthyDBs.Count -gt 0)
    {
        # See if we have a healthy DB on this server we can reseed the partner from
        foreach ($db in $unhealthyDBs)
        {
            if ($null -ne (Get-MailboxDatabaseCopyStatus -Identity $db.DatabaseName | Where-Object {$_.MailboxServer -like "$($env:COMPUTERNAME)" -and $_.ContentIndexState -like "Healthy"}))
            {
                Write-Verbose -Message "Reseeding content index of copy $($db.Identity)"

                Update-MailboxDatabaseCopy -Identity $db.Identity -CatalogOnly -BeginSeed -Confirm:$false -Force
            }
        }

        # Now wait up to 15 minutes for the indexes to go healthy
        for ($i = 0; $i -lt 15 -and !$hasHealthyContentIndexes; $i++)
        {
            $hasHealthyContentIndexes = (Get-UnhealthySecondaryPartnerIndexesInDAG).Count -eq 0

            if (!$hasHealthyContentIndexes)
            {
                Write-Warning -Message 'One or more databases on another DAG server have a content index in an unhealthy state. Waiting up to 15 minutes for them to become healthy. Sleeping for 60 seconds.'
                Start-Sleep -Seconds 60
            }
        }
    }
    else
    {
        $hasHealthyContentIndexes = $true
    }

    return $hasHealthyContentIndexes
}

<#
    .SYNOPSIS
        Returns an array containing the database copy status of each database
        on this server with Content Index state that is not Healthy.
#>
function Get-UnhealthyPrimaryIndexesOnServer
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param()

    return (Get-MailboxDatabaseCopyStatus -Server $env:COMPUTERNAME | Where-Object {$_.ActivationPreference -eq 1 -and $_.ContentIndexState -ne "Healthy"})
}

<#
    .SYNOPSIS
        Returns an array containing the database copy status of each database
        copy partner on other DAG mebmers with Content Index state that is not
        Healthy.
#>
function Get-UnhealthySecondaryPartnerIndexesInDAG
{
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param()

    return (Get-MailboxDatabase -Server $env:COMPUTERNAME | Get-MailboxDatabaseCopyStatus | Where-Object {$_.MailboxServer -notlike "*$($env:COMPUTERNAME)*" -and $_.ContentIndexState -ne "Healthy"})
}

if ($null -eq (Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue))
{
    Write-Verbose -Message 'Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS'
    return
}

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    # Make sure server is a DAG member
    if ($null -eq $isDagMember)
    {
        Get-RemoteExchangeSession -Credential $shellCredentials `
                                 -CommandsToLoad 'Get-MailboxServer', 'Get-MailboxDatabaseCopyStatus', 'Get-MailboxDatabase'

        $mbxServer = Get-MailboxServer $env:COMPUTERNAME

        [System.Boolean] $isDagMember = !([System.String]::IsNullOrEmpty($mbxServer.DatabaseAvailabilityGroup))
    }

    if ($isDagMember -eq $false)
    {
        Write-Warning -Message 'Tests in this file require that this server be a member of a Database Availability Group. Skipping testing.'
        return
    }

    # Make sure server only has replicated DB's
    $nonReplicatedDBs = Get-MailboxDatabase -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue | Where-Object -FilterScript {
        $_.ReplicationType -like 'None'
    }

    if ($null -ne $nonReplicatedDBs)
    {
        Write-Warning -Message 'Tests in this file require that all databases on this server must have copies on other DAG members. Skipping testing.'
        return
    }

    # Get Domain Controller
    [System.String] $dcToTestAgainst = Get-TestDomainController

    if ([System.String]::IsNullOrEmpty($dcToTestAgainst))
    {
        Write-Error -Message 'Unable to discover Domain Controller to use for DC specific tests.'
        return
    }

    Write-Verbose -Message 'Ensuring server is out of maintenance mode before beginning tests'
    Set-ThenAssertOutOfMaintenanceMode

    # Make sure the content index is healthy on primary database copies
    if (!(Wait-ForPrimaryHealthyIndexState -Verbose))
    {
        Write-Error -Message 'One or more databases on this server have a content index in an unhealthy state. Unable to perform Maintenance Mode tests.'
        return
    }

    if (!(Wait-ForSecondaryHealthyIndexState -Verbose))
    {
        Write-Error -Message 'One or more database replica partners on other DAG servers have a content index in an unhealthy state. Unable to perform Maintenance Mode tests.'
        return
    }

    Describe 'Test Putting a Server in and out of Maintenance Mode' {
        # Put server in maintenance mode
        $testParams = @{
            Enabled                        = $true
            Credential                     = $shellCredentials
            AdditionalComponentsToActivate = Get-VersionSpecificComponentsToActivate
            MountDialOverride              = 'BestEffort' # Copy queue can get behind when rapidly failing over DB's for tests, so set this to BestEffort
            MovePreferredDatabasesBack     = $true
            SkipClientExperienceChecks     = $true # Content Index takes a while to become healthy after failing over. Override for tests.
            SkipLagChecks                  = $true # Copy queue can get behind when rapidly failing over DB's for tests, so skip LAG checks just in case
            SkipMoveSuppressionChecks      = $true # Exchange 2016 only allows a DB to be failed over 4 times in an hour. Override for tests.
        }

        $expectedGetResults = @{
            Enabled              = $true
            ActiveComponentCount = 2 # Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount        = 0
            ActiveUMCallCount    = 0
            ClusterState         = 'Paused'
            QueuedMessageCount   = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-Verbose -Verbose

        # Take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled      = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode -GetTargetResourceParameters $testParams
        Wait-Verbose -Verbose

        # Test passing in UpgradedServerVersion that is lower than the current server version
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

        # Test using Domain Controller switch to put server in maintenance mode
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
            ActiveComponentCount = 2 # Monitoring and RecoveryActionsEnabled should still be Active after this
            ActiveDBCount        = 0
            ActiveUMCallCount    = 0
            ClusterState         = 'Paused'
            QueuedMessageCount   = 0
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Put server in maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Wait-Verbose -Verbose

        # Test using Domain Controller switch to take server out of maintenance mode
        $testParams.Enabled = $false

        $expectedGetResults = @{
            Enabled      = $false
            ClusterState = 'Up'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Take server out of maintenance mode using Domain Controller switch' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ServerIsOutOfMaintenanceMode -GetTargetResourceParameters $testParams
        Wait-Verbose -Verbose

        # Test SetInactiveComponentsFromAnyRequesterToActive Parameter
        # First put the server in maintenance mode
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
            # Manually set a component to Inactive as the HealthApi
            Set-ServerComponentState -Identity $env:COMPUTERNAME -Component 'ImapProxy' -State 'Inactive' -Requester 'HealthApi'

            # Do a failed attempt to take server out of maintenance mode
            $testParams.Enabled = $false

            Set-TargetResource @testParams -Verbose
            $testResults = Test-TargetResource @testParams -Verbose

            It 'Test should fail' {
                $testResults | Should Be $false
            }

            # Now set SetInactiveComponentsFromAnyRequesterToActive to true and try again. This should succeed
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
