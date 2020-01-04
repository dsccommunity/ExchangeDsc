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

        Mock -CommandName Write-FunctionEntry -Verifiable

        $commonTargetResourceParams = @{
            Server              = 'Server'
            Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            AllowServiceRestart = $true
        }

        $commonImapSettingsStandardOutput = @{
            ExternalConnectionSettings        = [System.String[]] @()
            LoginType                         = [System.String] ''
            X509CertificateName               = [System.String] ''
            AuthenticatedConnectionTimeout    = [System.String] ''
            Banner                            = [System.String] ''
            CalendarItemRetrievalOption       = [System.String] ''
            EnableExactRFC822Size             = [System.Boolean] $false
            EnableGSSAPIAndNTLMAuth           = [System.Boolean] $false
            EnforceCertificateErrors          = [System.Boolean] $false
            ExtendedProtectionPolicy          = [System.String] ''
            InternalConnectionSettings        = [System.String[]] @()
            LogFileLocation                   = [System.String] ''
            LogFileRollOverSettings           = [System.String] ''
            LogPerFileSizeQuota               = [System.String] ''
            MaxCommandSize                    = [System.Int32] 1
            MaxConnectionFromSingleIP         = [System.Int32] 1
            MaxConnections                    = [System.Int32] 1
            MaxConnectionsPerUser             = [System.Int32] 1
            MessageRetrievalMimeFormat        = [System.String] ''
            OwaServerUrl                      = [System.String] ''
            PreAuthenticatedConnectionTimeout = [System.String] ''
            ProtocolLogEnabled                = [System.Boolean] $false
            ProxyTargetPort                   = [System.Int32] 1
            ShowHiddenFoldersEnabled          = [System.Boolean] $false
            SSLBindings                       = [System.String[]] @()
            SuppressReadReceipt               = [System.Boolean] $false
            UnencryptedOrTLSBindings          = [System.String[]] @()
        }

        Describe 'MSFT_xExchImapSettings\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {

                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-ImapSettingsInternal -Verifiable -MockWith { return $commonImapSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }

        Describe 'MSFT_xExchImapSettings\Set-TargetResource' -Tag 'Set' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            function Set-ImapSettings {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-TargetResource is called' {
                It 'Should call expected functions when AllowServiceRestart is true' {
                    Mock -CommandName Set-ImapSettings -Verifiable
                    Mock -CommandName Restart-Service -Verifiable

                    Set-TargetResource @commonTargetResourceParams
                }


                It 'Should warn that a MSExchangeIMAP4 service restart is required' {
                    $AllowServiceRestart = $commonTargetResourceParams.AllowServiceRestart
                    $commonTargetResourceParams.AllowServiceRestart = $false
                    Mock -CommandName Set-ImapSettings -Verifiable
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter {$Message -eq 'The configuration will not take effect until MSExchangeIMAP4 services are manually restarted.'}

                    Set-TargetResource @commonTargetResourceParams
                    $commonTargetResourceParams.AllowServiceRestart = $AllowServiceRestart
                }
            }
        }

        Describe 'MSFT_xExchImapSettings\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                It 'Should return False when Get-ImapSettingsInternal returns null' {
                    Mock -CommandName Get-ImapSettingsInternal -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }

                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-ImapSettingsInternal -Verifiable -MockWith { return $commonImapSettingsStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-ImapSettingsInternal -Verifiable -MockWith { return $commonImapSettingsStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }
        }

        Describe 'MSFT_xExchImapSettings\Get-ImapSettingsInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Get-ImapSettings { }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ImapSettingsInternal is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Get-ImapSettings -Verifiable -MockWith { return $commonImapSettingsStandardOutput }

                    Get-ImapSettingsInternal @commonTargetResourceParams
                }
            }
        }

        Describe 'MSFT_xExchImapSettings\Get-ImapSettingsInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Get-ImapSettings { }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ImapSettingsInternal is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Get-ImapSettings -Verifiable -MockWith { return $commonImapSettingsStandardOutput }

                    Get-ImapSettingsInternal @commonTargetResourceParams
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
