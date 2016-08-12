Configuration InstallExchange
{
    param
    (
        [PSCredential]$InstallCreds,
        [PSCredential]$FileCopyCreds
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
            Credential      = $FileCopyCreds
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
            Credential = $InstallCreds

            DependsOn  = '[xPendingReboot]BeforeExchangeInstall'
        }

        #This section licenses the server
        xExchExchangeServer EXServer
        {
            Identity            = $Node.NodeName
            Credential          = $InstallCreds
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

if ($null -eq $InstallCreds)
{
    $InstallCreds = Get-Credential -Message "Enter credentials for Installing Exchange"
}

if ($null -eq $FileCopyCreds)
{
    $FileCopyCreds = Get-Credential -Message "Enter credentials for copying Exchange setup files from the file server"
}

###Compiles the example
InstallExchange -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1 -InstallCreds $InstallCreds -FileCopyCreds $FileCopyCreds

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\InstallExchange -Verbose -Wait -ComputerName XXX
