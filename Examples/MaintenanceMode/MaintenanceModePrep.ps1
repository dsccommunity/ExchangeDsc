<#
.EXAMPLE
    This example shows how to prepare maintenance mode.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            #region Common Settings for All Nodes
            NodeName        = '*'

            <#
                The location of the exported public certificate which will be used to encrypt
                credentials during compilation.
                CertificateFile = 'C:\public-certificate.cer'
            #>

            # Thumbprint of the certificate being used for decrypting credentials
            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673'

            Site1DC         = 'dc-1'
            Site2DC         = 'dc-2'
        }

        # Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            NodeFqdn = 'e15-1.contoso.local'
        }
    )
}

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
            ConfigurationMode = 'ApplyOnly' # Set to ApplyOnly, as we probably don't want to continuously check our config during Maintenance
        }

        xExchMailboxServer SetMbxServerSite1
        {
            Identity                         = $Node.NodeName # Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use HOSTNAME here.
            Credential                       = $ExchangeAdminCredential
            DatabaseCopyAutoActivationPolicy = 'Blocked'
            DomainController                 = $Node.Site1DC
        }

        xExchMailboxServer SetMbxServerSite2
        {
            Identity                         = $Node.NodeFqdn # Use a different server Identity for each xExchMailboxServer resource to satisfy the Key requirement. Use FQDN here.
            Credential                       = $ExchangeAdminCredential
            DatabaseCopyAutoActivationPolicy = 'Blocked'
            DomainController                 = $Node.Site2DC
        }
    }
}
