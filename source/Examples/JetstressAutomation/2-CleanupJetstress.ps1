<#
.EXAMPLE
    This example shows how to cleanup Jet Stress.
#>

Configuration Example
{
    Import-DscResource -Module xExchange

    node localhost
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        # Uninstall Jetstress from the computer
        Package UninstallJetstress
        {
            Ensure    = 'Absent'
            Path      = 'C:\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013 - Uninstall'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'
        }

        # Clean up Jetstress databases, mount points, and binaries
        xExchJetstressCleanup CleanupJetstress
        {
            JetstressPath               = 'C:\Program Files\Exchange Jetstress'
            ConfigFilePath              = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'
            DeleteAssociatedMountPoints = $true
            OutputSaveLocation          = 'C:\JetstressOutput'
            RemoveBinaries              = $true
            DependsOn                   = '[Package]UninstallJetstress'
        }
    }
}
