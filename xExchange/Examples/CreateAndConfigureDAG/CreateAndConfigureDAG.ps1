Configuration CreateAndConfigureDAG
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange


    Node $AllNodes.NodeName
    {
        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
    }


    #This section only configures a single DAG node, the first member of the DAG.
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
            ManualDagNetworkConfiguration        = $true
            ReplayLagManagerEnabled              = $true
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
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
CreateAndConfigureDAG -ConfigurationData $PSScriptRoot\CreateAndConfigureDAG-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
Set-DscLocalConfigurationManager -Path .\CreateAndConfigureDAG -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\CreateAndConfigureDAG -Verbose -Wait 
