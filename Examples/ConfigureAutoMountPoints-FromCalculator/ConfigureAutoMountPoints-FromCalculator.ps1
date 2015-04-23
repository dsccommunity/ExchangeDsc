###See the following blog post for information on how to use this example:
###http://blogs.technet.com/b/mhendric/archive/2014/10/27/managing-exchange-2013-with-dsc-part-3-automating-mount-point-setup-and-maintenance-for-autoreseed.aspx

Configuration ConfigureAutoMountPointsFromCalculator
{
    Import-DscResource -Module xExchange

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.FullName)\HelperScripts\ExchangeConfigHelper.psm1"

    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId]
        
        $dbMap = DBMapFromServersCsv `
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

###Compiles the example
ConfigureAutoMountPointsFromCalculator -ConfigurationData $PSScriptRoot\ConfigureAutoMountPoints-FromCalculator-Config.psd1

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\ConfigureAutoMountPointsFromCalculator -Verbose -Wait
