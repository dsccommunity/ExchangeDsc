@{
    AllNodes = @(
		#Settings under 'NodeName = *' apply to all nodes.
        @{
            NodeName        = '*'

            #CertificateFile and Thumbprint are used for securing credentials. See:
            #http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
                        #The location on the compiling machine of the public key export of the certfificate which will be used to encrypt credentials            CertificateFile = 'C:\publickey.cer'             #Thumbprint of the certificate being used for encrypting credentials            Thumbprint      = '39bef4b2e82599233154465323ebf96a12b60673' 
        }

		#Individual target nodes are defined next
        @{
            NodeName           = 'e15-1'
            ServerNameInCsv    = 'SRV-nn-01'
			DbNameReplacements = @{"-nn-" = "-01-"}
        }

        @{
            NodeName           = 'e15-2'
            ServerNameInCsv    = 'SRV-nn-02'
			DbNameReplacements = @{"-nn-" = "-01-"}
        }
    );
}