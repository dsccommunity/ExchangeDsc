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

    #Get the test OAB
    $testOabName = Get-TestOfflineAddressBook -ShellCredentials $Global:ShellCredentials

    Describe "Test Creating a DB and Setting Properties with xExchMailboxDatabase" {
        #First create and set properties on a test database
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
            OfflineAddressBook = $testOabName
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
            OfflineAddressBook = "\$testOabName"
            RetainDeletedItemsUntilBackup = $false
            IssueWarningQuota = "27 MB"
            ProhibitSendQuota = "1GB"
            ProhibitSendReceiveQuota = "1.5 GB"
            RecoverableItemsQuota = "uNlImItEd"
            RecoverableItemsWarningQuota = "1,000,448"
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Create Test Database" -ExpectedGetResults $expectedGetResults        

        #Now change properties on the test database
        $testParams.CalendarLoggingQuota = "30mb"
        $testParams.CircularLoggingEnabled = $false
        $testParams.DeletedItemRetention = "15.00:00:00"
        $testParams.EventHistoryRetentionPeriod = "04:05:06"
        $testParams.IndexEnabled = $false
        $testParams.IsExcludedFromProvisioning = $true
        $testParams.IsSuspendedFromProvisioning = $true
        $testParams.MailboxRetention = "31.00:00:00"
        $testParams.MountAtStartup = $false
        $testParams.RetainDeletedItemsUntilBackup = $true
        $testParams.IssueWarningQuota = "28 MB"
        $testParams.ProhibitSendQuota = "2GB"
        $testParams.ProhibitSendReceiveQuota = "2.5 GB"
        $testParams.RecoverableItemsQuota = "2 GB"
        $testParams.RecoverableItemsWarningQuota = "1.5 GB"

        $expectedGetResults.CalendarLoggingQuota = "30mb"
        $expectedGetResults.CircularLoggingEnabled = $false
        $expectedGetResults.DeletedItemRetention = "15.00:00:00"
        $expectedGetResults.EventHistoryRetentionPeriod = "04:05:06"
        $expectedGetResults.IndexEnabled = $false
        $expectedGetResults.IsExcludedFromProvisioning = $true
        $expectedGetResults.IsSuspendedFromProvisioning = $true
        $expectedGetResults.MailboxRetention = "31.00:00:00"
        $expectedGetResults.MountAtStartup = $false
        $expectedGetResults.RetainDeletedItemsUntilBackup = $true
        $expectedGetResults.IssueWarningQuota = "28 MB"
        $expectedGetResults.ProhibitSendQuota = "2GB"
        $expectedGetResults.ProhibitSendReceiveQuota = "2.5 GB"
        $expectedGetResults.RecoverableItemsQuota = "2 GB"
        $expectedGetResults.RecoverableItemsWarningQuota = "1.5 GB"

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $testParams.Add("IsExcludedFromProvisioningReason", "Testing Excluding the Database")
            $expectedGetResults.Add("IsExcludedFromProvisioningReason", "Testing Excluding the Database")
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change many DB properties" -ExpectedGetResults $expectedGetResults

        #Test setting database quotas to unlimited, when they aren't already unlimited.
        #To reproduce the issue in (https://github.com/PowerShell/xExchange/issues/193), you must run
        #Test-TargetResource with an Unlimited parameter when the current value is not Unlimited.
        #If the current value is already Unlimited, the Test will succeed.
        Context "Test Unlimited Bug" {
            $caughtException = $false

            #First set a quota to a non-Unlimited value
            $testParams.ProhibitSendReceiveQuota = "10GB"
            Set-TargetResource @testParams 

            #Now test for the value and look to see if it's Unlimited
            $testParams.ProhibitSendReceiveQuota = "Unlimited"

            try
            {
                Test-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It "Should not hit exception trying to test for Unlimited" {
                $caughtException | Should Be $false
            }
        }

        #Set all quotas to unlimited
        $testParams.IssueWarningQuota = "unlimited"
        $testParams.ProhibitSendQuota = "Unlimited"
        $testParams.ProhibitSendReceiveQuota = "unlimited"
        $testParams.RecoverableItemsQuota = "unlimited"
        $testParams.RecoverableItemsWarningQuota = "unlimited"

        $expectedGetResults.IssueWarningQuota = "unlimited"
        $expectedGetResults.ProhibitSendQuota = "Unlimited"
        $expectedGetResults.ProhibitSendReceiveQuota = "unlimited"
        $expectedGetResults.RecoverableItemsQuota = "unlimited"
        $expectedGetResults.RecoverableItemsWarningQuota = "unlimited"

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set remaining quotas to Unlimited" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
