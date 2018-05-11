<#
.EXAMPLE
    This example shows how to install and run Jet Stress.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            #region Common Settings for All Nodes
            NodeName        = '*'

            <#
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                This is added so that AppVeyor automatic tests can pass, otherwise
                the tests will fail on passwords being in plain text and not being
                encrypted. Because it is not possible to have a certificate in
                AppVeyor to encrypt the passwords we need to add the parameter
                'PSDscAllowPlainTextPassword'.
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                See:
                http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
            #>
            PSDscAllowPlainTextPassword = $true
        }

        @{
            NodeName        = 'e15-1'   
        }
    )
}

Configuration Example
{
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
            DiskToDBMap                    = 'DB1,DB2,DB3,DB4','DB5,DB6,DB7,DB8'
            SpareVolumeCount               = 0
            VolumePrefix                   = 'EXVOL'
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
