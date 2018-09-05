#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = "MSFT_xExchInstall"

# Unit Test Template Version: 1.2.2
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/PowerShell/DscResource.Tests.git',(Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force

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

        $targetResourceParams = @{
            Path       = 'E:\Setup.exe'
            Arguments  = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist "fakeuser",(New-Object -TypeName System.Security.SecureString)
        }

        Describe 'MSFT_xExchInstall\Get-TargetResource' -Tag 'Get' {
            Context 'When Get-TargetResource is called' {
                It 'Should return the input Path and Arguments' {

                    $getResults = Get-TargetResource @targetResourceParams

                    $getResults.Path | Should -Be $targetResourceParams.Path
                    $getResults.Arguments | Should -Be $targetResourceParams.Arguments
                }
            }
        }

        Describe 'MSFT_xExchInstall\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-MockCalled -CommandName Get-InstallStatus -Exactly -Times 1 -Scope It
            }

            Context 'When Exchange is not present on the system' {
                It 'Should return $false' {
                    Mock -CommandName Get-InstallStatus -MockWith {
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
                    Mock -CommandName Get-InstallStatus -MockWith {
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
                    Mock -CommandName Get-InstallStatus -MockWith {
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
                    Mock -CommandName Get-InstallStatus -MockWith {
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
                    Mock -CommandName Get-InstallStatus -MockWith {
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
