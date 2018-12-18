#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchExchangeServer'

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
        Describe 'MSFT_xExchExchangeServer\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'ActiveSyncVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getGetExchangeServerStandardOutput = @{
                CustomerFeedbackEnabled  = [System.Boolean] $false
                InternetWebProxy         = [System.String] ''
                IsExchangeTrialEdition   = [System.Boolean] $false
                MonitoringGroup          = [System.String] ''
                WorkloadManagementPolicy = [System.String] ''
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getGetExchangeServerStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When IsExchangeTrialEdition is set to true' {
                It 'Should return an empty ProductKey' {
                    $defaultValue = $getGetExchangeServerStandardOutput.IsExchangeTrialEdition
                    $getGetExchangeServerStandardOutput.IsExchangeTrialEdition = $true

                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getGetExchangeServerStandardOutput }

                    (Get-TargetResource @getTargetResourceParams).ProductKey | Should -Be ''

                    $getGetExchangeServerStandardOutput.IsExchangeTrialEdition = $defaultValue
                }
            }

            Context 'When Get-TargetResource is called with WorkloadManagementPolicy and it is not an available parameter' {
                It 'Should be removed from PSBoundParameters' {
                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getGetExchangeServerStandardOutput }
                    Mock -CommandName Write-Warning -Verifiable
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable

                    $getTargetResourceParams.Add('WorkloadManagementPolicy', 'Policy')

                    Get-TargetResource @getTargetResourceParams

                    $getTargetResourceParams.Remove('WorkloadManagementPolicy')
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
