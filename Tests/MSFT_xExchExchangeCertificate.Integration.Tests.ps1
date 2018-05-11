###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param ()

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchExchangeCertificate\MSFT_xExchExchangeCertificate.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

function Test-ServicesInCertificate
{
    [CmdletBinding()]
    param([Hashtable]$TestParams, [string]$ContextLabel)

    Context $ContextLabel {
        [Hashtable]$getResult = Get-TargetResource @TestParams

        It 'Certificate Services Check' {
            CompareCertServices -ServicesActual $getResult.Services -ServicesDesired $TestParams.Services -AllowExtraServices $TestParams.AllowExtraServices | Should Be $true
        }
    }
}

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    #Get required credentials to use for the test
    $certPassword = ConvertTo-SecureString "Password1" -AsPlainText -Force
    $certCredentials = New-Object System.Management.Automation.PSCredential ("admin", $certPassword)

    [string]$testCertThumbprint1 = "766358855A7361C6D99D4FB58903AB0833296B2A"
    [string]$testCertThumbprint2 = "4C14890860F4126A18560779B8AF8B818B900F5A"
    [string]$testCertPath1 = "$($PSScriptRoot)\Data\TestCert1.pfx"
    [string]$testCertPath2 = "$($PSScriptRoot)\Data\TestCert2.pfx"

    Describe "Test Installing, Enabling, and Removing Exchange Certificates" {
        #Test installing and enabling test cert 1
        $testParams = @{
            Thumbprint = $testCertThumbprint1
            Credential = $Global:ShellCredentials
            Ensure = "Present"
            AllowExtraServices = $true
            CertCreds = $certCredentials
            CertFilePath = $testCertPath1
            Services = "IIS","POP","IMAP","SMTP"
        }

        $expectedGetResults = @{
            Thumbprint = $testCertThumbprint1
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Install and Enable Test Certificate 1" -ExpectedGetResults $expectedGetResults
        Test-ServicesInCertificate -TestParams $testParams -ContextLabel 'Verify Services on Test Certificate 1'


        #Test installing and enabling test cert2
        $testParams.Thumbprint = $testCertThumbprint2
        $testParams.CertFilePath = $testCertPath2
        $expectedGetResults.Thumbprint = $testCertThumbprint2

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Install and Enable Test Certificate 2" -ExpectedGetResults $expectedGetResults
        Test-ServicesInCertificate -TestParams $testParams -ContextLabel 'Verify Services on Test Certificate 2'


        #Test removing test cert 1
        $testParams.Thumbprint = $testCertThumbprint1
        $testParams.Ensure = "Absent"
        $expectedGetResults = $null
        
        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Remove Test Certificate 1" -ExpectedGetResults $expectedGetResults        
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
