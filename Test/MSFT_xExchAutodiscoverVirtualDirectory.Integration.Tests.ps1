###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchAutodiscoverVirtualDirectory\MSFT_xExchAutodiscoverVirtualDirectory.psm1
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

    if ($null -eq $Global:ServerFqdn)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe "Test Setting Properties with xExchAutodiscoverVirtualDirectory" {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExtendedProtectionFlags = @("AllowDotlessspn","NoServicenameCheck")
            ExtendedProtectionSPNList = @("http/mail.fabrikam.com","http/mail.fabrikam.local","http/wxweqc")
            ExtendedProtectionTokenChecking = "Allow"
            OAuthAuthentication = $true
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExtendedProtectionTokenChecking = "Allow"
            OAuthAuthentication = $true
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set standard parameters" -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionFlags -GetResultParameterName "ExtendedProtectionFlags" -ContextLabel "Verify ExtendedProtectionFlags" -ItLabel "ExtendedProtectionSPNList should contain three values"
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionSPNList -GetResultParameterName "ExtendedProtectionSPNList" -ContextLabel "Verify ExtendedProtectionSPNList" -ItLabel "ExtendedProtectionSPNList should contain three values"

        Context "Test missing ExtendedProtectionFlags for ExtendedProtectionSPNList" {
            $caughtException = $false
            $testParams.ExtendedProtectionFlags = @("NoServicenameCheck")
            try
            {
                $SetResults = Set-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It "Should hit exception for missing ExtendedProtectionFlags AllowDotlessSPN" {
                $caughtException | Should Be $true
            }

            It "Test results should be true after adding missing ExtendedProtectionFlags" {
                $testParams.ExtendedProtectionFlags = @("AllowDotlessSPN")
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should Be $true
            }
        }

        Context "Test invalid combination in ExtendedProtectionFlags" {
            $caughtException = $false
            $testParams.ExtendedProtectionFlags = @("NoServicenameCheck","None")
            try
            {
                $SetResults = Set-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It "Should hit exception for invalid combination ExtendedProtectionFlags" {
                $caughtException | Should Be $true
            }

            It "Test results should be true after correction of ExtendedProtectionFlags" {
                $testParams.ExtendedProtectionFlags = @("AllowDotlessSPN")
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should Be $true
            }
        }

        $testParams.BasicAuthentication = $false
        $testParams.DigestAuthentication = $true
        $testParams.OAuthAuthentication = $true
        $testParams.ExtendedProtectionFlags = 'None'
        $testParams.ExtendedProtectionSPNList = $null
        $testParams.ExtendedProtectionTokenChecking = 'None'
        $testParams.WindowsAuthentication = $false
        $testParams.WSSecurityAuthentication = $true
        $expectedGetResults.BasicAuthentication = $false
        $expectedGetResults.DigestAuthentication = $true
        $expectedGetResults.ExtendedProtectionFlags = $null
        $expectedGetResults.ExtendedProtectionSPNList = $null
        $expectedGetResults.ExtendedProtectionTokenChecking = 'None'
        $expectedGetResults.OAuthAuthentication = $true
        $expectedGetResults.WindowsAuthentication = $false
        $expectedGetResults.WSSecurityAuthentication = $true

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Change some parameters" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
