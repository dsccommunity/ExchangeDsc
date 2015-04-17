Configuration QuickStartTemplate
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        #Used when passing credentials securely. This configures the thumbprint of the 
        #cert that will be used to decrypt the creds
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
    }
}

#Get credentials if they haven't already been passed
if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
QuickStartTemplate -ConfigurationData $PSScriptRoot\QuickStartTemplate-Config.psd1 -ShellCreds $ShellCreds