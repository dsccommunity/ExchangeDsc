[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchUMCallRouterSettings'

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

        $commonTargetResourceParams = @{
            Server        = 'UMServer'
            Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            UMStartupMode = 'TLS'
        }

        $commonUMCallRouterSettingsStandardOutput = @{
            Server                      = [System.String] $Server
            UMStartupMode               = [System.String] $getTargetResourceParams.UMStartupMode
            DialPlans                   = [System.String[]] @()
            IPAddressFamily             = [System.String] 'Any'
            IPAddressFamilyConfigurable = [System.Boolean] $false
            MaxCallsAllowed             = [System.Int32] '100'
            SipTcpListeningPort         = [System.Int32] '5060'
            SipTlsListeningPort         = [System.Int32] '5061'
        }

        Describe 'MSFT_xExchUMCallRouterSettings\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-UMCallRouterSettings {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-UMCallRouterSettings -Verifiable -MockWith { return $commonUMCallRouterSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }

        Describe 'MSFT_xExchUMCallRouterSettings\Set-TargetResource' -Tag 'Set' {
            # Override Exchange cmdlets
            function Set-UMCallRouterSettings {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-TargetResource is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Set-UMCallRouterSettings -Verifiable

                    Set-TargetResource @commonTargetResourceParams
                }
            }
        }

        Describe 'MSFT_xExchUMCallRouterSettings\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            function Get-UMCallRouterSettings {}
            function Test-ExchangeSetting{}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                It 'Should return False when Get-UMCallRouterSettings returns null' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Get-UMCallRouterSettings -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }

                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Get-UMCallRouterSettings -Verifiable -MockWith { return $commonUMCallRouterSettingsStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Get-UMCallRouterSettings -Verifiable -MockWith { return $commonUMCallRouterSettingsStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
