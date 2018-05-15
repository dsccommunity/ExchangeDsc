<#
.EXAMPLE
    This example shows how to prepare maintenance mode.
#>

Write-Verbose -Message 'Loading Configuration File - ConfigurationData.psd1.'
$ConfigRoot = "$PSScriptRoot\Config"
$ConfigFile = Get-ChildItem "$ConfigRoot\ConfigurationData.psd1"
$ConfigurationData = New-Object -TypeName hashtable
$ConfigurationData = (Import-PowerShellDataFile -Path $ConfigFile.FullName)

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]    
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId     = $Node.Thumbprint
            ConfigurationMode = 'ApplyOnly' #Set to ApplyOnly, as we probably don't want to continuously check our config during Maintenance
        }

        xExchMailboxServer SetMbxServerSite1
        {
            Identity                         = $Node.NodeName #Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use HOSTNAME here.
            Credential                       = $ExchangeAdminCredential
            DatabaseCopyAutoActivationPolicy = 'Blocked'
            DomainController                 = $Node.Site1DC
        }

        xExchMailboxServer SetMbxServerSite2
        {
            Identity                         = $Node.NodeFqdn #Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use FQDN here.
            Credential                       = $ExchangeAdminCredential
            DatabaseCopyAutoActivationPolicy = 'Blocked'
            DomainController                 = $Node.Site2DC
        }
    }
}
