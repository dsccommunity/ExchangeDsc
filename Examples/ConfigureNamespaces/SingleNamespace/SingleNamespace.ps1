<#
.EXAMPLE
    This example shows how to configure single Namespaces.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
        },

        # Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
        }

        @{
            NodeName = 'e15-2'
        }
    )
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
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ExchangeAdminCredential
            AutoDiscoverServiceInternalUri = 'https://mail.contoso.local/autodiscover/autodiscover.xml'
            AutoDiscoverSiteScope          = 'Site1', 'Site2'
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.contoso.local/Microsoft-Server-ActiveSync'
            InternalUrl = 'https://mail.contoso.local/Microsoft-Server-ActiveSync'
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.contoso.local/ecp'
            InternalUrl = 'https://mail.contoso.local/ecp'
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ExchangeAdminCredential
            ExternalUrl              = 'https://mail.contoso.local/mapi'
            InternalUrl              = 'https://mail.contoso.local/mapi'
            IISAuthenticationMethods = 'NTLM', 'Negotiate'  # IISAuthenticationMethods is a required parameter for Set-MapiVirtualDirectory
            AllowServiceRestart      = $true               # Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.contoso.local/oab'
            InternalUrl = 'https://mail.contoso.local/oab'
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ExchangeAdminCredential
            ExternalHostName                   = 'mail.contoso.local'
            ExternalClientAuthenticationMethod = 'Ntlm' # ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientsRequireSsl          = $true  # ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            InternalHostName                   = 'mail.contoso.local'
            InternalClientAuthenticationMethod = 'Ntlm' # ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientsRequireSSL          = $true  # ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            AllowServiceRestart                = $true  # Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOwaVirtualDirectory OWAVdir
        {
            Identity    = "$($Node.NodeName)\owa (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.contoso.local/owa'
            InternalUrl = 'https://mail.contoso.local/owa'
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity    = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.contoso.local/ews/exchange.asmx'
            InternalUrl = 'https://mail.contoso.local/ews/exchange.asmx'
        }
    }
}
