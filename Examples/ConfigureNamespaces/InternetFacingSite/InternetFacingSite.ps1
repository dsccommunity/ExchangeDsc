<#
.EXAMPLE
    This example shows how to configure Internet facing Site.
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
            ExternalUrlActiveSync   = 'https://mail.contoso.local/Microsoft-Server-ActiveSync'
            ExternalUrlECP          = 'https://mail.contoso.local/ecp'
            ExternalUrlMAPI         = 'https://mail.contoso.local/mapi'
            ExternalUrlOAB          = 'https://mail.contoso.local/oab'
            ExternalUrlOA           = 'mail.contoso.local'
            ExternalUrlOWA          = 'https://mail.contoso.local/owa'
            ExternalUrlEWS          = 'https://mail.contoso.local/ews/exchange.asmx'
            InternalNLBFqdn         = 'mail-site1.contoso.local'
            AutoDiscoverSiteScope   = 'Site1'
        }
    );

    Site2CAS = @(
        @{
            ExternalUrlActiveSync   = ''
            ExternalUrlECP          = ''
            ExternalUrlMAPI         = ''
            ExternalUrlOAB          = ''
            ExternalUrlOA           = ''
            ExternalUrlOWA          = ''
            ExternalUrlEWS          = ''
            InternalNLBFqdn         = 'mail-site2.contoso.local'
            AutoDiscoverSiteScope   = 'Site2'
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
        # Look up and retrieve the CAS settings for this node
        $casSettings = $ConfigurationData[$Node.CASId]

        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ExchangeAdminCredential
            AutoDiscoverServiceInternalUri = "https://$($casSettings.InternalNLBFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettings.AutoDiscoverSiteScope
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = $casSettings.ExternalUrlActiveSync
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = $casSettings.ExternalUrlECP
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/ecp"
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ExchangeAdminCredential
            ExternalUrl              = $casSettings.ExternalUrlMAPI
            InternalUrl              = "https://$($casSettings.InternalNLBFqdn)/mapi"
            # IISAuthenticationMethods is a required parameter for Set-MapiVirtualDirectory
            IISAuthenticationMethods = 'NTLM', 'Negotiate'
            # Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
            AllowServiceRestart      = $true
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = $casSettings.ExternalUrlOAB
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/oab"
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ExchangeAdminCredential
            ExternalHostName                   = $casSettings.ExternalUrlOA
            # ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientAuthenticationMethod = 'Ntlm'
            # ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientsRequireSsl          = $true
            InternalHostName                   = $casSettings.InternalNLBFqdn
            # ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientAuthenticationMethod = 'Ntlm'
            # ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientsRequireSSL          = $true
            # Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
            AllowServiceRestart                = $true
        }

        xExchOwaVirtualDirectory OWAVdir
        {
            Identity    = "$($Node.NodeName)\owa (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = $casSettings.ExternalUrlOWA
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/owa"
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity    = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = $casSettings.ExternalUrlEWS
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/ews/exchange.asmx"
        }
    }
}
