Configuration WaitForADPrep
{
    param
    (
        [PSCredential]$Creds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId      = $Node.Thumbprint
        }

        xExchWaitForADPrep WaitForADPrep
        {
            Identity = "Doesn'tMatter"
            Credential = $Creds
            SchemaVersion = 15303
            OrganizationVersion = 15965
            DomainVersion = 13236
        }
    }
}

if ($null -eq $Creds)
{
    $Creds = Get-Credential -Message "Enter credentials for establishing Remote Powershell sessions to Exchange"
}

###Compiles the example
WaitForADPrep -ConfigurationData $PSScriptRoot\WaitForADPrep-Config.psd1 -Creds $Creds

###Sets up LCM on target computers to decrypt credentials, and to allow reboot during resource execution
#Set-DscLocalConfigurationManager -Path .\WaitForADPrep -Verbose

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\WaitForADPrep -Verbose -Wait

