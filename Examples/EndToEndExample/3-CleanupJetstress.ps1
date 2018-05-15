<#
.EXAMPLE
    This example shows how to cleanup jet stress.
#>

Write-Verbose -Message 'Loading Configuration File - ConfigurationData.psd1.'
$ConfigRoot = "$PSScriptRoot\Config"
$ConfigFile = Get-ChildItem "$ConfigRoot\ConfigurationData.psd1"
$ConfigurationData = New-Object -TypeName hashtable
$ConfigurationData = (Import-PowerShellDataFile -Path $ConfigFile.FullName)

Configuration Example
{

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        #Uninstall Jetstress from the computer
        Package UninstallJetstress
        {
            Ensure    = 'Absent'
            Path      = 'C:\Binaries\Jetstress\Jetstress.msi'
            Name      = 'Microsoft Exchange Jetstress 2013 - Uninstall'
            ProductId = '75189587-0D84-4404-8F02-79C39728FA64'
        }

        #Clean up Jetstress databases, mount points, and binaries
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
