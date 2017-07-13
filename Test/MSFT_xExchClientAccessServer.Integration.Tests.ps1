###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchClientAccessServer\MSFT_xExchClientAccessServer.psm1
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

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set autod url and site scope" -ExpectedGetResults $expectedGetResults


        #Now set the URL to empty
        $testParams.AutoDiscoverServiceInternalUri = ''
        $expectedGetResults.AutoDiscoverServiceInternalUri = $null

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set url to empty" -ExpectedGetResults $expectedGetResults


        #Now try multiple sites in the site scope
        $testParams.AutoDiscoverSiteScope = 'Site1','Site2'
        $expectedGetResults = @{}

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set site scope to multi value" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.AutoDiscoverSiteScope -GetResultParameterName "AutoDiscoverSiteScope" -ContextLabel "Verify AutoDiscoverSiteScope" -ItLabel "AutoDiscoverSiteScope should contain two values"


        #Now set the site scope to $null
        $testParams.AutoDiscoverSiteScope = $null
        $expectedGetResults = @{}

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set site scope to null" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.AutoDiscoverSiteScope -GetResultParameterName "AutoDiscoverSiteScope" -ContextLabel "Verify AutoDiscoverSiteScope" -ItLabel "AutoDiscoverSiteScope should be empty"


        #create ASA credentials
        if ($null -eq $Global:ASACredentials)
        {
            $UserASA = "Fabrikam\ASA"
            $PWordASA = ConvertTo-SecureString -String 'Pa$$w0rd!' -AsPlainText -Force
            $Global:ASACredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserASA, $PWordASA
        }

        #Now set ASA account
        $testParams.Remove('AutoDiscoverSiteScope')
        $testParams.Remove('AutoDiscoverServiceInternalUri')
        $testParams.Add('AlternateServiceAccountCredential',$Global:ASACredentials)
        $expectedGetResults.Add('AlternateServiceAccountCredential','UserName:Fabrikam\ASA Password:Pa$$w0rd!')
        
        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set AlternateServiceAccountCredential" -ExpectedGetResults $expectedGetResults

        
        #Now clear ASA account credentials
        $testParams.Remove('AlternateServiceAccountCredential')
        $testParams.RemoveAlternateServiceAccountCredentials = $true
        $expectedGetResults.Remove('AlternateServiceAccountCredential')

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Clear AlternateServiceAccountCredential" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
