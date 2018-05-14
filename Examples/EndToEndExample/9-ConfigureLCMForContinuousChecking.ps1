<#
.EXAMPLE
    This example shows how to configure LCM for continuous checking.
#>

$ConfigurationData = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psd1')

Configuration Example
{
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId                  = $Node.Thumbprint
            RebootNodeIfNeeded             = $false
            ConfigurationMode              = "ApplyAndAutoCorrect"
            ConfigurationModeFrequencyMins = 30
        }
    }
}
