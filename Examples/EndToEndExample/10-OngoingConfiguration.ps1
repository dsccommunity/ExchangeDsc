Configuration OngoingConfiguration
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

        ###Mailbox Server settings###
        $dbMap = DBMapFromServersCsv -ServersCsvPath $Node.ServersCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements
        $primaryDbList = DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $Node.MailboxDatabasesCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements
        $copyDbList = DBListFromMailboxDatabaseCopiesCsv -MailboxDatabaseCopiesCsvPath $Node.MailboxDatabaseCopiesCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements

        #Create all mount points on the server
        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $dbMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }

        #Create primary databases
        foreach ($DB in $primaryDbList)
        {
            $resourceId = "MDB:$($DB.Name)" #Need to define a unique ID for each database

            xExchMailboxDatabase $resourceId 
            {
                Name                            = $DB.Name
                Credential                      = $ShellCreds
                EdbFilePath                     = $DB.DBFilePath
                LogFolderPath                   = $DB.LogFolderPath
                Server                          = $Node.NodeName
                CircularLoggingEnabled          = $true
                DatabaseCopyCount               = $dagSettings.AutoDagDatabaseCopiesPerVolume
                OfflineAddressBook              = $casSettingsPerSite.DefaultOAB
                SkipInitialDatabaseMount        = $true

                DependsOn                       = '[xExchAutoMountPoint]AMP' #Can't create databases until the mount points exist
            }
        }

        #Configure the copies
        foreach ($DB in $copyDbList)
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
                Identity                        = $DB.Name
                Credential                      = $ShellCreds
                MailboxServer                   = $Node.NodeName
                ActivationPreference            = $DB.ActivationPreference
                #ReplayLagTime                   = $DB.ReplayLagTime #Note that ReplayLagTime is being excluded for the ongoing configuration so that it's easier to disable lags, if necessary
                AllowServiceRestart             = $false
                
                DependsOn                       = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }

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
            ManualDagNetworkConfiguration        = $false
            ReplayLagManagerEnabled              = $true
            SkipDagValidation                    = $true
            WitnessDirectory                     = 'C:\FSW'
            WitnessServer                        = $dagSettings.WitnessServer
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

if ($FileCopyCreds -eq $null)
{
    $FileCopyCreds = Get-Credential -Message 'Enter credentials for copying files from the file server'
}

###Compiles the example
OngoingConfiguration -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1 -ShellCreds $ShellCreds -CertCreds $CertCreds -FileCopyCreds $FileCopyCreds

###Pushes configuration to specified computer
#Start-DscConfiguration -Path .\OngoingConfiguration -Verbose -Wait -ComputerName XXX