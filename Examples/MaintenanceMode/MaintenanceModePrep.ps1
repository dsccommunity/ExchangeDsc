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
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                This is added so that AppVeyor automatic tests can pass, otherwise
                the tests will fail on passwords being in plain text and not being
                encrypted. Because it is not possible to have a certificate in
                AppVeyor to encrypt the passwords we need to add the parameter
                'PSDscAllowPlainTextPassword'.
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                See:
                http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
            #>
            PSDscAllowPlainTextPassword = $true

            <#
                The location of the exported public certifcate which will be used to encrypt
                credentials during compilation.
                CertificateFile = 'C:\public-certificate.cer' 
            #>
            
            #Thumbprint of the certificate being used for decrypting credentials
            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673' 

            Site1DC         = 'dc-1'
            Site2DC         = 'dc-2'
        }

        #Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            NodeFqdn = 'e15-1.mikelab.local'
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
