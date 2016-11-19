###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchMailboxDatabase\MSFT_xExchMailboxDatabase.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Removes the test DAG if it exists, and any associated databases
function PrepTestDB
{
    [CmdletBinding()]
    param
    (
        [string]
        $TestDBName
    )
    
    Write-Verbose "Cleaning up test database"

    GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "*-MailboxDatabase"

    Get-MailboxDatabase | Where-Object {$_.Name -like "$($TestDBName)"} | Remove-MailboxDatabase -Confirm:$false

    Get-ChildItem -LiteralPath "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

    if ($null -ne (Get-MailboxDatabase | Where-Object {$_.Name -like "$($TestDBName)"}))
    {
        throw "Failed to cleanup test database"
    }

    Write-Verbose "Finished cleaning up test database"
}

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    $TestDBName = "Mailbox Database Test 123"

    PrepTestDB -TestDBName $TestDBName

    Describe "Test Creating a DB and Setting Properties with xExchMailboxDatabase" {
        $testParams = @{
            Name = $TestDBName
            Credential = $Global:ShellCredentials
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"         
            AllowServiceRestart = $true
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = "unlimited"
            CircularLoggingEnabled = $true
            DatabaseCopyCount = 1
            DeletedItemRetention = "14.00:00:00"
            EventHistoryRetentionPeriod = "03:04:05"
            IndexEnabled = $true
            IsExcludedFromProvisioning = $false
            IsSuspendedFromProvisioning = $false
            MailboxRetention = "30.00:00:00"
            MountAtStartup = $true
            OfflineAddressBook = "Default Offline Address Book (Ex2013)"
            RetainDeletedItemsUntilBackup = $false
            IssueWarningQuota = "27 MB"
            ProhibitSendQuota = "1GB"
            ProhibitSendReceiveQuota = "1.5 GB"
            RecoverableItemsQuota = "uNlImItEd"
            RecoverableItemsWarningQuota = "1,000,448"
        }

        $expectedGetResults = @{
            Name = $TestDBName
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"         
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = "unlimited"
            CircularLoggingEnabled = $true
            DatabaseCopyCount = 1
            DeletedItemRetention = "14.00:00:00"
            EventHistoryRetentionPeriod = "03:04:05"
            IndexEnabled = $true
            IsExcludedFromProvisioning = $false
            IsSuspendedFromProvisioning = $false
            MailboxRetention = "30.00:00:00"
            MountAtStartup = $true
            OfflineAddressBook = "\Default Offline Address Book (Ex2013)"
            RetainDeletedItemsUntilBackup = $false
            IssueWarningQuota = "27 MB"
            ProhibitSendQuota = "1GB"
            ProhibitSendReceiveQuota = "1.5 GB"
            RecoverableItemsQuota = "uNlImItEd"
            RecoverableItemsWarningQuota = "1,000,448"
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Create Test Database" -ExpectedGetResults $expectedGetResults        

        $testParams = @{
            Name = $TestDBName
            Credential = $Global:ShellCredentials
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"         
            AllowServiceRestart = $true
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = "30mb"
            CircularLoggingEnabled = $false
            DatabaseCopyCount = 1
            DeletedItemRetention = "15.00:00:00"
            EventHistoryRetentionPeriod = "04:05:06"
            IndexEnabled = $false
            IsExcludedFromProvisioning = $true
            IsSuspendedFromProvisioning = $true
            MailboxRetention = "31.00:00:00"
            MountAtStartup = $false
            OfflineAddressBook = "Default Offline Address Book (Ex2013)"
            RetainDeletedItemsUntilBackup = $true
            IssueWarningQuota = "28 MB"
            ProhibitSendQuota = "2GB"
            ProhibitSendReceiveQuota = "2.5 GB"
            RecoverableItemsQuota = "2 GB"
            RecoverableItemsWarningQuota = "1.5 GB"
        }

        $expectedGetResults = @{
            Name = $TestDBName
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"         
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = "30mb"
            CircularLoggingEnabled = $false
            DatabaseCopyCount = 1
            DeletedItemRetention = "15.00:00:00"
            EventHistoryRetentionPeriod = "04:05:06"
            IndexEnabled = $false
            IsExcludedFromProvisioning = $true
            IsSuspendedFromProvisioning = $true
            MailboxRetention = "31.00:00:00"
            MountAtStartup = $false
            OfflineAddressBook = "\Default Offline Address Book (Ex2013)"
            RetainDeletedItemsUntilBackup = $true
            IssueWarningQuota = "28 MB"
            ProhibitSendQuota = "2GB"
            ProhibitSendReceiveQuota = "2.5 GB"
            RecoverableItemsQuota = "2 GB"
            RecoverableItemsWarningQuota = "1.5 GB"
        }

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $testParams.Add("IsExcludedFromProvisioningReason", "Testing Excluding the Database")
            $expectedGetResults.Add("IsExcludedFromProvisioningReason", "Testing Excluding the Database")
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change many DB properties" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
