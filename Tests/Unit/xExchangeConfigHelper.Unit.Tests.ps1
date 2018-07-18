[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Examples' -ChildPath (Join-Path -Path 'HelperScripts' -ChildPath 'ExchangeConfigHelper.psm1'))) -Force

#Performs common tests against the specified MailboxDatabases.csv file
function Test-MailboxDatabasesCsv
{
    [CmdletBinding()]
    param([System.String]$MailboxDatabasesCsvPath, [System.String]$ServerNameInCsv, [Hashtable]$DbNameReplacements, [System.String]$ContextLabel)

    Context $ContextLabel {

        $dbList = $null
        $dbList = DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $MailboxDatabasesCsvPath `
                                                -ServerNameInCsv $ServerNameInCsv `
                                                -DbNameReplacements $DbNameReplacements

        It 'DB List Should Not Be Null' {
            ($null -ne $dbList) | Should Be $true
        }

        if ($null -ne $dbList)
        {
            It 'DB List Should Contain Ten Members' {
                ($dbList.Count -eq 10) | Should Be $true
            }

            It 'DBFilePath Should Not Be Null Or Empty' {
                ([System.String]::IsNullOrEmpty($dbList[0].DBFilePath)) | Should Be $false
            }
        }
    }
}

[System.String]$mailboxDatabasesCsv66 = Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'Data' -ChildPath 'MailboxDatabasesV6.6.csv'))
[System.String]$mailboxDatabasesCsv = Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'Data' -ChildPath 'MailboxDatabases.csv'))
[System.String]$serverNameInCsv = 'SRV-nn-01'
[System.Collections.Hashtable]$dbNameReplacements = @{'-nn-' = '-01-'}

Describe 'Test DBListFromMailboxDatabasesCsv' {
    Test-MailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesCsv66 `
                             -ServerNameInCsv $serverNameInCsv `
                             -DbNameReplacements $dbNameReplacements `
                             -ContextLabel 'Test MailboxDatabases.csv v6.6'
    
    Test-MailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesCsv `
                             -ServerNameInCsv $serverNameInCsv `
                             -DbNameReplacements $dbNameReplacements `
                             -ContextLabel 'Test MailboxDatabases.csv Current'
}
