<#
.EXAMPLE
    This example shows how to configure LCM for continuous checking.
#>

Write-Verbose -Message 'Loading Configuration File - ConfigurationData.psd1.'
$ConfigRoot = "$PSScriptRoot\Config"
$ConfigFile = Get-ChildItem "$ConfigRoot\ConfigurationData.psd1"
$ConfigurationData = New-Object -TypeName hashtable
$ConfigurationData = (Import-PowerShellDataFile -Path $ConfigFile.FullName)

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
