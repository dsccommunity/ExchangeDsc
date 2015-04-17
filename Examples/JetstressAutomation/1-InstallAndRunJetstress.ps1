Configuration InstallAndRunJetstress
{
    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        #Create mount points for use with Jetstress. Here I prefer to use the same database names for ALL servers,
        #that way I can use the same JetstressConfig.xml for all of them.
        xExchAutoMountPoint AMPForJetstress
        {
            Identity                       = $Node.NodeName            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'            DiskToDBMap                    = 'DB1,DB2,DB3,DB4','DB5,DB6,DB7,DB8'            SpareVolumeCount               = 0            VolumePrefix                   = 'EXVOL'
            CreateSubfolders               = $true
        }

        #Copy the Jetstress install file
        File CopyJetstress
        {
            Ensure          = 'Present'
            SourcePath      = '\\rras-1\Jetstress\Jetstress.msi'
            DestinationPath = 'C:\Jetstress\Jetstress.msi'
        }

        #Install Jetstress
        Package InstallJetstress
        {
            Ensure    = 'Present'
            Path      = 'C:\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'

            DependsOn = '[xExchAutoMountPoint]AMPForJetstress','[File]CopyJetstress'
        }

        #Copy required ESE DLL's to the Jetstress installation directory
        File CopyESEDlls
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            Recurse         = $true
            SourcePath      = '\\rras-1\Jetstress\ESEDlls(CU7)'
            DestinationPath = 'C:\Program Files\Exchange Jetstress'

            DependsOn       = '[Package]InstallJetstress'
        }

        #Copy JetstressConfig.xml to the Jetstress installation directory
        File CopyJetstressConfig
        {
            Ensure          = 'Present'
            SourcePath      = '\\rras-1\Jetstress\JetstressConfig.xml'
            DestinationPath = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'

            DependsOn       = '[Package]InstallJetstress'
        }

        #Run the Jetstress test, and evaluate the results
        xExchJetstress RunJetstress
        {
            Type            = 'Performance'
            JetstressPath   = 'C:\Program Files\Exchange Jetstress'
            JetstressParams = '/c "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"'
            MinAchievedIOPS = 500

            DependsOn       = '[File]CopyESEDlls','[File]CopyJetstressConfig'
        }
    }
}

###Compiles the example
InstallAndRunJetstress -ConfigurationData $PSScriptRoot\Jetstress-Config.psd1

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\InstallAndRunJetstress -Verbose -Wait
