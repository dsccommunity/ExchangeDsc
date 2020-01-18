[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchMailboxDatabase'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$script:testEnvironment = Invoke-TestSetup -DSCModuleName $script:dscModuleName -DSCResourceName $script:dscResourceName

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchMailboxDatabase\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Set-ADServerSettings
            {
            }

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

