<#
.EXAMPLE
    This example shows how to configure LCM for continuous checking.
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
            CertificateId                  = $Node.Thumbprint
            RebootNodeIfNeeded             = $false
            ConfigurationMode              = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 30
        }
    }
}
