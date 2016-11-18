###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchUMCallRouterSettings\MSFT_xExchUMCallRouterSettings.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Test Setting Properties with xExchUMCallRouterSettings" {
        $testParams = @{
            Server =  $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            UMStartupMode = "TLS"       
        }

        $expectedGetResults = @{
            Server =  $env:COMPUTERNAME
            UMStartupMode = "TLS"  
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams.UMStartupMode = "Dual"
        $expectedGetResults.UMStartupMode = "Dual"

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
