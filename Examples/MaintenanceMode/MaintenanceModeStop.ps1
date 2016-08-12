Configuration MaintenanceModeStop
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        xExchMaintenanceMode ExitMaintenanceMode
        {
            Enabled = $false
            Credential = $ShellCreds
            AdditionalComponentsToActivate = "AutoDiscoverProxy","ActiveSyncProxy","EcpProxy","EwsProxy","ImapProxy","OabProxy","OwaProxy","PopProxy","PushNotificationsProxy","RpsProxy","RwsProxy","RpcProxy","UMCallRouter","XropProxy","HttpProxyAvailabilityGroup","MapiProxy","EdgeTransport","HighAvailability","SharedCache"
            MovePreferredDatabasesBack = $true
            SetInactiveComponentsFromAnyRequesterToActive = $true
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
MaintenanceModeStop -ConfigurationData $PSScriptRoot\MaintenanceMode-Config.psd1 -ShellCreds $ShellCreds

###Pushes configuration and waits for execution
#Start-DscConfiguration -Path .\MaintenanceModeStop -Verbose -Wait -ComputerName XXX
