@{
    AllNodes = @(
        #Settings in this section will apply to all nodes. For the purposes of this demo,
        #the only thing that will be configured in here is how credentials will be stored
        #in the compiled MOF files.
        @{
            NodeName = "*"

            ###SECURE CREDENTIAL PASSING METHOD###
            #This is the preferred method for passing credentials, as they are not stored in plain text. See:
            #http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
                        # The path to the .cer file containing the             # public key of the Encryption Certificate             # used to encrypt credentials for this node             CertificateFile = "C:\publickey.cer"             # The thumbprint of the Encryption Certificate             # used to decrypt the credentials on target node             Thumbprint = "986366e5781f1e1f541f3ad0c4121d04a2b8545e" 
        }

        @{
            NodeName = "dscpull-1"
        }
    );
}
