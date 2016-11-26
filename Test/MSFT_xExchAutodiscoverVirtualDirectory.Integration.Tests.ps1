###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchAutodiscoverVirtualDirectory\MSFT_xExchAutodiscoverVirtualDirectory.psm1
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

    if ($null -eq $Global:ServerFqdn)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe "Test Setting Properties with xExchAutodiscoverVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $true
            DigestAuthentication = $false
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true        
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            BasicAuthentication = $true
            DigestAuthentication = $false
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true    
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams.BasicAuthentication = $false
        $testParams.DigestAuthentication = $true
        $testParams.WindowsAuthentication = $false
        $testParams.WSSecurityAuthentication = $true
        $expectedGetResults.BasicAuthentication = $false
        $expectedGetResults.DigestAuthentication = $true
        $expectedGetResults.WindowsAuthentication = $false
        $expectedGetResults.WSSecurityAuthentication = $true

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
