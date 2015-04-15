@{
    AllNodes = @(
        #Settings under 'NodeName = *' apply to all nodes.
        @{
            NodeName        = '*'

            #CertificateFile and Thumbprint are used for securing credentials. See:
            #http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
                        #The location on the compiling machine of the public key export of the certfificate which will be used to encrypt credentials            CertificateFile = 'C:\publickey.cer'             #Thumbprint of the certificate being used for encrypting credentials            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673' 
        }

        #Individual target nodes are defined next
        @{
            NodeName      = 'e15-1'
            Fqdn          = 'e15-1.mikelab.local'
            Role          = 'FirstDAGMember'
            DAGId         = 'DAG1' #Used to determine which DAG settings the servers should use. Corresponds to DAG1 hashtable entry below.
            CASId         = 'Site1CAS' #Used to determine which CAS settings the server should use. Corresponds to Site1CAS hashtable entry below.

            #DB's that should be on the same disk must be in the same string, and comma separated. In this example, DB1 and DB2 will go on one disk, and DB3 and DB4 will go on another
            DiskToDBMap   = 'DB1,DB2','DB3,DB4'

            #Configure the databases whose primary copies will reside on this server
            PrimaryDBList = @{
                DB1 = @{Name = 'DB1'; EdbFilePath = 'C:\ExchangeDatabases\DB1\DB1.db\DB1.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB1\DB1.log'};
                DB3 = @{Name = 'DB3'; EdbFilePath = 'C:\ExchangeDatabases\DB3\DB3.db\DB3.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB3\DB3.log'}
            }

            #Configure the copies next.
            CopyDBList    = @{
                DB2 = @{Name = 'DB2'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB4 = @{Name = 'DB4'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
        }

        @{
            NodeName      = 'e15-2'
            Fqdn          = 'e15-2.mikelab.local'
            Role          = 'AdditionalDAGMember'
            DAGId         = 'DAG1'
            CASID         = 'Site1CAS'

            DiskToDBMap   = 'DB1,DB2','DB3,DB4'

            PrimaryDBList = @{
                DB2 = @{Name = 'DB2'; EdbFilePath = 'C:\ExchangeDatabases\DB2\DB2.db\DB2.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB2\DB2.log'};
                DB4 = @{Name = 'DB4'; EdbFilePath = 'C:\ExchangeDatabases\DB4\DB4.db\DB4.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB4\DB4.log'}
            }

            CopyDBList    = @{
                DB1 = @{Name = 'DB1'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB3 = @{Name = 'DB3'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
        }

        @{
            NodeName    = 'e15-3'
            Fqdn        = 'e15-3.mikelab.local'
            Role        = 'AdditionalDAGMember'
            DAGId       = 'DAG1'
            CASID       = 'Site2CAS'

            DiskToDBMap = 'DB1,DB2','DB3,DB4'

            CopyDBList  = @{
                DB1 = @{Name = 'DB1'; ActivationPreference = 3; ReplayLagTime = '00:00:00'};
                DB2 = @{Name = 'DB2'; ActivationPreference = 4; ReplayLagTime = '7.00:00:00'}; #Lag copy
                DB3 = @{Name = 'DB3'; ActivationPreference = 3; ReplayLagTime = '00:00:00'};
                DB4 = @{Name = 'DB4'; ActivationPreference = 4; ReplayLagTime = '7.00:00:00'} #Lag copy
            }
        }

        @{
            NodeName    = 'e15-4'
            Fqdn        = 'e15-4.mikelab.local'
            Role        = 'AdditionalDAGMember'
            DAGId       = 'DAG1'
            CASID       = 'Site2CAS'

            DiskToDBMap = 'DB1,DB2','DB3,DB4'

            CopyDBList  = @{
                DB1 = @{Name = 'DB1'; ActivationPreference = 4; ReplayLagTime = '7.00:00:00'}; #Lag copy
                DB2 = @{Name = 'DB2'; ActivationPreference = 3; ReplayLagTime = '00:00:00'};
                DB3 = @{Name = 'DB3'; ActivationPreference = 4; ReplayLagTime = '7.00:00:00'}; #Lag copy
                DB4 = @{Name = 'DB4'; ActivationPreference = 3; ReplayLagTime = '00:00:00'}
            }
        }
    );

    #Settings that are unique per DAG will go in separate hash table entries.
    DAG1 = @(
        @{
            ###DAG Settings###
            DAGName                              = 'TestDAG1'           
            AutoDagTotalNumberOfServers          = 4                 AutoDagDatabaseCopiesPerVolume       = 2
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.99','192.168.2.99'     
            ManualDagNetworkConfiguration        = $true
            ReplayLagManagerEnabled              = $true
            SkipDagValidation                    = $true
            WitnessServer                        = 'e14-1.mikelab.local'

            #xDatabaseAvailabilityGroupNetwork params
            #New network params
            DAGNet1NetworkName                   = 'MapiNetwork'
            DAGNet1ReplicationEnabled            = $false
            DAGNet1Subnets                       = '192.168.1.0/24','192.168.2.0/24'

            DAGNet2NetworkName                   = 'ReplNetwork'
            DAGNet2ReplicationEnabled            = $true
            DAGNet2Subnets                       = '10.10.10.0/24','10.10.11.0/24'

            #Old network to remove
            OldNetworkName                       = 'MapiDagNetwork'

            #Certificate Settings
            Thumbprint                           = '7D959B3A37E45978445F8EC8F01D200D00C3141F'
            CertFilePath                         = 'c:\certexport1.pfx'
            Services                             = 'IIS','POP','IMAP','SMTP'
        }
    );

    #CAS settings that are unique per site will go in separate hash table entries as well.
    Site1CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site1.mikelab.local'
            ExternalNLBFqdn            = 'mail.mikelab.local'

            #ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site1'

            #OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site1'

            #OWA Settings
            InstantMessagingServerName = 'lync-site1.mikelab.local'
        }
    );

    Site2CAS = @(
        @{
            InternalNLBFqdn            = 'mail-site2.mikelab.local'
            ExternalNLBFqdn            = 'mail.mikelab.local'

            #ClientAccessServer Settings
            AutoDiscoverSiteScope      = 'Site2'

            #OAB Settings
            OABsToDistribute           = 'Default Offline Address Book - Site2'

            #OWA Settings
            InstantMessagingServerName = 'lync-site2.mikelab.local'
        }
    );
}
