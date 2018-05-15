<#
.EXAMPLE
    This example shows how to configure LCM for deployment.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.ps1'
. $ConfigurationDataFile

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
