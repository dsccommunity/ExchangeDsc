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

            #The product key to license Exchange 2013
            ProductKey = '12345-12345-12345-12345-12345'

            #The paths to the CSV files generated by the Server Role Requirements Calculator
            ServersCsvPath               = "$($PSScriptRoot)\Calculators\Lab\Servers.csv"
            MailboxDatabasesCsvPath      = "$($PSScriptRoot)\Calculators\Lab\MailboxDatabases.csv"
            MailboxDatabaseCopiesCsvPath = "$($PSScriptRoot)\Calculators\Lab\MailboxDatabaseCopies.csv"

            #DiskToDBMap used by xExchAutoMountPoint specifically for Jetstress purposes
            JetstressDiskToDBMap = 'DB1,DB2,DB3,DB4','DB5,DB6,DB7,DB8'

            #The base file server UNC path that will be used for copying things like certificates, Exchange binaries, and Jetstress binaries
            FileServerBase = '\\rras-1.mikelab.local\Binaries'

            #endregion
        }

        #region Individual Node Settings
        #region DAG01 Nodes
        @{
            NodeName        = 'e15-1'
            Fqdn            = 'e15-1.mikelab.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site1CAS'
            ServerNameInCsv = 'e15-1'          
        }

        @{
            NodeName        = 'e15-2'
            Fqdn            = 'e15-2.mikelab.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site1CAS'
            ServerNameInCsv = 'e15-2'
        }

        @{
            NodeName        = 'e15-3'
            Fqdn            = 'e15-3.mikelab.local'
            Role            = 'FirstDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site2CAS'
            ServerNameInCsv = 'e15-3'       
        }

        @{
            NodeName        = 'e15-4'
            Fqdn            = 'e15-4.mikelab.local'
            Role            = 'AdditionalDAGMember'
            DAGId           = 'DAG01'
            CASId           = 'Site2CAS'
            ServerNameInCsv = 'e15-4'
        }
        #endregion
    );

    #region DAG Settings
    DAG01 = @(
        @{
            DAGName                              = 'DAG01'           
            AutoDagTotalNumberOfServers          = 12
            AutoDagDatabaseCopiesPerVolume       = 4
            DatabaseAvailabilityGroupIPAddresses = '192.168.1.31','192.168.2.31'
            WitnessServer                        = 'e14-1.mikelab.local'
            DbNameReplacements                   = @{"nn" = "01"}
            Thumbprint                           = "0079D0F68F44C7DA5252B4779F872F46DFAF0CBC"
        }
    )
    #endregion

    #region CAS Settings
    #Settings that will apply to all CAS
    AllCAS = @(
        @{
            ExternalNamespace = 'mail.mikelab.local'
        }
    )

    #Settings that will apply only to Quincy CAS
    Site1CAS = @(
        @{
            InternalNamespace          = 'mail-site1.mikelab.local'
            AutoDiscoverSiteScope      = 'Site1'
            InstantMessagingServerName = 'l15-1.mikelab.local'
            DefaultOAB                 = "Default Offline Address Book (Site1)"
        }
    );

    #Settings that will apply only to Phoenix CAS
    Site2CAS = @(
        @{
            InternalNamespace          = 'mail-site2.mikelab.local'
            AutoDiscoverSiteScope      = 'Site2'
            InstantMessagingServerName = 'l15-2.mikelab.local'
            DefaultOAB                 = "Default Offline Address Book (Site2)"
        }
    );
    #endregion
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
        #Copy the Exchange setup files locally
        File ExchangeBinaries
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            Recurse         = $true
            SourcePath      = "$($Node.FileServerBase)\E2K13CU8"
            DestinationPath = 'C:\Binaries\E2K13CU8'
            Credential      = $ExchangeAdminCredential
        }

        #Check if a reboot is needed before installing Exchange
        xPendingReboot BeforeExchangeInstall
        {
            Name      = "BeforeExchangeInstall"
            DependsOn = '[File]ExchangeBinaries'
        }

        #Do the Exchange install
        xExchInstall InstallExchange
        {
            Path       = "C:\Binaries\E2K13CU8\Setup.exe"
            Arguments  = "/mode:Install /role:Mailbox,ClientAccess /IAcceptExchangeServerLicenseTerms"
            Credential = $ExchangeInstallCredential
            DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
        }

        #This section licenses the server
        xExchExchangeServer EXServer
        {
            Identity            = $Node.NodeName
            Credential          = $ExchangeInstallCredential
            ProductKey          = $Node.ProductKey
            AllowServiceRestart = $true
            DependsOn           = '[xExchInstall]InstallExchange'
        }

        #See if a reboot is required after installing Exchange
        xPendingReboot AfterExchangeInstall
        {
            Name      = "AfterExchangeInstall"
            DependsOn = '[xExchInstall]InstallExchange'
        }
    }
}
