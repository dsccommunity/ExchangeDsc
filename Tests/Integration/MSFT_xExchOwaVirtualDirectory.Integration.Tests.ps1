<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchOwaVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchOwaVirtualDirectory'
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

    #Get the thumbprint to use for Lync integration
    if ($null -eq $Global:IMCertThumbprint)
    {
        $Global:IMCertThumbprint = Read-Host -Prompt 'Enter the thumbprint of an Exchange certificate to use when enabling Lync integration'
    }

    Describe 'Test Setting Properties with xExchOwaVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            Credential = $Global:ShellCredentials
            #AdfsAuthentication = $false #Don't test AdfsAuthentication changes in dedicated OWA tests, as they have to be done to ECP at the same time
            BasicAuthentication = $true
            ChangePasswordEnabled = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/owa"
            FormsAuthentication = $true
            InstantMessagingEnabled = $false
            InstantMessagingCertificateThumbprint = ''
            InstantMessagingServerName = ''
            InstantMessagingType = 'None'
            InternalUrl = "https://$($Global:ServerFqdn)/owa"     
            LogonPagePublicPrivateSelectionEnabled = $true
            LogonPageLightSelectionEnabled = $true   
            WindowsAuthentication = $false
            LogonFormat = 'PrincipalName'
            DefaultDomain = 'contoso.local'      
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            BasicAuthentication = $true
            ChangePasswordEnabled = $true
            DigestAuthentication = $false
            ExternalUrl = "https://$($Global:ServerFqdn)/owa"
            FormsAuthentication = $true
            InstantMessagingEnabled = $false
            InstantMessagingCertificateThumbprint = ''
            InstantMessagingServerName = ''
            InstantMessagingType = 'None'
            InternalUrl = "https://$($Global:ServerFqdn)/owa"     
            LogonPagePublicPrivateSelectionEnabled = $true
            LogonPageLightSelectionEnabled = $true   
            WindowsAuthentication = $false
            LogonFormat = 'PrincipalName'
            DefaultDomain = 'contoso.local' 
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set standard parameters' -ExpectedGetResults $expectedGetResults


        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            ChangePasswordEnabled = $false
            DigestAuthentication = $true
            ExternalUrl = ''
            FormsAuthentication = $false
            InstantMessagingEnabled = $true
            InstantMessagingCertificateThumbprint = $Global:IMCertThumbprint
            InstantMessagingServerName = $env:COMPUTERNAME
            InstantMessagingType = 'Ocs'
            InternalUrl = ''   
            LogonPagePublicPrivateSelectionEnabled = $false
            LogonPageLightSelectionEnabled = $false   
            WindowsAuthentication = $true 
            LogonFormat = 'FullDomain'
            DefaultDomain = ''      
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            BasicAuthentication = $false
            ChangePasswordEnabled = $false
            DigestAuthentication = $true
            ExternalUrl = ''
            FormsAuthentication = $false
            InstantMessagingEnabled = $true
            InstantMessagingCertificateThumbprint = $Global:IMCertThumbprint
            InstantMessagingServerName = $env:COMPUTERNAME
            InstantMessagingType = 'Ocs'
            InternalUrl = ''
            LogonPagePublicPrivateSelectionEnabled = $false
            LogonPageLightSelectionEnabled = $false   
            WindowsAuthentication = $true
            LogonFormat = 'FullDomain'
            DefaultDomain = ''    
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Try with the opposite of each property value' -ExpectedGetResults $expectedGetResults


        #Set Authentication values back to default
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $true
            DigestAuthentication = $false
            FormsAuthentication = $true                      
            WindowsAuthentication = $false        
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\owa (Default Web Site)"
            BasicAuthentication = $true
            DigestAuthentication = $false
            FormsAuthentication = $true                      
            WindowsAuthentication = $false   
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Reset authentication to default' -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
