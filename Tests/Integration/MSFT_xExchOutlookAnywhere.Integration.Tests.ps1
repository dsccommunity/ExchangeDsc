<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchOutlookAnywhere DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchOutlookAnywhere'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean]$exchangeInstalled = Get-IsSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
    }

    #Get the Server FQDN for using in URL's
    if ($null -eq $Global:ServerFqdn)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe 'Test Setting Properties with xExchOutlookAnywhere' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Rpc (Default Web Site)"
            Credential = $Global:ShellCredentials
            ExtendedProtectionFlags = 'Proxy','ProxyCoHosting'
            ExtendedProtectionSPNList = @()
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSsl = $true
            ExternalHostname = $Global:ServerFqdn
            IISAuthenticationMethods = 'Basic','Ntlm','Negotiate'
            InternalClientAuthenticationMethod = 'Negotiate'
            InternalHostname = $Global:ServerFqdn
            InternalClientsRequireSsl = $true
            SSLOffloading = $false      
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Rpc (Default Web Site)"
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSsl = $true
            ExternalHostname = $Global:ServerFqdn
            InternalClientAuthenticationMethod = 'Negotiate'
            InternalHostname = $Global:ServerFqdn
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
