###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchClientAccessServer\MSFT_xExchClientAccessServer.psm1
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

    Describe "Test Setting Properties with xExchClientAccessServer" {        
        #Do standard URL and scope tests
        $testParams = @{
            Identity =  $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            AutoDiscoverServiceInternalUri = "https://$($Global:ServerFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope = 'Site1'
        }

        $expectedGetResults = @{
            Identity =  $env:COMPUTERNAME
            AutoDiscoverServiceInternalUri = "https://$($Global:ServerFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope = 'Site1'  
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set autod url and site scope" -ExpectedGetResults $expectedGetResults


        #Now set the URL to empty
        $testParams.AutoDiscoverServiceInternalUri = ''
        $expectedGetResults.AutoDiscoverServiceInternalUri = $null

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set url to empty" -ExpectedGetResults $expectedGetResults


        #Now try multiple sites in the site scope
        $testParams.AutoDiscoverSiteScope = 'Site1','Site2'
        $expectedGetResults = @{}

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set site scope to multi value" -ExpectedGetResults $expectedGetResults
        Test-ArrayContents -TestParams $testParams -DesiredArrayContents $testParams.AutoDiscoverSiteScope -GetResultParameterName "AutoDiscoverSiteScope" -ContextLabel "Verify AutoDiscoverSiteScope" -ItLabel "AutoDiscoverSiteScope should contain two values"


        #Now set the site scope to $null
        $testParams.AutoDiscoverSiteScope = $null
        $expectedGetResults = @{}

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Set site scope to null" -ExpectedGetResults $expectedGetResults
        Test-ArrayContents -TestParams $testParams -DesiredArrayContents $testParams.AutoDiscoverSiteScope -GetResultParameterName "AutoDiscoverSiteScope" -ContextLabel "Verify AutoDiscoverSiteScope" -ItLabel "AutoDiscoverSiteScope should be empty"
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    