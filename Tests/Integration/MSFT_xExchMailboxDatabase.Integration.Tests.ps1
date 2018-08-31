<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchMailboxDatabase DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchMailboxDatabase'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean]$exchangeInstalled = Get-IsSetupComplete

#endregion HEADER

<#
    .SYNOPSIS
        Removes the specified Mailbox Database and associated files

    .PARAMETER Database
        The name of the Mailbox Database to remove.
#>
function Initialize-ExchDscDatabase
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Database
    )

    Write-Verbose -Message 'Cleaning up test database'

    GetRemoteExchangeSession -Credential $shellCredentials -CommandsToLoad '*-MailboxDatabase'
    Get-MailboxDatabase | Where-Object -FilterScript {
        $_.Name -like "$($Database)"
    } | Remove-MailboxDatabase -Confirm:$false

    Get-ChildItem -LiteralPath "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($Database)" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

    if ($null -ne (Get-MailboxDatabase | Where-Object {$_.Name -like "$($Database)"}))
    {
        throw 'Failed to cleanup test database'
    }

    Write-Verbose -Message 'Finished cleaning up test database'
}

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    $TestDBName = 'Mailbox Database Test 123'

    Initialize-ExchDscDatabase -Database $TestDBName

    #Get the test OAB
    $testOabName = Get-TestOfflineAddressBook -ShellCredentials $shellCredentials

    Describe 'Test Creating a DB and Setting Properties with xExchMailboxDatabase' {
        #First create and set properties on a test database
        $testParams = @{
            Name = $TestDBName
            Credential = $shellCredentials
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"
            AllowServiceRestart = $true
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = 'unlimited'
            CircularLoggingEnabled = $true
            DatabaseCopyCount = 1
            DeletedItemRetention = '14.00:00:00'
            EventHistoryRetentionPeriod = '03:04:05'
            IndexEnabled = $true
            IsExcludedFromProvisioning = $false
            IsSuspendedFromProvisioning = $false
            MailboxRetention = '30.00:00:00'
            MountAtStartup = $true
            OfflineAddressBook = $testOabName
            RetainDeletedItemsUntilBackup = $false
            IssueWarningQuota = '27 MB'
            ProhibitSendQuota = '1GB'
            ProhibitSendReceiveQuota = '1.5 GB'
            RecoverableItemsQuota = 'uNlImItEd'
            RecoverableItemsWarningQuota = '1,000,448'
        }

        $expectedGetResults = @{
            Name = $TestDBName
            Server = $env:COMPUTERNAME
            EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)\$($TestDBName).edb"
            LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)"
            AutoDagExcludeFromMonitoring = $true
            BackgroundDatabaseMaintenance = $true
            CalendarLoggingQuota = 'unlimited'
            CircularLoggingEnabled = $true
            DatabaseCopyCount = 1
            DeletedItemRetention = '14.00:00:00'
            EventHistoryRetentionPeriod = '03:04:05'
            IndexEnabled = $true
            IsExcludedFromProvisioning = $false
            IsSuspendedFromProvisioning = $false
            MailboxRetention = '30.00:00:00'
            MountAtStartup = $true
            OfflineAddressBook = "\$testOabName"
            RetainDeletedItemsUntilBackup = $false
            IssueWarningQuota = '27 MB (28,311,552 bytes)'
            ProhibitSendQuota = '1 GB (1,073,741,824 bytes)'
            ProhibitSendReceiveQuota = '1.5 GB (1,610,612,736 bytes)'
            RecoverableItemsQuota = 'uNlImItEd'
            RecoverableItemsWarningQuota = '977 KB (1,000,448 bytes)'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Create Test Database' `
                                         -ExpectedGetResults $expectedGetResults

        #Now change properties on the test database
        $testParams.CalendarLoggingQuota = '30mb'
        $testParams.CircularLoggingEnabled = $false
        $testParams.DeletedItemRetention = '15.00:00:00'
        $testParams.EventHistoryRetentionPeriod = '04:05:06'
        $testParams.IndexEnabled = $false
        $testParams.IsExcludedFromProvisioning = $true
        $testParams.IsSuspendedFromProvisioning = $true
        $testParams.MailboxRetention = '31.00:00:00'
        $testParams.MountAtStartup = $false
        $testParams.RetainDeletedItemsUntilBackup = $true
        $testParams.IssueWarningQuota = '28 MB'
        $testParams.ProhibitSendQuota = '2GB'
        $testParams.ProhibitSendReceiveQuota = '2.5 GB'
        $testParams.RecoverableItemsQuota = '2 GB'
        $testParams.RecoverableItemsWarningQuota = '1.5 GB'

        $expectedGetResults.CalendarLoggingQuota = '30 MB (31,457,280 bytes)'
        $expectedGetResults.CircularLoggingEnabled = $false
        $expectedGetResults.DeletedItemRetention = '15.00:00:00'
        $expectedGetResults.EventHistoryRetentionPeriod = '04:05:06'
        $expectedGetResults.IndexEnabled = $false
        $expectedGetResults.IsExcludedFromProvisioning = $true
        $expectedGetResults.IsSuspendedFromProvisioning = $true
        $expectedGetResults.MailboxRetention = '31.00:00:00'
        $expectedGetResults.MountAtStartup = $false
        $expectedGetResults.RetainDeletedItemsUntilBackup = $true
        $expectedGetResults.IssueWarningQuota = '28 MB (29,360,128 bytes)'
        $expectedGetResults.ProhibitSendQuota = '2 GB (2,147,483,648 bytes)'
        $expectedGetResults.ProhibitSendReceiveQuota = '2.5 GB (2,684,354,560 bytes)'
        $expectedGetResults.RecoverableItemsQuota = '2 GB (2,147,483,648 bytes)'
        $expectedGetResults.RecoverableItemsWarningQuota = '1.5 GB (1,610,612,736 bytes)'

        $serverVersion = Get-ExchangeVersion

        if ($serverVersion -in '2016','2019')
        {
            $testParams.Add('IsExcludedFromProvisioningReason', 'Testing Excluding the Database')
            $expectedGetResults.Add('IsExcludedFromProvisioningReason', 'Testing Excluding the Database')
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Change many DB properties' -ExpectedGetResults $expectedGetResults

        <#
            Test setting database quotas to unlimited, when they aren't already unlimited.
            To reproduce the issue in (https://github.com/PowerShell/xExchange/issues/193), you must run
            Test-TargetResource with an Unlimited parameter when the current value is not Unlimited.
            If the current value is already Unlimited, the Test will succeed.
        #>

        Context 'Test Looking For Unlimited Value When Currently Set to Non-Unlimited Value' {
            $caughtException = $false

            #First set a quota to a non-Unlimited value
            $testParams.ProhibitSendReceiveQuota = '10GB'
            Set-TargetResource @testParams

            #Now test for the value and look to see if it's Unlimited
            $testParams.ProhibitSendReceiveQuota = 'Unlimited'

            try
            {
                $testResults = Test-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It 'Should not hit exception trying to test for Unlimited' {
                $caughtException | Should Be $false
            }

            It 'Test results should be false after testing for new quota' {
                $testResults | Should Be $false
            }
        }

        #Test setting database quotas to non-unlimited value, when they are currently set to a different non-unlimited value
        Context 'Test Looking For Non-Unlimited Value When Currently Set to Different Non-Unlimited Value' {
            #First set a quota to a non-Unlimited value
            $testParams.ProhibitSendReceiveQuota = '10GB'
            Set-TargetResource @testParams

            #Now test for the value and look to see if it's a different non-unlimited value
            $testParams.ProhibitSendReceiveQuota = '11GB'

            $testResults = Test-TargetResource @testParams

            It 'Test results should be false after testing for new quota' {
                $testResults | Should Be $false
            }
        }

        Context 'Test Looking For Non-Unlimited Value When Currently Set to Unlimited Value' {
            #First set a quota to an Unlimited value
            $testParams.ProhibitSendReceiveQuota = 'Unlimited'
            Set-TargetResource @testParams

            #Now test for the value and look to see if it's non-Unlimited
            $testParams.ProhibitSendReceiveQuota = '11GB'

            $testResults = Test-TargetResource @testParams

            It 'Test results should be false after testing for new quota' {
                $testResults | Should Be $false
            }
        }

        Context 'Test Looking For Same Value In A Different Size Format' {
            #First set a quota to a non-Unlimited value in megabytes
            $testParams.ProhibitSendReceiveQuota = '10240MB'
            Set-TargetResource @testParams

            #Now test for the value and look to see if it's the same value, but in gigabytes
            $testParams.ProhibitSendReceiveQuota = '10GB'

            $testResults = Test-TargetResource @testParams

            It 'Test results should be true after testing for new quota' {
                $testResults | Should Be $true
            }
        }

        #Set all quotas to unlimited
        $testParams.IssueWarningQuota = 'unlimited'
        $testParams.ProhibitSendQuota = 'Unlimited'
        $testParams.ProhibitSendReceiveQuota = 'unlimited'
        $testParams.RecoverableItemsQuota = 'unlimited'
        $testParams.RecoverableItemsWarningQuota = 'unlimited'

        $expectedGetResults.IssueWarningQuota = 'unlimited'
        $expectedGetResults.ProhibitSendQuota = 'Unlimited'
        $expectedGetResults.ProhibitSendReceiveQuota = 'unlimited'
        $expectedGetResults.RecoverableItemsQuota = 'unlimited'
        $expectedGetResults.RecoverableItemsWarningQuota = 'unlimited'

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set remaining quotas to Unlimited' `
                                         -ExpectedGetResults $expectedGetResults
    }

    # Clean up the test database
    Initialize-ExchDscDatabase -Database $TestDBName
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
