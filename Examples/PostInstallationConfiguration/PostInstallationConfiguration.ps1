Configuration PostInstallationConfiguration
{
    param
    (
        [PSCredential]$ShellCreds,
        [PSCredential]$CertCreds
    )

    Import-DscResource -Module xExchange

    #This script shows examples of how to utilize most resources in the xExchange module.
    #Where possible, configuration settings have been entered directly into this script.
    #That was done for all settings which will be common for every server being configured.
    #Settings which may be different, like for DAG's, CAS in different sites, or for individual
    #servers, are defined in EndToEndExample-Config.psd1.


    #This first section only configures a single DAG node, the first member of the DAG.
    #The first member of the DAG will be responsible for DAG creation and maintaining its configuration
    Node $AllNodes.Where{$_.Role -eq 'FirstDAGMember'}.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Look up and retrieve the DAG settings for this node

        #Create the DAG
        xExchDatabaseAvailabilityGroup DAG
        {
            Name                                 = $dagSettings.DAGName
            Credential                           = $ShellCreds
            AutoDagTotalNumberOfServers          = $dagSettings.AutoDagTotalNumberOfServers
            AutoDagDatabaseCopiesPerVolume       = $dagSettings.AutoDagDatabaseCopiesPerVolume
            AutoDagDatabasesRootFolderPath       = 'C:\ExchangeDatabases'            AutoDagVolumesRootFolderPath         = 'C:\ExchangeVolumes'
            DatacenterActivationMode             = "DagOnly"
            DatabaseAvailabilityGroupIPAddresses = $dagSettings.DatabaseAvailabilityGroupIPAddresses 
            ManualDagNetworkConfiguration        = $dagSettings.ManualDagNetworkConfiguration
            ReplayLagManagerEnabled              = $dagSettings.ReplayLagManagerEnabled 
            SkipDagValidation                    = $true
            WitnessDirectory                     = 'C:\FSW'
            WitnessServer                        = $dagSettings.WitnessServer
        }

        #Add this server as member
        xExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $dagSettings.DAGName
            SkipDagValidation = $true

            DependsOn         = '[xExchDatabaseAvailabilityGroup]DAG'
        }

        #Create two new DAG Networks
        xExchDatabaseAvailabilityGroupNetwork DAGNet1
        {
            Name                      = $dagSettings.DAGNet1NetworkName
            Credential                = $ShellCreds
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Present'
            ReplicationEnabled        = $dagSettings.DAGNet1ReplicationEnabled
            Subnets                   = $dagSettings.DAGNet1Subnets

            DependsOn                 = '[xExchDatabaseAvailabilityGroupMember]DAGMember' #Can't do work on DAG networks until at least one member is in the DAG...
        }

        xExchDatabaseAvailabilityGroupNetwork DAGNet2
        {
            Name                      = $dagSettings.DAGNet2NetworkName
            Credential                = $ShellCreds
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Present'
            ReplicationEnabled        = $dagSettings.DAGNet2ReplicationEnabled
            Subnets                   = $dagSettings.DAGNet2Subnets
            
            DependsOn                 = '[xExchDatabaseAvailabilityGroupMember]DAGMember' #Can't do work on DAG networks until at least one member is in the DAG...
        }

        #Remove the original DAG Network
        xExchDatabaseAvailabilityGroupNetwork DAGNetOld
        {
            Name                      = $dagSettings.OldNetworkName
            Credential                = $ShellCreds
            DatabaseAvailabilityGroup = $dagSettings.DAGName
            Ensure                    = 'Absent'

            DependsOn                 = '[xExchDatabaseAvailabilityGroupNetwork]DAGNet1','[xExchDatabaseAvailabilityGroupNetwork]DAGNet2' #Dont remove the old one until the new one is in place
        }
    }


    #Next we'll add the remaining nodes to the DAG
    Node $AllNodes.Where{$_.Role -eq 'AdditionalDAGMember'}.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Look up and retrieve the DAG settings for this node

        #Can't join until the DAG exists...
        xExchWaitForDAG WaitForDAG
        {
            Identity   = $dagSettings.DAGName
            Credential = $ShellCreds
        }

        xExchDatabaseAvailabilityGroupMember DAGMember
        {
            MailboxServer     = $Node.NodeName
            Credential        = $ShellCreds
            DAGName           = $dagSettings.DAGName
            SkipDagValidation = $true

            DependsOn         = '[xExchWaitForDAG]WaitForDAG'
        }
    }


    #This section will handle configuring all non-DAG specific settings, including CAS and MBX settings.
    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Look up and retrieve the DAG settings for this node
        $casSettings = $ConfigurationData[$Node.CASId] #Look up and retrieve the CAS settings for this node

        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }

        ###General server settings###
        #This section licenses the server
        xExchExchangeServer EXServer
        {
            Identity            = $Node.NodeName
            Credential          = $ShellCreds
            ProductKey          = '12345-12345-12345-12345-12345'
            AllowServiceRestart = $true
        }

        #This imports a certificate .PFX that had been previously exported, and enabled services on it
        xExchExchangeCertificate Certificate
        {
            Thumbprint         = $dagSettings.Thumbprint
            Credential         = $ShellCreds
            Ensure             = 'Present'
            AllowExtraServices = $dagSettings.AllowExtraServices        
            CertCreds          = $CertCreds
            CertFilePath       = $dagSettings.CertFilePath
            Services           = $dagSettings.Services
        }


        ###CAS specific settings###
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ShellCreds
            AutoDiscoverServiceInternalUri = "https://$($casSettings.InternalNLBFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettings.AutoDiscoverSiteScope
        }

        #Install features that are required for xExchActiveSyncVirtualDirectory to do Auto Certification Based Authentication
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

        #This example shows how to enable Certificate Based Authentication for ActiveSync
        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity                    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential                  = $ShellCreds
            AutoCertBasedAuth           = $true
            AutoCertBasedAuthThumbprint = $dagSettings.Thumbprint
            BasicAuthEnabled            = $false
            ClientCertAuth              = 'Required'
            ExternalUrl                 = "https://$($casSettings.ExternalNLBFqdn)/Microsoft-Server-ActiveSync"  
            InternalUrl                 = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"  
            WindowsAuthEnabled          = $false
            AllowServiceRestart         = $true
            
            DependsOn                   = '[WindowsFeature]WebClientAuth','[WindowsFeature]WebCertAuth','[xExchExchangeCertificate]Certificate' #Can't configure CBA until we have a valid cert, and have required features
        }

        #Ensures forms based auth and configures URLs
        xExchEcpVirtualDirectory ECPVDir
        {
            Identity                      = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential                    = $ShellCreds
            BasicAuthentication           = $true
            ExternalAuthenticationMethods = 'Fba'
            ExternalUrl                   = "https://$($casSettings.ExternalNLBFqdn)/ecp"
            FormsAuthentication           = $true
            InternalUrl                   = "https://$($casSettings.InternalNLBFqdn)/ecp"           
            WindowsAuthentication         = $false
            AllowServiceRestart           = $true
        }

        #Configure URL's and for NTLM and negotiate auth
        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ShellCreds
            ExternalUrl              = "https://$($casSettings.ExternalNLBFqdn)/mapi"
            IISAuthenticationMethods = 'NTLM','Negotiate'
            InternalUrl              = "https://$($casSettings.InternalNLBFqdn)/mapi" 
            AllowServiceRestart      = $true
        }

        #Configure URL's and add any OABs this vdir should distribute
        xExchOabVirtualDirectory OABVdir
        {
            Identity            = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential          = $ShellCreds
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/oab"
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/oab"     
            OABsToDistribute    = $casSettings.OABsToDistribute
            AllowServiceRestart = $true
        }

        #Configure URL's and auth settings
        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ShellCreds
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSSL          = $true
            ExternalHostName                   = $casSettings.ExternalNLBFqdn
            IISAuthenticationMethods           = 'Ntlm'
            InternalClientAuthenticationMethod = 'Ntlm'
            InternalClientsRequireSSL          = $true
            InternalHostName                   = $casSettings.InternalNLBFqdn
            AllowServiceRestart                = $true
        }

        #Ensures forms based auth and configures URLs and IM integration
        xExchOwaVirtualDirectory OWAVdir
        {
            Identity                              = "$($Node.NodeName)\owa (Default Web Site)"
            Credential                            = $ShellCreds
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
            
            DependsOn                             = '[xExchExchangeCertificate]Certificate' #Can't configure the IM cert until it's valid
        }

        #Turn on Windows Integrated auth for remote powershell connections
        xExchPowerShellVirtualDirectory PSVdir
        {
            Identity              = "$($Node.NodeName)\PowerShell (Default Web Site)"
            Credential            = $ShellCreds
            WindowsAuthentication = $true
            AllowServiceRestart   = $true
        }

        #Configure URL's
        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity            = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential          = $ShellCreds
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/ews/exchange.asmx" 
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/ews/exchange.asmx"
            AllowServiceRestart = $true         
        }


        ###Transport specific settings###
        #Create a custom receive connector which could be used to receive SMTP mail from internal non-Exchange mail servers
        xExchReceiveConnector CustomConnector1
        {
            Identity         = "$($Node.NodeName)\Internal SMTP Servers to $($Node.NodeName)"
            Credential       = $ShellCreds
            Ensure           = 'Present'
            AuthMechanism    = 'Tls','ExternalAuthoritative'
            Bindings         = '0.0.0.0:25'
            MaxMessageSize   = '25MB'
            PermissionGroups = 'AnonymousUsers','ExchangeServers'
            RemoteIPRanges   = '192.168.1.101','192.168.1.102'
            TransportRole    = 'FrontendTransport'
            Usage            = 'Custom'
        }

        #Ensures that Exchange built in AntiMalware Scanning is enabled or disabled
        xExchAntiMalwareScanning AMS
        {
            Enabled    = $true
            Credential = $ShellCreds
        }

        
        ###Mailbox Server settings###
        #Create database and volume mount points for AutoReseed
        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $Node.DiskToDBMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }

        #Create primary databases
        foreach ($DB in $Node.PrimaryDBList.Values)
        {
            $resourceId = "MDB:$($DB.Name)" #Need to define a unique ID for each database

            xExchMailboxDatabase $resourceId 
            {
                Name                     = $DB.Name
                Credential               = $ShellCreds
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

                DependsOn                = '[xExchAutoMountPoint]AMP' #Can"t create databases until the mount points exist
            }
        }

        #Create the copies
        foreach ($DB in $Node.CopyDBList.Values)
        {
            $waitResourceId = "WaitForDB:$($DB.Name)" #Unique ID for the xWaitForMailboxDatabase resource
            $copyResourceId = "MDBCopy:$($DB.Name)" #Unique ID for the xMailboxDatabaseCopy resource 

            #Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ShellCreds                
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity             = $DB.Name
                Credential           = $ShellCreds
                MailboxServer        = $Node.NodeName
                ActivationPreference = $DB.ActivationPreference
                ReplayLagTime        = $DB.ReplayLagTime
                AllowServiceRestart  = $true
                
                DependsOn            = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

if ($CertCreds -eq $null)
{
    $CertCreds = Get-Credential -Message 'Enter credentials for importing the Exchange certificate'
}

###Compiles the example
PostInstallationConfiguration -ConfigurationData $PSScriptRoot\PostInstallationConfiguration-Config.psd1 -ShellCreds $ShellCreds -CertCreds $CertCreds

###Sets up LCM on target computers to decrypt credentials.
Set-DscLocalConfigurationManager -Path .\PostInstallationConfiguration -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\PostInstallationConfiguration -Verbose -Wait 
