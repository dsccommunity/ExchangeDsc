<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchUMService DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchUMService'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

$testUMDPName = 'UMDP (DSC Test)'

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    $serverVersion = Get-ExchangeVersionYear

    if ($serverVersion -in '2013', '2016')
    {
        # Check if the test UM Dial Plan exists, and if not, create it
        Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad '*-UMDialPlan'

        if ($null -eq (Get-UMDialPlan -Identity $testUMDPName -ErrorAction SilentlyContinue))
        {
            Write-Verbose -Message "Test UM Dial Plan does not exist. Creating UM Dial Plan with name '$testUMDPName'."

            $testUMDP = New-UMDialPlan -Name $testUMDPName -URIType SipName -CountryOrRegionCode 1 -NumberOfDigitsInExtension 10

            if ($null -eq $testUMDP)
            {
                throw 'Failed to create test UM Dial Plan.'
            }
        }

        # Remove our remote Exchange session so as not to interfere with actual Integration testing
        Remove-RemoteExchangeModule

        Describe 'Test Setting Properties with xExchUMService' {
            $testParams = @{
                Identity      = $env:COMPUTERNAME
                Credential    = $shellCredentials
                UMStartupMode = 'TLS'
                DialPlans     = @()
            }

            $expectedGetResults = @{
                Identity      = $env:COMPUTERNAME
                UMStartupMode = 'TLS'
            }

            Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set standard parameters' -ExpectedGetResults $expectedGetResults
            Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName 'DialPlans' -ContextLabel 'Verify DialPlans' -ItLabel 'DialPlans should be empty'

            $testParams.UMStartupMode = 'Dual'
            $testParams.DialPlans = @($testUMDPName)
            $expectedGetResults.UMStartupMode = 'Dual'
            $expectedGetResults.DialPlans = @($testUMDPName)

            Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Change some parameters' -ExpectedGetResults $expectedGetResults
            Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName 'DialPlans' -ContextLabel 'Verify DialPlans' -ItLabel 'DialPlans should contain a value'
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
