###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchEventLogLevel\MSFT_xExchEventLogLevel.psm1
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

    Describe "Test Enabling and Disabling Event Log Levels" {
        #Set event log level to high
        $testParams = @{
            Identity = "MSExchangeTransport\DSN"
            Level = "High"
            Credential = $Global:ShellCredentials
        }

        $expectedGetResults = @{
            Level = "High"
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set MSExchangeTransport\DSN to High" -ExpectedGetResults $expectedGetResults
        

        #Set event log level to lowest
        $testParams.Level = "Lowest"
        $expectedGetResults.Level = "Lowest"

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set MSExchangeTransport\DSN to Lowest" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
