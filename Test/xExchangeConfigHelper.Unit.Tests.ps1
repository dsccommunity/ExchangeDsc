Import-Module $PSScriptRoot\..\Examples\HelperScripts\ExchangeConfigHelper.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Performs common tests against the specified MailboxDatabases.csv file
function Test-MailboxDatabasesCsv
{
    [CmdletBinding()]
    param([string]$MailboxDatabasesCsvPath, [string]$ServerNameInCsv, [Hashtable]$DbNameReplacements, [string]$ContextLabel)

    Context $ContextLabel {

        $dbList = $null
        $dbList = DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $MailboxDatabasesCsvPath -ServerNameInCsv $ServerNameInCsv -DbNameReplacements $DbNameReplacements

        It "DB List Should Not Be Null" {
            ($null -ne $dbList) | Should Be $true
        }

        if ($null -ne $dbList)
        {
            It "DB List Should Contain Ten Members" {
                ($dbList.Count -eq 10) | Should Be $true
            }

            It "DBFilePath Should Not Be Null Or Empty" {
                ([string]::IsNullOrEmpty($dbList[0].DBFilePath)) | Should Be $false
            }
        }
    }
}

[string]$mailboxDatabasesCsv66 = "$($PSScriptRoot)\Data\MailboxDatabases v6.6.csv"
[string]$mailboxDatabasesCsv = "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.FullName)\Examples\ConfigureDatabases-FromCalculator\CalculatorAndScripts\MailboxDatabases.csv"
[string]$serverNameInCsv = 'SRV-nn-01'
[Hashtable]$dbNameReplacements = @{"-nn-" = "-01-"}

Describe "Test DBListFromMailboxDatabasesCsv" {
    Test-MailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesCsv66 -ServerNameInCsv $serverNameInCsv -DbNameReplacements $dbNameReplacements -ContextLabel 'Test MailboxDatabases.csv v6.6'
    Test-MailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesCsv -ServerNameInCsv $serverNameInCsv -DbNameReplacements $dbNameReplacements -ContextLabel 'Test MailboxDatabases.csv Current'
}
    
