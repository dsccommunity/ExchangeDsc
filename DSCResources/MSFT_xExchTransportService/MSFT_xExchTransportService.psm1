function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogPath,

        [Parameter()]
        [System.Boolean]
        $AgentLogEnabled,

        [Parameter()]
        [System.String]
        $AgentLogMaxAge,

        [Parameter()]
        [System.String]
        $AgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $AgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $AgentLogPath,

        [Parameter()]
        [System.Boolean]
        $AntispamAgentsEnabled,

        [Parameter()]
        [System.Boolean]
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.String]
        $DelayNotificationTimeout,

        [Parameter()]
        [System.Boolean]
        $DnsLogEnabled,

        [Parameter()]
        [System.String]
        $DnsLogMaxAge,

        [Parameter()]
        [System.String]
        $DnsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $DnsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $DnsLogPath,

        [Parameter()]
        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $ExternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $ExternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $ExternalDNSServers,

        [Parameter()]
        [System.String]
        $ExternalIPAddress,

        [Parameter()]
        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $InternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $InternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $InternalDNSServers,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Int32]
        $MaxConnectionRatePerMinute,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [Parameter()]
        [System.String]
        $MessageExpirationTimeout,

        [Parameter()]
        [System.String]
        $MessageRetryInterval,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogEnabled,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxAge,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogPath,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [Parameter()]
        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [Parameter()]
        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [Parameter()]
        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [Parameter()]
        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [Parameter()]
        [System.String]
        $PickupDirectoryPath,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [Parameter()]
        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [Parameter()]
        [System.String]
        $QueueLogMaxAge,

        [Parameter()]
        [System.String]
        $QueueLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $QueueLogMaxFileSize,

        [Parameter()]
        [System.String]
        $QueueLogPath,

        [Parameter()]
        [System.String]
        $QueueMaxIdleTime,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [Parameter()]
        [System.String]
        $ReplayDirectoryPath,

        [Parameter()]
        [System.String]
        $RootDropDirectoryPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogPath,

        [Parameter()]
        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval,

        [Parameter()]
        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-TransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    $TransportService = Get-TransportService $Identity -ErrorAction SilentlyContinue
    if ($null -ne $TransportService)
    {
        $returnValue = @{
            Identity                                        = [System.String] $Identity
            ActiveUserStatisticsLogMaxAge                   = [System.String] $TransportService.ActiveUserStatisticsLogMaxAge
            ActiveUserStatisticsLogMaxDirectorySize         = [System.String] $TransportService.ActiveUserStatisticsLogMaxDirectorySize
            ActiveUserStatisticsLogMaxFileSize              = [System.String] $TransportService.ActiveUserStatisticsLogMaxFileSize
            ActiveUserStatisticsLogPath                     = [System.String] $TransportService.ActiveUserStatisticsLogPath
            AgentLogEnabled                                 = [System.Boolean] $TransportService.AgentLogEnabled
            AgentLogMaxAge                                  = [System.String] $TransportService.AgentLogMaxAge
            AgentLogMaxDirectorySize                        = [System.String] $TransportService.AgentLogMaxDirectorySize
            AgentLogMaxFileSize                             = [System.String] $TransportService.AgentLogMaxFileSize
            AgentLogPath                                    = [System.String] $TransportService.AgentLogPath
            AntispamAgentsEnabled                           = [System.Boolean] $TransportService.AntispamAgentsEnabled
            ConnectivityLogEnabled                          = [System.Boolean] $TransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                           = [System.String] $TransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize                 = [System.String] $TransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize                      = [System.String] $TransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                             = [System.String] $TransportService.ConnectivityLogPath
            ContentConversionTracingEnabled                 = [System.Boolean] $TransportService.ContentConversionTracingEnabled
            DelayNotificationTimeout                        = [System.String] $TransportService.DelayNotificationTimeout
            DnsLogEnabled                                   = [System.Boolean] $TransportService.DnsLogEnabled
            DnsLogMaxAge                                    = [System.String] $TransportService.DnsLogMaxAge
            DnsLogMaxDirectorySize                          = [System.String] $TransportService.DnsLogMaxDirectorySize
            DnsLogMaxFileSize                               = [System.String] $TransportService.DnsLogMaxFileSize
            DnsLogPath                                      = [System.String] $TransportService.DnsLogPath
            ExternalDNSAdapterEnabled                       = [System.Boolean] $TransportService.ExternalDNSAdapterEnabled
            ExternalDNSAdapterGuid                          = [System.String] $TransportService.ExternalDNSAdapterGuid
            ExternalDNSProtocolOption                       = [System.String] $TransportService.ExternalDNSProtocolOption
            ExternalDNSServers                              = [System.String[]] $TransportService.ExternalDNSServers
            ExternalIPAddress                               = [System.String] $TransportService.ExternalIPAddress
            InternalDNSAdapterEnabled                       = [System.Boolean] $TransportService.InternalDNSAdapterEnabled
            InternalDNSAdapterGuid                          = [System.String] $TransportService.InternalDNSAdapterGuid
            InternalDNSProtocolOption                       = [System.String] $TransportService.InternalDNSProtocolOption
            InternalDNSServers                              = [System.String[]] $TransportService.InternalDNSServers
            IntraOrgConnectorProtocolLoggingLevel           = [System.String] $TransportService.IntraOrgConnectorProtocolLoggingLevel
            IntraOrgConnectorSmtpMaxMessagesPerConnection   = [System.Int32] $TransportService.IntraOrgConnectorSmtpMaxMessagesPerConnection
            IrmLogEnabled                                   = [System.Boolean] $TransportService.IrmLogEnabled
            IrmLogMaxAge                                    = [System.String] $TransportService.IrmLogMaxAge
            IrmLogMaxDirectorySize                          = [System.String] $TransportService.IrmLogMaxDirectorySize
            IrmLogMaxFileSize                               = [System.String] $TransportService.IrmLogMaxFileSize
            IrmLogPath                                      = [System.String] $TransportService.IrmLogPath
            MaxConcurrentMailboxDeliveries                  = [System.Int32] $TransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions                 = [System.Int32] $TransportService.MaxConcurrentMailboxSubmissions
            MaxConnectionRatePerMinute                      = [System.Int32] $TransportService.MaxConnectionRatePerMinute
            MaxOutboundConnections                          = [System.String] $TransportService.MaxOutboundConnections
            MaxPerDomainOutboundConnections                 = [System.String] $TransportService.MaxPerDomainOutboundConnections
            MessageExpirationTimeout                        = [System.String] $TransportService.MessageExpirationTimeout
            MessageRetryInterval                            = [System.String] $TransportService.MessageRetryInterval
            MessageTrackingLogEnabled                       = [System.Boolean] $TransportService.MessageTrackingLogEnabled
            MessageTrackingLogMaxAge                        = [System.String] $TransportService.MessageTrackingLogMaxAge
            MessageTrackingLogMaxDirectorySize              = [System.String] $TransportService.MessageTrackingLogMaxDirectorySize
            MessageTrackingLogMaxFileSize                   = [System.String] $TransportService.MessageTrackingLogMaxFileSize
            MessageTrackingLogPath                          = [System.String] $TransportService.MessageTrackingLogPath
            MessageTrackingLogSubjectLoggingEnabled         = [System.Boolean] $TransportService.MessageTrackingLogSubjectLoggingEnabled
            OutboundConnectionFailureRetryInterval          = [System.String] $TransportService.OutboundConnectionFailureRetryInterval
            PickupDirectoryMaxHeaderSize                    = [System.String] $TransportService.PickupDirectoryMaxHeaderSize
            PickupDirectoryMaxMessagesPerMinute             = [System.Int32] $TransportService.PickupDirectoryMaxMessagesPerMinute
            PickupDirectoryMaxRecipientsPerMessage          = [System.Int32] $TransportService.PickupDirectoryMaxRecipientsPerMessage
            PickupDirectoryPath                             = [System.String] $TransportService.PickupDirectoryPath
            PipelineTracingEnabled                          = [System.Boolean] $TransportService.PipelineTracingEnabled
            PipelineTracingPath                             = [System.String] $TransportService.PipelineTracingPath
            PipelineTracingSenderAddress                    = [System.String] $TransportService.PipelineTracingSenderAddress
            PoisonMessageDetectionEnabled                   = [System.Boolean] $TransportService.PoisonMessageDetectionEnabled
            PoisonThreshold                                 = [System.Int32] $TransportService.PoisonThreshold
            QueueLogMaxAge                                  = [System.String] $TransportService.QueueLogMaxAge
            QueueLogMaxDirectorySize                        = [System.String] $TransportService.QueueLogMaxDirectorySize
            QueueLogMaxFileSize                             = [System.String] $TransportService.QueueLogMaxFileSize
            QueueLogPath                                    = [System.String] $TransportService.QueueLogPath
            QueueMaxIdleTime                                = [System.String] $TransportService.QueueMaxIdleTime
            ReceiveProtocolLogMaxAge                        = [System.String] $TransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize              = [System.String] $TransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize                   = [System.String] $TransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                          = [System.String] $TransportService.ReceiveProtocolLogPath
            RecipientValidationCacheEnabled                 = [System.Boolean] $TransportService.RecipientValidationCacheEnabled
            ReplayDirectoryPath                             = [System.String] $TransportService.ReplayDirectoryPath
            RootDropDirectoryPath                           = [System.String] $TransportService.RootDropDirectoryPath
            RoutingTableLogMaxAge                           = [System.String] $TransportService.RoutingTableLogMaxAge
            RoutingTableLogMaxDirectorySize                 = [System.String] $TransportService.RoutingTableLogMaxDirectorySize
            RoutingTableLogPath                             = [System.String] $TransportService.RoutingTableLogPath
            SendProtocolLogMaxAge                           = [System.String] $TransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize                 = [System.String] $TransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize                      = [System.String] $TransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                             = [System.String] $TransportService.SendProtocolLogPath
            ServerStatisticsLogMaxAge                       = [System.String] $TransportService.ServerStatisticsLogMaxAge
            ServerStatisticsLogMaxDirectorySize             = [System.String] $TransportService.ServerStatisticsLogMaxDirectorySize
            ServerStatisticsLogMaxFileSize                  = [System.String] $TransportService.ServerStatisticsLogMaxFileSize
            ServerStatisticsLogPath                         = [System.String] $TransportService.ServerStatisticsLogPath
            TransientFailureRetryCount                      = [System.Int32] $TransportService.TransientFailureRetryCount
            TransientFailureRetryInterval                   = [System.String] $TransportService.TransientFailureRetryInterval.ToString()
            UseDowngradedExchangeServerAuth                 = [System.Boolean] $TransportService.UseDowngradedExchangeServerAuth
        }
    }
    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogPath,

        [Parameter()]
        [System.Boolean]
        $AgentLogEnabled,

        [Parameter()]
        [System.String]
        $AgentLogMaxAge,

        [Parameter()]
        [System.String]
        $AgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $AgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $AgentLogPath,

        [Parameter()]
        [System.Boolean]
        $AntispamAgentsEnabled,

        [Parameter()]
        [System.Boolean]
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.String]
        $DelayNotificationTimeout,

        [Parameter()]
        [System.Boolean]
        $DnsLogEnabled,

        [Parameter()]
        [System.String]
        $DnsLogMaxAge,

        [Parameter()]
        [System.String]
        $DnsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $DnsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $DnsLogPath,

        [Parameter()]
        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $ExternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $ExternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $ExternalDNSServers,

        [Parameter()]
        [System.String]
        $ExternalIPAddress,

        [Parameter()]
        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $InternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $InternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $InternalDNSServers,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Int32]
        $MaxConnectionRatePerMinute,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [Parameter()]
        [System.String]
        $MessageExpirationTimeout,

        [Parameter()]
        [System.String]
        $MessageRetryInterval,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogEnabled,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxAge,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogPath,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [Parameter()]
        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [Parameter()]
        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [Parameter()]
        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [Parameter()]
        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [Parameter()]
        [System.String]
        $PickupDirectoryPath,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [Parameter()]
        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [Parameter()]
        [System.String]
        $QueueLogMaxAge,

        [Parameter()]
        [System.String]
        $QueueLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $QueueLogMaxFileSize,

        [Parameter()]
        [System.String]
        $QueueLogPath,

        [Parameter()]
        [System.String]
        $QueueMaxIdleTime,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [Parameter()]
        [System.String]
        $ReplayDirectoryPath,

        [Parameter()]
        [System.String]
        $RootDropDirectoryPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogPath,

        [Parameter()]
        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval,

        [Parameter()]
        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-TransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # If PipelineTracingSenderAddress exists and is $null remove it from $PSBoundParameters and add argument
    if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress'))
    {
        if ([System.String]::IsNullOrEmpty($PipelineTracingSenderAddress))
        {
            Write-Verbose -Message 'PipelineTracingSenderAddress is NULL'
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'PipelineTracingSenderAddress'
            $PSBoundParameters['PipelineTracingSenderAddress'] = $null
        }
    }

    # If ExternalIPAddress exists and is $null remove it from $PSBoundParameters and add argument
    if ($PSBoundParameters.ContainsKey('ExternalIPAddress'))
    {
        if ([System.String]::IsNullOrEmpty($ExternalIPAddress))
        {
            Write-Verbose -Message 'ExternalIPAddress is NULL'
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'ExternalIPAddress'
            $PSBoundParameters['ExternalIPAddress'] = $null
        }
    }

    # If InternalDNSServers exists and is $null remove it from $PSBoundParameters and add argument
    if ($PSBoundParameters.ContainsKey('InternalDNSServers'))
    {
        if ([System.String]::IsNullOrEmpty($InternalDNSServers))
        {
            Write-Verbose -Message 'InternalDNSServers is NULL'
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'InternalDNSServers'
            $PSBoundParameters['InternalDNSServers'] = $null
        }
    }

    # If ExternalDNSServers exists and is $null remove it from $PSBoundParameters and add argument
    if ($PSBoundParameters.ContainsKey('ExternalDNSServers'))
    {
        if ([System.String]::IsNullOrEmpty($ExternalDNSServers))
        {
            Write-Verbose -Message 'ExternalDNSServers is NULL'
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'ExternalDNSServers'
            $PSBoundParameters['ExternalDNSServers'] = $null
        }
    }

    Set-TransportService @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restart service MSExchangeTransport'
        Restart-Service -Name MSExchangeTransport -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until the MSExchangeTransport service is manually restarted.'
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ActiveUserStatisticsLogPath,

        [Parameter()]
        [System.Boolean]
        $AgentLogEnabled,

        [Parameter()]
        [System.String]
        $AgentLogMaxAge,

        [Parameter()]
        [System.String]
        $AgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $AgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $AgentLogPath,

        [Parameter()]
        [System.Boolean]
        $AntispamAgentsEnabled,

        [Parameter()]
        [System.Boolean]
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.String]
        $DelayNotificationTimeout,

        [Parameter()]
        [System.Boolean]
        $DnsLogEnabled,

        [Parameter()]
        [System.String]
        $DnsLogMaxAge,

        [Parameter()]
        [System.String]
        $DnsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $DnsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $DnsLogPath,

        [Parameter()]
        [System.Boolean]
        $ExternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $ExternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $ExternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $ExternalDNSServers,

        [Parameter()]
        [System.String]
        $ExternalIPAddress,

        [Parameter()]
        [System.Boolean]
        $InternalDNSAdapterEnabled,

        [Parameter()]
        [System.String]
        $InternalDNSAdapterGuid,

        [Parameter()]
        [ValidateSet('Any', 'UseTcpOnly', 'UseUdpOnly')]
        [System.String]
        $InternalDNSProtocolOption,

        [Parameter()]
        [System.String[]]
        $InternalDNSServers,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $IntraOrgConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Int32]
        $IntraOrgConnectorSmtpMaxMessagesPerConnection,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Int32]
        $MaxConnectionRatePerMinute,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxOutboundConnections,

        [Parameter()]
        [ValidateRange(1,2147483647)]
        [System.String]
        $MaxPerDomainOutboundConnections,

        [Parameter()]
        [System.String]
        $MessageExpirationTimeout,

        [Parameter()]
        [System.String]
        $MessageRetryInterval,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogEnabled,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxAge,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MessageTrackingLogPath,

        [Parameter()]
        [System.Boolean]
        $MessageTrackingLogSubjectLoggingEnabled,

        [Parameter()]
        [System.String]
        $OutboundConnectionFailureRetryInterval,

        [Parameter()]
        [System.String]
        $PickupDirectoryMaxHeaderSize,

        [Parameter()]
        [ValidateRange(1,20000)]
        [System.Int32]
        $PickupDirectoryMaxMessagesPerMinute,

        [Parameter()]
        [ValidateRange(1,10000)]
        [System.Int32]
        $PickupDirectoryMaxRecipientsPerMessage,

        [Parameter()]
        [System.String]
        $PickupDirectoryPath,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.Boolean]
        $PoisonMessageDetectionEnabled,

        [Parameter()]
        [ValidateRange(1,10)]
        [System.Int32]
        $PoisonThreshold,

        [Parameter()]
        [System.String]
        $QueueLogMaxAge,

        [Parameter()]
        [System.String]
        $QueueLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $QueueLogMaxFileSize,

        [Parameter()]
        [System.String]
        $QueueLogPath,

        [Parameter()]
        [System.String]
        $QueueMaxIdleTime,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.Boolean]
        $RecipientValidationCacheEnabled,

        [Parameter()]
        [System.String]
        $ReplayDirectoryPath,

        [Parameter()]
        [System.String]
        $RootDropDirectoryPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxAge,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ServerStatisticsLogPath,

        [Parameter()]
        [ValidateRange(1,15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval,

        [Parameter()]
        [System.Boolean]
        $UseDowngradedExchangeServerAuth
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-TransportService' -Verbose:$VerbosePreference

    $TransportService = Get-TransportService $Identity -ErrorAction SilentlyContinue

    $testResults = $true

    if ($null -eq $TransportService)
    {
        Write-Error -Message 'Unable to retrieve Transport Service for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'ActiveUserStatisticsLogMaxAge' -Type 'Timespan' -ExpectedValue $ActiveUserStatisticsLogMaxAge -ActualValue $TransportService.ActiveUserStatisticsLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ActiveUserStatisticsLogMaxDirectorySize' -Type 'ByteQuantifiedSize' -ExpectedValue $ActiveUserStatisticsLogMaxDirectorySize -ActualValue $TransportService.ActiveUserStatisticsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ActiveUserStatisticsLogMaxFileSize' -Type 'ByteQuantifiedSize' -ExpectedValue $ActiveUserStatisticsLogMaxFileSize -ActualValue $TransportService.ActiveUserStatisticsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ActiveUserStatisticsLogPath' -Type 'String' -ExpectedValue $ActiveUserStatisticsLogPath -ActualValue $TransportService.ActiveUserStatisticsLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogEnabled' -Type 'Boolean' -ExpectedValue $AgentLogEnabled -ActualValue $TransportService.AgentLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxAge' -Type 'Timespan' -ExpectedValue $AgentLogMaxAge -ActualValue $TransportService.AgentLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $AgentLogMaxDirectorySize -ActualValue $TransportService.AgentLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $AgentLogMaxFileSize -ActualValue $TransportService.AgentLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogPath' -Type 'String' -ExpectedValue $AgentLogPath -ActualValue $TransportService.AgentLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AntispamAgentsEnabled' -Type 'Boolean' -ExpectedValue $AntispamAgentsEnabled -ActualValue $TransportService.AntispamAgentsEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogEnabled' -Type 'Boolean' -ExpectedValue $ConnectivityLogEnabled -ActualValue $TransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxAge' -Type 'Timespan' -ExpectedValue $ConnectivityLogMaxAge -ActualValue $TransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $TransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $TransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogPath' -Type 'String' -ExpectedValue $ConnectivityLogPath -ActualValue $TransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ContentConversionTracingEnabled' -Type 'Boolean' -ExpectedValue $ContentConversionTracingEnabled -ActualValue $TransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DelayNotificationTimeout' -Type 'TimeSpan' -ExpectedValue $DelayNotificationTimeout -ActualValue $TransportService.DelayNotificationTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogEnabled' -Type 'Boolean' -ExpectedValue $DnsLogEnabled -ActualValue $TransportService.DnsLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxAge' -Type 'TimeSpan' -ExpectedValue $DnsLogMaxAge -ActualValue $TransportService.DnsLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $DnsLogMaxDirectorySize -ActualValue $TransportService.DnsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $DnsLogMaxFileSize -ActualValue $TransportService.DnsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogPath' -Type 'String' -ExpectedValue $DnsLogPath -ActualValue $TransportService.DnsLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSAdapterEnabled' -Type 'Boolean' -ExpectedValue $ExternalDNSAdapterEnabled -ActualValue $TransportService.ExternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSAdapterGuid' -Type 'String' -ExpectedValue $ExternalDNSAdapterGuid -ActualValue $TransportService.ExternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSProtocolOption' -Type 'String' -ExpectedValue $ExternalDNSProtocolOption -ActualValue $TransportService.ExternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSServers' -Type 'IPAddresses' -ExpectedValue $ExternalDNSServers -ActualValue $TransportService.ExternalDNSServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalIPAddress' -Type 'IPAddress' -ExpectedValue $ExternalIPAddress -ActualValue $TransportService.ExternalIPAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSAdapterEnabled' -Type 'Boolean' -ExpectedValue $InternalDNSAdapterEnabled -ActualValue $TransportService.InternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSAdapterGuid' -Type 'String' -ExpectedValue $InternalDNSAdapterGuid -ActualValue $TransportService.InternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSProtocolOption' -Type 'String' -ExpectedValue $InternalDNSProtocolOption -ActualValue $TransportService.InternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSServers' -Type 'IPAddresses' -ExpectedValue $InternalDNSServers -ActualValue $TransportService.InternalDNSServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IntraOrgConnectorProtocolLoggingLevel' -Type 'String' -ExpectedValue $IntraOrgConnectorProtocolLoggingLevel -ActualValue $TransportService.IntraOrgConnectorProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IntraOrgConnectorSmtpMaxMessagesPerConnection' -Type 'Int' -ExpectedValue $IntraOrgConnectorSmtpMaxMessagesPerConnection -ActualValue $TransportService.IntraOrgConnectorSmtpMaxMessagesPerConnection -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogEnabled' -Type 'Boolean' -ExpectedValue $IrmLogEnabled -ActualValue $TransportService.IrmLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxAge' -Type 'TimeSpan' -ExpectedValue $IrmLogMaxAge -ActualValue $TransportService.IrmLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $IrmLogMaxDirectorySize -ActualValue $TransportService.IrmLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxFileSize' -Type 'ByteQuantifiedSize' -ExpectedValue $IrmLogMaxFileSize -ActualValue $TransportService.IrmLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogPath' -Type 'String' -ExpectedValue $IrmLogPath -ActualValue $TransportService.IrmLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxDeliveries' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $TransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxSubmissions' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $TransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConnectionRatePerMinute' -Type 'Int' -ExpectedValue $MaxConnectionRatePerMinute -ActualValue $TransportService.MaxConnectionRatePerMinute -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxOutboundConnections' -Type 'Unlimited' -ExpectedValue $MaxOutboundConnections -ActualValue $TransportService.MaxOutboundConnections -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxPerDomainOutboundConnections' -Type 'Unlimited' -ExpectedValue $MaxPerDomainOutboundConnections -ActualValue $TransportService.MaxPerDomainOutboundConnections -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageExpirationTimeout' -Type 'TimeSpan' -ExpectedValue $MessageExpirationTimeout -ActualValue $TransportService.MessageExpirationTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageRetryInterval' -Type 'TimeSpan' -ExpectedValue $MessageRetryInterval -ActualValue $TransportService.MessageRetryInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogEnabled' -Type 'Boolean' -ExpectedValue $MessageTrackingLogEnabled -ActualValue $TransportService.MessageTrackingLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogMaxAge' -Type 'TimeSpan' -ExpectedValue $MessageTrackingLogMaxAge -ActualValue $TransportService.MessageTrackingLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $MessageTrackingLogMaxDirectorySize -ActualValue $TransportService.MessageTrackingLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogMaxFileSize' -Type 'ByteQuantifiedSize' -ExpectedValue $MessageTrackingLogMaxFileSize -ActualValue $TransportService.MessageTrackingLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogPath' -Type 'String' -ExpectedValue $MessageTrackingLogPath -ActualValue $TransportService.MessageTrackingLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageTrackingLogSubjectLoggingEnabled' -Type 'Boolean' -ExpectedValue $MessageTrackingLogSubjectLoggingEnabled -ActualValue $TransportService.MessageTrackingLogSubjectLoggingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'OutboundConnectionFailureRetryInterval' -Type 'TimeSpan' -ExpectedValue $OutboundConnectionFailureRetryInterval -ActualValue $TransportService.OutboundConnectionFailureRetryInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PickupDirectoryMaxHeaderSize' -Type 'ByteQuantifiedSize' -ExpectedValue $PickupDirectoryMaxHeaderSize -ActualValue $TransportService.PickupDirectoryMaxHeaderSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PickupDirectoryMaxMessagesPerMinute' -Type 'Int' -ExpectedValue $PickupDirectoryMaxMessagesPerMinute -ActualValue $TransportService.PickupDirectoryMaxMessagesPerMinute -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PickupDirectoryMaxRecipientsPerMessage' -Type 'Int' -ExpectedValue $PickupDirectoryMaxRecipientsPerMessage -ActualValue $TransportService.PickupDirectoryMaxRecipientsPerMessage -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PickupDirectoryPath' -Type 'String' -ExpectedValue $PickupDirectoryPath -ActualValue $TransportService.PickupDirectoryPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingEnabled' -Type 'Boolean' -ExpectedValue $PipelineTracingEnabled -ActualValue $TransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingPath' -Type 'String' -ExpectedValue $PipelineTracingPath -ActualValue $TransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }


        if (!(Test-ExchangeSetting -Name 'PipelineTracingSenderAddress' -Type 'SMTPAddress' -ExpectedValue $PipelineTracingSenderAddress -ActualValue $TransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PoisonMessageDetectionEnabled' -Type 'Boolean' -ExpectedValue $PoisonMessageDetectionEnabled -ActualValue $TransportService.PoisonMessageDetectionEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PoisonThreshold' -Type 'Int' -ExpectedValue $PoisonThreshold -ActualValue $TransportService.PoisonThreshold -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'QueueLogMaxAge' -Type 'TimeSpan' -ExpectedValue $QueueLogMaxAge -ActualValue $TransportService.QueueLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'QueueLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $QueueLogMaxDirectorySize -ActualValue $TransportService.QueueLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'QueueLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $QueueLogMaxFileSize -ActualValue $TransportService.QueueLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'QueueLogPath' -Type 'String' -ExpectedValue $QueueLogPath -ActualValue $TransportService.QueueLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'QueueMaxIdleTime' -Type 'TimeSpan' -ExpectedValue $QueueMaxIdleTime -ActualValue $TransportService.QueueMaxIdleTime -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $TransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $TransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $TransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogPath' -Type 'String' -ExpectedValue $ReceiveProtocolLogPath -ActualValue $TransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RecipientValidationCacheEnabled' -Type 'Boolean' -ExpectedValue $RecipientValidationCacheEnabled -ActualValue $TransportService.RecipientValidationCacheEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
        if (!(Test-ExchangeSetting -Name 'ReplayDirectoryPath' -Type 'String' -ExpectedValue $ReplayDirectoryPath -ActualValue $TransportService.ReplayDirectoryPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RootDropDirectoryPath' -Type 'String' -ExpectedValue $RootDropDirectoryPath -ActualValue $TransportService.RootDropDirectoryPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogMaxAge' -Type 'TimeSpan' -ExpectedValue $RoutingTableLogMaxAge -ActualValue $TransportService.RoutingTableLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $RoutingTableLogMaxDirectorySize -ActualValue $TransportService.RoutingTableLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogPath' -Type 'String' -ExpectedValue $RoutingTableLogPath -ActualValue $TransportService.RoutingTableLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $SendProtocolLogMaxAge -ActualValue $TransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $TransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $TransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogPath' -Type 'String' -ExpectedValue $SendProtocolLogPath -ActualValue $TransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ServerStatisticsLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ServerStatisticsLogMaxAge -ActualValue $TransportService.ServerStatisticsLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ServerStatisticsLogMaxDirectorySize' -Type 'ByteQuantifiedSize' -ExpectedValue $ServerStatisticsLogMaxDirectorySize -ActualValue $TransportService.ServerStatisticsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ServerStatisticsLogMaxFileSize' -Type 'ByteQuantifiedSize' -ExpectedValue $ServerStatisticsLogMaxFileSize -ActualValue $TransportService.ServerStatisticsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ServerStatisticsLogPath' -Type 'String' -ExpectedValue $ServerStatisticsLogPath -ActualValue $TransportService.ServerStatisticsLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'TransientFailureRetryCount' -Type 'Int' -ExpectedValue $TransientFailureRetryCount -ActualValue $TransportService.TransientFailureRetryCount -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'TransientFailureRetryInterval' -Type 'TimeSpan' -ExpectedValue $TransientFailureRetryInterval -ActualValue $TransportService.TransientFailureRetryInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'UseDowngradedExchangeServerAuth' -Type 'Boolean' -ExpectedValue $UseDowngradedExchangeServerAuth -ActualValue $TransportService.UseDowngradedExchangeServerAuth -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
