Configuration RegionalNamespaces
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        $casSettings = $ConfigurationData[$Node.CASId] #Look up and retrieve the CAS settings for this node

        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
        
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ShellCreds
            AutoDiscoverServiceInternalUri = "https://$($casSettings.InternalNLBFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettings.AutoDiscoverSiteScope
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettings.ExternalNLBFqdn)/Microsoft-Server-ActiveSync"  
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"  
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettings.ExternalNLBFqdn)/ecp"
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/ecp"           
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ShellCreds
            ExternalUrl              = "https://$($casSettings.ExternalNLBFqdn)/mapi"
            InternalUrl              = "https://$($casSettings.InternalNLBFqdn)/mapi"
            IISAuthenticationMethods = "NTLM","Negotiate"  #IISAuthenticationMethods is a required parameter for Set-MapiVirtualDirectory
            AllowServiceRestart      = $true               #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettings.ExternalNLBFqdn)/oab"
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/oab"     
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ShellCreds
            ExternalHostName                   = $casSettings.ExternalNLBFqdn
            ExternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            ExternalClientsRequireSsl          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if ExternalHostName is specified
            InternalHostName                   = $casSettings.InternalNLBFqdn
            InternalClientAuthenticationMethod = 'Ntlm' #ExternalClientAuthenticationMethod is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            InternalClientsRequireSSL          = $true  #ExternalClientsRequireSsl is a required parameter for Set-OutlookAnywhere if InternalHostName is specified
            AllowServiceRestart                = $true  #Since we are changing the default auth method, we allow the app pool to be restarted right away so the change goes into effect immediately
        }

        xExchOwaVirtualDirectory OWAVdir
        {
            Identity    = "$($Node.NodeName)\owa (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettings.ExternalNLBFqdn)/owa"
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/owa"    
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity    = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettings.ExternalNLBFqdn)/ews/exchange.asmx" 
            InternalUrl = "https://$($casSettings.InternalNLBFqdn)/ews/exchange.asmx"    
        }
    }
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
RegionalNamespaces -ConfigurationData $PSScriptRoot\RegionalNamespaces-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
#Set-DscLocalConfigurationManager -Path .\RegionalNamespaces -Verbose

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\RegionalNamespaces -Verbose -Wait 