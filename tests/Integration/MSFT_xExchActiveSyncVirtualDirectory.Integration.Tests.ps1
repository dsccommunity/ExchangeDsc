<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchActiveSyncVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchActiveSyncVirtualDirectory'
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

    # Get the Server FQDN for using in URL's
    if ($null -eq $serverFqdn)
    {
        $serverFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    if ($null -eq $webCertAuthInstalled)
    {
        $webCertAuth = Get-WindowsFeature -Name Web-Cert-Auth

        if ($webCertAuth.InstallState -ne 'Installed')
        {
            $webCertAuthInstalled = $false
            Write-Verbose -Message 'Web-Cert-Auth is not installed. Skipping certificate based authentication tests.'
        }
        else
        {
            $webCertAuthInstalled = $true
        }
    }

    if ($webCertAuthInstalled -eq $true)
    {
        # Get the thumbprint to use for ActiveSync Cert Based Auth
        if ($null -eq $cbaCertThumbprint)
        {
            $cbaCertThumbprint = Read-Host -Prompt 'Enter the thumbprint of an Exchange certificate to use when enabling Certificate Based Authentication'
        }
    }

    Describe 'Test Setting Properties with xExchActiveSyncVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential = $shellCredentials
            AutoCertBasedAuth = $false
            AutoCertBasedAuthThumbprint = ''
            BadItemReportingEnabled = $false
            BasicAuthEnabled = $true
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $true
            ExtendedProtectionFlags = @('AllowDotlessspn', 'NoServicenameCheck')
            ExtendedProtectionSPNList = @('http/mail.fabrikam.com', 'http/mail.fabrikam.local', 'http/wxweqc')
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalAuthenticationMethods = @('Basic', 'Kerberos')
            ExternalUrl = "https://$($serverFqdn)/Microsoft-Server-ActiveSync"
            InstallIsapiFilter = $true
            InternalAuthenticationMethods = @('Basic', 'Kerberos')
            InternalUrl = "https://$($serverFqdn)/Microsoft-Server-ActiveSync"
            MobileClientCertificateAuthorityURL = 'http://whatever.com/CA'
            MobileClientCertificateProvisioningEnabled = $true
            MobileClientCertTemplateName = 'MyTemplateforEAS'
            # Name = "$($Node.NodeName) EAS Site"
            RemoteDocumentsActionForUnknownServers = 'Block'
            RemoteDocumentsAllowedServers = @('AllowedA', 'AllowedB')
            RemoteDocumentsBlockedServers = @('BlockedA', 'BlockedB')
            RemoteDocumentsInternalDomainSuffixList = @('InternalA', 'InternalB')
            SendWatsonReport = $false
            WindowsAuthEnabled = $false
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            BadItemReportingEnabled = $false
            BasicAuthEnabled = $true
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $true
            ExtendedProtectionTokenChecking = 'Allow'
            ExternalUrl = "https://$($serverFqdn)/Microsoft-Server-ActiveSync"
            InternalAuthenticationMethods = @('Basic', 'Kerberos')
            InternalUrl = "https://$($serverFqdn)/Microsoft-Server-ActiveSync"
            MobileClientCertificateAuthorityURL = 'http://whatever.com/CA'
            MobileClientCertificateProvisioningEnabled = $true
            MobileClientCertTemplateName = 'MyTemplateforEAS'
            # Name = "$($Node.NodeName) EAS Site"
            RemoteDocumentsActionForUnknownServers = 'Block'
            SendWatsonReport = $false
            WindowsAuthEnabled = $false
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

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.ExternalAuthenticationMethods `
                                -GetResultParameterName 'ExternalAuthenticationMethods' `
                                -ContextLabel 'Verify ExternalAuthenticationMethods' `
                                -ItLabel 'ExternalAuthenticationMethods should contain two values'

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.InternalAuthenticationMethods `
                                -GetResultParameterName 'InternalAuthenticationMethods' `
                                -ContextLabel 'Verify InternalAuthenticationMethods' `
                                -ItLabel 'InternalAuthenticationMethods should contain two values'

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.RemoteDocumentsAllowedServers `
                                -GetResultParameterName 'RemoteDocumentsAllowedServers' `
                                -ContextLabel 'Verify RemoteDocumentsAllowedServers' `
                                -ItLabel 'RemoteDocumentsAllowedServers should contain two values'

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.RemoteDocumentsBlockedServers `
                                -GetResultParameterName 'RemoteDocumentsBlockedServers' `
                                -ContextLabel 'Verify RemoteDocumentsBlockedServers' `
                                -ItLabel 'RemoteDocumentsBlockedServers should contain two values'

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.RemoteDocumentsInternalDomainSuffixList `
                                -GetResultParameterName 'RemoteDocumentsInternalDomainSuffixList' `
                                -ContextLabel 'Verify RemoteDocumentsInternalDomainSuffixList' `
                                -ItLabel 'RemoteDocumentsInternalDomainSuffixList should contain two values'

        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = ''
        $expectedGetResults.InternalUrl = ''

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Try with empty URLs' `
                                         -ExpectedGetResults $expectedGetResults

        if ($webCertAuthInstalled -eq $true)
        {
            $testParams.AutoCertBasedAuth = $true
            $testParams.AutoCertBasedAuthThumbprint = $cbaCertThumbprint
            $testParams.ClientCertAuth = 'Required'
            $expectedGetResults.ClientCertAuth = 'Required'

            Test-TargetResourceFunctionality -Params $testParams `
                                             -ContextLabel 'Try enabling certificate based authentication' `
                                             -ExpectedGetResults $expectedGetResults
        }

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

        $testParams.ActiveSyncServer = "https://eas.$($env:USERDNSDOMAIN)/Microsoft-Server-ActiveSync"
        $testParams.Remove('ExternalUrl')
        $expectedGetResults.ActiveSyncServer = "https://eas.$($env:USERDNSDOMAIN)/Microsoft-Server-ActiveSync"
        $expectedGetResults.ExternalUrl = "https://eas.$($env:USERDNSDOMAIN)/Microsoft-Server-ActiveSync"

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Try by setting External URL via ActiveSyncServer' `
                                         -ExpectedGetResults $expectedGetResults

        # Set values back to default
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential = $shellCredentials
            BadItemReportingEnabled = $true
            BasicAuthEnabled = $false
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $false
            ExtendedProtectionFlags = 'None'
            ExtendedProtectionSPNList = $null
            ExtendedProtectionTokenChecking = 'None'
            ExternalAuthenticationMethods = $null
            InternalAuthenticationMethods = $null
            MobileClientCertificateAuthorityURL = $null
            MobileClientCertificateProvisioningEnabled = $false
            MobileClientCertTemplateName = $null
            RemoteDocumentsActionForUnknownServers = 'Allow'
            RemoteDocumentsAllowedServers = $null
            RemoteDocumentsBlockedServers = $null
            RemoteDocumentsInternalDomainSuffixList = $null
            SendWatsonReport = $true
            WindowsAuthEnabled = $true
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\Microsoft-Server-ActiveSync (Default Web Site)"
            BadItemReportingEnabled = $true
            BasicAuthEnabled = $false
            ClientCertAuth = 'Ignore'
            CompressionEnabled = $false
            ExtendedProtectionTokenChecking = 'None'
            ExtendedProtectionFlags = [System.String[]] @()
            ExtendedProtectionSPNList = [System.String[]] @()
            ExternalAuthenticationMethods = [System.String[]] @()
            InternalAuthenticationMethods = [System.String[]] @()
            MobileClientCertificateAuthorityURL = ''
            MobileClientCertificateProvisioningEnabled = $false
            MobileClientCertTemplateName = ''
            RemoteDocumentsActionForUnknownServers = 'Allow'
            RemoteDocumentsAllowedServers = $null
            RemoteDocumentsBlockedServers = $null
            RemoteDocumentsInternalDomainSuffixList = $null
            SendWatsonReport = $true
            WindowsAuthEnabled = $true
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Reset values to default' `
                                         -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
