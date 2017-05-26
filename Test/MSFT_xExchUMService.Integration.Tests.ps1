###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchUMService\MSFT_xExchUMService.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

$testUMDPName = "UMDP (DSC Test)"

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    #Check if the test UM Dial Plan exists, and if not, create it
    GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "*-UMDialPlan"

    if ($null -eq (Get-UMDialPlan -Identity $testUMDPName -ErrorAction SilentlyContinue))
    {
        Write-Verbose "Test UM Dial Plan does not exist. Creating UM Dial Plan with name '$testUMDPName'."

        $testUMDP = New-UMDialPlan -Name $testUMDPName -URIType SipName -CountryOrRegionCode 1 -NumberOfDigitsInExtension 10

        if ($null -eq $testUMDP)
        {
            throw "Failed to create test UM Dial Plan."
        }
    }

    Describe "Test Setting Properties with xExchUMService" {
        $testParams = @{
            Identity =  $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            UMStartupMode = "TLS"
            DialPlans = @()
        }

        $expectedGetResults = @{
            Identity =  $env:COMPUTERNAME
            UMStartupMode = "TLS"
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName "DialPlans" -ContextLabel "Verify DialPlans" -ItLabel "DialPlans should be empty"

        $testParams.UMStartupMode = "Dual"
        $testParams.DialPlans = @($testUMDPName)
        $expectedGetResults.UMStartupMode = "Dual"
        $expectedGetResults.DialPlans = @($testUMDPName)

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName "DialPlans" -ContextLabel "Verify DialPlans" -ItLabel "DialPlans should contain a value"
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
