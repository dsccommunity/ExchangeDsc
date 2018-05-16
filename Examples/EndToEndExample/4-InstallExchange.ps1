<#
.EXAMPLE
    This example shows how to install Exchange.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psm1'
. $ConfigurationDataFile

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
