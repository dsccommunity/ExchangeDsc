###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchUMService\MSFT_xExchUMService.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($Global:ShellCredentials -eq $null)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    if ($Global:UMDialPlan -eq $null)
    {
        $Global:UMDialPlan = Read-Host -Prompt "Enter the name of the existing UM Dial Plan to test with"
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

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContents -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName "DialPlans" -ContextLabel "Verify DialPlans" -ItLabel "DialPlans should be empty"

        $testParams.UMStartupMode = "Dual"
        $testParams.DialPlans = @($Global:UMDialPlan)
        $expectedGetResults.UMStartupMode = "Dual"
        $expectedGetResults.DialPlans = @($Global:UMDialPlan)

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContents -TestParams $testParams -DesiredArrayContents $testParams.DialPlans -GetResultParameterName "DialPlans" -ContextLabel "Verify DialPlans" -ItLabel "DialPlans should contain a value"
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
