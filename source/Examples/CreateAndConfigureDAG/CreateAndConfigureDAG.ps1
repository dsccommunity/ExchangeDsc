<#
.EXAMPLE
    This example shows how to configure databases manually.
#>

$ConfigurationData = @{
    AllNodes = @(
        # Settings under 'NodeName = *' apply to all nodes.
        @{
            NodeName                    = '*'
        },

        # Individual target nodes are defined next
        @{
            NodeName      = 'e15-1'
            Role          = 'FirstDAGMember'
            DAGId         = 'DAG1' # Used to determine which DAG settings the servers should use. Corresponds to DAG1 hashtable entry below.
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

    # Settings that are unique per DAG will go in separate hash table entries.
    DAG1 = @(
        @{
            ###DAG Settings###
            DAGName                              = 'TestDAG1'
            AutoDagTotalNumberOfServers          = 4
            AutoDagDatabaseCopiesPerVolume       = 2
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.99', '192.168.2.99'
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
        }
    );
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

    # This section only configures a single DAG node, the first member of the DAG.
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
            ManualDagNetworkConfiguration        = $true
            ReplayLagManagerEnabled              = $true
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
}
