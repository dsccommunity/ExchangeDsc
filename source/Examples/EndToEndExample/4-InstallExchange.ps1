<#
.EXAMPLE
    This example shows how to install Exchange.
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

            # The product key to license Exchange 2013
            ProductKey = '12345-12345-12345-12345-12345'

            # The base file server UNC path that will be used for copying things like certificates, Exchange binaries, and Jetstress binaries
            FileServerBase = '\\rras-1.contoso.local\Binaries'

            #endregion
        }

        #region Individual Node Settings
        #region DAG01 Nodes
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

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $ExchangeInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange
    Import-DscResource -Module xPendingReboot

    Node $AllNodes.NodeName
    {
        # Copy the Exchange setup files locally
        File ExchangeBinaries
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            Recurse         = $true
            SourcePath      = "$($Node.FileServerBase)\E2K13CU8"
            DestinationPath = 'C:\Binaries\E2K13CU8'
            Credential      = $ExchangeAdminCredential
        }

        # Check if a reboot is needed before installing Exchange
        xPendingReboot BeforeExchangeInstall
        {
            Name      = "BeforeExchangeInstall"
            DependsOn = '[File]ExchangeBinaries'
        }

        # Do the Exchange install
        xExchInstall InstallExchange
        {
            Path       = "C:\Binaries\E2K13CU8\Setup.exe"
            Arguments  = "/mode:Install /role:Mailbox /IAcceptExchangeServerLicenseTerms"
            Credential = $ExchangeInstallCredential
            DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
        }

        # This section licenses the server
        xExchExchangeServer EXServer
        {
            Identity            = $Node.NodeName
            Credential          = $ExchangeInstallCredential
            ProductKey          = $Node.ProductKey
            AllowServiceRestart = $true
            DependsOn           = '[xExchInstall]InstallExchange'
        }

        # See if a reboot is required after installing Exchange
        xPendingReboot AfterExchangeInstall
        {
            Name      = "AfterExchangeInstall"
            DependsOn = '[xExchInstall]InstallExchange'
        }
    }
}
