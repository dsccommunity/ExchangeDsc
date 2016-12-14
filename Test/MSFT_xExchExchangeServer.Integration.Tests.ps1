###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.
###This module has the following additional requirements;
### * Requires that the ActiveDirectory module is installed

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchExchangeServer\MSFT_xExchExchangeServer.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Sets props retrieved by Get-ExchangeServer back to their default values
function PrepTestExchangeServer
{
    [CmdletBinding()]
    param()

    Import-Module ActiveDirectory
    ClearServerADProp("msExchProductID")
    ClearServerADProp("msExchCustomerFeedbackEnabled")
    ClearServerADProp("msExchInternetWebProxy")
    #ClearServerADProp("msExchShadowDisplayName")   
}

#Used to null out the specified Active Directory property of an Exchange Server
function ClearServerADProp
{
    [CmdletBinding()]
    param($prop)

    Get-ADObject -SearchBase "$($Global:ExchangeServerDN)" -Filter {ObjectClass -eq "msExchExchangeServer"} | Where-Object {$_.ObjectClass -eq "msExchExchangeServer"} | Set-ADObject -Clear "$($prop)"
}

function VerifyServerPrepped
{
    [CmdletBinding()]
    param()

    Context "Server has had relevant properties nulled out for xExchExchangeServer tests" {
        [Hashtable]$getResult = Get-TargetResource @testParams -Verbose

        #It "CustomerFeedbackEnabled should be null" {
        #    $getResult.CustomerFeedbackEnabled | Should Be $null
        #}

        It "InternetWebProxy should be empty" {
            [string]::IsNullOrEmpty($getResult.InternetWebProxy) | Should Be $true
        }

        It "ProductKey should be empty" {
            [string]::IsNullOrEmpty($getResult.ProductKey) | Should Be $true
        }
    }
}

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    #Check if Exchange is installed on this machine. If not, we can't run tests
    [bool]$exchangeInstalled = IsSetupComplete

    if ($exchangeInstalled)
    {
        #Get required credentials to use for the test
        if ($null -eq $Global:ShellCredentials)
        {
            [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
        }

        if ($null -eq $Global:ExchangeServerDN)
        {
            GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "Get-ExchangeServer"

            $server = Get-ExchangeServer -Identity $env:COMPUTERNAME

            if ($null -ne $server)
            {
                $Global:ExchangeServerDN = $server.DistinguishedName
            }

            if ($null -eq $Global:ExchangeServerDN)
            {
                throw "Failed to determine distinguishedName of Exchange Server object"
            }
        }

        #Get the product key to use for testing
        if ($null -eq $Global:ProductKey)
        {
            $Global:ProductKey = Read-Host -Prompt "Enter the product key to license Exchange with"
        }

        Describe "Test Setting Properties with xExchExchangeServer" {
            #Create out initial test params
            $testParams = @{
                Identity = $env:COMPUTERNAME
                Credential = $Global:ShellCredentials
            }

            #First prepare the server for tests
            PrepTestExchangeServer
            VerifyServerPrepped


            #Now do tests
            $testParams = @{
                Identity = $env:COMPUTERNAME
                Credential = $Global:ShellCredentials
                InternetWebProxy = "http://someproxy.local/"
                ProductKey = $Global:ProductKey
            }

            $expectedGetResults = @{
                Identity = $env:COMPUTERNAME
                InternetWebProxy = "http://someproxy.local/"
                ProductKey = "Licensed"
            }

            Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Standard xExchExchangeServer tests" -ExpectedGetResults $expectedGetResults
        }
    }
    else
    {
        Write-Verbose "Tests in this file require that Exchange is installed to be run."
    }
}
else
{
    Write-Verbose "Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS"
}
    
