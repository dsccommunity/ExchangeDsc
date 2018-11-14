<#
.EXAMPLE
    This example shows how to install and run jet stress.
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

            # DiskToDBMap used by xExchAutoMountPoint specifically for Jetstress purposes
            JetstressDiskToDBMap = 'DB1,DB2,DB3,DB4', 'DB5,DB6,DB7,DB8'

            # The base file server UNC path that will be used for copying things like certificates, Exchange binaries, and Jetstress binaries
            FileServerBase = '\\rras-1.contoso.local\Binaries'

            #endregion
        }

        #region Individual Node Settings
        #region DAG01 Nodes
        @{
            NodeName        = 'e15-1'
        }

        @{
            NodeName        = 'e15-2'
        }

        @{
            NodeName        = 'e15-3'
        }

        @{
            NodeName        = 'e15-4'
        }
        #endregion
    )
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

    Node $AllNodes.NodeName
    {
        # Create mount points for use with Jetstress. Here I prefer to use the same database names for ALL servers,
        # that way I can use the same JetstressConfig.xml for all of them.
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

        # Copy the Jetstress install file
        File CopyJetstress
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Jetstress\Jetstress.msi"
            DestinationPath = 'C:\Binaries\Jetstress\Jetstress.msi'
            Credential      = $ExchangeAdminCredential
        }

        # Install Jetstress
        Package InstallJetstress
        {
            Ensure    = 'Present'
            Path      = 'C:\Binaries\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'
            DependsOn = '[xExchAutoMountPoint]AMPForJetstress', '[File]CopyJetstress'
        }

        # Copy required ESE DLL's to the Jetstress installation directory
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

        # Copy JetstressConfig.xml to the Jetstress installation directory
        File CopyJetstressConfig
        {
            Ensure          = 'Present'
            SourcePath      = "$($Node.FileServerBase)\Jetstress\JetstressConfig.xml"
            DestinationPath = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'
            Credential      = $ExchangeAdminCredential
            DependsOn       = '[Package]InstallJetstress'
        }

        # Run the Jetstress test, and evaluate the results
        xExchJetstress RunJetstress
        {
            Type            = 'Performance'
            JetstressPath   = 'C:\Program Files\Exchange Jetstress'
            JetstressParams = '/c "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"'
            MinAchievedIOPS = 100
            DependsOn       = '[File]CopyESEDlls', '[File]CopyJetstressConfig'
        }
    }
}
