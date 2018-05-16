<#
.EXAMPLE
    This example shows how to configure LCM for deployment.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psm1'
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
