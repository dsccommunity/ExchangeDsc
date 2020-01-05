[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

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
        Describe 'MSFT_xExchMailboxDatabase\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Set-ADServerSettings {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Name                            = 'MailboxDatabase'
                Credential                      = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                DatabaseCopyCount               = 1
                EdbFilePath                     = 'SomeEDBPath'
                LogFolderPath                   = 'SomeLogPath'
                Server                          = 'Server'
                AdServerSettingsPreferredServer = 'SomeDC'
            }

            $getMailboxDatabaseStandardOutput = @{
                AutoDagExcludeFromMonitoring     = [System.Boolean] $false
                BackgroundDatabaseMaintenance    = [System.Boolean] $false
                CalendarLoggingQuota             = [System.String] ''
                CircularLoggingEnabled           = [System.Boolean] $false
                DataMoveReplicationConstraint    = [System.String] ''
                DeletedItemRetention             = [System.String] ''
                EventHistoryRetentionPeriod      = [System.String] ''
                IndexEnabled                     = [System.Boolean] $false
                IsExcludedFromProvisioning       = [System.Boolean] $false
                IssueWarningQuota                = [System.String] ''
                IsSuspendedFromProvisioning      = [System.Boolean] $false
                JournalRecipient                 = [System.String] ''
                MailboxRetention                 = [System.String] ''
                MountAtStartup                   = [System.Boolean] $false
                OfflineAddressBook               = [System.String] ''
                ProhibitSendQuota                = [System.String] ''
                ProhibitSendReceiveQuota         = [System.String] ''
                RecoverableItemsQuota            = [System.String] ''
                RecoverableItemsWarningQuota     = [System.String] ''
                RetainDeletedItemsUntilBackup    = [System.Boolean] $false
                IsExcludedFromProvisioningReason = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-MailboxDatabaseInternal -Verifiable -MockWith { return $getMailboxDatabaseStandardOutput }
                Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return '2016' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
