<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchExchangeServer DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
        This module has the following additional requirements:
            * Requires that the ActiveDirectory module is installed
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchExchangeServer'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

#Sets properties retrieved by Get-ExchangeServer back to their default values
function Clear-PropsForExchDscServer
{
    [CmdletBinding()]
    param()

    Import-Module -Name ActiveDirectory
    Clear-ExchDscServerADProperty -Property 'msExchProductID'
    Clear-ExchDscServerADProperty -Property 'msExchCustomerFeedbackEnabled'
    Clear-ExchDscServerADProperty -Property 'msExchInternetWebProxy'
}

#Used to null out the specified Active Directory property of an Exchange Server
function Clear-ExchDscServerADProperty
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.string]
        $Property
    )

    Get-ADObject -SearchBase "$($exchangeServerDN)" -Filter {ObjectClass -eq 'msExchExchangeServer'} | Where-Object -FilterScript {
        $_.ObjectClass -eq 'msExchExchangeServer'
    } | Set-ADObject -Clear "$($Property)"
}

function Test-ExchDscServerPrepped
{
    [CmdletBinding()]
    param()

    Context 'Server has had relevant properties nulled out for xExchExchangeServer tests' {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @testParams -Verbose

        It 'InternetWebProxy should be empty' {
            [System.String]::IsNullOrEmpty($getResult.InternetWebProxy) | Should Be $true
        }

        It 'ProductKey should be empty' {
            [System.String]::IsNullOrEmpty($getResult.ProductKey) | Should Be $true
        }
    }
}

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    if ($exchangeInstalled)
    {
        #Get required credentials to use for the test
        $shellCredentials = Get-TestCredential

        if ($null -eq $exchangeServerDN)
        {
            Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer'
            $server = Get-ExchangeServer -Identity $env:COMPUTERNAME

            if ($null -ne $server)
            {
                $exchangeServerDN = $server.DistinguishedName
            }

            if ($null -eq $exchangeServerDN)
            {
                throw 'Failed to determine distinguishedName of Exchange Server object'
            }
        }

        #Get the product key to use for testing
        if ($null -eq $productKey)
        {
            $productKey = Read-Host -Prompt 'Enter the product key to license Exchange with, or press ENTER to skip testing the licensing of the server.'
        }

        Describe 'Test Setting Properties with xExchExchangeServer' {
            #Create out initial test params
            $testParams = @{
                Identity = $env:COMPUTERNAME
                Credential = $shellCredentials
            }

            #First prepare the server for tests
            Clear-PropsForExchDscServer
            Test-ExchDscServerPrepped

            #Now do tests
            $testParams = @{
                Identity = $env:COMPUTERNAME
                Credential = $shellCredentials
                InternetWebProxy = 'http://someproxy.local/'
            }

            $expectedGetResults = @{
                Identity = $env:COMPUTERNAME
                InternetWebProxy = 'http://someproxy.local/'
            }

            if (![System.String]::IsNullOrEmpty($productKey))
            {
                $testParams.Add('ProductKey', $productKey)
                $expectedGetResults.Add('ProductKey', 'Licensed')
            }

            Test-TargetResourceFunctionality -Params $testParams `
                                             -ContextLabel 'Standard xExchExchangeServer tests' `
                                             -ExpectedGetResults $expectedGetResults
        }
    }
    else
    {
        Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS'
}
