Configuration InstallExchange
{
    param
    (
        [PSCredential]$Creds
    )

    Import-DscResource -Module xExchange
    Import-DscResource -Module xPendingReboot

    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            CertificateId      = $Node.Thumbprint
            RebootNodeIfNeeded = $true
        }

        #Copy the Exchange setup files locally
        File ExchangeBinaries
        {
            Ensure          = 'Present'
            Type            = 'Directory'
            Recurse         = $true
            SourcePath      = '\\rras-1\Binaries\E15CU6'
            DestinationPath = 'C:\Binaries\E15CU6'
        }

        #Check if a reboot is needed before installing Exchange
        xPendingReboot BeforeExchangeInstall
        {
            Name      = "BeforeExchangeInstall"

            DependsOn  = '[File]ExchangeBinaries'
        }

        #Do the Exchange install
        xExchInstall InstallExchange
        {
            Path       = "C:\Binaries\E15CU6\Setup.exe"
            Arguments  = "/mode:Install /role:Mailbox,ClientAccess /Iacceptexchangeserverlicenseterms"
            Credential = $Creds

            DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
        }

        #See if a reboot is required after installing Exchange
        xPendingReboot AfterExchangeInstall
        {
            Name      = "AfterExchangeInstall"

            DependsOn = '[xExchInstall]InstallExchange'
        }
    }
}

if ($Creds -eq $null)
{
    $Creds = Get-Credential -Message "Enter credentials for establishing Remote Powershell sessions to Exchange"
}

###Compiles the example
InstallExchange -ConfigurationData $PSScriptRoot\InstallExchange-Config.psd1 -Creds $Creds

###Sets up LCM on target computers to decrypt credentials, and to allow reboot during resource execution
Set-DscLocalConfigurationManager -Path .\InstallExchange -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\InstallExchange -Verbose -Wait

