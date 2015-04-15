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
            Role          = 'FirstDAGMember'
            DAGId         = 'DAG1' #Used to determine which DAG settings the servers should use. Corresponds to DAG1 hashtable entry below.
        }

        @{
            NodeName      = 'e15-2'
            Role          = 'AdditionalDAGMember'
            DAGId         = 'DAG1'
        }

        @{
            NodeName    = 'e15-3'
            Role        = 'AdditionalDAGMember'
            DAGId       = 'DAG1'
        }

        @{
            NodeName    = 'e15-4'
            Role        = 'AdditionalDAGMember'
            DAGId       = 'DAG1'
        }
    );

    #Settings that are unique per DAG will go in separate hash table entries.
    DAG1 = @(
        @{
            ###DAG Settings###
            DAGName                              = 'TestDAG1'           
            AutoDagTotalNumberOfServers          = 4                 AutoDagDatabaseCopiesPerVolume       = 2
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.99','192.168.2.99'     
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
        }
    );
}
