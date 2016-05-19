Configuration ConfigureLCMForDeployment
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

###Compiles the example
ConfigureLCMForDeployment -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1

###Sets up LCM on target computers to decrypt credentials, and to allow reboot during resource execution
#Set-DscLocalConfigurationManager -Path .\ConfigureLCMForDeployment -Verbose -ComputerName XXX
