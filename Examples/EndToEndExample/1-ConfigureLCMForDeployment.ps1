<#
.EXAMPLE
    This example shows how to configure LCM for deployment.
#>

$ConfigurationData = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psd1')

Configuration Example
{  
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId      = $Node.Thumbprint
            ConfigurationMode  = "ApplyAndMonitor"
            RebootNodeIfNeeded = $true
        }
    }
}
