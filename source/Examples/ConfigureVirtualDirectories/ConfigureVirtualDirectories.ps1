<#
.EXAMPLE
    This example shows how to configure virtual directories.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
        },

        # Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            CASID    = 'Site1CAS'
        }

        @{
            NodeName = 'e15-2'
            CASID    = 'Site2CAS'
        }
    );

    # CAS settings that are unique per site will go in separate hash table entries.
    Site1CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site1.contoso.local'
            ExternalNLBFqdn            = 'mail.contoso.local'

            # ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site1', 'Site3', 'Site5'

            # OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site1'
        }
    );

    Site2CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site2.contoso.local'
            ExternalNLBFqdn            = 'mail.contoso.local'

            # ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site2', 'Site4', 'Site6'

            # OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site2'
        }
    );
}

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        $casSettings = $ConfigurationData[$Node.CASId] # Look up and retrieve the CAS settings for this node

        ###CAS specific settings###
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ExchangeAdminCredential
            AutoDiscoverServiceInternalUri = "https://$($casSettings.InternalNLBFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettings.AutoDiscoverSiteScope
        }

        # Install features that are required for xExchActiveSyncVirtualDirectory to do Auto Certification Based Authentication
        WindowsFeature WebClientAuth
        {
            Name   = 'Web-Client-Auth'
            Ensure = 'Present'
        }

        WindowsFeature WebCertAuth
        {
            Name   = 'Web-Cert-Auth'
            Ensure = 'Present'
        }

        # This example shows how to enable Certificate Based Authentication for ActiveSync
        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity                    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential                  = $ExchangeAdminCredential
            AutoCertBasedAuth           = $true
            AutoCertBasedAuthThumbprint = '49bef4b2e82599233154465323ebf96a12b60673'
            BasicAuthEnabled            = $false
            ClientCertAuth              = 'Required'
            ExternalUrl                 = "https://$($casSettings.ExternalNLBFqdn)/Microsoft-Server-ActiveSync"
            InternalUrl                 = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"
            WindowsAuthEnabled          = $false
            AllowServiceRestart         = $true

            DependsOn                   = '[WindowsFeature]WebClientAuth', '[WindowsFeature]WebCertAuth'
            # NOTE: If CBA is being configured, this should also be dependent on the cert whose thumbprint is being used. See EndToEndExample.
        }

        # Ensures forms based auth and configures URLs
        xExchEcpVirtualDirectory ECPVDir
        {
            Identity                      = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential                    = $ExchangeAdminCredential
            BasicAuthentication           = $true
            ExternalAuthenticationMethods = 'Fba'
            ExternalUrl                   = "https://$($casSettings.ExternalNLBFqdn)/ecp"
            FormsAuthentication           = $true
            InternalUrl                   = "https://$($casSettings.InternalNLBFqdn)/ecp"
            WindowsAuthentication         = $false
            AllowServiceRestart           = $true
        }

        # Configure URL's and for NTLM and negotiate auth
        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ExchangeAdminCredential
            ExternalUrl              = "https://$($casSettings.ExternalNLBFqdn)/mapi"
            IISAuthenticationMethods = 'NTLM', 'Negotiate'
            InternalUrl              = "https://$($casSettings.InternalNLBFqdn)/mapi"
            AllowServiceRestart      = $true
        }

        # Configure URL's and add any OABs this vdir should distribute
        xExchOabVirtualDirectory OABVdir
        {
            Identity            = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential          = $ExchangeAdminCredential
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/oab"
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/oab"
            OABsToDistribute    = $casSettings.OABsToDistribute
            AllowServiceRestart = $true
        }

        # Configure URL's and auth settings
        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ExchangeAdminCredential
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSSL          = $true
            ExternalHostName                   = $casSettings.ExternalNLBFqdn
            IISAuthenticationMethods           = 'Ntlm'
            InternalClientAuthenticationMethod = 'Ntlm'
            InternalClientsRequireSSL          = $true
            InternalHostName                   = $casSettings.InternalNLBFqdn
            AllowServiceRestart                = $true
        }

        # Ensures forms based auth and configures URLs and IM integration
        xExchOwaVirtualDirectory OWAVdir
        {
            Identity                              = "$($Node.NodeName)\owa (Default Web Site)"
            Credential                            = $ExchangeAdminCredential
            BasicAuthentication                   = $true
            ExternalAuthenticationMethods         = 'Fba'
            ExternalUrl                           = "https://$($casSettings.ExternalNLBFqdn)/owa"
            FormsAuthentication                   = $true
            InternalUrl                           = "https://$($casSettings.InternalNLBFqdn)/owa"
            WindowsAuthentication                 = $false
            AllowServiceRestart                   = $true
        }

        # Turn on Windows Integrated auth for remote powershell connections
        xExchPowerShellVirtualDirectory PSVdir
        {
            Identity              = "$($Node.NodeName)\PowerShell (Default Web Site)"
            Credential            = $ExchangeAdminCredential
            WindowsAuthentication = $true
            AllowServiceRestart   = $true
        }

        # Configure URL's
        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity            = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential          = $ExchangeAdminCredential
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/ews/exchange.asmx"
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/ews/exchange.asmx"
            AllowServiceRestart = $true
        }
    }
}
