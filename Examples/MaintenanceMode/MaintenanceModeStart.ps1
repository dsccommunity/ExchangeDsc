Configuration MaintenanceModeStart
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        xExchMaintenanceMode EnterMaintenanceMode
        {
            Enabled    = $true
            Credential = $ShellCreds
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
MaintenanceModeStart -ConfigurationData $PSScriptRoot\MaintenanceMode-Config.psd1 -ShellCreds $ShellCreds

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\MaintenanceModeStart -Verbose -Wait -ComputerName XXX
