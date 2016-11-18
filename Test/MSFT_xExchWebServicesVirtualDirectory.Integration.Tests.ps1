###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchWebServicesVirtualDirectory\MSFT_xExchWebServicesVirtualDirectory.psm1
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

    Describe "Test Setting Properties with xExchWebServicesVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\EWS (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            CertificateAuthentication = $false
            DigestAuthentication = $false
            ExternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalNLBBypassUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            OAuthAuthentication = $false                       
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true          
        }

        $expectedGetResults = @{
            BasicAuthentication = $false
            CertificateAuthentication = $null
            DigestAuthentication = $false
            ExternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalNLBBypassUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            OAuthAuthentication = $false                       
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true    
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = $null
        $expectedGetResults.InternalUrl = $null

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Try with empty URL's" -ExpectedGetResults $expectedGetResults


        #Set Authentication values back to default
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\EWS (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            DigestAuthentication = $false
            OAuthAuthentication = $true                       
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true          
        }

        $expectedGetResults = @{
            BasicAuthentication = $false
            DigestAuthentication = $false
            OAuthAuthentication = $true                       
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true     
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Reset authentication to default" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
