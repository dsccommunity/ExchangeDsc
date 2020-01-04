<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchImapSettings DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchImapSettings'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
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

    Describe 'Test Setting Properties with xExchImapSettings' {
        $testParams = @{
            Server =  $env:COMPUTERNAME
            Credential = $shellCredentials
            LoginType = 'PlainTextLogin'
            ExternalConnectionSettings = @("$($serverFqdn):143:TLS")
            X509CertificateName = "$($serverFqdn)"
        }

        $expectedGetResults = @{
            LoginType = 'PlainTextLogin'
            X509CertificateName = "$($serverFqdn)"
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set standard parameters' `
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExternalConnectionSettings `
                                -GetResultParameterName 'ExternalConnectionSettings' `
                                -ContextLabel 'Verify ExternalConnectionSettings' `
                                -ItLabel 'ExternalConnectionSettings should contain a value'

        $testParams.LoginType = 'SecureLogin'
        $testParams.ExternalConnectionSettings = @()
        $testParams.X509CertificateName = ''
        $expectedGetResults.LoginType = 'SecureLogin'
        $expectedGetResults.X509CertificateName = ''

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Change some parameters' `
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExternalConnectionSettings `
                                -GetResultParameterName 'ExternalConnectionSettings' `
                                -ContextLabel 'Verify ExternalConnectionSettings' `
                                -ItLabel 'ExternalConnectionSettings should be empty'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
