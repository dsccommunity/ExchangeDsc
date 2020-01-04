###See the following blog post for information on how to use this example:
###http://blogs.technet.com/b/mhendric/archive/2014/10/27/managing-exchange-2013-with-dsc-part-3-automating-mount-point-setup-and-maintenance-for-autoreseed.aspx

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = 'SRV-01-01'
            ServerNameInCsv = 'SRV-nn-01'
            DAGId           = "DAG1"
        }

        @{
            NodeName        = 'SRV-01-02'
            ServerNameInCsv = 'SRV-nn-02'
            DAGId           = "DAG1"
        }
        @{
            NodeName        = 'SRV-01-03'
            ServerNameInCsv = 'SRV-nn-03'
            DAGId           = "DAG1"
        }

        @{
            NodeName        = 'SRV-01-04'
            ServerNameInCsv = 'SRV-nn-04'
            DAGId           = "DAG1"
        }
    );

    DAG1 = @{
        DbNameReplacements = @{"-nn-" = "-01-"}
    }
}

Configuration Example
{
    Import-DscResource -Module xExchange

    Import-Module -Name (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Modules\xExchangeCalculatorHelper.psm1')

    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId]

        $dbMap = Get-DBMapFromServersCsv `
                    -ServersCsvPath "$($PSScriptRoot)\CalculatorAndScripts\Servers.csv" `
                    -ServerNameInCsv $Node.ServerNameInCsv `
                    -DbNameReplacements $dagSettings.DbNameReplacements

        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $dbMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }
    }
}
