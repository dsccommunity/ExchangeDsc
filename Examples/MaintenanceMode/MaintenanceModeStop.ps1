<#
.EXAMPLE
    This example shows how to stop maintenance mode.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.ps1'
. $ConfigurationDataFile

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]    
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        xExchMaintenanceMode ExitMaintenanceMode
        {
            Enabled                                         = $false
            Credential                                      = $ExchangeAdminCredential
            AdditionalComponentsToActivate                  = 'AutoDiscoverProxy',`
                                                              'ActiveSyncProxy',`
                                                              'EcpProxy',`
                                                              'EwsProxy',`
                                                              'ImapProxy',`
                                                              'OabProxy',`
                                                              'OwaProxy',`
                                                              'PopProxy',`
                                                              'PushNotificationsProxy',`
                                                              'RpsProxy',`
                                                              'RwsProxy',`
                                                              'RpcProxy',`
                                                              'UMCallRouter',`
                                                              'XropProxy',`
                                                              'HttpProxyAvailabilityGroup',`
                                                              'MapiProxy',`
                                                              'EdgeTransport',`
                                                              'HighAvailability',`
                                                              'SharedCache'
            MovePreferredDatabasesBack                      = $true
            SetInactiveComponentsFromAnyRequesterToActive   = $true
        }
    }
}
