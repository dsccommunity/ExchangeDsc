###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchPowershellVirtualDirectory\MSFT_xExchPowershellVirtualDirectory.psm1
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

    Describe "Test Setting Properties with xExchPowershellVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\PowerShell (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            CertificateAuthentication = $true
            ExternalUrl = "http://$($Global:ServerFqdn)/powershell"
            InternalUrl = "http://$($Global:ServerFqdn)/powershell"
            RequireSSL = $false                       
            WindowsAuthentication = $false           
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\PowerShell (Default Web Site)"
            BasicAuthentication = $false
            CertificateAuthentication = $true
            ExternalUrl = "http://$($Global:ServerFqdn)/powershell"
            InternalUrl = "http://$($Global:ServerFqdn)/powershell"
            RequireSSL = $false                       
            WindowsAuthentication = $false  
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = $null
        $expectedGetResults.InternalUrl = $null

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Try with empty URL's" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
