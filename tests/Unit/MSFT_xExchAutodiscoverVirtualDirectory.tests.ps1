#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchAutodiscoverVirtualDirectory'

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
        Mock -CommandName Write-FunctionEntry -Verifiable

        $commonTargetResourceParams = @{
            Identity   = 'AutodiscoverVirtualDirectory'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        $commonAutodiscoverVirtualDirectoryInternalStandardOutput = @{
            BasicAuthentication             = [System.Boolean] $false
            DigestAuthentication            = [System.Boolean] $false
            ExtendedProtectionFlags         = [System.String[]] @()
            ExtendedProtectionSPNList       = [System.String[]] @()
            ExtendedProtectionTokenChecking = [System.String] ''
            OAuthAuthentication             = [System.Boolean] $false
            WindowsAuthentication           = [System.Boolean] $false
            WSSecurityAuthentication        = [System.Boolean] $false
        }

        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-AutodiscoverVirtualDirectoryInternal -Verifiable -MockWith { return $commonAutodiscoverVirtualDirectoryInternalStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }

        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-TargetResource is called' {
                function Set-AutodiscoverVirtualDirectory { }

                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                It 'Should warn about restarting the MSExchangeAutodiscoverAppPool' {
                    Mock -CommandName Set-AutodiscoverVirtualDirectory -Verifiable
                    Mock -CommandName Write-Warning -ParameterFilter {$Message -eq 'The configuration will not take effect until MSExchangeAutodiscoverAppPool is manually recycled.'}

                    Set-TargetResource @commonTargetResourceParams
                }

                It 'Should call expected functions' {
                    $commonTargetResourceParams.AllowServiceRestart = $true
                    Mock -CommandName Set-AutodiscoverVirtualDirectory -Verifiable
                    Mock -CommandName Restart-ExistingAppPool -Verifiable

                    Set-TargetResource @commonTargetResourceParams
                    $commonTargetResourceParams.Remove('AllowServiceRestart')
                }

                It 'Should throw error about SPN' {
                    Mock -CommandName Test-ExtendedProtectionSPNList -Verifiable -MockWith { return $false }

                    { Set-TargetResource @commonTargetResourceParams } | Should -Throw -ExpectedMessage 'SPN list contains DotlessSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
                }
            }
        }

        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                It 'Should return False when Get-AutodiscoverVirtualDirectoryInternal returns null' {
                    Mock -CommandName Get-AutodiscoverVirtualDirectoryInternal -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }

                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-AutodiscoverVirtualDirectoryInternal -Verifiable -MockWith { return $commonAutodiscoverVirtualDirectoryInternalStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-AutodiscoverVirtualDirectoryInternal -Verifiable -MockWith { return $commonAutodiscoverVirtualDirectoryInternalStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }
        }

        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Get-AutodiscoverVirtualDirectoryInternal' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-AutodiscoverVirtualDirectoryInternal is called' {
                It 'Should call the expected functions' {
                    function Get-AutodiscoverVirtualDirectory { }
                    Mock -CommandName Get-AutodiscoverVirtualDirectory -Verifiable -MockWith { return $commonAutodiscoverVirtualDirectoryInternalStandardOutput }

                    Get-AutodiscoverVirtualDirectoryInternal @commonTargetResourceParams
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
