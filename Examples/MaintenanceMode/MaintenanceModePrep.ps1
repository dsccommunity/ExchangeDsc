Configuration MaintenanceModePrep
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId     = $Node.Thumbprint
            ConfigurationMode = "ApplyOnly" #Set to ApplyOnly, as we probably don't want to continuously check our config during Maintenance
        }

        xExchMailboxServer SetMbxServerSite1
        {
            Identity                         = $Node.NodeName #Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use HOSTNAME here.
            Credential                       = $ShellCreds
            DatabaseCopyAutoActivationPolicy = "Blocked"
            DomainController                 = $Node.Site1DC
        }

        xExchMailboxServer SetMbxServerSite2
        {
            Identity                         = $Node.NodeFqdn #Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use FQDN here.
            Credential                       = $ShellCreds
            DatabaseCopyAutoActivationPolicy = "Blocked"
            DomainController                 = $Node.Site2DC
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
MaintenanceModePrep -ConfigurationData $PSScriptRoot\MaintenanceMode-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
#Set-DscLocalConfigurationManager -Path .\MaintenanceModePrep -Verbose -ComputerName XXX

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\MaintenanceModePrep -Verbose -Wait -ComputerName XXX
