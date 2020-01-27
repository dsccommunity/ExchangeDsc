$ConfigurationData = @{
    AllNodes = @(
        # Settings under 'NodeName = *' apply to all nodes.
        @{
            NodeName        = '*'

            # CertificateFile and Thumbprint are used for securing credentials. See:
            # http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx

            <#
                The location of the exported public certificate which will be used to encrypt
                credentials during compilation.
                CertificateFile = 'C:\public-certificate.cer'
            #>

            # Thumbprint of the certificate being used for decrypting credentials
            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673'
        }

        # Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
        }

        @{
            NodeName = 'e15-2'
        }
    )
}

Configuration Example
{
    [CmdletBinding()]
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
        # Used when passing credentials securely. This configures the thumbprint of the
        # cert that will be used to decrypt the creds
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
    }
}
