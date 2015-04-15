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
                        # The path to the .cer file containing the             # public key of the Encryption Certificate             # used to encrypt credentials for this node             CertificateFile = "C:\publickey.cer"             # The thumbprint of the Encryption Certificate             # used to decrypt the credentials on target node             Thumbprint = "6db197a3abc1a1a8423d4bd3e38718fc3b54809f" 
        }

        @{
            NodeName = "dscpull-1"
        }
    );
}
