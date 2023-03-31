<#
    .SYNOPSIS
        Automated integration test for DSC_ExchMailboxServer DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'ExchangeDsc'
[System.String] $script:DSCResourceFriendlyName = 'ExchMailboxServer'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'ExchangeDscTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'ExchangeDscHelper\ExchangeDscHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'Test Setting Properties with ExchMailboxServer' {
        $serverVersion = Get-ExchangeVersionYear

        # Make sure DB activation is not blocked
        $testParams = @{
            Identity = $env:COMPUTERNAME
            Credential = $shellCredentials
            AutoDatabaseMountDial = 'BestAvailability'
            CalendarRepairIntervalEndWindow = '15'
            CalendarRepairLogDirectorySizeLimit = '1GB'
            CalendarRepairLogEnabled = $false
            CalendarRepairLogFileAgeLimit = '30.00:00:00'
            CalendarRepairLogPath = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Calendar Repair DSC'
            CalendarRepairLogSubjectLoggingEnabled = $false
            CalendarRepairMissingItemFixDisabled = $true
            CalendarRepairMode = 'ValidateOnly'
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = 'Unrestricted'
            FolderLogForManagedFoldersEnabled = $true
            ForceGroupMetricsGeneration = $true
            IsExcludedFromProvisioning = $true
            JournalingLogForManagedFoldersEnabled = $true
            LogDirectorySizeLimitForManagedFolders = '10GB'
            LogFileAgeLimitForManagedFolders = '7.00:00:00'
            LogFileSizeLimitForManagedFolders = '15MB'
            LogPathForManagedFolders = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Managed Folder Assistant DSC'
            MAPIEncryptionRequired = $true
            MaximumActiveDatabases = '36'
            MaximumPreferredActiveDatabases = '24'
            RetentionLogForManagedFoldersEnabled = $false
            SharingPolicySchedule = 'Sun.11:30 PM-Mon.1:30 AM'
            SubjectLogForManagedFoldersEnabled = $true
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            AutoDatabaseMountDial = 'BestAvailability'
            CalendarRepairIntervalEndWindow = '15'
            CalendarRepairLogDirectorySizeLimit = '1 GB (1,073,741,824 bytes)'
            CalendarRepairLogEnabled = $false
            CalendarRepairLogFileAgeLimit = '30.00:00:00'
            CalendarRepairLogPath = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Calendar Repair DSC'
            CalendarRepairLogSubjectLoggingEnabled = $false
            CalendarRepairMissingItemFixDisabled = $true
            CalendarRepairMode = 'ValidateOnly'
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = 'Unrestricted'
            FolderLogForManagedFoldersEnabled = $true
            ForceGroupMetricsGeneration = $true
            IsExcludedFromProvisioning = $true
            JournalingLogForManagedFoldersEnabled = $true
            LogDirectorySizeLimitForManagedFolders = '10 GB (10,737,418,240 bytes)'
            LogFileAgeLimitForManagedFolders = '7.00:00:00'
            LogFileSizeLimitForManagedFolders = '15 MB (15,728,640 bytes)'
            LogPathForManagedFolders = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Managed Folder Assistant DSC'
            MAPIEncryptionRequired = $true
            MaximumActiveDatabases = '36'
            MaximumPreferredActiveDatabases = '24'
            RetentionLogForManagedFoldersEnabled = $false
            SharingPolicySchedule = 'Sun.11:30 PM-Mon.1:30 AM'
            SubjectLogForManagedFoldersEnabled = $true
        }

        if ($serverVersion -in '2016', '2019')
        {
            $testParams.Add('WacDiscoveryEndpoint', '')
            $expectedGetResults.Add('WacDiscoveryEndpoint', '')
        }

        if ($serverVersion -eq '2013')
        {
            $testParams.Add('CalendarRepairWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('CalendarRepairWorkCycle', '2.00:00:00')
            $testParams.Add('CalendarRepairWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('CalendarRepairWorkCycleCheckpoint', '2.00:00:00')
            $testParams.Add('MailboxProcessorWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('MailboxProcessorWorkCycle', '2.00:00:00')
            $testParams.Add('ManagedFolderAssistantSchedule', 'Sun.11:30 PM-Mon.1:30 AM')
            $expectedGetResults.Add('ManagedFolderAssistantSchedule', 'Sun.11:30 PM-Mon.1:30 AM')
            $testParams.Add('ManagedFolderWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('ManagedFolderWorkCycle', '2.00:00:00')
            $testParams.Add('ManagedFolderWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('ManagedFolderWorkCycleCheckpoint', '2.00:00:00')
            $testParams.Add('OABGeneratorWorkCycle', '10:00:00')
            $expectedGetResults.Add('OABGeneratorWorkCycle', '10:00:00')
            $testParams.Add('OABGeneratorWorkCycleCheckpoint', '10:00:00')
            $expectedGetResults.Add('OABGeneratorWorkCycleCheckpoint', '10:00:00')
            $testParams.Add('PublicFolderWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('PublicFolderWorkCycle', '2.00:00:00')
            $testParams.Add('PublicFolderWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('PublicFolderWorkCycleCheckpoint', '2.00:00:00')
            $testParams.Add('SharingPolicyWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('SharingPolicyWorkCycle', '2.00:00:00')
            $testParams.Add('SharingPolicyWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('SharingPolicyWorkCycleCheckpoint', '2.00:00:00')
            $testParams.Add('SharingSyncWorkCycle', '05:00:00')
            $expectedGetResults.Add('SharingSyncWorkCycle', '05:00:00')
            $testParams.Add('SharingSyncWorkCycleCheckpoint', '05:00:00')
            $expectedGetResults.Add('SharingSyncWorkCycleCheckpoint', '05:00:00')
            $testParams.Add('SiteMailboxWorkCycle', '05:00:00')
            $expectedGetResults.Add('SiteMailboxWorkCycle', '05:00:00')
            $testParams.Add('SiteMailboxWorkCycleCheckpoint', '05:00:00')
            $expectedGetResults.Add('SiteMailboxWorkCycleCheckpoint', '05:00:00')
            $testParams.Add('TopNWorkCycle', '10.00:00:00')
            $expectedGetResults.Add('TopNWorkCycle', '10.00:00:00')
            $testParams.Add('TopNWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('TopNWorkCycleCheckpoint', '2.00:00:00')
            $testParams.Add('UMReportingWorkCycle', '2.00:00:00')
            $expectedGetResults.Add('UMReportingWorkCycle', '2.00:00:00')
            $testParams.Add('UMReportingWorkCycleCheckpoint', '2.00:00:00')
            $expectedGetResults.Add('UMReportingWorkCycleCheckpoint', '2.00:00:00')
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set non-default values for all properties' `
                                         -ExpectedGetResults $expectedGetResults

        # Block DB activation
        $testParams.DatabaseCopyActivationDisabledAndMoveNow = $true
        $testParams.DatabaseCopyAutoActivationPolicy = 'Blocked'
        $testParams.MaximumActiveDatabases = '24'
        $testParams.MaximumPreferredActiveDatabases = '12'

        $expectedGetResults.DatabaseCopyActivationDisabledAndMoveNow = $true
        $expectedGetResults.DatabaseCopyAutoActivationPolicy = 'Blocked'
        $expectedGetResults.MaximumActiveDatabases = '24'
        $expectedGetResults.MaximumPreferredActiveDatabases = '12'

        if ($serverVersion -in '2016', '2019')
        {
            $testParams['WacDiscoveryEndpoint'] = 'https://localhost/hosting/discovery'
            $expectedGetResults['WacDiscoveryEndpoint'] = 'https://localhost/hosting/discovery'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Block DB Activation, Set WacDiscoveryEndpoint, and modify MaxDBValues' `
                                         -ExpectedGetResults $expectedGetResults

        # Make sure DB activation is not blocked
        $testParams = @{
            Identity = $env:COMPUTERNAME
            Credential = $shellCredentials
            AutoDatabaseMountDial = 'GoodAvailability'
            CalendarRepairLogDirectorySizeLimit = '500MB'
            CalendarRepairLogEnabled = $true
            CalendarRepairLogFileAgeLimit = '10.00:00:00'
            CalendarRepairLogPath = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Calendar Repair'
            CalendarRepairLogSubjectLoggingEnabled = $true
            CalendarRepairMissingItemFixDisabled = $false
            CalendarRepairMode = 'RepairAndValidate'
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = 'Unrestricted'
            FolderLogForManagedFoldersEnabled = $false
            ForceGroupMetricsGeneration = $false
            IsExcludedFromProvisioning = $false
            JournalingLogForManagedFoldersEnabled = $false
            LogDirectorySizeLimitForManagedFolders = 'Unlimited'
            LogFileAgeLimitForManagedFolders = '00:00:00'
            LogFileSizeLimitForManagedFolders = '10MB'
            LogPathForManagedFolders = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Managed Folder Assistant'
            MAPIEncryptionRequired = $false
            MaximumActiveDatabases = ''
            MaximumPreferredActiveDatabases = ''
            RetentionLogForManagedFoldersEnabled = $false
            SharingPolicySchedule = $null
            SubjectLogForManagedFoldersEnabled = $false
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            AutoDatabaseMountDial = 'GoodAvailability'
            CalendarRepairLogDirectorySizeLimit = '500 MB (524,288,000 bytes)'
            CalendarRepairLogEnabled = $true
            CalendarRepairLogFileAgeLimit = '10.00:00:00'
            CalendarRepairLogPath = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Calendar Repair'
            CalendarRepairLogSubjectLoggingEnabled = $true
            CalendarRepairMissingItemFixDisabled = $false
            CalendarRepairMode = 'RepairAndValidate'
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = 'Unrestricted'
            FolderLogForManagedFoldersEnabled = $false
            ForceGroupMetricsGeneration = $false
            IsExcludedFromProvisioning = $false
            JournalingLogForManagedFoldersEnabled = $false
            LogDirectorySizeLimitForManagedFolders = 'Unlimited'
            LogFileAgeLimitForManagedFolders = '00:00:00'
            LogFileSizeLimitForManagedFolders = '10 MB (10,485,760 bytes)'
            LogPathForManagedFolders = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\Managed Folder Assistant'
            MAPIEncryptionRequired = $false
            MaximumActiveDatabases = ''
            MaximumPreferredActiveDatabases = ''
            RetentionLogForManagedFoldersEnabled = $false
            SubjectLogForManagedFoldersEnabled = $false
        }

        if ($serverVersion -in '2016', '2019')
        {
            $testParams['CalendarRepairIntervalEndWindow'] = '7'
            $expectedGetResults['CalendarRepairIntervalEndWindow'] = '7'
            $testParams['WacDiscoveryEndpoint'] = ''
            $expectedGetResults['WacDiscoveryEndpoint'] = ''
        }

        if ($serverVersion -eq '2013')
        {
            $testParams['CalendarRepairIntervalEndWindow'] = '30'
            $expectedGetResults['CalendarRepairIntervalEndWindow'] = '30'
            $testParams['CalendarRepairWorkCycle'] = '1.00:00:00'
            $expectedGetResults['CalendarRepairWorkCycle'] = '1.00:00:00'
            $testParams['CalendarRepairWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['CalendarRepairWorkCycleCheckpoint'] = '1.00:00:00'
            $testParams['MailboxProcessorWorkCycle'] = '1.00:00:00'
            $expectedGetResults['MailboxProcessorWorkCycle'] = '1.00:00:00'
            $testParams['ManagedFolderAssistantSchedule'] = $null
            $expectedGetResults['ManagedFolderAssistantSchedule'] = $null
            $testParams['ManagedFolderWorkCycle'] = '1.00:00:00'
            $expectedGetResults['ManagedFolderWorkCycle'] = '1.00:00:00'
            $testParams['ManagedFolderWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['ManagedFolderWorkCycleCheckpoint'] = '1.00:00:00'
            $testParams['OABGeneratorWorkCycle'] = '08:00:00'
            $expectedGetResults['OABGeneratorWorkCycle'] = '08:00:00'
            $testParams['OABGeneratorWorkCycleCheckpoint'] = '01:00:00'
            $expectedGetResults['OABGeneratorWorkCycleCheckpoint'] = '01:00:00'
            $testParams['PublicFolderWorkCycle'] = '1.00:00:00'
            $expectedGetResults['PublicFolderWorkCycle'] = '1.00:00:00'
            $testParams['PublicFolderWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['PublicFolderWorkCycleCheckpoint'] = '1.00:00:00'
            $testParams['SharingPolicyWorkCycle'] = '1.00:00:00'
            $expectedGetResults['SharingPolicyWorkCycle'] = '1.00:00:00'
            $testParams['SharingSyncWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['SharingSyncWorkCycleCheckpoint'] = '1.00:00:00'
            $testParams['SiteMailboxWorkCycle'] = '06:00:00'
            $expectedGetResults['SiteMailboxWorkCycle'] = '06:00:00'
            $testParams['SiteMailboxWorkCycleCheckpoint'] = '06:00:00'
            $expectedGetResults['SiteMailboxWorkCycleCheckpoint'] = '06:00:00'
            $testParams['TopNWorkCycle'] = '7.00:00:00'
            $expectedGetResults['TopNWorkCycle'] = '7.00:00:00'
            $testParams['TopNWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['TopNWorkCycleCheckpoint'] = '1.00:00:00'
            $testParams['UMReportingWorkCycle'] = '1.00:00:00'
            $expectedGetResults['UMReportingWorkCycle'] = '1.00:00:00'
            $testParams['UMReportingWorkCycleCheckpoint'] = '1.00:00:00'
            $expectedGetResults['UMReportingWorkCycleCheckpoint'] = '1.00:00:00'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Reset values to default' `
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.SharingPolicySchedule `
                                -GetResultParameterName 'SharingPolicySchedule' `
                                -ContextLabel 'Verify SharingPolicySchedule' `
                                -ItLabel 'SharingPolicySchedule should be empty'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
