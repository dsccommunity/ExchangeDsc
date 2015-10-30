###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchActiveSyncVirtualDirectory\MSFT_xExchActiveSyncVirtualDirectory.psm1
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

    #Get the thumbprint to use for ActiveSync Cert Based Auth
    if ($Global:CBACertThumbprint -eq $null)
    {
        $Global:CBACertThumbprint = Read-Host -Prompt "Enter the thumbprint of an Exchange certificate to use when enabling Certificate Based Authentication"
    }

    Describe "Test Setting Properties with xExchActiveSyncVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential = $Global:ShellCredentials
            AutoCertBasedAuth = $false
            AutoCertBasedAuthThumbprint = ''
            BasicAuthEnabled = $true
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/Microsoft-Server-ActiveSync"
            InternalUrl = "https://$($Global:ServerFqdn)/Microsoft-Server-ActiveSync"                        
            WindowsAuthEnabled = $false           
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            BasicAuthEnabled = $true
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/Microsoft-Server-ActiveSync"
            InternalUrl = "https://$($Global:ServerFqdn)/Microsoft-Server-ActiveSync"                        
            WindowsAuthEnabled = $false 
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults


        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = $null
        $expectedGetResults.InternalUrl = $null

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Try with empty URL's" -ExpectedGetResults $expectedGetResults


        $testParams.AutoCertBasedAuth = $true
        $testParams.AutoCertBasedAuthThumbprint = $Global:CBACertThumbprint
        $testParams.ClientCertAuth = 'Required'
        $expectedGetResults.ClientCertAuth = 'Required'

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Try enabling certificate based authentication" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    