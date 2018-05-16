<#
.EXAMPLE
    This example shows how to install and run jet stress.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psm1'
. $ConfigurationDataFile

Configuration Example
{   
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        #Create mount points for use with Jetstress. Here I prefer to use the same database names for ALL servers,
        #that way I can use the same JetstressConfig.xml for all of them.
        xExchAutoMountPoint AMPForJetstress
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $Node.JetstressDiskToDBMap
            SpareVolumeCount               = 0
            VolumePrefix                   = 'EXVOL'
            CreateSubfolders               = $true
        }

        #Copy the Jetstress install file
        File CopyJetstress
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Jetstress\Jetstress.msi"
            DestinationPath = 'C:\Binaries\Jetstress\Jetstress.msi'
            Credential      = $ExchangeAdminCredential
        }

        #Install Jetstress
        Package InstallJetstress
        {
            Ensure    = 'Present'
            Path      = 'C:\Binaries\Jetstress\Jetstress.msi'
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
            SourcePath      = "$($Node.FileServerBase)\Jetstress\ESEDlls"
            DestinationPath = 'C:\Program Files\Exchange Jetstress'
            Credential      = $ExchangeAdminCredential
            DependsOn       = '[Package]InstallJetstress'
        }

        #Copy JetstressConfig.xml to the Jetstress installation directory
        File CopyJetstressConfig
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Jetstress\JetstressConfig.xml"
            DestinationPath = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'
            Credential      = $ExchangeAdminCredential
            DependsOn       = '[Package]InstallJetstress'
        }

        #Run the Jetstress test, and evaluate the results
        xExchJetstress RunJetstress
        {
            Type            = 'Performance'
            JetstressPath   = 'C:\Program Files\Exchange Jetstress'
            JetstressParams = '/c "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"'
            MinAchievedIOPS = 100
            DependsOn       = '[File]CopyESEDlls','[File]CopyJetstressConfig'
        }
    }
}
