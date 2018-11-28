<#
.EXAMPLE
    This example shows how to stop maintenance mode.
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

            Site1DC         = 'dc-1'
            Site2DC         = 'dc-2'
        }

        # Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            NodeFqdn = 'e15-1.contoso.local'
        }
    )
}

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
