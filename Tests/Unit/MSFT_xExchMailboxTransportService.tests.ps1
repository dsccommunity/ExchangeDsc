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
        Describe 'MSFT_xExchMailboxTransportService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-MailboxTransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'MailboxTransportService'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getMailboxTransportServiceStandardOutput = @{
                ConnectivityLogEnabled             = [System.Boolean] $false
                ConnectivityLogMaxAge              = [System.String] ''
                ConnectivityLogMaxDirectorySize    = [System.String] ''
                ConnectivityLogMaxFileSize         = [System.String] ''
                ConnectivityLogPath                = [System.String] ''
                ContentConversionTracingEnabled    = [System.Boolean] $false
                MaxConcurrentMailboxDeliveries     = [System.Int32] 1
                MaxConcurrentMailboxSubmissions    = [System.Int32] 1
                PipelineTracingEnabled             = [System.Boolean] $false
                PipelineTracingPath                = [System.String] ''
                PipelineTracingSenderAddress       = [System.String] ''
                ReceiveProtocolLogMaxAge           = [System.String] ''
                ReceiveProtocolLogMaxDirectorySize = [System.String] ''
                ReceiveProtocolLogMaxFileSize      = [System.String] ''
                ReceiveProtocolLogPath             = [System.String] ''
                SendProtocolLogMaxAge              = [System.String] ''
                SendProtocolLogMaxDirectorySize    = [System.String] ''
                SendProtocolLogMaxFileSize         = [System.String] ''
                SendProtocolLogPath                = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-MailboxTransportService -Verifiable -MockWith { return $getMailboxTransportServiceStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
