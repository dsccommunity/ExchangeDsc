<#
.EXAMPLE
    This example shows how to configure LCM for deployment.
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

            #endregion
        }

        #region Individual Node Settings
        @{
            NodeName        = 'e15-1'
        }

        @{
            NodeName        = 'e15-2'
        }

        @{
            NodeName        = 'e15-3'
        }

        @{
            NodeName        = 'e15-4'
        }
        #endregion
    )
}

Configuration Example
{
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId      = $Node.Thumbprint
            ConfigurationMode  = 'ApplyAndMonitor'
            RebootNodeIfNeeded = $true
        }
    }
}
