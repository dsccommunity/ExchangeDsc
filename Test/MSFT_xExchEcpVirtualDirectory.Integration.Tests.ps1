###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchEcpVirtualDirectory\MSFT_xExchEcpVirtualDirectory.psm1
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

    #Get the Server FQDN for using in URL's
    if ($Global:ServerFqdn -eq $null)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe "Test Setting Properties with xExchEcpVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            Credential = $Global:ShellCredentials
            AdfsAuthentication = $false
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/ecp"
            FormsAuthentication = $true
            InternalUrl = "https://$($Global:ServerFqdn)/ecp"                        
            WindowsAuthentication = $false        
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            AdfsAuthentication = $false
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/ecp"
            FormsAuthentication = $true
            InternalUrl = "https://$($Global:ServerFqdn)/ecp"                        
            WindowsAuthentication = $false  
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            Credential = $Global:ShellCredentials
            AdfsAuthentication = $true
            BasicAuthentication = $false
            DigestAuthentication = $true
            ExternalUrl = ''
            FormsAuthentication = $false
            InternalUrl = ''                       
            WindowsAuthentication = $true        
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            AdfsAuthentication = $true
            BasicAuthentication = $false
            DigestAuthentication = $true
            ExternalUrl = $null
            FormsAuthentication = $false
            InternalUrl = $null                      
            WindowsAuthentication = $true 
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Try with the opposite of each property value" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    