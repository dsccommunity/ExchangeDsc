###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchPopSettings\MSFT_xExchPopSettings.psm1
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

    #Get the Server FQDN for using in URL's
    if ($null -eq $Global:ServerFqdn)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe "Test Setting Properties with xExchPopSettings" {
        $testParams = @{
            Server =  $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            LoginType = "PlainTextLogin"
            ExternalConnectionSettings = @("$($Global:ServerFqdn):143:TLS")
            X509CertificateName = "$($Global:ServerFqdn)"     
        }

        $expectedGetResults = @{
            LoginType = "PlainTextLogin"
            X509CertificateName = "$($Global:ServerFqdn)"    
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExternalConnectionSettings -GetResultParameterName "ExternalConnectionSettings" -ContextLabel "Verify ExternalConnectionSettings" -ItLabel "ExternalConnectionSettings should contain a value"

        $testParams.LoginType = "SecureLogin"
        $testParams.ExternalConnectionSettings = @()
        $testParams.X509CertificateName = ""
        $expectedGetResults.LoginType = "SecureLogin"
        $expectedGetResults.X509CertificateName = ""

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExternalConnectionSettings -GetResultParameterName "ExternalConnectionSettings" -ContextLabel "Verify ExternalConnectionSettings" -ItLabel "ExternalConnectionSettings should be empty"
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
