<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchExchangeCertificate DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

# Suppression of this PSSA rule allowed in tests.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
Param()

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchExchangeCertificate'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    # Get required credentials to use for the test
    $certPassword = ConvertTo-SecureString 'Password1' -AsPlainText -Force
    $certCredentials = New-Object System.Management.Automation.PSCredential ('admin', $certPassword)

    [System.String] $testCertThumbprint1 = '766358855A7361C6D99D4FB58903AB0833296B2A'
    [System.String] $testCertThumbprint2 = '4C14890860F4126A18560779B8AF8B818B900F5A'
    [System.String] $testCertPath1 = Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'Data' -ChildPath 'TestCert1.pfx'))
    [System.String] $testCertPath2 = Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'Data' -ChildPath 'TestCert2.pfx'))

    Describe 'Test Installing, Enabling, and Removing Exchange Certificates' {
        # Test installing and enabling test cert 1
        $testParams = @{
            Thumbprint = $testCertThumbprint1
            Credential = $shellCredentials
            Ensure = 'Present'
            AllowExtraServices = $true
            CertCreds = $certCredentials
            CertFilePath = $testCertPath1
            Services = 'IIS', 'POP', 'IMAP', 'SMTP'
        }

        $expectedGetResults = @{
            Thumbprint = $testCertThumbprint1
            Services = 'IIS', 'POP', 'IMAP', 'SMTP'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Install and Enable Test Certificate 1' `
                                         -ExpectedGetResults $expectedGetResults

        # Test installing and enabling test cert2
        $testParams.Thumbprint = $testCertThumbprint2
        $testParams.CertFilePath = $testCertPath2
        $testParams.Add('DoNotRequireSsl', $true)
        $testParams.Add('NetworkServiceAllowed', $true)
        $expectedGetResults.Thumbprint = $testCertThumbprint2

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Install and Enable Test Certificate 2' `
                                         -ExpectedGetResults $expectedGetResults

        # Test removing test cert 1
        $testParams.Thumbprint = $testCertThumbprint1
        $testParams.Ensure = 'Absent'
        $expectedGetResults = $null

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Remove Test Certificate 1' `
                                         -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
