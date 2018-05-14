<#
.EXAMPLE
    This example shows how to prepare maintenance mode.
#>

$ConfigurationData = Import-PowerShellDataFile -Path (Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psd1')

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
