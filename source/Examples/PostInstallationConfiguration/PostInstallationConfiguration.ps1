<#
.EXAMPLE
    This example shows how to configure exchange after installation.
    This script shows examples of how to utilize most resources in the xExchange module.
    Where possible, configuration settings have been entered directly into this script.
    That was done for all settings which will be common for every server being configured.
    Settings which may be different, like for DAG's, CAS in different sites, or for individual
    servers, are defined in EndToEndExample-Config.psd1.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = '*'

            <#
                The location of the exported public certificate which will be used to encrypt
                credentials during compilation.
                CertificateFile = 'C:\public-certificate.cer'
            #>

            # Thumbprint of the certificate being used for decrypting credentials
            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673'
        }

        # Individual target nodes are defined next
        @{
            NodeName      = 'e15-1'
            Fqdn          = 'e15-1.contoso.local'
            Role          = 'FirstDAGMember'
            DAGId         = 'DAG1' # Used to determine which DAG settings the servers should use. Corresponds to DAG1 hashtable entry below.
            CASId         = 'Site1CAS' # Used to determine which CAS settings the server should use. Corresponds to Site1CAS hashtable entry below.

            # DB's that should be on the same disk must be in the same string, and comma separated. In this example, DB1 and DB2 will go on one disk, and DB3 and DB4 will go on another
            DiskToDBMap   = 'DB1,DB2', 'DB3,DB4'

            # Configure the databases whose primary copies will reside on this server
            PrimaryDBList = @{
                DB1 = @{Name = 'DB1'; EdbFilePath = 'C:\ExchangeDatabases\DB1\DB1.db\DB1.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB1\DB1.log'};
                DB3 = @{Name = 'DB3'; EdbFilePath = 'C:\ExchangeDatabases\DB3\DB3.db\DB3.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB3\DB3.log'}
            }

            # Configure the copies next.
            CopyDBList    = @{
                DB2 = @{Name = 'DB2'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB4 = @{Name = 'DB4'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
        }

        @{
            NodeName      = 'e15-2'
            Fqdn          = 'e15-2.contoso.local'
            Role          = 'AdditionalDAGMember'
            DAGId         = 'DAG1'
            CASID         = 'Site1CAS'

            DiskToDBMap   = 'DB1,DB2', 'DB3,DB4'

            PrimaryDBList = @{
                DB2 = @{Name = 'DB2'; EdbFilePath = 'C:\ExchangeDatabases\DB2\DB2.db\DB2.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB2\DB2.log'};
                DB4 = @{Name = 'DB4'; EdbFilePath = 'C:\ExchangeDatabases\DB4\DB4.db\DB4.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB4\DB4.log'}
            }

            CopyDBList    = @{
                DB1 = @{Name = 'DB1'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB3 = @{Name = 'DB3'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
        }
    );

    # Settings that are unique per DAG will go in separate hash table entries.
    DAG1 = @(
        @{
            ###DAG Settings###
            DAGName                              = 'TestDAG1'
            AutoDagTotalNumberOfServers          = 4
            AutoDagDatabaseCopiesPerVolume       = 2
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.99', '192.168.2.99'
            ManualDagNetworkConfiguration        = $true
            ReplayLagManagerEnabled              = $true
            SkipDagValidation                    = $true
            WitnessServer                        = 'e14-1.contoso.local'

            # xDatabaseAvailabilityGroupNetwork params
            # New network params
            DAGNet1NetworkName                   = 'MapiNetwork'
            DAGNet1ReplicationEnabled            = $false
            DAGNet1Subnets                       = '192.168.1.0/24', '192.168.2.0/24'

            DAGNet2NetworkName                   = 'ReplNetwork'
            DAGNet2ReplicationEnabled            = $true
            DAGNet2Subnets                       = '10.10.10.0/24', '10.10.11.0/24'

            # Old network to remove
            OldNetworkName                       = 'MapiDagNetwork'

            # Certificate Settings
            Thumbprint                           = '7D959B3A37E45978445F8EC8F01D200D00C3141F'
            CertFilePath                         = 'c:\certexport1.pfx'
            Services                             = 'IIS', 'POP', 'IMAP', 'SMTP'
        }
    );

    # CAS settings that are unique per site will go in separate hash table entries as well.
    Site1CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site1.contoso.local'
            ExternalNLBFqdn            = 'mail.contoso.local'

            # ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site1'

            # OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site1'

            # OWA Settings
            InstantMessagingServerName = 'lync-site1.contoso.local'
        }
    );

    Site2CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site2.contoso.local'
            ExternalNLBFqdn            = 'mail.contoso.local'

            # ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site2'

            # OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site2'

            # OWA Settings
            InstantMessagingServerName = 'lync-site2.contoso.local'
        }
    );
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
        $ExchangeCertCredential
    )

    Import-DscResource -Module xExchange

    # This first section only configures a single DAG node, the first member of the DAG.
    # The first member of the DAG will be responsible for DAG creation and maintaining its configuration
    Node $AllNodes.Where{$_.Role -eq 'FirstDAGMember'}.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] # Look up and retrieve the DAG settings for this node

        # Create the DAG
        xExchDatabaseAvailabilityGroup DAG
        {
            Name                                 = $dagSettings.DAGName
            Credential                           = $ExchangeAdminCredential
            AutoDagTotalNumberOfServers          = $dagSettings.AutoDagTotalNumberOfServers
            AutoDagDatabaseCopiesPerVolume       = $dagSettings.AutoDagDatabaseCopiesPerVolume
            AutoDagDatabasesRootFolderPath       = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath         = 'C:\ExchangeVolumes'
            DatacenterActivationMode             = 'DagOnly'
            DatabaseAvailabilityGroupIPAddresses = $dagSettings.DatabaseAvailabilityGroupIPAddresses
            ManualDagNetworkConfiguration        = $dagSettings.ManualDagNetworkConfiguration
            ReplayLagManagerEnabled              = $dagSettings.ReplayLagManagerEnabled
            SkipDagValidation                    = $true
            WitnessDirectory                     = 'C:\FSW'
            WitnessServer                        = $dagSettings.WitnessServer
        }

        # Add this server as member
        xExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ExchangeAdminCredential
            DAGName           = $dagSettings.DAGName
            SkipDagValidation = $true
            DependsOn         = '[xExchDatabaseAvailabilityGroup]DAG'
        }

        # Create two new DAG Networks
        xExchDatabaseAvailabilityGroupNetwork DAGNet1
        {
            Name                      = $dagSettings.DAGNet1NetworkName
            Credential                = $ExchangeAdminCredential
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Present'
            ReplicationEnabled        = $dagSettings.DAGNet1ReplicationEnabled
            Subnets                   = $dagSettings.DAGNet1Subnets
            DependsOn                 = '[xExchDatabaseAvailabilityGroupMember]DAGMember' # Can't do work on DAG networks until at least one member is in the DAG...
        }

        xExchDatabaseAvailabilityGroupNetwork DAGNet2
        {
            Name                      = $dagSettings.DAGNet2NetworkName
            Credential                = $ExchangeAdminCredential
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Present'
            ReplicationEnabled        = $dagSettings.DAGNet2ReplicationEnabled
            Subnets                   = $dagSettings.DAGNet2Subnets
            DependsOn                 = '[xExchDatabaseAvailabilityGroupMember]DAGMember' # Can't do work on DAG networks until at least one member is in the DAG...
        }

        # Remove the original DAG Network
        xExchDatabaseAvailabilityGroupNetwork DAGNetOld
        {
            Name                      = $dagSettings.OldNetworkName
            Credential                = $ExchangeAdminCredential
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Absent'
            DependsOn                 = '[xExchDatabaseAvailabilityGroupNetwork]DAGNet1', '[xExchDatabaseAvailabilityGroupNetwork]DAGNet2' # Dont remove the old one until the new one is in place
        }
    }


    # Next we'll add the remaining nodes to the DAG
    Node $AllNodes.Where{$_.Role -eq 'AdditionalDAGMember'}.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] # Look up and retrieve the DAG settings for this node

        # Can't join until the DAG exists...
        xExchWaitForDAG WaitForDAG
        {
            Identity   = $dagSettings.DAGName
            Credential = $ExchangeAdminCredential
        }

        xExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ExchangeAdminCredential
            DAGName           = $dagSettings.DAGName
            SkipDagValidation = $true
            DependsOn         = '[xExchWaitForDAG]WaitForDAG'
        }
    }

    # This section will handle configuring all non-DAG specific settings, including CAS and MBX settings.
    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] # Look up and retrieve the DAG settings for this node
        $casSettings = $ConfigurationData[$Node.CASId] # Look up and retrieve the CAS settings for this node

        # Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }

        ###General server settings###
        # This section licenses the server
        xExchExchangeServer EXServer
        {
            Identity            = $Node.NodeName
            Credential          = $ExchangeAdminCredential
            ProductKey          = '12345-12345-12345-12345-12345'
            AllowServiceRestart = $true
        }

        # This imports a certificate .PFX that had been previously exported, and enabled services on it
        xExchExchangeCertificate Certificate
        {
            Thumbprint          = $dagSettings.Thumbprint
            Credential          = $ExchangeAdminCredential
            Ensure              = 'Present'
            AllowExtraServices  = $false
            CertCreds           = $ExchangeCertCredential
            CertFilePath        = $dagSettings.CertFilePath
            Services            = $dagSettings.Services
        }

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
            AutoCertBasedAuthThumbprint = $dagSettings.Thumbprint
            BasicAuthEnabled            = $false
            ClientCertAuth              = 'Required'
            ExternalUrl                 = "https://$($casSettings.ExternalNLBFqdn)/Microsoft-Server-ActiveSync"
            InternalUrl                 = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"
            WindowsAuthEnabled          = $false
            AllowServiceRestart         = $true
            DependsOn                   = '[WindowsFeature]WebClientAuth', '[WindowsFeature]WebCertAuth', '[xExchExchangeCertificate]Certificate' # Can't configure CBA until we have a valid cert, and have required features
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
            InstantMessagingEnabled               = $true
            InstantMessagingCertificateThumbprint = $dagSettings.Thumbprint
            InstantMessagingServerName            = $casSettings.InstantMessagingServerName
            InstantMessagingType                  = 'Ocs'
            InternalUrl                           = "https://$($casSettings.InternalNLBFqdn)/owa"
            WindowsAuthentication                 = $false
            AllowServiceRestart                   = $true
            DependsOn                             = '[xExchExchangeCertificate]Certificate' # Can't configure the IM cert until it's valid
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

        ###Transport specific settings###
        # Create a custom receive connector which could be used to receive SMTP mail from internal non-Exchange mail servers
        xExchReceiveConnector CustomConnector1
        {
            Identity             = "$($Node.NodeName)\Internal SMTP Servers to $($Node.NodeName)"
            Credential           = $ExchangeAdminCredential
            Ensure               = 'Present'
            AuthMechanism        = 'Tls', 'ExternalAuthoritative'
            Bindings             = '0.0.0.0:25'
            MaxMessageSize       = '25MB'
            PermissionGroups     = 'AnonymousUsers', 'ExchangeServers'
            RemoteIPRanges       = '192.168.1.101', '192.168.1.102'
            ProtocolLoggingLevel = 'Verbose'
            TransportRole        = 'FrontendTransport'
            Usage                = 'Custom'
        }

        # Ensures that Exchange built in AntiMalware Scanning is enabled or disabled
        xExchAntiMalwareScanning AMS
        {
            Enabled    = $true
            Credential = $ExchangeAdminCredential
        }

        #Ensure that the Receive Protocol logs are enabled for the Frontend Transport service and that they are kept for an adequate length of time.
        xExchFrontendTransportService FrontendTransportService
        {
            Credential                         = $ExchangeAdminCredential
            Identity                           = $Node.NodeName
            AllowServiceRestart                = $true
            ReceiveProtocolLogMaxAge           = (New-TimeSpan -Days 60).ToString()
            ReceiveProtocolLogMaxDirectorySize = '2GB'
        }

        ###Mailbox Server settings###
        # Create database and volume mount points for AutoReseed
        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $Node.DiskToDBMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }

        # Create primary databases
        foreach ($DB in $Node.PrimaryDBList.Values)
        {
            # Need to define a unique ID for each database
            $resourceId = "MDB_$($DB.Name)"

            xExchMailboxDatabase $resourceId
            {
                Name                     = $DB.Name
                Credential               = $ExchangeAdminCredential
                EdbFilePath              = $DB.EdbFilePath
                LogFolderPath            = $DB.LogFolderPath
                Server                   = $Node.NodeName
                CircularLoggingEnabled   = $true
                DatabaseCopyCount        = 4
                DeletedItemRetention     = '7.00:00:00'
                IssueWarningQuota        = '5120MB'
                ProhibitSendQuota        = '5300MB'
                ProhibitSendReceiveQuota = '5500MB'
                AllowServiceRestart      = $true
                DependsOn                = '[xExchAutoMountPoint]AMP' # Can"t create databases until the mount points exist
            }
        }

        # Create the copies
        foreach ($DB in $Node.CopyDBList.Values)
        {
            # Unique ID for the xWaitForMailboxDatabase resource
            $waitResourceId = "WaitForDB_$($DB.Name)"

            # Unique ID for the xMailboxDatabaseCopy resource
            $copyResourceId = "MDBCopy_$($DB.Name)"

            # Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ExchangeAdminCredential
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity             = $DB.Name
                Credential           = $ExchangeAdminCredential
                MailboxServer        = $Node.NodeName
                ActivationPreference = $DB.ActivationPreference
                ReplayLagTime        = $DB.ReplayLagTime
                AllowServiceRestart  = $true
                DependsOn            = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }
}
