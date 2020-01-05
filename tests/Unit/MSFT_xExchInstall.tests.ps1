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

        $targetResourceParams = @{
            Path       = 'E:\Setup.exe'
            Arguments  = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        Describe 'MSFT_xExchInstall\Get-TargetResource' -Tag 'Get' {
            Context 'When Get-TargetResource is called' {
                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $targetResourceParams

                It 'Should return the input Path and Arguments' {

                    $getResults = Get-TargetResource @targetResourceParams

                    $getResults.Path | Should -Be $targetResourceParams.Path
                    $getResults.Arguments | Should -Be $targetResourceParams.Arguments
                }
            }
        }

        Describe 'MSFT_xExchInstall\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When ShouldStartInstall is true, and Set-WSManConfigStatus requires a reboot' {
                It 'Should force a reboot' {
                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            ShouldStartInstall = $true
                        }
                    }
                    Mock -CommandName Set-WSManConfigStatus -Verifiable -MockWith { return $true }
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter { $Message -like 'Server needs a reboot before the installation of Exchange can begin.' }

                    Set-TargetResource @targetResourceParams
                }
            }

            Context 'When ShouldStartInstall is true, and Set-WSManConfigStatus does not require a reboot' {
                It 'Should start the install, wait for it to complete, then detect setup is successful' {
                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            ShouldStartInstall = $true
                        }
                    }
                    Mock -CommandName Set-WSManConfigStatus -Verifiable -MockWith { return $false }
                    Mock -CommandName Start-ExchangeScheduledTask -Verifiable
                    Mock -CommandName Wait-ForProcessStart -Verifiable -MockWith { return $true }
                    Mock -CommandName Wait-ForProcessStop -Verifiable
                    Mock -CommandName Assert-ExchangeSetupArgumentsComplete -Verifiable

                    Set-TargetResource @targetResourceParams
                }
            }

            Context 'When it tries to start install, but does not detect the setup process' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            ShouldStartInstall = $true
                        }
                    }
                    Mock -CommandName Set-WSManConfigStatus -Verifiable -MockWith { return $false }
                    Mock -CommandName Start-ExchangeScheduledTask -Verifiable
                    Mock -CommandName Wait-ForProcessStart -Verifiable -MockWith { return $false }

                    { Set-TargetResource @targetResourceParams } | Should -Throw -ExpectedMessage 'Waited 60 seconds, but was unable to detect that ExSetup.exe was started'
                }
            }

            Context 'When setup is already running' {
                It 'Should wait for the install, then detect setup is successful' {
                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            ShouldStartInstall = $false
                            SetupRunning       = $true
                        }
                    }
                    Mock -CommandName Wait-ForProcessStop -Verifiable
                    Mock -CommandName Assert-ExchangeSetupArgumentsComplete -Verifiable

                    Set-TargetResource @targetResourceParams
                }
            }

            Context 'When setup is complete' {
                It 'Should do nothing' {
                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            ShouldStartInstall = $false
                            SetupComplete      = $true
                        }
                    }
                    Mock -CommandName Wait-ForProcessStop
                    Mock -CommandName Assert-ExchangeSetupArgumentsComplete

                    Set-TargetResource @targetResourceParams

                    Assert-MockCalled -CommandName Assert-ExchangeSetupArgumentsComplete -Times 0
                }
            }
        }

        Describe 'MSFT_xExchInstall\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-MockCalled -CommandName Get-ExchangeInstallStatus -Exactly -Times 1 -Scope It
            }

            Context 'When Exchange is not present on the system' {
                It 'Should return $false' {
                    Mock -CommandName Get-ExchangeInstallStatus -MockWith {
                        return @{
                            ShouldInstallLanguagePack = $false
                            SetupRunning              = $false
                            SetupComplete             = $false
                            ExchangePresent           = $false
                            ShouldStartInstall        = $true
                        }
                    }

                    Test-TargetResource @targetResourceParams | Should -Be $false
                }
            }

            Context 'When Exchange Setup has fully completed' {
                It 'Should return $true' {
                    Mock -CommandName Get-ExchangeInstallStatus -MockWith {
                        return @{
                            ShouldInstallLanguagePack = $false
                            SetupRunning              = $false
                            SetupComplete             = $true
                            ExchangePresent           = $true
                            ShouldStartInstall        = $false
                        }
                    }

                    Test-TargetResource @targetResourceParams | Should -Be $true
                }
            }

            Context 'When Exchange Setup has partially completed' {
                It 'Should return $false' {
                    Mock -CommandName Get-ExchangeInstallStatus -MockWith {
                        return @{
                            ShouldInstallLanguagePack = $false
                            SetupRunning              = $false
                            SetupComplete             = $false
                            ExchangePresent           = $true
                            ShouldStartInstall        = $true
                        }
                    }

                    Test-TargetResource @targetResourceParams | Should -Be $false
                }
            }

            Context 'When Exchange Setup is currently running' {
                It 'Should return $false' {
                    Mock -CommandName Get-ExchangeInstallStatus -MockWith {
                        return @{
                            ShouldInstallLanguagePack = $false
                            SetupRunning              = $true
                            SetupComplete             = $false
                            ExchangePresent           = $true
                            ShouldStartInstall        = $false
                        }
                    }

                    Test-TargetResource @targetResourceParams | Should -Be $false
                }
            }

            Context 'When a Language Pack install is requested, and the Language Pack has not been installed' {
                It 'Should return $false' {
                    Mock -CommandName Get-ExchangeInstallStatus -MockWith {
                        return @{
                            ShouldInstallLanguagePack = $true
                            SetupRunning              = $false
                            SetupComplete             = $true
                            ExchangePresent           = $true
                            ShouldStartInstall        = $true
                        }
                    }

                    Test-TargetResource @targetResourceParams | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
