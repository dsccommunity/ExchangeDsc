###See the following blog post for information on how to use this example:
###http://blogs.technet.com/b/mhendric/archive/2014/10/27/managing-exchange-2013-with-dsc-part-3-automating-mount-point-setup-and-maintenance-for-autoreseed.aspx

Configuration ConfigureAutoMountPointsManual
{
    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $Node.DiskToDBMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }
    }
}

###Compiles the example
ConfigureAutoMountPointsManual -ConfigurationData $PSScriptRoot\ConfigureAutoMountPoints-Manual-Config.psd1

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\ConfigureAutoMountPointsManual -Verbose -Wait 