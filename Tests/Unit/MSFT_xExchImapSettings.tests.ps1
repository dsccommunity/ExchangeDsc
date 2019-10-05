#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchImapSettings'

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
        function Get-ImapSettings
        {
            param(
                $Server,
                $Credential
            )
        }
        function Set-ImapSettings
        {
            param (
                $Server,
                $AuthenticatedConnectionTimeout,
                $ExternalConnectionSettings,
                $InternalConnectionSettings
            )
        }
        Describe 'MSFT_xExchImapSettings\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Server     = 'Server'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getImapSettingsStandardOutput = [PSCustomObject] @{
                ExternalConnectionSettings        = [System.String[]] @()
                LoginType                         = [System.String] ''
                X509CertificateName               = [System.String] ''
                AuthenticatedConnectionTimeout    = [System.TimeSpan] '00:01:00'
                PreAuthenticatedConnectionTimeout = [System.TimeSpan] '00:01:00'
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-ImapSettings -Verifiable -MockWith { return $getImapSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
        Describe 'MSFT_xExchImapSettings\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $setTargetResourceParams = @{
                Server                         = 'Server'
                Credential                     = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AuthenticatedConnectionTimeout = '00:30:00'
                ExternalConnectionSettings     = 'externalimap.test.com:993:TLS'
            }

            Context 'When Set-TargetResource is called' {
                It 'Should call all functions' {
                    Mock -CommandName 'Set-ImapSettings' -ParameterFilter { $Server -eq 'Server' -and
                        $AuthenticatedConnectionTimeout -eq [System.TimeSpan] '00:30:00' -and
                        $ExternalConnectionSettings -eq 'externalimap.test.com:993:TLS'
                    } -Verifiable

                    Set-TargetResource @setTargetResourceParams 3>&1 | Should -Be 'The configuration will not take effect until MSExchangeIMAP4 services are manually restarted.'
                }
                It 'Should restart the service' {
                    $setTargetResourceParams['AllowServiceRestart'] = $true

                    Mock -CommandName 'Set-ImapSettings' -ParameterFilter { $Server -eq 'Server' -and
                        $AuthenticatedConnectionTimeout -eq [System.TimeSpan] '00:30:00' -and
                        $ExternalConnectionSettings -eq 'externalimap.test.com:993:TLS'
                    } -Verifiable
                    Mock -CommandName 'Get-Service' -MockWith { return 'MSExchangeIMAP4FakeService' } -Verifiable
                    Mock -CommandName 'Restart-Service' -Verifiable

                    { Set-TargetResource @setTargetResourceParams } | Should -Not -Throw
                }
            }
        }
        Describe 'MSFT_xExchImapSettings\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $testTargetResourceParams = @{
                Server                         = 'Server'
                Credential                     = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AuthenticatedConnectionTimeout = '00:30:00'
                ExternalConnectionSettings     = 'externalimap.test.com:993:TLS', 'externalimap.test.com:994:TLS'
                EnableGSSAPIAndNTLMAuth        = $false
            }

            $getTargetResourceOutput = @{
                Server                         = 'Server'
                AuthenticatedConnectionTimeout = [System.TimeSpan]'00:30:00'
                ExternalConnectionSettings     = [System.String[]] @('externalimap.test.com:993:TLS', 'externalimap.test.com:994:TLS')
                EnableGSSAPIAndNTLMAuth        = $false
            }

            Context 'When Test-TargetResource is called' {
                It 'Should return $true when all properties match' {
                    Mock -CommandName 'Get-ImapSettings' -MockWith { return [PSCustomObject] $getTargetResourceOutput } -Verifiable

                    Test-TargetResource @testTargetResourceParams | Should -Be $true
                }
                It 'Should return $false when not all properties match' {
                    $getTargetResourceOutputWrong = @{ } + $getTargetResourceOutput
                    $getTargetResourceOutputWrong['ExternalConnectionSettings'] = [System.String[]] @('externalimap.test.com:993:TLS', 'externalimap.test.com:995:TLS')

                    Mock -CommandName 'Get-ImapSettings' -MockWith { return [PSCustomObject] $getTargetResourceOutputWrong } -Verifiable

                    Test-TargetResource @testTargetResourceParams | Should -Be $false
                }
                It 'Should return $false when IMAP settings could not be determined' {
                    Mock -CommandName 'Get-ImapSettings' -MockWith { return $null } -Verifiable

                    Test-TargetResource @testTargetResourceParams 2>&1| Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
