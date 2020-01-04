<#
.EXAMPLE
    This example shows how to configure DAG.
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
        $ExchangeAdminCredential
    )

    # Import required DSC Modules
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
            DatacenterActivationMode             = "DagOnly"
            DatabaseAvailabilityGroupIPAddresses = $dagSettings.DatabaseAvailabilityGroupIPAddresses
            ManualDagNetworkConfiguration        = $false
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
    }

    # Next we'll add the remaining nodes to the DAG
    Node $AllNodes.Where{$_.Role -eq 'AdditionalDAGMember'}.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] # Look up and retrieve the DAG settings for this node

        # Can't join until the DAG exists...
        xExchWaitForDAG WaitForDAG
        {
            Identity         = $dagSettings.DAGName
            Credential       = $ExchangeAdminCredential
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
