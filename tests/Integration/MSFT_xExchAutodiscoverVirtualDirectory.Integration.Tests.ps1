<#
    .SYNOPSIS
        Automated unit integration for MSFT_xExchAutodiscoverVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchAutodiscoverVirtualDirectory'
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

    if ($null -eq $serverFqdn)
    {
        $serverFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe 'Test Setting Properties with xExchAutodiscoverVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            Credential = $shellCredentials
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExtendedProtectionFlags = @('AllowDotlessspn', 'NoServicenameCheck')
            ExtendedProtectionSPNList = @('http/mail.fabrikam.com', 'http/mail.fabrikam.local', 'http/wxweqc')
            ExtendedProtectionTokenChecking = 'Allow'
            OAuthAuthentication = $true
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Autodiscover (Default Web Site)"
            BasicAuthentication = $true
            DigestAuthentication = $false
            ExtendedProtectionTokenChecking = 'Allow'
            OAuthAuthentication = $true
            WindowsAuthentication = $true
            WSSecurityAuthentication = $true
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set standard parameters' `
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExtendedProtectionFlags `
                                -GetResultParameterName 'ExtendedProtectionFlags' `
                                -ContextLabel 'Verify ExtendedProtectionFlags' `
                                -ItLabel 'ExtendedProtectionSPNList should contain three values'

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExtendedProtectionSPNList `
                                -GetResultParameterName 'ExtendedProtectionSPNList' `
                                -ContextLabel 'Verify ExtendedProtectionSPNList' `
                                -ItLabel 'ExtendedProtectionSPNList should contain three values'

        Context 'Test missing ExtendedProtectionFlags for ExtendedProtectionSPNList' {
            $testParams.ExtendedProtectionFlags = @('NoServicenameCheck')

            It 'Should hit exception for missing ExtendedProtectionFlags AllowDotlessSPN' {
                { Set-TargetResource @testParams } | Should -Throw
            }

            It 'Test results should be true after adding missing ExtendedProtectionFlags' {
                $testParams.ExtendedProtectionFlags = @('AllowDotlessSPN')
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should -Be $true
            }
        }

        Context 'Test invalid combination in ExtendedProtectionFlags' {
            $testParams.ExtendedProtectionFlags = @('NoServicenameCheck', 'None')

            It 'Should hit exception for invalid combination ExtendedProtectionFlags' {
                { Set-TargetResource @testParams } | Should -Throw
            }

            It 'Test results should be true after correction of ExtendedProtectionFlags' {
                $testParams.ExtendedProtectionFlags = @('AllowDotlessSPN')
                Set-TargetResource @testParams
                $testResults = Test-TargetResource @testParams
                $testResults | Should -Be $true
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

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Change some parameters' `
                                         -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose 'Tests in this file require that Exchange is installed to be run.'
}

