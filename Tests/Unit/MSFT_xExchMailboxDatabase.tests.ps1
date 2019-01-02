[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchMailboxDatabase'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -ResourceType 'Mof' `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup
{

}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    Invoke-TestSetup

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
