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
        Describe 'MSFT_xExchUMCallRouterSettings\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-UMCallRouterSettings {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Server        = 'UMServer'
                Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                UMStartupMode = 'TLS'
            }

            $getUMCallRouterSettingsStandardOutput = @{
                UMStartupMode                = [System.String] $getTargetResourceParams.UMStartupMode
                DialPlans                    = [System.String[]] @()
                $IPAddressFamily             = [System.String] 'Any'
                $IPAddressFamilyConfigurable = [System.Boolean] $false
                $MaxCallsAllowed             = [System.Int32] '100'
                $SipTcpListeningPort         = [System.Int32] '5060'
                $SipTlsListeningPort         = [System.Int32] '5061'
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-UMCallRouterSettings -Verifiable -MockWith { return $getUMCallRouterSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
