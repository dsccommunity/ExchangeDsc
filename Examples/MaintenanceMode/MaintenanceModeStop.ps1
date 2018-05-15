<#
.EXAMPLE
    This example shows how to stop maintenance mode.
#>

Write-Verbose -Message 'Loading Configuration File - ConfigurationData.psd1.'
$ConfigRoot = "$PSScriptRoot\Config"
$ConfigFile = Get-ChildItem "$ConfigRoot\ConfigurationData.psd1"
$ConfigurationData = New-Object -TypeName hashtable
$ConfigurationData = (Import-PowerShellDataFile -Path $ConfigFile.FullName)

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
