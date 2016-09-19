function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,
        
        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [System.String]
        $ActiveUserStatisticsLogPath,

        [System.Boolean]
        $AgentLogEnabled,

        [System.String]
        $AgentLogMaxAge,

        [System.String]
        $AgentLogMaxDirectorySize,

        [System.String]
        $AgentLogMaxFileSize,

        [System.String]
        $AgentLogPath,

        [System.Boolean]
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.String]
        $DelayNotificationTimeout,

        [System.Boolean]
        $DnsLogEnabled,

        [System.String]
        $DnsLogMaxAge,

        [System.String]
        $DnsLogMaxDirectorySize,

        [System.String]
        $DnsLogMaxFileSize,

        [System.String]
        $DnsLogPath,

        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [System.String]
        $ExternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $ExternalDNSProtocolOption,

        [System.String[]]
        $ExternalDNSServers,

        [System.String]
        $ExternalIPAddress,

        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [System.String]
        $InternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $InternalDNSProtocolOption,

        [System.String[]]
        $InternalDNSServers,

        [ValidateSet("None","Verbose")]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [System.Boolean]
        $IrmLogEnabled,

        [System.String]
        $IrmLogMaxAge,

        [System.String]
        $IrmLogMaxDirectorySize,

        [System.String]
        $IrmLogMaxFileSize,

        [System.String]
        $IrmLogPath,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Int32]
        $MaxConnectionRatePerMinute,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [System.String]
        $MessageExpirationTimeout,

        [System.String]
        $MessageRetryInterval,

        [System.Boolean]
        $MessageTrackingLogEnabled,

        [System.String]
        $MessageTrackingLogMaxAge,

        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [System.String]
        $MessageTrackingLogMaxFileSize,

        [System.String]
        $MessageTrackingLogPath,

        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [System.String]
        $PickupDirectoryPath,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [System.String]
        $QueueLogMaxAge,

        [System.String]
        $QueueLogMaxDirectorySize,

        [System.String]
        $QueueLogMaxFileSize,

        [System.String]
        $QueueLogPath,

        [System.String]
        $QueueMaxIdleTime,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [System.String]
        $ReplayDirectoryPath,

        [System.String]
        $RootDropDirectoryPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath,

        [System.String]
        $ServerStatisticsLogMaxAge,

        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [System.String]
        $ServerStatisticsLogPath,

        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [System.String]
        $TransientFailureRetryInterval,

        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-TransportService" -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    $TransportService = Get-TransportService $Identity -ErrorAction SilentlyContinue
    if ($null -ne $TransportService)
    {
        $returnValue = @{
            Identity                                        = $Identity
            ActiveUserStatisticsLogMaxAge                   = $TransportService.ActiveUserStatisticsLogMaxAge
            ActiveUserStatisticsLogMaxDirectorySize         = $TransportService.ActiveUserStatisticsLogMaxDirectorySize
            ActiveUserStatisticsLogMaxFileSize              = $TransportService.ActiveUserStatisticsLogMaxFileSize
            ActiveUserStatisticsLogPath                     = $TransportService.ActiveUserStatisticsLogPath
            AgentLogEnabled                                 = $TransportService.AgentLogEnabled
            AgentLogMaxAge                                  = $TransportService.AgentLogMaxAge
            AgentLogMaxDirectorySize                        = $TransportService.AgentLogMaxDirectorySize
            AgentLogMaxFileSize                             = $TransportService.AgentLogMaxFileSize
            AgentLogPath                                    = $TransportService.AgentLogPath
            ConnectivityLogEnabled                          = $TransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                           = $TransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize                 = $TransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize                      = $TransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                             = $TransportService.ConnectivityLogPath
            ContentConversionTracingEnabled                 = $TransportService.ContentConversionTracingEnabled
            DelayNotificationTimeout                        = $TransportService.DelayNotificationTimeout
            DnsLogEnabled                                   = $TransportService.DnsLogEnabled
            DnsLogMaxAge                                    = $TransportService.DnsLogMaxAge
            DnsLogMaxDirectorySize                          = $TransportService.DnsLogMaxDirectorySize
            DnsLogMaxFileSize                               = $TransportService.DnsLogMaxFileSize
            DnsLogPath                                      = $TransportService.DnsLogPath
            ExternalDNSAdapterEnabled                       = $TransportService.ExternalDNSAdapterEnabled
            ExternalDNSAdapterGuid                          = $TransportService.ExternalDNSAdapterGuid
            ExternalDNSProtocolOption                       = $TransportService.ExternalDNSProtocolOption
            ExternalDNSServers                              = $TransportService.ExternalDNSServers.IPAddressToString
            ExternalIPAddress                               = $TransportService.ExternalIPAddress
            InternalDNSAdapterEnabled                       = $TransportService.InternalDNSAdapterEnabled
            InternalDNSAdapterGuid                          = $TransportService.InternalDNSAdapterGuid
            InternalDNSProtocolOption                       = $TransportService.InternalDNSProtocolOption
            InternalDNSServers                              = $TransportService.InternalDNSServers.IPAddressToString
            IntraOrgConnectorProtocolLoggingLevel           = $TransportService.IntraOrgConnectorProtocolLoggingLevel
            IntraOrgConnectorSmtpMaxMessagesPerConnection   = $TransportService.IntraOrgConnectorSmtpMaxMessagesPerConnection
            IrmLogEnabled                                   = $TransportService.IrmLogEnabled
            IrmLogMaxAge                                    = $TransportService.IrmLogMaxAge
            IrmLogMaxDirectorySize                          = $TransportService.IrmLogMaxDirectorySize
            IrmLogMaxFileSize                               = $TransportService.IrmLogMaxFileSize
            IrmLogPath                                      = $TransportService.IrmLogPath
            MaxConcurrentMailboxDeliveries                  = $TransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions                 = $TransportService.MaxConcurrentMailboxSubmissions
            MaxConnectionRatePerMinute                      = $TransportService.MaxConnectionRatePerMinute
            MaxOutboundConnections                          = $TransportService.MaxOutboundConnections
            MaxPerDomainOutboundConnections                 = $TransportService.MaxPerDomainOutboundConnections
            MessageExpirationTimeout                        = $TransportService.MessageExpirationTimeout
            MessageRetryInterval                            = $TransportService.MessageRetryInterval
            MessageTrackingLogEnabled                       = $TransportService.MessageTrackingLogEnabled
            MessageTrackingLogMaxAge                        = $TransportService.MessageTrackingLogMaxAge
            MessageTrackingLogMaxDirectorySize              = $TransportService.MessageTrackingLogMaxDirectorySize
            MessageTrackingLogMaxFileSize                   = $TransportService.MessageTrackingLogMaxFileSize
            MessageTrackingLogPath                          = $TransportService.MessageTrackingLogPath
            MessageTrackingLogSubjectLoggingEnabled         = $TransportService.MessageTrackingLogSubjectLoggingEnabled
            OutboundConnectionFailureRetryInterval          = $TransportService.OutboundConnectionFailureRetryInterval
            PickupDirectoryMaxHeaderSize                    = $TransportService.PickupDirectoryMaxHeaderSize
            PickupDirectoryMaxMessagesPerMinute             = $TransportService.PickupDirectoryMaxMessagesPerMinute
            PickupDirectoryMaxRecipientsPerMessage          = $TransportService.PickupDirectoryMaxRecipientsPerMessage
            PickupDirectoryPath                             = $TransportService.PickupDirectoryPath
            PipelineTracingEnabled                          = $TransportService.PipelineTracingEnabled
            PipelineTracingPath                             = $TransportService.PipelineTracingPath
            PipelineTracingSenderAddress                    = $TransportService.PipelineTracingSenderAddress
            PoisonMessageDetectionEnabled                   = $TransportService.PoisonMessageDetectionEnabled
            PoisonThreshold                                 = $TransportService.PoisonThreshold
            QueueLogMaxAge                                  = $TransportService.QueueLogMaxAge
            QueueLogMaxDirectorySize                        = $TransportService.QueueLogMaxDirectorySize
            QueueLogMaxFileSize                             = $TransportService.QueueLogMaxFileSize
            QueueLogPath                                    = $TransportService.QueueLogPath
            QueueMaxIdleTime                                = $TransportService.QueueMaxIdleTime
            ReceiveProtocolLogMaxAge                        = $TransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize              = $TransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize                   = $TransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                          = $TransportService.ReceiveProtocolLogPath
            RecipientValidationCacheEnabled                 = $TransportService.RecipientValidationCacheEnabled
            ReplayDirectoryPath                             = $TransportService.ReplayDirectoryPath
            RootDropDirectoryPath                           = $TransportService.RootDropDirectoryPath
            RoutingTableLogMaxAge                           = $TransportService.RoutingTableLogMaxAge
            RoutingTableLogMaxDirectorySize                 = $TransportService.RoutingTableLogMaxDirectorySize
            RoutingTableLogPath                             = $TransportService.RoutingTableLogPath
            SendProtocolLogMaxAge                           = $TransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize                 = $TransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize                      = $TransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                             = $TransportService.SendProtocolLogPath
            ServerStatisticsLogMaxAge                       = $TransportService.ServerStatisticsLogMaxAge
            ServerStatisticsLogMaxDirectorySize             = $TransportService.ServerStatisticsLogMaxDirectorySize
            ServerStatisticsLogMaxFileSize                  = $TransportService.ServerStatisticsLogMaxFileSize
            ServerStatisticsLogPath                         = $TransportService.ServerStatisticsLogPath
            TransientFailureRetryCount                      = $TransportService.TransientFailureRetryCount
            TransientFailureRetryInterval                   = $TransportService.TransientFailureRetryInterval.ToString()
            UseDowngradedExchangeServerAuth                 = $TransportService.UseDowngradedExchangeServerAuth
        }
    }
    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,
        
        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [System.String]
        $ActiveUserStatisticsLogPath,

        [System.Boolean]
        $AgentLogEnabled,

        [System.String]
        $AgentLogMaxAge,

        [System.String]
        $AgentLogMaxDirectorySize,

        [System.String]
        $AgentLogMaxFileSize,

        [System.String]
        $AgentLogPath,

        [System.Boolean]
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.String]
        $DelayNotificationTimeout,

        [System.Boolean]
        $DnsLogEnabled,

        [System.String]
        $DnsLogMaxAge,

        [System.String]
        $DnsLogMaxDirectorySize,

        [System.String]
        $DnsLogMaxFileSize,

        [System.String]
        $DnsLogPath,

        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [System.String]
        $ExternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $ExternalDNSProtocolOption,

        [System.String[]]
        $ExternalDNSServers,

        [System.String]
        $ExternalIPAddress,

        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [System.String]
        $InternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $InternalDNSProtocolOption,

        [System.String[]]
        $InternalDNSServers,

        [ValidateSet("None","Verbose")]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [System.Boolean]
        $IrmLogEnabled,

        [System.String]
        $IrmLogMaxAge,

        [System.String]
        $IrmLogMaxDirectorySize,

        [System.String]
        $IrmLogMaxFileSize,

        [System.String]
        $IrmLogPath,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Int32]
        $MaxConnectionRatePerMinute,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [System.String]
        $MessageExpirationTimeout,

        [System.String]
        $MessageRetryInterval,

        [System.Boolean]
        $MessageTrackingLogEnabled,

        [System.String]
        $MessageTrackingLogMaxAge,

        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [System.String]
        $MessageTrackingLogMaxFileSize,

        [System.String]
        $MessageTrackingLogPath,

        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [System.String]
        $PickupDirectoryPath,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [System.String]
        $QueueLogMaxAge,

        [System.String]
        $QueueLogMaxDirectorySize,

        [System.String]
        $QueueLogMaxFileSize,

        [System.String]
        $QueueLogPath,

        [System.String]
        $QueueMaxIdleTime,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [System.String]
        $ReplayDirectoryPath,

        [System.String]
        $RootDropDirectoryPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath,

        [System.String]
        $ServerStatisticsLogMaxAge,

        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [System.String]
        $ServerStatisticsLogPath,

        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [System.String]
        $TransientFailureRetryInterval,

        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-TransportService" -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    try
    {

        #if PipelineTracingSenderAddress exists and is $null remove it from $PSBoundParameters and add argument
        if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress'))
        {
            if ([string]::IsNullOrEmpty($PipelineTracingSenderAddress))
            {
                Write-Verbose "PipelineTracingSenderAddress is NULL"
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "PipelineTracingSenderAddress"
                $Arguments += '-PipelineTracingSenderAddress $null '
            }
        }

        #if ExternalIPAddress exists and is $null remove it from $PSBoundParameters and add argument
        if ($PSBoundParameters.ContainsKey('ExternalIPAddress'))
        {
            if ([string]::IsNullOrEmpty($ExternalIPAddress))
            {
                Write-Verbose "ExternalIPAddress is NULL"
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "ExternalIPAddress"
                $Arguments += '-ExternalIPAddress $null '
            }
        }

        #if InternalDNSServers exists and is $null remove it from $PSBoundParameters and add argument
        if ($PSBoundParameters.ContainsKey('InternalDNSServers'))
        {
            if ([string]::IsNullOrEmpty($InternalDNSServers))
            {
                Write-Verbose "InternalDNSServers is NULL"
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "InternalDNSServers"
                $Arguments += '-InternalDNSServers $null '
            }
        }

        #if ExternalDNSServers exists and is $null remove it from $PSBoundParameters and add argument
        if ($PSBoundParameters.ContainsKey('ExternalDNSServers'))
        {
            if ([string]::IsNullOrEmpty($ExternalDNSServers))
            {
                Write-Verbose "ExternalDNSServers is NULL"
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "ExternalDNSServers"
                $Arguments += '-ExternalDNSServers $null '
            }
        }

        if ($arguments)
        {
            $expression = 'Set-TransportService @PSBoundParameters '+$Arguments
            Invoke-Expression $expression
        }
        else
        {
            Set-TransportService @PSBoundParameters
        }
    }
    catch
    {
        Write-Verbose "The following exception was thrown:$($_.Exception.Message)"
    }
    
    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Restart service MSExchangeTransport"
        Restart-Service -Name MSExchangeTransport -WarningAction SilentlyContinue
    }
    Else
    {
        Write-Warning "The configuration will not take effect until the MSExchangeTransport service is manually restarted."
    }

}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [System.String]
        $ActiveUserStatisticsLogPath,

        [System.Boolean]
        $AgentLogEnabled,

        [System.String]
        $AgentLogMaxAge,

        [System.String]
        $AgentLogMaxDirectorySize,

        [System.String]
        $AgentLogMaxFileSize,

        [System.String]
        $AgentLogPath,

        [System.Boolean]
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.String]
        $DelayNotificationTimeout,

        [System.Boolean]
        $DnsLogEnabled,

        [System.String]
        $DnsLogMaxAge,

        [System.String]
        $DnsLogMaxDirectorySize,

        [System.String]
        $DnsLogMaxFileSize,

        [System.String]
        $DnsLogPath,

        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [System.String]
        $ExternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $ExternalDNSProtocolOption,

        [System.String[]]
        $ExternalDNSServers,

        [System.String]
        $ExternalIPAddress,

        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [System.String]
        $InternalDNSAdapterGuid,

        [ValidateSet("Any","UseTcpOnly","UseUdpOnly")]
        [System.String]
        $InternalDNSProtocolOption,

        [System.String[]]
        $InternalDNSServers,

        [ValidateSet("None","Verbose")]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [System.Boolean]
        $IrmLogEnabled,

        [System.String]
        $IrmLogMaxAge,

        [System.String]
        $IrmLogMaxDirectorySize,

        [System.String]
        $IrmLogMaxFileSize,

        [System.String]
        $IrmLogPath,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Int32]
        $MaxConnectionRatePerMinute,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [System.String]
        $MessageExpirationTimeout,

        [System.String]
        $MessageRetryInterval,

        [System.Boolean]
        $MessageTrackingLogEnabled,

        [System.String]
        $MessageTrackingLogMaxAge,

        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [System.String]
        $MessageTrackingLogMaxFileSize,

        [System.String]
        $MessageTrackingLogPath,

        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [System.String]
        $PickupDirectoryPath,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [System.String]
        $QueueLogMaxAge,

        [System.String]
        $QueueLogMaxDirectorySize,

        [System.String]
        $QueueLogMaxFileSize,

        [System.String]
        $QueueLogPath,

        [System.String]
        $QueueMaxIdleTime,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [System.String]
        $ReplayDirectoryPath,

        [System.String]
        $RootDropDirectoryPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath,

        [System.String]
        $ServerStatisticsLogMaxAge,

        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [System.String]
        $ServerStatisticsLogPath,

        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [System.String]
        $TransientFailureRetryInterval,

        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-TransportService" -VerbosePreference $VerbosePreference

    $TransportService = Get-TransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $TransportService)
    {

        if (!(VerifySetting -Name "ActiveUserStatisticsLogMaxAge" -Type "Timespan" -ExpectedValue $ActiveUserStatisticsLogMaxAge -ActualValue $TransportService.ActiveUserStatisticsLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ActiveUserStatisticsLogMaxDirectorySize" -Type "ByteQuantifiedSize" -ExpectedValue $ActiveUserStatisticsLogMaxDirectorySize -ActualValue $TransportService.ActiveUserStatisticsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ActiveUserStatisticsLogMaxFileSize" -Type "ByteQuantifiedSize" -ExpectedValue $ActiveUserStatisticsLogMaxFileSize -ActualValue $TransportService.ActiveUserStatisticsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }   

        if (!(VerifySetting -Name "ActiveUserStatisticsLogPath" -Type "String" -ExpectedValue $ActiveUserStatisticsLogPath -ActualValue $TransportService.ActiveUserStatisticsLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }   

        if (!(VerifySetting -Name "AgentLogEnabled" -Type "Boolean" -ExpectedValue $AgentLogEnabled -ActualValue $TransportService.AgentLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AgentLogMaxAge" -Type "Timespan" -ExpectedValue $AgentLogMaxAge -ActualValue $TransportService.AgentLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AgentLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $AgentLogMaxDirectorySize -ActualValue $TransportService.AgentLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AgentLogMaxFileSize" -Type "Unlimited" -ExpectedValue $AgentLogMaxFileSize -ActualValue $TransportService.AgentLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AgentLogPath" -Type "String" -ExpectedValue $AgentLogPath -ActualValue $TransportService.AgentLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogEnabled" -Type "Boolean" -ExpectedValue $ConnectivityLogEnabled -ActualValue $TransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxAge" -Type "Timespan" -ExpectedValue $ConnectivityLogMaxAge -ActualValue $TransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $TransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxFileSize" -Type "Unlimited" -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $TransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogPath" -Type "String" -ExpectedValue $ConnectivityLogPath -ActualValue $TransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ContentConversionTracingEnabled" -Type "Boolean" -ExpectedValue $ContentConversionTracingEnabled -ActualValue $TransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DelayNotificationTimeout" -Type "TimeSpan" -ExpectedValue $DelayNotificationTimeout -ActualValue $TransportService.DelayNotificationTimeout -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DnsLogEnabled" -Type "Boolean" -ExpectedValue $DnsLogEnabled -ActualValue $TransportService.DnsLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DnsLogMaxAge" -Type "TimeSpan" -ExpectedValue $DnsLogMaxAge -ActualValue $TransportService.DnsLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DnsLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $DnsLogMaxDirectorySize -ActualValue $TransportService.DnsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DnsLogMaxFileSize" -Type "Unlimited" -ExpectedValue $DnsLogMaxFileSize -ActualValue $TransportService.DnsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DnsLogPath" -Type "String" -ExpectedValue $DnsLogPath -ActualValue $TransportService.DnsLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalDNSAdapterEnabled" -Type "Boolean" -ExpectedValue $ExternalDNSAdapterEnabled -ActualValue $TransportService.ExternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalDNSAdapterGuid" -Type "String" -ExpectedValue $ExternalDNSAdapterGuid -ActualValue $TransportService.ExternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
 
        if (!(VerifySetting -Name "ExternalDNSProtocolOption" -Type "String" -ExpectedValue $ExternalDNSProtocolOption -ActualValue $TransportService.ExternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalDNSServers" -Type "IPAddresses" -ExpectedValue $ExternalDNSServers -ActualValue $TransportService.ExternalDNSServers.IPAddressToString -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalIPAddress" -Type "IPAddress" -ExpectedValue $ExternalIPAddress -ActualValue $TransportService.ExternalIPAddress -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalDNSAdapterEnabled" -Type "Boolean" -ExpectedValue $InternalDNSAdapterEnabled -ActualValue $TransportService.InternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalDNSAdapterGuid" -Type "String" -ExpectedValue $InternalDNSAdapterGuid -ActualValue $TransportService.InternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalDNSProtocolOption" -Type "String" -ExpectedValue $InternalDNSProtocolOption -ActualValue $TransportService.InternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalDNSServers" -Type "IPAddresses" -ExpectedValue $InternalDNSServers -ActualValue $TransportService.InternalDNSServers.IPAddressToString -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IntraOrgConnectorProtocolLoggingLevel" -Type "String" -ExpectedValue $IntraOrgConnectorProtocolLoggingLevel -ActualValue $TransportService.IntraOrgConnectorProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IntraOrgConnectorSmtpMaxMessagesPerConnection" -Type "Int" -ExpectedValue $IntraOrgConnectorSmtpMaxMessagesPerConnection -ActualValue $TransportService.IntraOrgConnectorSmtpMaxMessagesPerConnection -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IrmLogEnabled" -Type "Boolean" -ExpectedValue $IrmLogEnabled -ActualValue $TransportService.IrmLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IrmLogMaxAge" -Type "TimeSpan" -ExpectedValue $IrmLogMaxAge -ActualValue $TransportService.IrmLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IrmLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $IrmLogMaxDirectorySize -ActualValue $TransportService.IrmLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IrmLogMaxFileSize" -Type "ByteQuantifiedSize" -ExpectedValue $IrmLogMaxFileSize -ActualValue $TransportService.IrmLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IrmLogPath" -Type "String" -ExpectedValue $IrmLogPath -ActualValue $TransportService.IrmLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxConcurrentMailboxDeliveries" -Type "Int" -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $TransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxConcurrentMailboxSubmissions" -Type "Int" -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $TransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxConnectionRatePerMinute" -Type "Int" -ExpectedValue $MaxConnectionRatePerMinute -ActualValue $TransportService.MaxConnectionRatePerMinute -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxOutboundConnections" -Type "Unlimited" -ExpectedValue $MaxOutboundConnections -ActualValue $TransportService.MaxOutboundConnections -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxPerDomainOutboundConnections" -Type "Unlimited" -ExpectedValue $MaxPerDomainOutboundConnections -ActualValue $TransportService.MaxPerDomainOutboundConnections -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageExpirationTimeout" -Type "TimeSpan" -ExpectedValue $MessageExpirationTimeout -ActualValue $TransportService.MessageExpirationTimeout -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageRetryInterval" -Type "TimeSpan" -ExpectedValue $MessageRetryInterval -ActualValue $TransportService.MessageRetryInterval -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogEnabled" -Type "Boolean" -ExpectedValue $MessageTrackingLogEnabled -ActualValue $TransportService.MessageTrackingLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogMaxAge" -Type "TimeSpan" -ExpectedValue $MessageTrackingLogMaxAge -ActualValue $TransportService.MessageTrackingLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $MessageTrackingLogMaxDirectorySize -ActualValue $TransportService.MessageTrackingLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogMaxFileSize" -Type "ByteQuantifiedSize" -ExpectedValue $MessageTrackingLogMaxFileSize -ActualValue $TransportService.MessageTrackingLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogPath" -Type "String" -ExpectedValue $MessageTrackingLogPath -ActualValue $TransportService.MessageTrackingLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MessageTrackingLogSubjectLoggingEnabled" -Type "Boolean" -ExpectedValue $MessageTrackingLogSubjectLoggingEnabled -ActualValue $TransportService.MessageTrackingLogSubjectLoggingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "OutboundConnectionFailureRetryInterval" -Type "TimeSpan" -ExpectedValue $OutboundConnectionFailureRetryInterval -ActualValue $TransportService.OutboundConnectionFailureRetryInterval -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PickupDirectoryMaxHeaderSize" -Type "ByteQuantifiedSize" -ExpectedValue $PickupDirectoryMaxHeaderSize -ActualValue $TransportService.PickupDirectoryMaxHeaderSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PickupDirectoryMaxMessagesPerMinute" -Type "Int" -ExpectedValue $PickupDirectoryMaxMessagesPerMinute -ActualValue $TransportService.PickupDirectoryMaxMessagesPerMinute -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PickupDirectoryMaxRecipientsPerMessage" -Type "Int" -ExpectedValue $PickupDirectoryMaxRecipientsPerMessage -ActualValue $TransportService.PickupDirectoryMaxRecipientsPerMessage -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
        
        if (!(VerifySetting -Name "PickupDirectoryPath" -Type "String" -ExpectedValue $PickupDirectoryPath -ActualValue $TransportService.PickupDirectoryPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PipelineTracingEnabled" -Type "Boolean" -ExpectedValue $PipelineTracingEnabled -ActualValue $TransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PipelineTracingPath" -Type "String" -ExpectedValue $PipelineTracingPath -ActualValue $TransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }


        if (!(VerifySetting -Name "PipelineTracingSenderAddress" -Type "SMTPAddress" -ExpectedValue $PipelineTracingSenderAddress -ActualValue $TransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PoisonMessageDetectionEnabled" -Type "Boolean" -ExpectedValue $PoisonMessageDetectionEnabled -ActualValue $TransportService.PoisonMessageDetectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PoisonThreshold" -Type "Int" -ExpectedValue $PoisonThreshold -ActualValue $TransportService.PoisonThreshold -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "QueueLogMaxAge" -Type "TimeSpan" -ExpectedValue $QueueLogMaxAge -ActualValue $TransportService.QueueLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "QueueLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $QueueLogMaxDirectorySize -ActualValue $TransportService.QueueLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "QueueLogMaxFileSize" -Type "Unlimited" -ExpectedValue $QueueLogMaxFileSize -ActualValue $TransportService.QueueLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "QueueLogPath" -Type "String" -ExpectedValue $QueueLogPath -ActualValue $TransportService.QueueLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "QueueMaxIdleTime" -Type "TimeSpan" -ExpectedValue $QueueMaxIdleTime -ActualValue $TransportService.QueueMaxIdleTime -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxAge" -Type "TimeSpan" -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $TransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $TransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxFileSize" -Type "Unlimited" -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $TransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogPath" -Type "String" -ExpectedValue $ReceiveProtocolLogPath -ActualValue $TransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RecipientValidationCacheEnabled" -Type "Boolean" -ExpectedValue $RecipientValidationCacheEnabled -ActualValue $TransportService.RecipientValidationCacheEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
        if (!(VerifySetting -Name "ReplayDirectoryPath" -Type "String" -ExpectedValue $ReplayDirectoryPath -ActualValue $TransportService.ReplayDirectoryPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RootDropDirectoryPath" -Type "String" -ExpectedValue $RootDropDirectoryPath -ActualValue $TransportService.RootDropDirectoryPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RoutingTableLogMaxAge" -Type "TimeSpan" -ExpectedValue $RoutingTableLogMaxAge -ActualValue $TransportService.RoutingTableLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RoutingTableLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $RoutingTableLogMaxDirectorySize -ActualValue $TransportService.RoutingTableLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RoutingTableLogPath" -Type "String" -ExpectedValue $RoutingTableLogPath -ActualValue $TransportService.RoutingTableLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxAge" -Type "TimeSpan" -ExpectedValue $SendProtocolLogMaxAge -ActualValue $TransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $TransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxFileSize" -Type "Unlimited" -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $TransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogPath" -Type "String" -ExpectedValue $SendProtocolLogPath -ActualValue $TransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ServerStatisticsLogMaxAge" -Type "TimeSpan" -ExpectedValue $ServerStatisticsLogMaxAge -ActualValue $TransportService.ServerStatisticsLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ServerStatisticsLogMaxDirectorySize" -Type "ByteQuantifiedSize" -ExpectedValue $ServerStatisticsLogMaxDirectorySize -ActualValue $TransportService.ServerStatisticsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ServerStatisticsLogMaxFileSize" -Type "ByteQuantifiedSize" -ExpectedValue $ServerStatisticsLogMaxFileSize -ActualValue $TransportService.ServerStatisticsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ServerStatisticsLogPath" -Type "String" -ExpectedValue $ServerStatisticsLogPath -ActualValue $TransportService.ServerStatisticsLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "TransientFailureRetryCount" -Type "Int" -ExpectedValue $TransientFailureRetryCount -ActualValue $TransportService.TransientFailureRetryCount -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "TransientFailureRetryInterval" -Type "TimeSpan" -ExpectedValue $TransientFailureRetryInterval -ActualValue $TransportService.TransientFailureRetryInterval -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "UseDowngradedExchangeServerAuth" -Type "Boolean" -ExpectedValue $UseDowngradedExchangeServerAuth -ActualValue $TransportService.UseDowngradedExchangeServerAuth -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

    }
    else
    {
        return $false
    }
    return $true
}

function CompareIPAddressewithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([System.Net.IPAddress]$IPAddress, [String]$String)
    if (($null -eq $IPAddress -and !([string]::IsNullOrEmpty($String))) -or ($null -ne $IPAddress -and [string]::IsNullOrEmpty($String)))
    {
        $returnValue = $false
    }
    elseif ($null -eq $IPAddress -and [string]::IsNullOrEmpty($String))
    {
        $returnValue = $true
    }
    else
    {
        $returnValue =($IPAddress.Equals([System.Net.IPAddress]::Parse($string)))
    }
    
    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $IPAddress -ExpectedValue $ExpectedValue -ActualValue $IPAddress -VerbosePreference $VerbosePreference
    }
    return $returnValue
}

function CompareSmtpAdresswithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param($SmtpAddress,[String]$String)
    if (($null -eq $SmtpAddress) -and ([string]::IsNullOrEmpty($String)))
    {
        Write-Verbose "Expected and actual value is empty, therefore equal!"
        return $true
    }
    elseif (($null -eq $SmtpAddress) -and -not ([string]::IsNullOrEmpty($String)))
    {
        return $false
    }
    elseif ($SmtpAddress.Gettype() -eq [Microsoft.Exchange.Data.SmtpAddress])
    {
        if ([string]::IsNullOrEmpty($String))
        {
            return $false
        }
        else
        {
            return($SmtpAddress.Equals([Microsoft.Exchange.Data.SmtpAddress]::Parse($string)))
        }
    }
    else
    {
        Write-Verbose "No type of [Microsoft.Exchange.Data.SmtpAddress]!"
        return $false
    }
}

Export-ModuleMember -Function *-TargetResource
