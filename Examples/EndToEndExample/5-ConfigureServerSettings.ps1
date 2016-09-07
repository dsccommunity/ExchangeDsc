Configuration ConfigureServerSettings
{
    param
    (
        [PSCredential]$ShellCreds,
        [PSCredential]$CertCreds,
        [PSCredential]$FileCopyCreds
    )

    #Import required DSC Modules
    Import-DscResource -Module xExchange
    Import-DscResource -Module xWebAdministration


    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Get DAG settings for this node

        $casSettingsAll = $ConfigurationData.AllCAS #Get CAS settings for all sites
        $casSettingsPerSite = $ConfigurationData[$Node.CASId] #Get site specific CAS settings for this node


        #Copy an certificate .PFX that had been previously exported, import it, and enable services on it
        File CopyExchangeCert
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Certificates\ExchangeCert.pfx"
            DestinationPath = 'C:\Binaries\Certificates\ExchangeCert.pfx'
            Credential      = $FileCopyCreds
        }
       
        xExchExchangeCertificate Certificate
        {
            Thumbprint         = $dagSettings.Thumbprint
            Credential         = $ShellCreds
            Ensure             = 'Present'
            AllowExtraServices = $true        
            CertCreds          = $CertCreds
            CertFilePath       = 'C:\Binaries\Certificates\ExchangeCert.pfx'
            Services           = 'IIS','POP','IMAP','SMTP'

            DependsOn          = '[File]CopyExchangeCert'
        }


        ###CAS specific settings###
        #The following section shows how to configure commonly configured URL's on various virtual directories
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ShellCreds
            AutoDiscoverServiceInternalUri = "https://$($casSettingsPerSite.InternalNamespace)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettingsPerSite.AutoDiscoverSiteScope
        }

        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/Microsoft-Server-ActiveSync"  
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/Microsoft-Server-ActiveSync"  
        }

        xExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/ecp"  
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/ecp"    
        }

        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ShellCreds
            ExternalUrl              = "https://$($casSettingsAll.ExternalNamespace)/mapi"
            InternalUrl              = "https://$($casSettingsPerSite.InternalNamespace)/mapi"
            IISAuthenticationMethods = 'Ntlm','OAuth','Negotiate'
        }

        xExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ShellCreds
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/oab"
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/oab"  
        }

        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ShellCreds
            ExternalClientAuthenticationMethod = 'Negotiate'
            ExternalClientsRequireSSL          = $true
            ExternalHostName                   = $casSettingsAll.ExternalNamespace
            IISAuthenticationMethods           = 'Basic', 'Ntlm', 'Negotiate'
            InternalClientAuthenticationMethod = 'Ntlm'
            InternalClientsRequireSSL          = $true
            InternalHostName                   = $casSettingsPerSite.InternalNamespace
        }

        #Configure OWA Lync Integration in the web.config
        xWebConfigKeyValue OWAIMCertificateThumbprint
        {
            WebsitePath   = "IIS:\Sites\Exchange Back End\owa"
            ConfigSection = "AppSettings"
            Ensure        = "Present"
            Key           = "IMCertificateThumbprint"
            Value         = $dagSettings.Thumbprint
        }

        xWebConfigKeyValue OWAIMServerName
        {
            WebsitePath   = "IIS:\Sites\Exchange Back End\owa"
            ConfigSection = "AppSettings"
            Ensure        = "Present"
            Key           = "IMServerName"
            Value         = $casSettingsPerSite.InstantMessagingServerName
        }

        #Sets OWA url's, and enables Lync integration on the OWA front end directory
        xExchOwaVirtualDirectory OWAVdir
        {
            Identity                              = "$($Node.NodeName)\owa (Default Web Site)"
            Credential                            = $ShellCreds
            ExternalUrl                           = "https://$($casSettingsAll.ExternalNamespace)/owa"  
            InternalUrl                           = "https://$($casSettingsPerSite.InternalNamespace)/owa"   
            InstantMessagingEnabled               = $true
            InstantMessagingCertificateThumbprint = $dagSettings.Thumbprint
            InstantMessagingServerName            = $casSettingsPerSite.InstantMessagingServerName
            InstantMessagingType                  = 'Ocs'
            
            DependsOn                             = '[xExchExchangeCertificate]Certificate' #Can't configure the IM cert until it's valid
        }

        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity             = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential           = $ShellCreds
            ExternalUrl          = "https://$($casSettingsAll.ExternalNamespace)/ews/exchange.asmx"
            InternalNLBBypassUrl = "https://$($Node.Fqdn)/ews/exchange.asmx"
            InternalUrl          = "https://$($casSettingsPerSite.InternalNamespace)/ews/exchange.asmx"
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

if ($null -eq $CertCreds)
{
    $CertCreds = Get-Credential -Message 'Enter credentials for importing the Exchange certificate'
}

if ($null -eq $FileCopyCreds)
{
    $FileCopyCreds = Get-Credential -Message 'Enter credentials for copying files from the file server'
}

###Compiles the example
ConfigureServerSettings -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1 -ShellCreds $ShellCreds -CertCreds $CertCreds -FileCopyCreds $FileCopyCreds

###Pushes configuration to specified computer
#Start-DscConfiguration -Path .\ConfigureServerSettings -Verbose -Wait -ComputerName XXX
