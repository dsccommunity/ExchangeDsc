<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchEcpVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchEcpVirtualDirectory'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    # Get the Server FQDN for using in URL's
    if ($null -eq $serverFqdn)
    {
        $serverFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe 'Test Setting Properties with xExchEcpVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            Credential = $shellCredentials
            AdminEnabled = $false
            # AdfsAuthentication = $false #Don't test AdfsAuthentication changes in dedicated ECP tests, as they have to be done to OWA at the same time
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($serverFqdn)/ecp"
            FormsAuthentication = $true
            GzipLevel = 'Off'
            InternalUrl = "https://$($serverFqdn)/ecp"
            WindowsAuthentication = $false
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            AdminEnabled = $false
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($serverFqdn)/ecp"
            FormsAuthentication = $true
            GzipLevel = 'Off'
            InternalUrl = "https://$($serverFqdn)/ecp"
            WindowsAuthentication = $false
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set standard parameters' `
                                         -ExpectedGetResults $expectedGetResults

        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            Credential = $shellCredentials
            AdminEnabled = $true
            BasicAuthentication = $false
            DigestAuthentication = $true
            ExternalUrl = ''
            FormsAuthentication = $false
            GzipLevel = 'High'
            InternalUrl = ''
            WindowsAuthentication = $true
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            AdminEnabled = $true
            BasicAuthentication = $false
            DigestAuthentication = $true
            ExternalUrl = ''
            FormsAuthentication = $false
            GzipLevel = 'High'
            InternalUrl = ''
            WindowsAuthentication = $true
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Try with the opposite of each property value' `
                                         -ExpectedGetResults $expectedGetResults

        # Set Authentication values back to default
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            Credential = $shellCredentials
            BasicAuthentication = $true
            DigestAuthentication = $false
            FormsAuthentication = $true
            WindowsAuthentication = $false
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\ecp (Default Web Site)"
            BasicAuthentication = $true
            DigestAuthentication = $false
            FormsAuthentication = $true
            WindowsAuthentication = $false
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Reset authentication to default' `
                                         -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
