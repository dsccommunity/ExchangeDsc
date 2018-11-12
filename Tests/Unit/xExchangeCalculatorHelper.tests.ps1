#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCHelperName = "xExchangeCalculatorHelper"

# Unit Test Template Version: 1.2.2
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeCalculatorHelper.psm1')) -Force

#endregion HEADER

function Invoke-TestSetup
{

}

function Invoke-TestCleanup
{

}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:DSCHelperName {
        $validServerName = 'srv-nn-01'
        $invalidServerName = 'srv-nn-05'

        Describe 'xExchangeCalculatorHelper\Get-DBMapFromServersCsv' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $servers76CsvPath = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Tests\Data\ServersV7.6.csv')
            $serversLatestCsvPath = $servers76CsvPath

            $differentVersionValidCsvPaths = @(
                @{
                    ServersCsvPath = $servers76CsvPath
                }
            )

            Context 'When a valid Servers.csv is discovered, and data for the server is found' {
                It 'Should return a valid DiskToDBMap array' -TestCases $differentVersionValidCsvPaths {
                    param
                    (
                        [System.String]
                        $ServersCsvPath
                    )

                    Mock -CommandName Update-StringContent -Verifiable -MockWith { return $StringIn }

                    $dbMap = Get-DBMapFromServersCsv -ServersCsvPath $ServersCsvPath -ServerNameInCsv $validServerName

                    $dbMap.Count | Should -Be 10
                }
            }

            Context 'When the specified Servers.csv does not exist' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $false }

                    { Get-DBMapFromServersCsv -ServersCsvPath $serversLatestCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'Unable to access file specified in ServersCsvPath'
                }
            }

            Context 'When the server cannot be found in the CSV file' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $true }
                    Mock -CommandName Import-Csv -Verifiable

                    { Get-DBMapFromServersCsv -ServersCsvPath $serversLatestCsvPath -ServerNameInCsv $invalidServerName } | `
                        Should -Throw -ExpectedMessage 'Failed to find single entry for server in Servers.Csv file'
                }
            }

            Context 'When the server cannot be found in the CSV file' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $true }
                    Mock -CommandName Import-Csv -Verifiable -MockWith {
                        return (New-Object -TypeName PSObject -Property @{
                            ServerName  = 'srv-nn-01'
                            DbPerVolume = 0
                        })
                    }

                    { Get-DBMapFromServersCsv -ServersCsvPath $serversLatestCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'DbPerVolume for server is null or less than 0'
                }
            }

            Context 'When the server cannot be found in the CSV file' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $true }
                    Mock -CommandName Import-Csv -Verifiable -MockWith {
                        return (New-Object -TypeName PSObject -Property @{
                            ServerName  = $validServerName
                            DbPerVolume = 4
                            DbMap       = ''
                        })
                    }

                    { Get-DBMapFromServersCsv -ServersCsvPath $serversLatestCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'No data specified in DbMap for server'
                }
            }
        }

        Describe 'xExchangeCalculatorHelper\Get-DBListFromMailboxDatabasesCsv' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $mailboxDatabases66CsvPath = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Tests\Data\MailboxDatabasesV6.6.csv')
            $mailboxDatabases76CsvPath = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Tests\Data\MailboxDatabasesV7.6.csv')
            $mailboxDatabasesBadCsvPath = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Tests\Data\MailboxDatabasesBad.csv')
            $mailboxDatabasesLatestCsvPath = $mailboxDatabases76CsvPath

            $differentVersionValidCsvPaths = @(
                @{
                    MailboxDatabasesCsvPath = $mailboxDatabases66CsvPath
                },
                @{
                    MailboxDatabasesCsvPath = $mailboxDatabases76CsvPath
                }
            )

            Context 'When a valid MailboxDatabases.csv is discovered, and data for the server is found' {
                It 'Should return a valid database list' -TestCases $differentVersionValidCsvPaths {
                    param
                    (
                        [System.String]
                        $MailboxDatabasesCsvPath
                    )

                    Mock -CommandName Update-StringContent -Verifiable -MockWith { return $StringIn }

                    $dbList = Get-DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $MailboxDatabasesCsvPath -ServerNameInCsv $validServerName

                    $dbList.Count | Should -Be 10

                    foreach ($dbInfo in $dbList)
                    {
                        foreach ($memberName in ($dbInfo | Get-Member -MemberType NoteProperty).Name)
                        {
                            [String]::IsNullOrEmpty($dbInfo.$memberName) | Should -Be $false
                        }
                    }
                }
            }

            Context 'When the specified MailboxDatabases.csv does not exist' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $false }

                    { Get-DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesLatestCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'Unable to access file specified in MailboxDatabasesCsvPath'
                }
            }

            Context 'When the specified MailboxDatabases.csv does not have a DBFilePath or EDBFilePath column' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $true }
                    Mock -CommandName Update-StringContent -Verifiable -MockWith { return $StringIn }

                    { Get-DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $mailboxDatabasesBadCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'Unable to locate column containing database file path'
                }
            }
        }

        Describe 'xExchangeCalculatorHelper\Get-DBListFromMailboxDatabaseCopiesCsv' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $mailboxDatabasesCopies76CsvPath = (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Tests\Data\MailboxDatabaseCopiesV7.6.csv')
            $mailboxDatabasesCopiesLatestCsvPath = $mailboxDatabasesCopies76CsvPath

            $differentVersionValidCsvPaths = @(
                @{
                    MailboxDatabaseCopiesCsvPath = $mailboxDatabasesCopies76CsvPath
                }
            )

            Context 'When a valid MailboxDatabaseCopies.csv is discovered, and data for the server is found' {
                It 'Should return a valid database copy list' -TestCases $differentVersionValidCsvPaths {
                    param
                    (
                        [System.String]
                        $MailboxDatabaseCopiesCsvPath
                    )

                    Mock -CommandName Update-StringContent -Verifiable -MockWith { return $StringIn }

                    $dbList = Get-DBListFromMailboxDatabaseCopiesCsv -MailboxDatabaseCopiesCsvPath $MailboxDatabaseCopiesCsvPath -ServerNameInCsv $validServerName

                    $dbList.Count | Should -Be 30

                    foreach ($dbInfo in $dbList)
                    {
                        foreach ($memberName in ($dbInfo | Get-Member -MemberType NoteProperty).Name)
                        {
                            [String]::IsNullOrEmpty($dbInfo.$memberName) | Should -Be $false
                        }
                    }
                }
            }

            Context 'When the specified MailboxDatabaseCopies.csv does not exist' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith { return $false }

                    { Get-DBListFromMailboxDatabaseCopiesCsv -MailboxDatabaseCopiesCsvPath $mailboxDatabasesCopiesLatestCsvPath -ServerNameInCsv $validServerName } | `
                        Should -Throw -ExpectedMessage 'Unable to access file specified in MailboxDatabaseCopiesCsvPath'
                }
            }
        }

        Describe 'xExchangeCalculatorHelper\Update-StringContent' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $noModificationStrings = @(
                @{StringIn = 'aBc'},
                @{StringIn = ''},
                @{StringIn = 'a b c'}
            )

            Context 'When Replacements is either not specified or is empty' {
                It 'Should return the same string that was input' -TestCases $noModificationStrings {
                    param
                    (
                        [System.String]
                        $StringIn
                    )

                    Update-StringContent -StringIn $StringIn | Should -BeExactly $StringIn
                }
            }

            $replacementCases = @(
                @{
                    StringIn     = 'SRV-nn-01'
                    StringOut    = 'SRV-01-01'
                    Replacements = @{
                        'nn' = '01'
                    }
                },
                @{
                    StringIn     = 'DAG-country-region-number'
                    StringOut    = 'DAG-USA-WEST-01'
                    Replacements = @{
                        'country' = 'USA'
                        'region'  = 'WEST'
                        'number'  = '01'
                    }
                }
            )

            Context 'When Replacements is specified' {
                It 'Should return the string with the requested replacements' -TestCases $replacementCases {
                    param
                    (
                        [System.String]
                        $StringIn,

                        [System.String]
                        $StringOut,

                        [System.Collections.Hashtable]
                        $Replacements
                    )

                    Update-StringContent -StringIn $StringIn -Replacements $Replacements | Should -BeExactly $StringOut
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
