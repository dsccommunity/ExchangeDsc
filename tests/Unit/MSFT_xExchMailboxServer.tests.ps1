function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
        InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchMailboxServer\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'MailboxServer'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getMailboxServerStandardOutput = @{
                # Generic Properties
                AutoDatabaseMountDial                    = [System.String] ''
                CalendarRepairIntervalEndWindow          = [System.Int32] 1
                CalendarRepairLogDirectorySizeLimit      = [System.String] ''
                CalendarRepairLogEnabled                 = [System.Boolean] $false
                CalendarRepairLogFileAgeLimit            = [System.String] ''
                CalendarRepairLogPath                    = [System.String] ''
                CalendarRepairLogSubjectLoggingEnabled   = [System.Boolean] $false
                CalendarRepairMissingItemFixDisabled     = [System.Boolean] $false
                CalendarRepairMode                       = [System.String] ''
                DatabaseCopyActivationDisabledAndMoveNow = [System.Boolean] $false
                DatabaseCopyAutoActivationPolicy         = [System.String] ''
                FolderLogForManagedFoldersEnabled        = [System.Boolean] $false
                ForceGroupMetricsGeneration              = [System.Boolean] $false
                IsExcludedFromProvisioning               = [System.Boolean] $false
                JournalingLogForManagedFoldersEnabled    = [System.Boolean] $false
                Locale                                   = [System.String[]] @()
                LogDirectorySizeLimitForManagedFolders   = [System.String] ''
                LogFileAgeLimitForManagedFolders         = [System.String] ''
                LogFileSizeLimitForManagedFolders        = [System.String] ''
                LogPathForManagedFolders                 = [System.String] ''
                MAPIEncryptionRequired                   = [System.Boolean] $false
                MaximumActiveDatabases                   = [System.String] ''
                MaximumPreferredActiveDatabases          = [System.String] ''
                RetentionLogForManagedFoldersEnabled     = [System.Boolean] $false
                SharingPolicySchedule                    = [System.String[]] @()
                SubjectLogForManagedFoldersEnabled       = [System.Boolean] $false

                # 2016/2019 Only Properties
                WacDiscoveryEndpoint                     = [System.String] ''

                # 2013 Only Properties
                CalendarRepairWorkCycle                  = [System.String] ''
                CalendarRepairWorkCycleCheckpoint        = [System.String] ''
                MailboxProcessorWorkCycle                = [System.String] ''
                ManagedFolderAssistantSchedule           = [System.String] @()
                ManagedFolderWorkCycle                   = [System.String] ''
                ManagedFolderWorkCycleCheckpoint         = [System.String] ''
                OABGeneratorWorkCycle                    = [System.String] ''
                OABGeneratorWorkCycleCheckpoint          = [System.String] ''
                PublicFolderWorkCycle                    = [System.String] ''
                PublicFolderWorkCycleCheckpoint          = [System.String] ''
                SharingPolicyWorkCycle                   = [System.String] ''
                SharingPolicyWorkCycleCheckpoint         = [System.String] ''
                SharingSyncWorkCycle                     = [System.String] ''
                SharingSyncWorkCycleCheckpoint           = [System.String] ''
                SiteMailboxWorkCycle                     = [System.String] ''
                SiteMailboxWorkCycleCheckpoint           = [System.String] ''
                TopNWorkCycle                            = [System.String] ''
                TopNWorkCycleCheckpoint                  = [System.String] ''
                UMReportingWorkCycle                     = [System.String] ''
                UMReportingWorkCycleCheckpoint           = [System.String] ''
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            Mock -CommandName Get-MailboxServerInternal -Verifiable -MockWith { return $getMailboxServerStandardOutput }

            Context 'When Exchange version is 2016 or 2019' {
                Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return '2016' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When Exchange version is 2013' {
                Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return '2013' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams

                # Try changing ManagedFolderAssistantSchedule to $null
                $getMailboxServerStandardOutput.ManagedFolderAssistantSchedule = $null

                Mock -CommandName Get-MailboxServerInternal -Verifiable -MockWith { return $getMailboxServerStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
