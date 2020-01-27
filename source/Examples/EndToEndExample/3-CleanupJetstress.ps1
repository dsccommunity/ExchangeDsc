<#
.EXAMPLE
    This example shows how to cleanup jet stress.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            #region Common Settings for All Nodes
            NodeName        = '*'

            # The base file server UNC path that will be used for copying things like certificates, Exchange binaries, and Jetstress binaries
            FileServerBase = '\\rras-1.contoso.local\Binaries'

            #endregion
        }

        #region Individual Node Settings
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

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        # Uninstall Jetstress from the computer
        Package UninstallJetstress
        {
            Ensure    = 'Absent'
            Path      = 'C:\Binaries\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013 - Uninstall'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'
        }

        # Clean up Jetstress databases, mount points, and binaries
        xExchJetstressCleanup CleanupJetstress
        {
            JetstressPath               = 'C:\Program Files\Exchange Jetstress'
            ConfigFilePath              = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'
            DeleteAssociatedMountPoints = $true
            OutputSaveLocation          = "$($Node.FileServerBase)\JetstressOutput\$($Node.NodeName)"
            RemoveBinaries              = $true
            DependsOn                   = '[Package]UninstallJetstress'
        }
    }
}
