<#
.EXAMPLE
    This example shows how to configure LCM for continuous checking.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psm1'
. $ConfigurationDataFile

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
