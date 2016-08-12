Configuration ConfigureLCMForContinuousChecking
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

if ($null -eq $RemoteServerCreds)
{
    $RemoteServerCreds = Get-Credential -Message "Enter credentials for connecting to remote Exchange Server"
}

###Compiles the example
ConfigureLCMForContinuousChecking -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1

###Sets up LCM on target computers to decrypt credentials, and to allow reboot during resource execution
#Set-DscLocalConfigurationManager -Path .\ConfigureLCMForContinuousChecking -Verbose -ComputerName XXX
