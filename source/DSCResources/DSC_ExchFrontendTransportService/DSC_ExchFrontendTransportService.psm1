<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the server that you want to modify.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the MSExchangeFrontEndTransport service
        after making changes. Defaults to $false.

    .PARAMETER AgentLogEnabled
        The AgentLogEnabled parameter specifies whether the agent log is
        enabled. The default value is $true.

    .PARAMETER AgentLogMaxAge
        The AgentLogMaxAge parameter specifies the maximum age for the agent
        log file. Log files older than the specified value are deleted. The
        default value is 7.00:00:00 or 7 days.

    .PARAMETER AgentLogMaxDirectorySize
        The AgentLogMaxDirectorySize parameter specifies the maximum size of
        all agent logs in the agent log directory. When a directory reaches its
        maximum file size, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER AgentLogMaxFileSize
        The AgentLogMaxFileSize parameter specifies the maximum size of each
        agent log file. When a log file reaches its maximum file size, a new
        log file is created. The default value is 10 MB.

    .PARAMETER AgentLogPath
        The AgentLogPath parameter specifies the default agent log directory
        location.

    .PARAMETER AntispamAgentsEnabled
        The AntispamAgentsEnabled parameter specifies whether anti-spam agents
        are installed on the server specified with the Identity parameter. The
        default value is $false for the Front End Transport service.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity
        log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the
        connectivity log file. Log files older than the specified value are
        deleted. The default value is 30 days.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum
        size of all connectivity logs in the connectivity log directory. When a
        directory reaches its maximum file size, the server deletes the oldest
        log files first. The default value is 1000 MB.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of
        each connectivity log file. When a log file reaches its maximum file
        size, a new log file is created. The default value is 10 MB.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity
        log directory location.

    .PARAMETER DnsLogEnabled
        The DnsLogEnabled parameter specifies whether the DNS log is enabled.
        The default value is $false.

    .PARAMETER DnsLogMaxAge
        The DnsLogMaxAge parameter specifies the maximum age for the DNS log
        file. Log files older than the specified value are deleted. The default
        value is 7.00:00:00 or 7 days.

    .PARAMETER DnsLogMaxDirectorySize
        The DnsLogMaxDirectorySize parameter specifies the maximum size of all
        DNS logs in the DNS log directory. When a directory reaches its maximum
        file size, the server deletes the oldest log files first. The default
        value is 100 MB.

    .PARAMETER DnsLogMaxFileSize
        The DnsLogMaxFileSize parameter specifies the maximum size of each DNS
        log file. When a log file reaches its maximum file size, a new log file
        is created. The default value is 10 MB.

    .PARAMETER DnsLogPath
        The DnsLogPath parameter specifies the DNS log directory location. The
        default value is blank ($null), which indicates no location is
        configured. If you enable DNS logging, you need to specify a local file
        path for the DNS log files by using this parameter.

    .PARAMETER ExternalDNSAdapterEnabled
        The ExternalDNSAdapterEnabled parameter specifies one or more Domain
        Name System (DNS) servers that Exchange uses for external DNS lookups.

    .PARAMETER ExternalDNSAdapterGuid
        The ExternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of destinations that exist
        outside the Exchange organization.

    .PARAMETER ExternalDNSProtocolOption
        The ExternalDNSProtocolOption parameter specifies which protocol to use
        when querying external DNS servers. The valid options for this
        parameter are Any, UseTcpOnly, and UseUdpOnly. The default value is
        Any.

    .PARAMETER ExternalDNSServers
        The ExternalDNSServers parameter specifies the list of external DNS
        servers that the server queries when resolving a remote domain. You
        must separate IP addresses by using commas. The default value is an
        empty list ({}).

    .PARAMETER ExternalIPAddress
        The ExternalIPAddress parameter specifies the IP address used in the
        Received message header field for every message that travels through
        the Front End Transport service.

    .PARAMETER InternalDNSAdapterEnabled
        The InternalDNSAdapterEnabled parameter specifies one or more DNS
        servers that Exchange uses for internal DNS lookups.

    .PARAMETER InternalDNSAdapterGuid
        The InternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of servers that exist inside
        the Exchange organization.

    .PARAMETER InternalDNSProtocolOption
        The InternalDNSProtocolOption parameter specifies which protocol to use
        when you query internal DNS servers. Valid options for this parameter
        are Any, UseTcpOnly, or UseUdpOnly. The default value is Any.

    .PARAMETER InternalDNSServers
        The InternalDNSServers parameter specifies the list of DNS servers that
        should be used when resolving a domain name. DNS servers are specified
        by IP address and are separated by commas. The default value is any
        empty list ({}).

    .PARAMETER IntraOrgConnectorProtocolLoggingLevel
        The IntraOrgConnectorProtocolLoggingLevel parameter enables or disables
        SMTP protocol logging on the implicit and invisible intra-organization
        Send connector in the Front End Transport service.

    .PARAMETER MaxConnectionRatePerMinute
        The MaxConnectionRatePerMinute parameter specifies the maximum rate
        that connections are allowed to be opened with the transport service.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Receive connectors in the
        Transport service on the server. Log files that are older than the
        specified value are automatically deleted.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Receive
        connectors in the Front End Transport service on the server. When the
        maximum directory size is reached, the server deletes the oldest log
        files first.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size
        of a protocol log file that's shared by all Receive connectors in the
        Front End Transport service on the server. When a log file reaches its
        maximum file size, a new log file is created.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the
        protocol log directory for all Receive connectors in the Front End
        Transport service on the server.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table
        log age. Log files older than the specified value are deleted. The
        default value is 7 days.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum
        size of the routing table log directory. When the maximum directory
        size is reached, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location
        where routing table log files should be stored.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Send connectors in the Front End
        Transport service that have this server configured as a source server.
        Log files that are older than the specified value are deleted.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Send connectors
        in the Front End Transport service that have this server configured as
        a source server. When the maximum directory size is reached, the server
        deletes the oldest log files first.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of
        a protocol log file that's shared by all the Send connectors in the
        Front End Transport service that have this server configured as a
        source server. When a log file reaches its maximum file size, a new log
        file is created.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the
        protocol log directory for all Send connectors in the Front End
        Transport service that have this server configured as a source server.

    .PARAMETER TransientFailureRetryCount
        The TransientFailureRetryCount parameter specifies the maximum number
        of immediate connection retries attempted when the server encounters a
        connection failure with a remote server. The default value is 6. The
        valid input range for this parameter is from 0 through 15. When the
        value of this parameter is set to 0, the server doesn't immediately
        attempt to retry an unsuccessful connection.

    .PARAMETER TransientFailureRetryInterval
        The TransientFailureRetryInterval parameter controls the connection
        interval between each connection attempt specified by the
        TransientFailureRetryCount parameter. For the Front End Transport
        service, the default value of the TransientFailureRetryInterval
        parameter is 5 minutes.
#>
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
        $MaxConnectionRatePerMinute,

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
        [ValidateRange(1, 15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-FrontendTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    $FrontendTransportService = Get-FrontendTransportService $Identity -ErrorAction SilentlyContinue
    if ($null -ne $FrontendTransportService)
    {
        $returnValue = @{
            Identity                              = [System.String] $Identity
            AgentLogEnabled                       = [System.Boolean] $FrontendTransportService.AgentLogEnabled
            AgentLogMaxAge                        = [System.String] $FrontendTransportService.AgentLogMaxAge
            AgentLogMaxDirectorySize              = [System.String] $FrontendTransportService.AgentLogMaxDirectorySize
            AgentLogMaxFileSize                   = [System.String] $FrontendTransportService.AgentLogMaxFileSize
            AgentLogPath                          = [System.String] $FrontendTransportService.AgentLogPath
            AntispamAgentsEnabled                 = [System.Boolean] $FrontendTransportService.AntispamAgentsEnabled
            ConnectivityLogEnabled                = [System.Boolean] $FrontendTransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                 = [System.String] $FrontendTransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize       = [System.String] $FrontendTransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize            = [System.String] $FrontendTransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                   = [System.String] $FrontendTransportService.ConnectivityLogPath
            DnsLogEnabled                         = [System.Boolean] $FrontendTransportService.DnsLogEnabled
            DnsLogMaxAge                          = [System.String] $FrontendTransportService.DnsLogMaxAge
            DnsLogMaxDirectorySize                = [System.String] $FrontendTransportService.DnsLogMaxDirectorySize
            DnsLogMaxFileSize                     = [System.String] $FrontendTransportService.DnsLogMaxFileSize
            DnsLogPath                            = [System.String] $FrontendTransportService.DnsLogPath
            ExternalDNSAdapterEnabled             = [System.Boolean] $FrontendTransportService.ExternalDNSAdapterEnabled
            ExternalDNSAdapterGuid                = [System.String] $FrontendTransportService.ExternalDNSAdapterGuid
            ExternalDNSProtocolOption             = [System.String] $FrontendTransportService.ExternalDNSProtocolOption
            ExternalDNSServers                    = [System.String[]] $FrontendTransportService.ExternalDNSServers
            ExternalIPAddress                     = [System.String] $FrontendTransportService.ExternalIPAddress
            InternalDNSAdapterEnabled             = [System.Boolean] $FrontendTransportService.InternalDNSAdapterEnabled
            InternalDNSAdapterGuid                = [System.String] $FrontendTransportService.InternalDNSAdapterGuid
            InternalDNSProtocolOption             = [System.String] $FrontendTransportService.InternalDNSProtocolOption
            InternalDNSServers                    = [System.String[]] $FrontendTransportService.InternalDNSServers
            IntraOrgConnectorProtocolLoggingLevel = [System.String] $FrontendTransportService.IntraOrgConnectorProtocolLoggingLevel
            MaxConnectionRatePerMinute            = [System.Int32] $FrontendTransportService.MaxConnectionRatePerMinute
            ReceiveProtocolLogMaxAge              = [System.String] $FrontendTransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize    = [System.String] $FrontendTransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize         = [System.String] $FrontendTransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                = [System.String] $FrontendTransportService.ReceiveProtocolLogPath
            RoutingTableLogMaxAge                 = [System.String] $FrontendTransportService.RoutingTableLogMaxAge
            RoutingTableLogMaxDirectorySize       = [System.String] $FrontendTransportService.RoutingTableLogMaxDirectorySize
            RoutingTableLogPath                   = [System.String] $FrontendTransportService.RoutingTableLogPath
            SendProtocolLogMaxAge                 = [System.String] $FrontendTransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize       = [System.String] $FrontendTransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize            = [System.String] $FrontendTransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                   = [System.String] $FrontendTransportService.SendProtocolLogPath
            TransientFailureRetryCount            = [System.Int32] $FrontendTransportService.TransientFailureRetryCount
            TransientFailureRetryInterval         = [System.String] $FrontendTransportService.TransientFailureRetryInterval.ToString()
        }
    }
    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the server that you want to modify.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the MSExchangeFrontEndTransport service
        after making changes. Defaults to $false.

    .PARAMETER AgentLogEnabled
        The AgentLogEnabled parameter specifies whether the agent log is
        enabled. The default value is $true.

    .PARAMETER AgentLogMaxAge
        The AgentLogMaxAge parameter specifies the maximum age for the agent
        log file. Log files older than the specified value are deleted. The
        default value is 7.00:00:00 or 7 days.

    .PARAMETER AgentLogMaxDirectorySize
        The AgentLogMaxDirectorySize parameter specifies the maximum size of
        all agent logs in the agent log directory. When a directory reaches its
        maximum file size, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER AgentLogMaxFileSize
        The AgentLogMaxFileSize parameter specifies the maximum size of each
        agent log file. When a log file reaches its maximum file size, a new
        log file is created. The default value is 10 MB.

    .PARAMETER AgentLogPath
        The AgentLogPath parameter specifies the default agent log directory
        location.

    .PARAMETER AntispamAgentsEnabled
        The AntispamAgentsEnabled parameter specifies whether anti-spam agents
        are installed on the server specified with the Identity parameter. The
        default value is $false for the Front End Transport service.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity
        log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the
        connectivity log file. Log files older than the specified value are
        deleted. The default value is 30 days.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum
        size of all connectivity logs in the connectivity log directory. When a
        directory reaches its maximum file size, the server deletes the oldest
        log files first. The default value is 1000 MB.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of
        each connectivity log file. When a log file reaches its maximum file
        size, a new log file is created. The default value is 10 MB.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity
        log directory location.

    .PARAMETER DnsLogEnabled
        The DnsLogEnabled parameter specifies whether the DNS log is enabled.
        The default value is $false.

    .PARAMETER DnsLogMaxAge
        The DnsLogMaxAge parameter specifies the maximum age for the DNS log
        file. Log files older than the specified value are deleted. The default
        value is 7.00:00:00 or 7 days.

    .PARAMETER DnsLogMaxDirectorySize
        The DnsLogMaxDirectorySize parameter specifies the maximum size of all
        DNS logs in the DNS log directory. When a directory reaches its maximum
        file size, the server deletes the oldest log files first. The default
        value is 100 MB.

    .PARAMETER DnsLogMaxFileSize
        The DnsLogMaxFileSize parameter specifies the maximum size of each DNS
        log file. When a log file reaches its maximum file size, a new log file
        is created. The default value is 10 MB.

    .PARAMETER DnsLogPath
        The DnsLogPath parameter specifies the DNS log directory location. The
        default value is blank ($null), which indicates no location is
        configured. If you enable DNS logging, you need to specify a local file
        path for the DNS log files by using this parameter.

    .PARAMETER ExternalDNSAdapterEnabled
        The ExternalDNSAdapterEnabled parameter specifies one or more Domain
        Name System (DNS) servers that Exchange uses for external DNS lookups.

    .PARAMETER ExternalDNSAdapterGuid
        The ExternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of destinations that exist
        outside the Exchange organization.

    .PARAMETER ExternalDNSProtocolOption
        The ExternalDNSProtocolOption parameter specifies which protocol to use
        when querying external DNS servers. The valid options for this
        parameter are Any, UseTcpOnly, and UseUdpOnly. The default value is
        Any.

    .PARAMETER ExternalDNSServers
        The ExternalDNSServers parameter specifies the list of external DNS
        servers that the server queries when resolving a remote domain. You
        must separate IP addresses by using commas. The default value is an
        empty list ({}).

    .PARAMETER ExternalIPAddress
        The ExternalIPAddress parameter specifies the IP address used in the
        Received message header field for every message that travels through
        the Front End Transport service.

    .PARAMETER InternalDNSAdapterEnabled
        The InternalDNSAdapterEnabled parameter specifies one or more DNS
        servers that Exchange uses for internal DNS lookups.

    .PARAMETER InternalDNSAdapterGuid
        The InternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of servers that exist inside
        the Exchange organization.

    .PARAMETER InternalDNSProtocolOption
        The InternalDNSProtocolOption parameter specifies which protocol to use
        when you query internal DNS servers. Valid options for this parameter
        are Any, UseTcpOnly, or UseUdpOnly. The default value is Any.

    .PARAMETER InternalDNSServers
        The InternalDNSServers parameter specifies the list of DNS servers that
        should be used when resolving a domain name. DNS servers are specified
        by IP address and are separated by commas. The default value is any
        empty list ({}).

    .PARAMETER IntraOrgConnectorProtocolLoggingLevel
        The IntraOrgConnectorProtocolLoggingLevel parameter enables or disables
        SMTP protocol logging on the implicit and invisible intra-organization
        Send connector in the Front End Transport service.

    .PARAMETER MaxConnectionRatePerMinute
        The MaxConnectionRatePerMinute parameter specifies the maximum rate
        that connections are allowed to be opened with the transport service.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Receive connectors in the
        Transport service on the server. Log files that are older than the
        specified value are automatically deleted.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Receive
        connectors in the Front End Transport service on the server. When the
        maximum directory size is reached, the server deletes the oldest log
        files first.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size
        of a protocol log file that's shared by all Receive connectors in the
        Front End Transport service on the server. When a log file reaches its
        maximum file size, a new log file is created.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the
        protocol log directory for all Receive connectors in the Front End
        Transport service on the server.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table
        log age. Log files older than the specified value are deleted. The
        default value is 7 days.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum
        size of the routing table log directory. When the maximum directory
        size is reached, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location
        where routing table log files should be stored.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Send connectors in the Front End
        Transport service that have this server configured as a source server.
        Log files that are older than the specified value are deleted.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Send connectors
        in the Front End Transport service that have this server configured as
        a source server. When the maximum directory size is reached, the server
        deletes the oldest log files first.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of
        a protocol log file that's shared by all the Send connectors in the
        Front End Transport service that have this server configured as a
        source server. When a log file reaches its maximum file size, a new log
        file is created.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the
        protocol log directory for all Send connectors in the Front End
        Transport service that have this server configured as a source server.

    .PARAMETER TransientFailureRetryCount
        The TransientFailureRetryCount parameter specifies the maximum number
        of immediate connection retries attempted when the server encounters a
        connection failure with a remote server. The default value is 6. The
        valid input range for this parameter is from 0 through 15. When the
        value of this parameter is set to 0, the server doesn't immediately
        attempt to retry an unsuccessful connection.

    .PARAMETER TransientFailureRetryInterval
        The TransientFailureRetryInterval parameter controls the connection
        interval between each connection attempt specified by the
        TransientFailureRetryCount parameter. For the Front End Transport
        service, the default value of the TransientFailureRetryInterval
        parameter is 5 minutes.
#>
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
        $MaxConnectionRatePerMinute,

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
        [ValidateRange(1, 15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-FrontendTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

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

    Set-FrontendTransportService @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restart service MSExchangeFrontEndTransport'
        Restart-Service -Name MSExchangeFrontEndTransport -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until the MSExchangeFrontEndTransport service is manually restarted.'
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The Identity parameter specifies the server that you want to modify.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the MSExchangeFrontEndTransport service
        after making changes. Defaults to $false.

    .PARAMETER AgentLogEnabled
        The AgentLogEnabled parameter specifies whether the agent log is
        enabled. The default value is $true.

    .PARAMETER AgentLogMaxAge
        The AgentLogMaxAge parameter specifies the maximum age for the agent
        log file. Log files older than the specified value are deleted. The
        default value is 7.00:00:00 or 7 days.

    .PARAMETER AgentLogMaxDirectorySize
        The AgentLogMaxDirectorySize parameter specifies the maximum size of
        all agent logs in the agent log directory. When a directory reaches its
        maximum file size, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER AgentLogMaxFileSize
        The AgentLogMaxFileSize parameter specifies the maximum size of each
        agent log file. When a log file reaches its maximum file size, a new
        log file is created. The default value is 10 MB.

    .PARAMETER AgentLogPath
        The AgentLogPath parameter specifies the default agent log directory
        location.

    .PARAMETER AntispamAgentsEnabled
        The AntispamAgentsEnabled parameter specifies whether anti-spam agents
        are installed on the server specified with the Identity parameter. The
        default value is $false for the Front End Transport service.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity
        log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the
        connectivity log file. Log files older than the specified value are
        deleted. The default value is 30 days.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum
        size of all connectivity logs in the connectivity log directory. When a
        directory reaches its maximum file size, the server deletes the oldest
        log files first. The default value is 1000 MB.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of
        each connectivity log file. When a log file reaches its maximum file
        size, a new log file is created. The default value is 10 MB.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity
        log directory location.

    .PARAMETER DnsLogEnabled
        The DnsLogEnabled parameter specifies whether the DNS log is enabled.
        The default value is $false.

    .PARAMETER DnsLogMaxAge
        The DnsLogMaxAge parameter specifies the maximum age for the DNS log
        file. Log files older than the specified value are deleted. The default
        value is 7.00:00:00 or 7 days.

    .PARAMETER DnsLogMaxDirectorySize
        The DnsLogMaxDirectorySize parameter specifies the maximum size of all
        DNS logs in the DNS log directory. When a directory reaches its maximum
        file size, the server deletes the oldest log files first. The default
        value is 100 MB.

    .PARAMETER DnsLogMaxFileSize
        The DnsLogMaxFileSize parameter specifies the maximum size of each DNS
        log file. When a log file reaches its maximum file size, a new log file
        is created. The default value is 10 MB.

    .PARAMETER DnsLogPath
        The DnsLogPath parameter specifies the DNS log directory location. The
        default value is blank ($null), which indicates no location is
        configured. If you enable DNS logging, you need to specify a local file
        path for the DNS log files by using this parameter.

    .PARAMETER ExternalDNSAdapterEnabled
        The ExternalDNSAdapterEnabled parameter specifies one or more Domain
        Name System (DNS) servers that Exchange uses for external DNS lookups.

    .PARAMETER ExternalDNSAdapterGuid
        The ExternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of destinations that exist
        outside the Exchange organization.

    .PARAMETER ExternalDNSProtocolOption
        The ExternalDNSProtocolOption parameter specifies which protocol to use
        when querying external DNS servers. The valid options for this
        parameter are Any, UseTcpOnly, and UseUdpOnly. The default value is
        Any.

    .PARAMETER ExternalDNSServers
        The ExternalDNSServers parameter specifies the list of external DNS
        servers that the server queries when resolving a remote domain. You
        must separate IP addresses by using commas. The default value is an
        empty list ({}).

    .PARAMETER ExternalIPAddress
        The ExternalIPAddress parameter specifies the IP address used in the
        Received message header field for every message that travels through
        the Front End Transport service.

    .PARAMETER InternalDNSAdapterEnabled
        The InternalDNSAdapterEnabled parameter specifies one or more DNS
        servers that Exchange uses for internal DNS lookups.

    .PARAMETER InternalDNSAdapterGuid
        The InternalDNSAdapterGuid parameter specifies the network adapter that
        has the DNS settings used for DNS lookups of servers that exist inside
        the Exchange organization.

    .PARAMETER InternalDNSProtocolOption
        The InternalDNSProtocolOption parameter specifies which protocol to use
        when you query internal DNS servers. Valid options for this parameter
        are Any, UseTcpOnly, or UseUdpOnly. The default value is Any.

    .PARAMETER InternalDNSServers
        The InternalDNSServers parameter specifies the list of DNS servers that
        should be used when resolving a domain name. DNS servers are specified
        by IP address and are separated by commas. The default value is any
        empty list ({}).

    .PARAMETER IntraOrgConnectorProtocolLoggingLevel
        The IntraOrgConnectorProtocolLoggingLevel parameter enables or disables
        SMTP protocol logging on the implicit and invisible intra-organization
        Send connector in the Front End Transport service.

    .PARAMETER MaxConnectionRatePerMinute
        The MaxConnectionRatePerMinute parameter specifies the maximum rate
        that connections are allowed to be opened with the transport service.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Receive connectors in the
        Transport service on the server. Log files that are older than the
        specified value are automatically deleted.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Receive
        connectors in the Front End Transport service on the server. When the
        maximum directory size is reached, the server deletes the oldest log
        files first.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size
        of a protocol log file that's shared by all Receive connectors in the
        Front End Transport service on the server. When a log file reaches its
        maximum file size, a new log file is created.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the
        protocol log directory for all Receive connectors in the Front End
        Transport service on the server.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table
        log age. Log files older than the specified value are deleted. The
        default value is 7 days.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum
        size of the routing table log directory. When the maximum directory
        size is reached, the server deletes the oldest log files first. The
        default value is 250 MB.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location
        where routing table log files should be stored.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a
        protocol log file that's shared by all Send connectors in the Front End
        Transport service that have this server configured as a source server.
        Log files that are older than the specified value are deleted.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum
        size of the protocol log directory that's shared by all Send connectors
        in the Front End Transport service that have this server configured as
        a source server. When the maximum directory size is reached, the server
        deletes the oldest log files first.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of
        a protocol log file that's shared by all the Send connectors in the
        Front End Transport service that have this server configured as a
        source server. When a log file reaches its maximum file size, a new log
        file is created.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the
        protocol log directory for all Send connectors in the Front End
        Transport service that have this server configured as a source server.

    .PARAMETER TransientFailureRetryCount
        The TransientFailureRetryCount parameter specifies the maximum number
        of immediate connection retries attempted when the server encounters a
        connection failure with a remote server. The default value is 6. The
        valid input range for this parameter is from 0 through 15. When the
        value of this parameter is set to 0, the server doesn't immediately
        attempt to retry an unsuccessful connection.

    .PARAMETER TransientFailureRetryInterval
        The TransientFailureRetryInterval parameter controls the connection
        interval between each connection attempt specified by the
        TransientFailureRetryCount parameter. For the Front End Transport
        service, the default value of the TransientFailureRetryInterval
        parameter is 5 minutes.
#>
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
        $MaxConnectionRatePerMinute,

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
        [ValidateRange(1, 15)]
        [System.Int32]
        $TransientFailureRetryCount,

        [Parameter()]
        [System.String]
        $TransientFailureRetryInterval
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-FrontendTransportService' -Verbose:$VerbosePreference

    $FrontendTransportService = Get-FrontendTransportService $Identity -ErrorAction SilentlyContinue

    $testResults = $true

    if ($null -eq $FrontendTransportService)
    {
        Write-Error -Message 'Unable to retrieve Frontend Transport Service for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'AgentLogEnabled' -Type 'Boolean' -ExpectedValue $AgentLogEnabled -ActualValue $FrontendTransportService.AgentLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxAge' -Type 'Timespan' -ExpectedValue $AgentLogMaxAge -ActualValue $FrontendTransportService.AgentLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $AgentLogMaxDirectorySize -ActualValue $FrontendTransportService.AgentLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $AgentLogMaxFileSize -ActualValue $FrontendTransportService.AgentLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AgentLogPath' -Type 'String' -ExpectedValue $AgentLogPath -ActualValue $FrontendTransportService.AgentLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AntispamAgentsEnabled' -Type 'Boolean' -ExpectedValue $AntispamAgentsEnabled -ActualValue $FrontendTransportService.AntispamAgentsEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogEnabled' -Type 'Boolean' -ExpectedValue $ConnectivityLogEnabled -ActualValue $FrontendTransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxAge' -Type 'Timespan' -ExpectedValue $ConnectivityLogMaxAge -ActualValue $FrontendTransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $FrontendTransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $FrontendTransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogPath' -Type 'String' -ExpectedValue $ConnectivityLogPath -ActualValue $FrontendTransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogEnabled' -Type 'Boolean' -ExpectedValue $DnsLogEnabled -ActualValue $FrontendTransportService.DnsLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxAge' -Type 'TimeSpan' -ExpectedValue $DnsLogMaxAge -ActualValue $FrontendTransportService.DnsLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $DnsLogMaxDirectorySize -ActualValue $FrontendTransportService.DnsLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $DnsLogMaxFileSize -ActualValue $FrontendTransportService.DnsLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DnsLogPath' -Type 'String' -ExpectedValue $DnsLogPath -ActualValue $FrontendTransportService.DnsLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSAdapterEnabled' -Type 'Boolean' -ExpectedValue $ExternalDNSAdapterEnabled -ActualValue $FrontendTransportService.ExternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSAdapterGuid' -Type 'String' -ExpectedValue $ExternalDNSAdapterGuid -ActualValue $FrontendTransportService.ExternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSProtocolOption' -Type 'String' -ExpectedValue $ExternalDNSProtocolOption -ActualValue $FrontendTransportService.ExternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalDNSServers' -Type 'IPAddresses' -ExpectedValue $ExternalDNSServers -ActualValue $FrontendTransportService.ExternalDNSServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalIPAddress' -Type 'IPAddress' -ExpectedValue $ExternalIPAddress -ActualValue $FrontendTransportService.ExternalIPAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSAdapterEnabled' -Type 'Boolean' -ExpectedValue $InternalDNSAdapterEnabled -ActualValue $FrontendTransportService.InternalDNSAdapterEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSAdapterGuid' -Type 'String' -ExpectedValue $InternalDNSAdapterGuid -ActualValue $FrontendTransportService.InternalDNSAdapterGuid -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSProtocolOption' -Type 'String' -ExpectedValue $InternalDNSProtocolOption -ActualValue $FrontendTransportService.InternalDNSProtocolOption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalDNSServers' -Type 'IPAddresses' -ExpectedValue $InternalDNSServers -ActualValue $FrontendTransportService.InternalDNSServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IntraOrgConnectorProtocolLoggingLevel' -Type 'String' -ExpectedValue $IntraOrgConnectorProtocolLoggingLevel -ActualValue $FrontendTransportService.IntraOrgConnectorProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConnectionRatePerMinute' -Type 'Int' -ExpectedValue $MaxConnectionRatePerMinute -ActualValue $FrontendTransportService.MaxConnectionRatePerMinute -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $FrontendTransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $FrontendTransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $FrontendTransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogPath' -Type 'String' -ExpectedValue $ReceiveProtocolLogPath -ActualValue $FrontendTransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogMaxAge' -Type 'TimeSpan' -ExpectedValue $RoutingTableLogMaxAge -ActualValue $FrontendTransportService.RoutingTableLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $RoutingTableLogMaxDirectorySize -ActualValue $FrontendTransportService.RoutingTableLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RoutingTableLogPath' -Type 'String' -ExpectedValue $RoutingTableLogPath -ActualValue $FrontendTransportService.RoutingTableLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $SendProtocolLogMaxAge -ActualValue $FrontendTransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $FrontendTransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $FrontendTransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogPath' -Type 'String' -ExpectedValue $SendProtocolLogPath -ActualValue $FrontendTransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'TransientFailureRetryCount' -Type 'Int' -ExpectedValue $TransientFailureRetryCount -ActualValue $FrontendTransportService.TransientFailureRetryCount -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'TransientFailureRetryInterval' -Type 'TimeSpan' -ExpectedValue $TransientFailureRetryInterval -ActualValue $FrontendTransportService.TransientFailureRetryInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
