[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

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
