#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchMailboxTransportService'

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

        $commonMailboxTransportServiceStandardOutput = @{
            ConnectivityLogEnabled                       = [System.Boolean] $false
            ConnectivityLogMaxAge                        = [System.String] ''
            ConnectivityLogMaxDirectorySize              = [System.String] ''
            ConnectivityLogMaxFileSize                   = [System.String] ''
            ConnectivityLogPath                          = [System.String] ''
            ContentConversionTracingEnabled              = [System.Boolean] $false
            MailboxDeliveryAgentLogEnabled               = [System.Boolean] $false
            MailboxDeliveryAgentLogMaxAge                = [System.String] ''
            MailboxDeliveryAgentLogMaxDirectorySize      = [System.String] ''
            MailboxDeliveryAgentLogMaxFileSize           = [System.String] ''
            MailboxDeliveryAgentLogPath                  = [System.String] ''
            MailboxDeliveryConnectorMaxInboundConnection = [System.String] ''
            MailboxDeliveryConnectorProtocolLoggingLevel = [System.String] ''
            MailboxDeliveryConnectorSMTPUtf8Enabled      = [System.Boolean] $false
            MailboxDeliveryThrottlingLogEnabled          = [System.Boolean] $false
            MailboxDeliveryThrottlingLogMaxAge           = [System.String] ''
            MailboxDeliveryThrottlingLogMaxDirectorySize = [System.String] ''
            MailboxDeliveryThrottlingLogMaxFileSize      = [System.String] ''
            MailboxDeliveryThrottlingLogPath             = [System.String] ''
            MailboxSubmissionAgentLogEnabled             = [System.Boolean] $false
            MailboxSubmissionAgentLogMaxAge              = [System.String] ''
            MailboxSubmissionAgentLogMaxDirectorySize    = [System.String] ''
            MailboxSubmissionAgentLogMaxFileSize         = [System.String] ''
            MailboxSubmissionAgentLogPath                = [System.String] ''
            MaxConcurrentMailboxDeliveries               = [System.Int32] 1
            MaxConcurrentMailboxSubmissions              = [System.Int32] 1
            PipelineTracingEnabled                       = [System.Boolean] $false
            PipelineTracingPath                          = [System.String] ''
            PipelineTracingSenderAddress                 = [System.String] ''
            ReceiveProtocolLogMaxAge                     = [System.String] ''
            ReceiveProtocolLogMaxDirectorySize           = [System.String] ''
            ReceiveProtocolLogMaxFileSize                = [System.String] ''
            ReceiveProtocolLogPath                       = [System.String] ''
            SendProtocolLogMaxAge                        = [System.String] ''
            SendProtocolLogMaxDirectorySize              = [System.String] ''
            SendProtocolLogMaxFileSize                   = [System.String] ''
            SendProtocolLogPath                          = [System.String] ''
        }

        $commonTargetResourceParams = @{
            Identity   = 'MailboxTransportService'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        Mock -CommandName Get-RemoteExchangeSession -Verifiable

        Describe 'MSFT_xExchMailboxTransportService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-MailboxTransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-MailboxTransportService -Verifiable -MockWith { return $commonMailboxTransportServiceStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }

        Describe 'MSFT_xExchMailboxTransportService\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-TargetResource is called' {
                function Set-MailboxTransportService { }

                #Mock -CommandName Get-RemoteExchangeSession -Verifiable
                It 'Should warn about restarting the MSExchangeDelivery and/or MSExchangeSubmission services' {
                    Mock -CommandName Set-MailboxTransportService -Verifiable
                    Mock -CommandName Write-Warning -ParameterFilter {$Message -eq 'The configuration will not take effect until the MSExchangeDelivery and/or MSExchangeSubmission services are manually restarted.'}

                    Set-TargetResource @commonTargetResourceParams
                }

                It 'Should call expected functions' {
                    $commonTargetResourceParams.AllowServiceRestart = $true
                    Mock -CommandName Set-MailboxTransportService -Verifiable
                    Mock -CommandName Restart-Service -Verifiable

                    Set-TargetResource @commonTargetResourceParams
                    $commonTargetResourceParams.Remove('AllowServiceRestart')
                }
            }
        }

        Describe 'MSFT_xExchMailboxTransportService\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            AfterEach {
                Assert-VerifiableMock
            }

            function Get-MailboxTransportService {}

            Context 'When Test-TargetResource is called' {
                It 'Should return False when Get-MailboxTransportService returns null' {
                    Mock -CommandName Get-MailboxTransportService -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }

                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-MailboxTransportService -Verifiable -MockWith { return $commonMailboxTransportServiceStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-MailboxTransportService -Verifiable -MockWith { return $commonMailboxTransportServiceStandardOutput }
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
