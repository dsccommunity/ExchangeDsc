<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchUMCallRouterSettings DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchUMCallRouterSettings'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    $serverVersion = Get-ExchangeVersionYear

    if ($serverVersion -in '2013', '2016')
    {
        Describe 'Test Setting Properties with xExchUMCallRouterSettings' {
            $testParams = @{
                Server =  $env:COMPUTERNAME
                Credential = $shellCredentials
                UMStartupMode = 'TLS'
            }

            $expectedGetResults = @{
                Server =  $env:COMPUTERNAME
                UMStartupMode = 'TLS'
            }

            Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set standard parameters' -ExpectedGetResults $expectedGetResults


            $testParams.UMStartupMode = 'Dual'
            $expectedGetResults.UMStartupMode = 'Dual'

            Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Change some parameters' -ExpectedGetResults $expectedGetResults
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
