$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchMailboxDatabaseCopy'
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
        $commonResourceParameters = @{
            Identity                        = 'MailboxDatabaseCopy'
            Credential                      = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            MailboxServer                   = 'Server'
            AdServerSettingsPreferredServer = 'SomeDC'
            AllowServiceRestart             = $false
        }


        Describe 'MSFT_xExchMailboxDatabaseCopy\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Set-ADServerSettings
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $getMailboxDatabaseStandardOutput = @{
                DatabaseCopies       = @(
                    @{
                        HostServerName = $commonResourceParameters.MailboxServer
                    }
                )
                ActivationPreference = @(
                    @{
                        Key   = @{
                            Name = $commonResourceParameters.MailboxServer
                        }
                        Value = 1
                    }
                )
                ReplayLagTimes       = @(
                    @{
                        Key   = @{
                            Name = $commonResourceParameters.MailboxServer
                        }
                        Value = 'ReplayLagTimes'
                    }
                )
                TruncationLagTimes   = @(
                    @{
                        Key   = @{
                            Name = $commonResourceParameters.MailboxServer
                        }
                        Value = 'TruncationLagTimes'
                    }
                )
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-MailboxDatabaseInternal -Verifiable -MockWith { return $getMailboxDatabaseStandardOutput }
                Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return '2019' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonResourceParameters
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Remove-NotApplicableParamsForVersion -Verifiable

            Context 'When Database Copy does not exist' {
                It 'Should be added' {
                    Mock -CommandName Get-TargetResource -Verifiable
                    Mock -CommandName Add-MailboxDatabaseCopyInternal -Verifiable

                    Set-TargetResource @commonResourceParameters
                }
            }

            Context 'When Database Copy does exist' {
                It 'Should set properties on the database copy' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Set-MailboxDatabaseCopyInternal -Verifiable

                    Set-TargetResource @commonResourceParameters
                }
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Remove-NotApplicableParamsForVersion -Verifiable

            Context 'When Database Copy does not exist' {
                It 'Should return false' {
                    Mock -CommandName Get-TargetResource -Verifiable

                    Test-TargetResource @commonResourceParameters | Should -Be $false
                }
            }

            Context 'When Database Copy does exist and Test-ExchangeSetting returns true' {
                It 'Should return true' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonResourceParameters | Should -Be $true
                }
            }

            Context 'When Database Copy does exist but Test-ExchangeSetting returns false' {
                It 'Should return false' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonResourceParameters | Should -Be $false
                }
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Get-MailboxDatabaseInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Get-MailboxDatabase
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When function is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable
                    Mock -CommandName Get-MailboxDatabase -Verifiable

                    Get-MailboxDatabaseInternal @commonResourceParameters
                }
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Get-MailboxDatabaseCopyCount' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-MailboxDatabaseInternal returns a database object' {
                It 'Should return the database count' {
                    Mock -CommandName Get-MailboxDatabaseInternal -Verifiable -MockWith {
                        return @{
                            DatabaseCopies = @{
                                Count = 2
                            }
                        }
                    }

                    Get-MailboxDatabaseCopyCount @commonResourceParameters | Should -Be 2
                }
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Add-MailboxDatabaseCopyInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Add-MailboxDatabaseCopy
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-Verbose -Verifiable
            Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable
            Mock -CommandName Get-PreviousError -Verifiable
            Mock -CommandName Add-MailboxDatabaseCopy -Verifiable
            Mock -CommandName Assert-NoNewError -Verifiable
            Mock -CommandName Add-ToPSBoundParametersFromHashtable -Verifiable

            Context 'When function is called and AllowServiceRestart is false' {
                It 'Should call expected functions and write a warning' {
                    Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter { $Message -like 'The configuration will not take effect until MSExchangeIS is manually restarted.' }

                    Add-MailboxDatabaseCopyInternal @commonResourceParameters
                }
            }

            Context 'When function is called and AllowServiceRestart is true' {
                It 'Should call expected functions and restart the Information Store' {
                    Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Restart-Service -Verifiable

                    $commonResourceParameters['AllowServiceRestart'] = $true

                    Add-MailboxDatabaseCopyInternal @commonResourceParameters

                    $commonResourceParameters['AllowServiceRestart'] = $false
                }
            }

            Context 'When function is called, PSBoundParameters contains SeedingPostponed, and SeedingPostponed is false' {
                It 'Should remove the SeedingPostponed parameter' {
                    Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter { $Message -like 'The configuration will not take effect until MSExchangeIS is manually restarted.' }

                    $commonResourceParameters['SeedingPostponed'] = $false

                    Add-MailboxDatabaseCopyInternal @commonResourceParameters

                    $commonResourceParameters.Remove('SeedingPostponed')
                }
            }

            Context 'When database creation is attempted but we cannot find the new database' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
                    Mock -CommandName Get-TargetResource -Verifiable

                    { Add-MailboxDatabaseCopyInternal @commonResourceParameters } | Should -Throw -ExpectedMessage 'Failed to find database copy after running Add-MailboxDatabaseCopy'
                }
            }

            Context 'When ActivationPreference is higher than the future copy count' {
                It 'Should skip setting ActivationPreference' {
                    Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter { $Message -like '*Skipping setting ActivationPreference at this point*' }
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'SomeCopy' }
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter { $Message -like 'The configuration will not take effect until MSExchangeIS is manually restarted.' }

                    $commonResourceParameters['ActivationPreference'] = 3

                    Add-MailboxDatabaseCopyInternal @commonResourceParameters
                }
            }
        }

        Describe 'MSFT_xExchMailboxDatabaseCopy\Set-MailboxDatabaseCopyInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Set-MailboxDatabaseCopy
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Get-MailboxDatabaseCopyCount -Verifiable -MockWith { return 1 }
            Mock -CommandName Add-ToPSBoundParametersFromHashtable -Verifiable
            Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable
            Mock -CommandName Write-Warning -Verifiable

            Context 'When function is called' {
                It 'Should call expected functions' {
                    Set-MailboxDatabaseCopyInternal @commonResourceParameters
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
