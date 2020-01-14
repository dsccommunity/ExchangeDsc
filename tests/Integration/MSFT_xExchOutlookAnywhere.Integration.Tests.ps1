<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchOutlookAnywhere DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchOutlookAnywhere'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

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

    Describe 'Test Setting Properties with xExchOutlookAnywhere' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Rpc (Default Web Site)"
            Credential = $shellCredentials
            ExtendedProtectionFlags = 'Proxy', 'ProxyCoHosting'
            ExtendedProtectionSPNList = @()
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSsl = $true
            ExternalHostname = $serverFqdn
            IISAuthenticationMethods = 'Basic', 'Ntlm', 'Negotiate'
            InternalClientAuthenticationMethod = 'Negotiate'
            InternalHostname = $serverFqdn
            InternalClientsRequireSsl = $true
            SSLOffloading = $false
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Rpc (Default Web Site)"
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSsl = $true
            ExternalHostname = $serverFqdn
            InternalClientAuthenticationMethod = 'Negotiate'
            InternalHostname = $serverFqdn
            InternalClientsRequireSsl = $true
            SSLOffloading = $false
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set standard parameters' `
                                         -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExtendedProtectionFlags `
                                -GetResultParameterName 'ExtendedProtectionFlags' `
                                -ContextLabel 'Verify ExtendedProtectionFlags' `
                                -ItLabel 'ExtendedProtectionFlags should contain two values'
        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExtendedProtectionSPNList `
                                -GetResultParameterName 'ExtendedProtectionSPNList' `
                                -ContextLabel 'Verify ExtendedProtectionSPNList' `
                                -ItLabel 'ExtendedProtectionSPNList should be empty'
        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.IISAuthenticationMethods `
                                -GetResultParameterName 'IISAuthenticationMethods' `
                                -ContextLabel 'Verify IISAuthenticationMethods' `
                                -ItLabel 'IISAuthenticationMethods should contain three values'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
