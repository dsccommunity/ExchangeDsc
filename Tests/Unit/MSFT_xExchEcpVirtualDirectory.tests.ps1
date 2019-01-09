#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchEcpVirtualDirectory'

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
        Describe 'MSFT_xExchEcpVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'EcpVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getEcpVirtualDirectoryStandardOutput = @{
                AdminEnabled                  = [System.Boolean] $false
                AdfsAuthentication            = [System.Boolean] $false
                BasicAuthentication           = [System.Boolean] $false
                DigestAuthentication          = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                ExternalAuthenticationMethods = [System.String[]] @()
                ExternalUrl                   = [System.String] ''
                FormsAuthentication           = [System.Boolean] $false
                GzipLevel                     = [System.String] ''
                InternalUrl                   = [System.String] ''
                WindowsAuthentication         = [System.Boolean] $false
                OwaOptionsEnabled               = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable -MockWith { return $getEcpVirtualDirectoryStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }

        Describe 'MSFT_xExchEcpVirtualDirectory\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Identity   = 'EcpVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $setEcpVirtualDirectoryStandardOutput = @{
                AdminEnabled                  = [System.Boolean] $false
                AdfsAuthentication            = [System.Boolean] $false
                BasicAuthentication           = [System.Boolean] $false
                DigestAuthentication          = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                ExternalAuthenticationMethods = [System.String[]] @()
                ExternalUrl                   = [System.String] ''
                FormsAuthentication           = [System.Boolean] $false
                GzipLevel                     = [System.String] ''
                InternalUrl                   = [System.String] ''
                WindowsAuthentication         = [System.Boolean] $false
                OwaOptionsEnabled               = [System.Boolean] $false
            }

            Context 'When Set-TargetResource is called' {
                It 'Should warn about restarting the MSExchangeECPAppPool' {
                    function Set-ECPVirtualDirectory {
                    }
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Set-ECPVirtualDirectory -Verifiable
                    Mock -CommandName Write-Warning -ParameterFilter {$message -eq 'The configuration will not take effect until MSExchangeECPAppPool is manually recycled.'}
                    Set-TargetResource @setTargetResourceParams
                }

                It 'Should call expected functions' {
                    function Set-ECPVirtualDirectory {
                    }
                    $setTargetResourceParams.AllowServiceRestart = $true
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Set-ECPVirtualDirectory -Verifiable
                    Mock -CommandName Restart-ExistingAppPool -Verifiable
                    Set-TargetResource @setTargetResourceParams
                    $setTargetResourceParams.Remove('AllowServiceReset')
                }

                It 'Should throw error about SPN' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Test-ExtendedProtectionSPNList -Verifiable -MockWith { return $false }

                    Set-TargetResource @setTargetResourceParams | Should -Throw -ExpectedMessage 'SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
                }
            }
        }

        Describe 'MSFT_xExchEcpVirtualDirectory\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }


            function Set-ECPVirtualDirectory {
            }

            $TestTargetResourceParams = @{
                Identity   = 'EcpVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getEcpVirtualDirectoryStandardOutput = @{
                AdminEnabled                  = [System.Boolean] $false
                AdfsAuthentication            = [System.Boolean] $false
                BasicAuthentication           = [System.Boolean] $false
                DigestAuthentication          = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                ExternalAuthenticationMethods = [System.String[]] @()
                ExternalUrl                   = [System.String] ''
                FormsAuthentication           = [System.Boolean] $false
                GzipLevel                     = [System.String] ''
                InternalUrl                   = [System.String] ''
                WindowsAuthentication         = [System.Boolean] $false
                OwaOptionsEnabled               = [System.Boolean] $false
            }

            Context 'When Test-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                It 'Should return False when Get-ECPVirtualDirectory returns False' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal  -Verifiable

                    Test-TargetResource @TestTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }
                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal  -Verifiable -MockWith { return $getEcpVirtualDirectoryStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @TestTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable -MockWith { return $getEcpVirtualDirectoryStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @TestTargetResourceParams | Should -Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
