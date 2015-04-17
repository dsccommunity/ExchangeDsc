Configuration SingleNamespace
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
        
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ShellCreds
            AutoDiscoverServiceInternalUri = "https://mail.mikelab.local/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = "Site1","Site2"
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://mail.mikelab.local/Microsoft-Server-ActiveSync"  
            InternalUrl = "https://mail.mikelab.local/Microsoft-Server-ActiveSync"  
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://mail.mikelab.local/ecp"
            InternalUrl = "https://mail.mikelab.local/ecp"
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ShellCreds
            ExternalUrl              = "https://mail.mikelab.local/mapi"
            InternalUrl              = "https://mail.mikelab.local/mapi"
            IISAuthenticationMethods = "NTLM","Negotiate"  #IISAuthenticationMethods is a required parameter for Set-MapiVirtualDirectory
            AllowServiceRestart      = $true               #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://mail.mikelab.local/oab"
            InternalUrl = "https://mail.mikelab.local/oab"     
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ShellCreds
            ExternalHostName                   = "mail.mikelab.local"
            ExternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientsRequireSsl          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            InternalHostName                   = "mail.mikelab.local"
            InternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientsRequireSSL          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            AllowServiceRestart                = $true  #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOwaVirtualDirectory OWAVdir
        {
            Identity    = "$($Node.NodeName)\owa (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://mail.mikelab.local/owa"
            InternalUrl = "https://mail.mikelab.local/owa"    
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity    = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://mail.mikelab.local/ews/exchange.asmx" 
            InternalUrl = "https://mail.mikelab.local/ews/exchange.asmx"      
        }
    }
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
SingleNamespace -ConfigurationData $PSScriptRoot\SingleNamespace-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
#Set-DscLocalConfigurationManager -Path .\SingleNamespace -Verbose

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\SingleNamespace -Verbose -Wait 