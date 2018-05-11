<#
.EXAMPLE
    This example shows how to configure single Namespaces.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'

            <#
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                This is added so that AppVeyor automatic tests can pass, otherwise
                the tests will fail on passwords being in plain text and not being
                encrypted. Because it is not possible to have a certificate in
                AppVeyor to encrypt the passwords we need to add the parameter
                'PSDscAllowPlainTextPassword'.
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                See:
                http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
            #>
            PSDscAllowPlainTextPassword = $true
        },

        #Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            CASID    = 'Site1CAS'
        }

        @{
            NodeName = 'e15-2'
            CASID    = 'Site2CAS'
        }
    )

    #Individual target nodes are defined next
    @{
        NodeName = 'e15-1'
    }

    @{
        NodeName = 'e15-2'
    }
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
            AutoDiscoverServiceInternalUri = 'https://mail.mikelab.local/autodiscover/autodiscover.xml'
            AutoDiscoverSiteScope          = 'Site1','Site2'
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.mikelab.local/Microsoft-Server-ActiveSync'  
            InternalUrl = 'https://mail.mikelab.local/Microsoft-Server-ActiveSync'  
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.mikelab.local/ecp'
            InternalUrl = 'https://mail.mikelab.local/ecp'
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ExchangeAdminCredential
            ExternalUrl              = 'https://mail.mikelab.local/mapi'
            InternalUrl              = 'https://mail.mikelab.local/mapi'
            IISAuthenticationMethods = 'NTLM','Negotiate'  #IISAuthenticationMethods is a required parameter for Set-MapiVirtualDirectory
            AllowServiceRestart      = $true               #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.mikelab.local/oab'
            InternalUrl = 'https://mail.mikelab.local/oab'     
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ExchangeAdminCredential
            ExternalHostName                   = 'mail.mikelab.local'
            ExternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientsRequireSsl          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            InternalHostName                   = 'mail.mikelab.local'
            InternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientsRequireSSL          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            AllowServiceRestart                = $true  #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOwaVirtualDirectory OWAVdir
        {
            Identity    = "$($Node.NodeName)\owa (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.mikelab.local/owa'
            InternalUrl = 'https://mail.mikelab.local/owa'    
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity    = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = 'https://mail.mikelab.local/ews/exchange.asmx' 
            InternalUrl = 'https://mail.mikelab.local/ews/exchange.asmx'      
        }
    }
}
