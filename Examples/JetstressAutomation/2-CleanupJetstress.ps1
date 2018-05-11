<#
.EXAMPLE
    This example shows how to cleanup Jet Stress.
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
            JetstressPath               = 'C:\Program Files\Exchange Jetstress'
            ConfigFilePath              = 'C:\Program Files\Exchange Jetstress\JetstressConfig.xml'
            DeleteAssociatedMountPoints = $true
            OutputSaveLocation          = 'C:\JetstressOutput'
            RemoveBinaries              = $true
            DependsOn                   = '[Package]UninstallJetstress'
        }
    }
}
