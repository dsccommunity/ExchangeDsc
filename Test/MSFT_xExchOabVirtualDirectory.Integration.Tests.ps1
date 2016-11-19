###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchOabVirtualDirectory\MSFT_xExchOabVirtualDirectory.psm1
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

    Describe "Test Setting Properties with xExchOabVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\OAB (Default Web Site)"
            Credential = $Global:ShellCredentials
            OABsToDistribute = "Default Offline Address Book (Ex2013)"
            BasicAuthentication = $false
            ExtendedProtectionFlags = "Proxy","ProxyCoHosting"
            ExtendedProtectionSPNList = @()
            ExtendedProtectionTokenChecking = "Allow"
            InternalUrl = "http://$($Global:ServerFqdn)/OAB"
            ExternalUrl = ""
            RequireSSL = $false
            WindowsAuthentication = $true
            PollInterval = 481                           
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\OAB (Default Web Site)"
            BasicAuthentication = $false
            ExtendedProtectionTokenChecking = "Allow"
            InternalUrl = "http://$($Global:ServerFqdn)/OAB"
            ExternalUrl = $null
            RequireSSL = $false
            WindowsAuthentication = $true
            PollInterval = 481   
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionFlags -GetResultParameterName "ExtendedProtectionFlags" -ContextLabel "Verify ExtendedProtectionFlags" -ItLabel "ExtendedProtectionFlags should contain two values"
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionSPNList -GetResultParameterName "ExtendedProtectionSPNList" -ContextLabel "Verify ExtendedProtectionSPNList" -ItLabel "ExtendedProtectionSPNList should be empty"
        Test-Array2ContainsArray1 -TestParams $testParams -DesiredArrayContents $testParams.OABsToDistribute -GetResultParameterName "OABsToDistribute" -ContextLabel "Verify OABsToDistribute" -ItLabel "OABsToDistribute contains an OAB"
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
