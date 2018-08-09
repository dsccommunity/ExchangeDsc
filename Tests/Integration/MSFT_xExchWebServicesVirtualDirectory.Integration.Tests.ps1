<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchWebServicesVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchWebServicesVirtualDirectory'
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

    Describe 'Test Setting Properties with xExchWebServicesVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\EWS (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            CertificateAuthentication = $false
            DigestAuthentication = $false
            ExtendedProtectionFlags = @('AllowDotlessSPN','NoServicenameCheck')
            ExtendedProtectionSPNList = @('http/mail.fabrikam.com','http/mail.fabrikam.local','http/wxweqc')
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            GzipLevel = 'High'
            InternalNLBBypassUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            OAuthAuthentication = $false
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        $expectedGetResults = @{
            BasicAuthentication = $false
            CertificateAuthentication = $false
            DigestAuthentication = $false
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            GzipLevel = 'High'
            InternalNLBBypassUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            InternalUrl = "http://$($Global:ServerFqdn)/ews/exchange.asmx"
            OAuthAuthentication = $false
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set standard parameters' -ExpectedGetResults $expectedGetResults
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionFlags -GetResultParameterName 'ExtendedProtectionFlags' -ContextLabel 'Verify ExtendedProtectionFlags' -ItLabel 'ExtendedProtectionSPNList should contain three values'
        Test-ArrayContentsEqual -TestParams $testParams -DesiredArrayContents $testParams.ExtendedProtectionSPNList -GetResultParameterName 'ExtendedProtectionSPNList' -ContextLabel 'Verify ExtendedProtectionSPNList' -ItLabel 'ExtendedProtectionSPNList should contain three values'

        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = ''
        $expectedGetResults.InternalUrl = ''

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Try with empty URLs' -ExpectedGetResults $expectedGetResults

        Context 'Test missing ExtendedProtectionFlags for ExtendedProtectionSPNList' {
            $caughtException = $false
            $testParams.ExtendedProtectionFlags = @('NoServicenameCheck')
            try
            {
                $SetResults = Set-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It 'Should hit exception for missing ExtendedProtectionFlags AllowDotlessSPN' {
                $caughtException | Should Be $true
            }

            It 'Test results should be true after adding missing ExtendedProtectionFlags' {
                $testParams.ExtendedProtectionFlags = @('AllowDotlessSPN')
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should Be $true
            }
        }

        Context 'Test invalid combination in ExtendedProtectionFlags' {
            $caughtException = $false
            $testParams.ExtendedProtectionFlags = @('NoServicenameCheck','None')
            try
            {
                $SetResults = Set-TargetResource @testParams
            }
            catch
            {
                $caughtException = $true
            }

            It 'Should hit exception for invalid combination ExtendedProtectionFlags' {
                $caughtException | Should Be $true
            }

            It 'Test results should be true after correction of ExtendedProtectionFlags' {
                $testParams.ExtendedProtectionFlags = @('AllowDotlessSPN')
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should Be $true
            }
        }

        #Set Authentication values back to default
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\EWS (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            DigestAuthentication = $false
            ExtendedProtectionFlags = 'None'
            ExtendedProtectionSPNList = $null
            ExtendedProtectionTokenChecking = 'None'
            GzipLevel = 'Low'
            OAuthAuthentication = $true                       
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true          
        }

        $expectedGetResults = @{
            BasicAuthentication = $false
            DigestAuthentication = $false
            ExtendedProtectionFlags = [System.String[]]@()
            ExtendedProtectionSPNList = [System.String[]]@()
            ExtendedProtectionTokenChecking = 'None'
            GzipLevel = 'Low'
            OAuthAuthentication = $true
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Reset to default' -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
