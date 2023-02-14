<#
.EXAMPLE
    This example shows how to configure server settings.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            #region Common Settings for All Nodes
            NodeName        = '*'

            <#
                The location of the exported public certificate which will be used to encrypt
                credentials during compilation.
                CertificateFile = 'C:\public-certificate.cer'
            #>

            # Thumbprint of the certificate being used for decrypting credentials
            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673'

            # The base file server UNC path that will be used for copying things like certificates, Exchange binaries, and Jetstress binaries
            FileServerBase = '\\rras-1.contoso.local\Binaries'

            #endregion
        }

        #region Individual Node Settings
        #region DAG01 Nodes
        @{
            NodeName        = 'e15-1'
            Fqdn            = 'e15-1.contoso.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site1CAS'
            ServerNameInCsv = 'e15-1'
        }

        @{
            NodeName        = 'e15-2'
            Fqdn            = 'e15-2.contoso.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site1CAS'
            ServerNameInCsv = 'e15-2'
        }

        @{
            NodeName        = 'e15-3'
            Fqdn            = 'e15-3.contoso.local'
            Role            = 'FirstDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site2CAS'
            ServerNameInCsv = 'e15-3'
        }

        @{
            NodeName        = 'e15-4'
            Fqdn            = 'e15-4.contoso.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site2CAS'
            ServerNameInCsv = 'e15-4'
        }
        #endregion
    );

    #region DAG Settings
    DAG01 = @(
        @{
            DAGName                              = 'DAG01'
            AutoDagTotalNumberOfServers          = 12
            AutoDagDatabaseCopiesPerVolume       = 4
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.31', '192.168.2.31'
            WitnessServer                        = 'e14-1.contoso.local'
            DbNameReplacements                   = @{"nn" = "01"}
            Thumbprint                           = "0079D0F68F44C7DA5252B4779F872F46DFAF0CBC"
        }
    )
    #endregion

    #region CAS Settings
    # Settings that will apply to all CAS
    AllCAS = @(
        @{
            ExternalNamespace = 'mail.contoso.local'
        }
    )

    # Settings that will apply only to Quincy CAS
    Site1CAS = @(
        @{
            InternalNamespace          = 'mail-site1.contoso.local'
            AutoDiscoverSiteScope      = 'Site1'
            InstantMessagingServerName = 'l15-1.contoso.local'
            DefaultOAB                 = "Default Offline Address Book (Site1)"
        }
    );

    # Settings that will apply only to Phoenix CAS
    Site2CAS = @(
        @{
            InternalNamespace          = 'mail-site2.contoso.local'
            AutoDiscoverSiteScope      = 'Site2'
            InstantMessagingServerName = 'l15-2.contoso.local'
            DefaultOAB                 = "Default Offline Address Book (Site2)"
        }
    );
    #endregion
}

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $ExchangeAdminCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $ExchangeCertCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $ExchangeFileCopyCredential
    )

    # Import required DSC Modules
    Import-DscResource -Module ExchangeDsc
    Import-DscResource -Module xWebAdministration

    Node $AllNodes.NodeName
    {
        $dagSettings        = $ConfigurationData[$Node.DAGId] # Get DAG settings for this node
        $casSettingsAll     = $ConfigurationData.AllCAS # Get CAS settings for all sites
        $casSettingsPerSite = $ConfigurationData[$Node.CASId] # Get site specific CAS settings for this node

        # Copy an certificate .PFX that had been previously exported, import it, and enable services on it
        File CopyExchangeCert
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Certificates\ExchangeCert.pfx"
            DestinationPath = 'C:\Binaries\Certificates\ExchangeCert.pfx'
            Credential      = $ExchangeFileCopyCredential
        }

        ExchExchangeCertificate Certificate
        {
            Thumbprint              = $dagSettings.Thumbprint
            Credential              = $ExchangeAdminCredential
            Ensure                  = 'Present'
            AllowExtraServices      = $true
            CertCreds               = $ExchangeCertCredential
            CertFilePath            = 'C:\Binaries\Certificates\ExchangeCert.pfx'
            Services                = 'IIS', 'POP', 'IMAP', 'SMTP'
            DependsOn               = '[File]CopyExchangeCert'
        }

        ###CAS specific settings###
        # The following section shows how to configure commonly configured URL's on various virtual directories
        ExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ExchangeAdminCredential
            AutoDiscoverServiceInternalUri = "https://$($casSettingsPerSite.InternalNamespace)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettingsPerSite.AutoDiscoverSiteScope
        }

        ExchActiveSyncVirtualDirectory ASVdir
        {
            Identity    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/Microsoft-Server-ActiveSync"
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/Microsoft-Server-ActiveSync"
        }

        ExchEcpVirtualDirectory ECPVDir
        {
            Identity    = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/ecp"
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/ecp"
        }

        ExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ExchangeAdminCredential
            ExternalUrl              = "https://$($casSettingsAll.ExternalNamespace)/mapi"
            InternalUrl              = "https://$($casSettingsPerSite.InternalNamespace)/mapi"
            IISAuthenticationMethods = 'Ntlm', 'OAuth', 'Negotiate'
        }

        ExchOabVirtualDirectory OABVdir
        {
            Identity    = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential  = $ExchangeAdminCredential
            ExternalUrl = "https://$($casSettingsAll.ExternalNamespace)/oab"
            InternalUrl = "https://$($casSettingsPerSite.InternalNamespace)/oab"
        }

        ExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ExchangeAdminCredential
            ExternalClientAuthenticationMethod = 'Negotiate'
            ExternalClientsRequireSSL          = $true
            ExternalHostName                   = $casSettingsAll.ExternalNamespace
            IISAuthenticationMethods           = 'Basic', 'Ntlm', 'Negotiate'
            InternalClientAuthenticationMethod = 'Ntlm'
            InternalClientsRequireSSL          = $true
            InternalHostName                   = $casSettingsPerSite.InternalNamespace
        }

        # Configure OWA Lync Integration in the web.config
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

        # Sets OWA url's, and enables Lync integration on the OWA front end directory
        ExchOwaVirtualDirectory OWAVdir
        {
            Identity                              = "$($Node.NodeName)\owa (Default Web Site)"
            Credential                            = $ExchangeAdminCredential
            ExternalUrl                           = "https://$($casSettingsAll.ExternalNamespace)/owa"
            InternalUrl                           = "https://$($casSettingsPerSite.InternalNamespace)/owa"
            InstantMessagingEnabled               = $true
            InstantMessagingCertificateThumbprint = $dagSettings.Thumbprint
            InstantMessagingServerName            = $casSettingsPerSite.InstantMessagingServerName
            InstantMessagingType                  = 'Ocs'
            DependsOn                             = '[ExchExchangeCertificate]Certificate' # Can't configure the IM cert until it's valid
        }

        ExchWebServicesVirtualDirectory EWSVdir
        {
            Identity             = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential           = $ExchangeAdminCredential
            ExternalUrl          = "https://$($casSettingsAll.ExternalNamespace)/ews/exchange.asmx"
            InternalNLBBypassUrl = "https://$($Node.Fqdn)/ews/exchange.asmx"
            InternalUrl          = "https://$($casSettingsPerSite.InternalNamespace)/ews/exchange.asmx"
        }
    }
}
