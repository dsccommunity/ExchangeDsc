Configuration CleanupJetstress
{
    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

		#Uninstall Jetstress from the computer
        Package UninstallJetstress
        {
            Ensure    = 'Absent'
            Path      = 'C:\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013 - Uninstall'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'
        }

		#Clean up Jetstress databases, mount points, and binaries
        xExchJetstressCleanup CleanupJetstress
        {
            JetstressPath               = "C:\Program Files\Exchange Jetstress"
            ConfigFilePath              = "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"
            DeleteAssociatedMountPoints = $true
            OutputSaveLocation          = "C:\JetstressOutput"
            RemoveBinaries              = $true

            DependsOn                   = '[Package]UninstallJetstress'
        }
    }
}

###Compiles the example
CleanupJetstress -ConfigurationData $PSScriptRoot\Jetstress-Config.psd1

###Sets up LCM on target computers to allow reboot during resource execution
Set-DscLocalConfigurationManager -Path .\CleanupJetstress -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\CleanupJetstress -Verbose -Wait