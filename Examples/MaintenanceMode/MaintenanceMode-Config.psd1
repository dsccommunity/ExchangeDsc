@{
    AllNodes = @(
        #Settings under 'NodeName = *' apply to all nodes.
        @{
            NodeName        = '*'

            #CertificateFile and Thumbprint are used for securing credentials. See:
            #http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
                        #The location on the compiling machine of the public key export of the certfificate which will be used to encrypt credentials            CertificateFile = 'C:\publickey.cer'             #Thumbprint of the certificate being used for encrypting credentials            Thumbprint      = '7D959B3A37E45978445F8EC8F01D200D00C3141F'

            Site1DC         = 'dc-1'
            Site2DC         = 'dc-2'
        }

        #Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            NodeFqdn = 'e15-1.mikelab.local'
        }
    );
}
