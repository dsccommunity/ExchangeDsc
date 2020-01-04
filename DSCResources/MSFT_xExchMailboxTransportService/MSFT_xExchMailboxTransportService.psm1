<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the connectivity log file. Log files older than the specified value are deleted. The default value is 30 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 25 days for this parameter, use 25.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting the value of the ConnectivityLogMaxAge parameter to 00:00:00 prevents the automatic removal of connectivity log files because of their age.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum size of all connectivity logs in the connectivity log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 1000 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log directory.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of each connectivity log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log files.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Connectivity. Setting the value of this parameter to $null disables connectivity logging. However, setting this parameter to $null when the value of the ConnectivityLogEnabled attribute is $true generates event log errors.

    .PARAMETER ContentConversionTracingEnabled
    The ContentConversionTracingEnabled parameter specifies whether content conversion tracing is enabled. Content conversion tracing captures content conversion failures that occur in the Transport service or in the Mailbox Transport service on the Mailbox server. The default value is $false. Content conversion tracing captures a maximum of 128 MB of content conversion failures. When the 128 MB limit is reached, no more content conversion failures are captured. Content conversion tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
        * Administrators: Full Control
        * Network Service: Full Control
        * System: Full Control

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory. You identify the domain controller by its fully qualified domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER MailboxDeliveryAgentLogEnabled
        The MailboxDeliveryAgentLogEnabled parameter specifies whether the agent log for the Mailbox Transport Delivery service is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryAgentLogMaxAge
        The MailboxDeliveryAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Delivery service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxDeliveryAgentLogMaxDirectorySize
        The MailboxDeliveryAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Delivery service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxDeliveryAgentLogMaxFileSize
        The MailboxDeliveryAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxDeliveryAgentLogPath
        The MailboxDeliveryAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Delivery. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxDeliveryAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxDeliveryConnectorMaxInboundConnection
        The MailboxDeliveryConnectorMaxInboundConnection parameter specifies the maximum number of inbound connections for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default value is 5000. If you enter the value unlimited, no connection limit is imposed on the mailbox delivery Receive connector.

    .PARAMETER MailboxDeliveryConnectorProtocolLoggingLevel
        The MailboxDeliveryConnectorProtocolLoggingLevel parameter enables or disables SMTP protocol logging for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * None: Protocol logging is disabled for the mailbox delivery Receive connector. This is the default value.
            * Verbose: Protocol logging is enabled for the mailbox delivery Receive connector. The location of the log files is controlled by the ReceiveProtocolLogPath parameter.

    .PARAMETER MailboxDeliveryConnectorSmtpUtf8Enabled
        The MailboxDeliveryConnectorSmtpUtf8Enabled parameters or disables email address internationalization (EAI) support for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * $true: Mail can be delivered to local mailboxes that have international characters in email addresses. This is the default value
            * $false: Mail can't be delivered to local mailboxes that have international characters in email addresses.

    .PARAMETER MailboxDeliveryThrottlingLogEnabled
        The MailboxDeliveryThrottlingLogEnabled parameter specifies whether the mailbox delivery throttling log is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryThrottlingLogMaxAge
        The MailboxDeliveryThrottlingLogMaxAge parameter specifies the maximum age for the mailbox delivery throttling log file. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryThrottlingLogMaxAge parameter to 00:00:00 prevents the automatic removal of mailbox delivery throttling log files because of their age.

    .PARAMETER MailboxDeliveryThrottlingLogMaxDirectorySize
        The MailboxDeliveryThrottlingLogMaxDirectorySize parameter specifies the maximum size of all mailbox delivery throttling logs in the mailbox delivery throttling log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 200 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log directory.

    .PARAMETER MailboxDeliveryThrottlingLogMaxFileSize
        The MailboxDeliveryThrottlingLogMaxFileSize parameter specifies the maximum size of each mailbox delivery throttling log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log files.

    .PARAMETER MailboxDeliveryThrottlingLogPath
        The MailboxDeliveryThrottlingLogPath parameter specifies the default mailbox delivery throttling log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Throttling\Delivery. Setting the value of this parameter to $null disables mailbox delivery throttling logging. However, setting this parameter to $null when the value of the MailboxDeliveryThrottlingLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxSubmissionAgentLogEnabled
        The MailboxSubmissionAgentLogEnabled parameter specifies whether the agent log is enabled for the Mailbox Transport Submission service. The default value is $true.

    .PARAMETER MailboxSubmissionAgentLogMaxAge
        The MailboxSubmissionAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Submission service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxSubmissionAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxSubmissionAgentLogMaxDirectorySize
        The MailboxSubmissionAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Submission service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxSubmissionAgentLogMaxFileSize
        The MailboxSubmissionAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxSubmissionAgentLogPath
        The MailboxSubmissionAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Submission. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxSubmissionAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MaxConcurrentMailboxDeliveries
        The MaxConcurrentMailboxDeliveries parameter specifies the maximum number of delivery threads that the transport service can have open at the same time to deliver messages to mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256. We recommend that you don't modify the default value unless Microsoft Customer Service and Support advises you to do this.

    .PARAMETER MaxConcurrentMailboxSubmissions
        The MaxConcurrentMailboxSubmissions parameter specifies the maximum number of submission threads that the transport service can have open at the same time to send messages from mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256.

    .PARAMETER PipelineTracingEnabled
        The PipelineTracingEnabled parameter specifies whether to enable pipeline tracing. Pipeline tracing captures message snapshot files that record the changes made to the message by each transport agent configured in the transport service on the server. Pipeline tracing creates verbose log files that accumulate quickly. Pipeline tracing should only be enabled for a short time to provide in-depth diagnostic information that enables you to troubleshoot problems. In addition to troubleshooting, you can use pipeline tracing to validate changes that you make to the configuration of the transport service where you enable pipeline tracing. The default value is $false.

    .PARAMETER PipelineTracingPath
        The PipelineTracingPath parameter specifies the location of the pipeline tracing logs. The default location is %ExchangeInstallPath%TransportRoles\Mailbox\Hub\PipelineTracing. The path must be local to the Exchange computer. Setting the value of this parameter to $null disables pipeline tracing. However, setting this parameter to $null when the value of the PipelineTracingEnabled attribute is $true generates event log errors. The preferred method to disable pipeline tracing is to use the PipelineTracingEnabled parameter. Pipeline tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
            * Administrators: Full Control
            * Network Service: Full Control
            * System: Full Control

    .PARAMETER PipelineTracingSenderAddress
        The PipelineTracingSenderAddress parameter specifies the sender email address that invokes pipeline tracing. Only messages from this address generate pipeline tracing output. The address can be either inside or outside the Exchange organization. Depending on your requirements, you may have to set this parameter to different sender addresses and send new messages to start the transport agents or routes that you want to test. The default value of this parameter is $null.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days).
        The value00:00:00 prevents the automatic removal of Receive connector protocol log files because of their age.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be greater than or equal to the value of the ReceiveProtocolLogMaxFileSize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the ReceiveProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive. The log files are automatically stored in the Delivery subdirectory.
        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the mailbox delivery Receive connector. To disable protocol logging for this connector, use the value None for the MailboxDeliveryConnectorProtocolLoggingLevel parameter.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table log age. Log files older than the specified value are deleted. The default value is 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 5 days for this parameter, use 5.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting this parameter to 00:00:00 prevents the automatic removal of routing table log files because of their age.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum size of the routing table log directory. When the maximum directory size is reached, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The valid input range for this parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the routing table log directory.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location where routing table log files should be stored. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Routing. Setting this parameter to $null disables routing table logging.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days). The value 00:00:00 prevents the automatic removal of Send connector protocol log files because of their age.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend. Log files are automatically stored in the following subdirectories:
            * Submission: Protocol log files for the intra-organization Send connector in the Mailbox Transport Submission service.
            * Delivery: Protocol log files for side effect messages that are submitted after messages are delivered to mailboxes. For example, a message delivered to a mailbox triggers an Inbox rule that redirects the message to another recipient.

        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the intra-organization Send connector in the Mailbox Transport Submission service. To disable protocol logging for this connector, use the value None for the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet.
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
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogPath,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorMaxInboundConnection,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryConnectorSMTPUtf8Enabled,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryThrottlingLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogPath,

        [Parameter()]
        [System.Boolean]
        $MailboxSubmissionAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

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
        $SendProtocolLogPath
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $mbxTransportService)
    {
        $returnValue = @{
            Identity                                     = [System.String] $Identity
            ConnectivityLogEnabled                       = [System.Boolean] $mbxTransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                        = [System.String] $mbxTransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize              = [System.String] $mbxTransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize                   = [System.String] $mbxTransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                          = [System.String] $mbxTransportService.ConnectivityLogPath
            ContentConversionTracingEnabled              = [System.Boolean] $mbxTransportService.ContentConversionTracingEnabled
            MailboxDeliveryAgentLogEnabled               = [System.Boolean] $mbxTransportService.MailboxDeliveryAgentLogEnabled
            MailboxDeliveryAgentLogMaxAge                = [System.String] $mbxTransportService.MailboxDeliveryAgentLogMaxAge
            MailboxDeliveryAgentLogMaxDirectorySize      = [System.String] $mbxTransportService.MailboxDeliveryAgentLogMaxDirectorySize
            MailboxDeliveryAgentLogMaxFileSize           = [System.String] $mbxTransportService.MailboxDeliveryAgentLogMaxFileSize
            MailboxDeliveryAgentLogPath                  = [System.String] $mbxTransportService.MailboxDeliveryAgentLogPath
            MailboxDeliveryConnectorMaxInboundConnection = [System.String] $mbxTransportService.MailboxDeliveryConnectorMaxInboundConnection
            MailboxDeliveryConnectorProtocolLoggingLevel = [System.String] $mbxTransportService.MailboxDeliveryConnectorProtocolLoggingLevel
            MailboxDeliveryConnectorSMTPUtf8Enabled      = [System.Boolean] $mbxTransportService.MailboxDeliveryConnectorSMTPUtf8Enabled
            MailboxDeliveryThrottlingLogEnabled          = [System.Boolean] $mbxTransportService.MailboxDeliveryThrottlingLogEnabled
            MailboxDeliveryThrottlingLogMaxAge           = [System.String] $mbxTransportService.MailboxDeliveryThrottlingLogMaxAge
            MailboxDeliveryThrottlingLogMaxDirectorySize = [System.String] $mbxTransportService.MailboxDeliveryThrottlingLogMaxDirectorySize
            MailboxDeliveryThrottlingLogMaxFileSize      = [System.String] $mbxTransportService.MailboxDeliveryThrottlingLogMaxFileSize
            MailboxDeliveryThrottlingLogPath             = [System.String] $mbxTransportService.MailboxDeliveryThrottlingLogPath
            MailboxSubmissionAgentLogEnabled             = [System.Boolean] $mbxTransportService.MailboxSubmissionAgentLogEnabled
            MailboxSubmissionAgentLogMaxAge              = [System.String] $mbxTransportService.MailboxSubmissionAgentLogMaxAge
            MailboxSubmissionAgentLogMaxDirectorySize    = [System.String] $mbxTransportService.MailboxSubmissionAgentLogMaxDirectorySize
            MailboxSubmissionAgentLogMaxFileSize         = [System.String] $mbxTransportService.MailboxSubmissionAgentLogMaxFileSize
            MailboxSubmissionAgentLogPath                = [System.String] $mbxTransportService.MailboxSubmissionAgentLogPath
            MaxConcurrentMailboxDeliveries               = [System.Int32] $mbxTransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions              = [System.Int32] $mbxTransportService.MaxConcurrentMailboxSubmissions
            PipelineTracingEnabled                       = [System.Boolean] $mbxTransportService.PipelineTracingEnabled
            PipelineTracingPath                          = [System.String] $mbxTransportService.PipelineTracingPath
            PipelineTracingSenderAddress                 = [System.String] $mbxTransportService.PipelineTracingSenderAddress
            ReceiveProtocolLogMaxAge                     = [System.String] $mbxTransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize           = [System.String] $mbxTransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize                = [System.String] $mbxTransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                       = [System.String] $mbxTransportService.ReceiveProtocolLogPath
            SendProtocolLogMaxAge                        = [System.String] $mbxTransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize              = [System.String] $mbxTransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize                   = [System.String] $mbxTransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                          = [System.String] $mbxTransportService.SendProtocolLogPath
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the connectivity log file. Log files older than the specified value are deleted. The default value is 30 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 25 days for this parameter, use 25.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting the value of the ConnectivityLogMaxAge parameter to 00:00:00 prevents the automatic removal of connectivity log files because of their age.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum size of all connectivity logs in the connectivity log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 1000 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log directory.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of each connectivity log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log files.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Connectivity. Setting the value of this parameter to $null disables connectivity logging. However, setting this parameter to $null when the value of the ConnectivityLogEnabled attribute is $true generates event log errors.

    .PARAMETER ContentConversionTracingEnabled
    The ContentConversionTracingEnabled parameter specifies whether content conversion tracing is enabled. Content conversion tracing captures content conversion failures that occur in the Transport service or in the Mailbox Transport service on the Mailbox server. The default value is $false. Content conversion tracing captures a maximum of 128 MB of content conversion failures. When the 128 MB limit is reached, no more content conversion failures are captured. Content conversion tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
        * Administrators: Full Control
        * Network Service: Full Control
        * System: Full Control

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory. You identify the domain controller by its fully qualified domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER MailboxDeliveryAgentLogEnabled
        The MailboxDeliveryAgentLogEnabled parameter specifies whether the agent log for the Mailbox Transport Delivery service is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryAgentLogMaxAge
        The MailboxDeliveryAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Delivery service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxDeliveryAgentLogMaxDirectorySize
        The MailboxDeliveryAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Delivery service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxDeliveryAgentLogMaxFileSize
        The MailboxDeliveryAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxDeliveryAgentLogPath
        The MailboxDeliveryAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Delivery. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxDeliveryAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxDeliveryConnectorMaxInboundConnection
        The MailboxDeliveryConnectorMaxInboundConnection parameter specifies the maximum number of inbound connections for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default value is 5000. If you enter the value unlimited, no connection limit is imposed on the mailbox delivery Receive connector.

    .PARAMETER MailboxDeliveryConnectorProtocolLoggingLevel
        The MailboxDeliveryConnectorProtocolLoggingLevel parameter enables or disables SMTP protocol logging for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * None: Protocol logging is disabled for the mailbox delivery Receive connector. This is the default value.
            * Verbose: Protocol logging is enabled for the mailbox delivery Receive connector. The location of the log files is controlled by the ReceiveProtocolLogPath parameter.

    .PARAMETER MailboxDeliveryConnectorSmtpUtf8Enabled
        The MailboxDeliveryConnectorSmtpUtf8Enabled parameters or disables email address internationalization (EAI) support for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * $true: Mail can be delivered to local mailboxes that have international characters in email addresses. This is the default value
            * $false: Mail can't be delivered to local mailboxes that have international characters in email addresses.

    .PARAMETER MailboxDeliveryThrottlingLogEnabled
        The MailboxDeliveryThrottlingLogEnabled parameter specifies whether the mailbox delivery throttling log is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryThrottlingLogMaxAge
        The MailboxDeliveryThrottlingLogMaxAge parameter specifies the maximum age for the mailbox delivery throttling log file. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryThrottlingLogMaxAge parameter to 00:00:00 prevents the automatic removal of mailbox delivery throttling log files because of their age.

    .PARAMETER MailboxDeliveryThrottlingLogMaxDirectorySize
        The MailboxDeliveryThrottlingLogMaxDirectorySize parameter specifies the maximum size of all mailbox delivery throttling logs in the mailbox delivery throttling log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 200 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log directory.

    .PARAMETER MailboxDeliveryThrottlingLogMaxFileSize
        The MailboxDeliveryThrottlingLogMaxFileSize parameter specifies the maximum size of each mailbox delivery throttling log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log files.

    .PARAMETER MailboxDeliveryThrottlingLogPath
        The MailboxDeliveryThrottlingLogPath parameter specifies the default mailbox delivery throttling log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Throttling\Delivery. Setting the value of this parameter to $null disables mailbox delivery throttling logging. However, setting this parameter to $null when the value of the MailboxDeliveryThrottlingLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxSubmissionAgentLogEnabled
        The MailboxSubmissionAgentLogEnabled parameter specifies whether the agent log is enabled for the Mailbox Transport Submission service. The default value is $true.

    .PARAMETER MailboxSubmissionAgentLogMaxAge
        The MailboxSubmissionAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Submission service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxSubmissionAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxSubmissionAgentLogMaxDirectorySize
        The MailboxSubmissionAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Submission service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxSubmissionAgentLogMaxFileSize
        The MailboxSubmissionAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxSubmissionAgentLogPath
        The MailboxSubmissionAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Submission. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxSubmissionAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MaxConcurrentMailboxDeliveries
        The MaxConcurrentMailboxDeliveries parameter specifies the maximum number of delivery threads that the transport service can have open at the same time to deliver messages to mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256. We recommend that you don't modify the default value unless Microsoft Customer Service and Support advises you to do this.

    .PARAMETER MaxConcurrentMailboxSubmissions
        The MaxConcurrentMailboxSubmissions parameter specifies the maximum number of submission threads that the transport service can have open at the same time to send messages from mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256.

    .PARAMETER PipelineTracingEnabled
        The PipelineTracingEnabled parameter specifies whether to enable pipeline tracing. Pipeline tracing captures message snapshot files that record the changes made to the message by each transport agent configured in the transport service on the server. Pipeline tracing creates verbose log files that accumulate quickly. Pipeline tracing should only be enabled for a short time to provide in-depth diagnostic information that enables you to troubleshoot problems. In addition to troubleshooting, you can use pipeline tracing to validate changes that you make to the configuration of the transport service where you enable pipeline tracing. The default value is $false.

    .PARAMETER PipelineTracingPath
        The PipelineTracingPath parameter specifies the location of the pipeline tracing logs. The default location is %ExchangeInstallPath%TransportRoles\Mailbox\Hub\PipelineTracing. The path must be local to the Exchange computer. Setting the value of this parameter to $null disables pipeline tracing. However, setting this parameter to $null when the value of the PipelineTracingEnabled attribute is $true generates event log errors. The preferred method to disable pipeline tracing is to use the PipelineTracingEnabled parameter. Pipeline tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
            * Administrators: Full Control
            * Network Service: Full Control
            * System: Full Control

    .PARAMETER PipelineTracingSenderAddress
        The PipelineTracingSenderAddress parameter specifies the sender email address that invokes pipeline tracing. Only messages from this address generate pipeline tracing output. The address can be either inside or outside the Exchange organization. Depending on your requirements, you may have to set this parameter to different sender addresses and send new messages to start the transport agents or routes that you want to test. The default value of this parameter is $null.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days).
        The value00:00:00 prevents the automatic removal of Receive connector protocol log files because of their age.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be greater than or equal to the value of the ReceiveProtocolLogMaxFileSize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the ReceiveProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive. The log files are automatically stored in the Delivery subdirectory.
        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the mailbox delivery Receive connector. To disable protocol logging for this connector, use the value None for the MailboxDeliveryConnectorProtocolLoggingLevel parameter.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table log age. Log files older than the specified value are deleted. The default value is 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 5 days for this parameter, use 5.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting this parameter to 00:00:00 prevents the automatic removal of routing table log files because of their age.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum size of the routing table log directory. When the maximum directory size is reached, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The valid input range for this parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the routing table log directory.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location where routing table log files should be stored. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Routing. Setting this parameter to $null disables routing table logging.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days). The value 00:00:00 prevents the automatic removal of Send connector protocol log files because of their age.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend. Log files are automatically stored in the following subdirectories:
            * Submission: Protocol log files for the intra-organization Send connector in the Mailbox Transport Submission service.
            * Delivery: Protocol log files for side effect messages that are submitted after messages are delivered to mailboxes. For example, a message delivered to a mailbox triggers an Inbox rule that redirects the message to another recipient.

        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the intra-organization Send connector in the Mailbox Transport Submission service. To disable protocol logging for this connector, use the value None for the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet.
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
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogPath,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorMaxInboundConnection,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryConnectorSMTPUtf8Enabled,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryThrottlingLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogPath,

        [Parameter()]
        [System.Boolean]
        $MailboxSubmissionAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

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
        $SendProtocolLogPath
    )

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-MailboxTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # If PipelineTracingSenderAddress exists and is empty, set it to $null so Set-MailboxTransportService nulls out the stored value
    if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress') -and [System.String]::IsNullOrEmpty($PipelineTracingSenderAddress))
    {
        $PSBoundParameters['PipelineTracingSenderAddress'] = $null
    }

    Set-MailboxTransportService @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restart service MSExchangeDelivery'
        Restart-Service -Name MSExchangeDelivery -WarningAction SilentlyContinue

        Write-Verbose -Message 'Restart service MSExchangeSubmission'
        Restart-Service -Name MSExchangeSubmission -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until the MSExchangeDelivery and/or MSExchangeSubmission services are manually restarted.'
    }
}

<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER ConnectivityLogEnabled
        The ConnectivityLogEnabled parameter specifies whether the connectivity log is enabled. The default value is $true.

    .PARAMETER ConnectivityLogMaxAge
        The ConnectivityLogMaxAge parameter specifies the maximum age for the connectivity log file. Log files older than the specified value are deleted. The default value is 30 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 25 days for this parameter, use 25.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting the value of the ConnectivityLogMaxAge parameter to 00:00:00 prevents the automatic removal of connectivity log files because of their age.

    .PARAMETER ConnectivityLogMaxDirectorySize
        The ConnectivityLogMaxDirectorySize parameter specifies the maximum size of all connectivity logs in the connectivity log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 1000 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log directory.

    .PARAMETER ConnectivityLogMaxFileSize
        The ConnectivityLogMaxFileSize parameter specifies the maximum size of each connectivity log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the ConnectivityLogMaxFileSize parameter must be less than or equal to the value of the ConnectivityLogMaxDirectorySize parameter. The valid input range for either parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the connectivity log files.

    .PARAMETER ConnectivityLogPath
        The ConnectivityLogPath parameter specifies the default connectivity log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Connectivity. Setting the value of this parameter to $null disables connectivity logging. However, setting this parameter to $null when the value of the ConnectivityLogEnabled attribute is $true generates event log errors.

    .PARAMETER ContentConversionTracingEnabled
    The ContentConversionTracingEnabled parameter specifies whether content conversion tracing is enabled. Content conversion tracing captures content conversion failures that occur in the Transport service or in the Mailbox Transport service on the Mailbox server. The default value is $false. Content conversion tracing captures a maximum of 128 MB of content conversion failures. When the 128 MB limit is reached, no more content conversion failures are captured. Content conversion tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
        * Administrators: Full Control
        * Network Service: Full Control
        * System: Full Control

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory. You identify the domain controller by its fully qualified domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER MailboxDeliveryAgentLogEnabled
        The MailboxDeliveryAgentLogEnabled parameter specifies whether the agent log for the Mailbox Transport Delivery service is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryAgentLogMaxAge
        The MailboxDeliveryAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Delivery service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxDeliveryAgentLogMaxDirectorySize
        The MailboxDeliveryAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Delivery service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxDeliveryAgentLogMaxFileSize
        The MailboxDeliveryAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxDeliveryAgentLogPath
        The MailboxDeliveryAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Delivery. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxDeliveryAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxDeliveryConnectorMaxInboundConnection
        The MailboxDeliveryConnectorMaxInboundConnection parameter specifies the maximum number of inbound connections for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default value is 5000. If you enter the value unlimited, no connection limit is imposed on the mailbox delivery Receive connector.

    .PARAMETER MailboxDeliveryConnectorProtocolLoggingLevel
        The MailboxDeliveryConnectorProtocolLoggingLevel parameter enables or disables SMTP protocol logging for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * None: Protocol logging is disabled for the mailbox delivery Receive connector. This is the default value.
            * Verbose: Protocol logging is enabled for the mailbox delivery Receive connector. The location of the log files is controlled by the ReceiveProtocolLogPath parameter.

    .PARAMETER MailboxDeliveryConnectorSmtpUtf8Enabled
        The MailboxDeliveryConnectorSmtpUtf8Enabled parameters or disables email address internationalization (EAI) support for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Valid values are:
            * $true: Mail can be delivered to local mailboxes that have international characters in email addresses. This is the default value
            * $false: Mail can't be delivered to local mailboxes that have international characters in email addresses.

    .PARAMETER MailboxDeliveryThrottlingLogEnabled
        The MailboxDeliveryThrottlingLogEnabled parameter specifies whether the mailbox delivery throttling log is enabled. The default value is $true.

    .PARAMETER MailboxDeliveryThrottlingLogMaxAge
        The MailboxDeliveryThrottlingLogMaxAge parameter specifies the maximum age for the mailbox delivery throttling log file. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxDeliveryThrottlingLogMaxAge parameter to 00:00:00 prevents the automatic removal of mailbox delivery throttling log files because of their age.

    .PARAMETER MailboxDeliveryThrottlingLogMaxDirectorySize
        The MailboxDeliveryThrottlingLogMaxDirectorySize parameter specifies the maximum size of all mailbox delivery throttling logs in the mailbox delivery throttling log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 200 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log directory.

    .PARAMETER MailboxDeliveryThrottlingLogMaxFileSize
        The MailboxDeliveryThrottlingLogMaxFileSize parameter specifies the maximum size of each mailbox delivery throttling log file. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxDeliveryThrottlingLogMaxFileSize parameter must be less than or equal to the value of the MailboxDeliveryThrottlingLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the mailbox delivery throttling log files.

    .PARAMETER MailboxDeliveryThrottlingLogPath
        The MailboxDeliveryThrottlingLogPath parameter specifies the default mailbox delivery throttling log directory location. The default location is %ExchangeInstallPath%TransportRoles\Logs\Throttling\Delivery. Setting the value of this parameter to $null disables mailbox delivery throttling logging. However, setting this parameter to $null when the value of the MailboxDeliveryThrottlingLogEnabled attribute is $true generates event log errors.

    .PARAMETER MailboxSubmissionAgentLogEnabled
        The MailboxSubmissionAgentLogEnabled parameter specifies whether the agent log is enabled for the Mailbox Transport Submission service. The default value is $true.

    .PARAMETER MailboxSubmissionAgentLogMaxAge
        The MailboxSubmissionAgentLogMaxAge parameter specifies the maximum age for the agent log file of the Mailbox Transport Submission service. Log files older than the specified value are deleted. The default value is 7.00:00:00 or 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Setting the value of the MailboxSubmissionAgentLogMaxAge parameter to 00:00:00 prevents the automatic removal of agent log files because of their age.

    .PARAMETER MailboxSubmissionAgentLogMaxDirectorySize
        The MailboxSubmissionAgentLogMaxDirectorySize parameter specifies the maximum size of all Mailbox Transport Submission service agent logs in the agent log directory. When a directory reaches its maximum file size, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log directory.

    .PARAMETER MailboxSubmissionAgentLogMaxFileSize
        The MailboxSubmissionAgentLogMaxFileSize parameter specifies the maximum size of each agent log file for the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created. The default value is 10 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of the MailboxSubmissionAgentLogMaxFileSize parameter must be less than or equal to the value of the MailboxSubmissionAgentLogMaxDirectorySize parameter. If you enter a value of unlimited, no size limit is imposed on the agent log files.

    .PARAMETER MailboxSubmissionAgentLogPath
        The MailboxSubmissionAgentLogPath parameter specifies the default agent log directory location for the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\AgentLog\Submission. Setting the value of this parameter to $null disables agent logging. However, setting this parameter to $null when the value of the MailboxSubmissionAgentLogEnabled attribute is $true generates event log errors.

    .PARAMETER MaxConcurrentMailboxDeliveries
        The MaxConcurrentMailboxDeliveries parameter specifies the maximum number of delivery threads that the transport service can have open at the same time to deliver messages to mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256. We recommend that you don't modify the default value unless Microsoft Customer Service and Support advises you to do this.

    .PARAMETER MaxConcurrentMailboxSubmissions
        The MaxConcurrentMailboxSubmissions parameter specifies the maximum number of submission threads that the transport service can have open at the same time to send messages from mailboxes. The default value is 20. The valid input range for this parameter is from 1 through 256.

    .PARAMETER PipelineTracingEnabled
        The PipelineTracingEnabled parameter specifies whether to enable pipeline tracing. Pipeline tracing captures message snapshot files that record the changes made to the message by each transport agent configured in the transport service on the server. Pipeline tracing creates verbose log files that accumulate quickly. Pipeline tracing should only be enabled for a short time to provide in-depth diagnostic information that enables you to troubleshoot problems. In addition to troubleshooting, you can use pipeline tracing to validate changes that you make to the configuration of the transport service where you enable pipeline tracing. The default value is $false.

    .PARAMETER PipelineTracingPath
        The PipelineTracingPath parameter specifies the location of the pipeline tracing logs. The default location is %ExchangeInstallPath%TransportRoles\Mailbox\Hub\PipelineTracing. The path must be local to the Exchange computer. Setting the value of this parameter to $null disables pipeline tracing. However, setting this parameter to $null when the value of the PipelineTracingEnabled attribute is $true generates event log errors. The preferred method to disable pipeline tracing is to use the PipelineTracingEnabled parameter. Pipeline tracing captures the complete contents of email messages to the path specified by the PipelineTracingPath parameter. Make sure that you restrict access to this directory. The permissions required on the directory specified by the PipelineTracingPath parameter are as follows:
            * Administrators: Full Control
            * Network Service: Full Control
            * System: Full Control

    .PARAMETER PipelineTracingSenderAddress
        The PipelineTracingSenderAddress parameter specifies the sender email address that invokes pipeline tracing. Only messages from this address generate pipeline tracing output. The address can be either inside or outside the Exchange organization. Depending on your requirements, you may have to set this parameter to different sender addresses and send new messages to start the transport agents or routes that you want to test. The default value of this parameter is $null.

    .PARAMETER ReceiveProtocolLogMaxAge
        The ReceiveProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days).
        The value00:00:00 prevents the automatic removal of Receive connector protocol log files because of their age.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxDirectorySize
        The ReceiveProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be greater than or equal to the value of the ReceiveProtocolLogMaxFileSize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogMaxFileSize
        The ReceiveProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the ReceiveProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the MailboxDeliveryConnectorProtocolLoggingLevel parameter is set to the value Verbose.

    .PARAMETER ReceiveProtocolLogPath
        The ReceiveProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible mailbox delivery Receive connector in the Mailbox Transport Delivery service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpReceive. The log files are automatically stored in the Delivery subdirectory.
        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the mailbox delivery Receive connector. To disable protocol logging for this connector, use the value None for the MailboxDeliveryConnectorProtocolLoggingLevel parameter.

    .PARAMETER RoutingTableLogMaxAge
        The RoutingTableLogMaxAge parameter specifies the maximum routing table log age. Log files older than the specified value are deleted. The default value is 7 days.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        For example, to specify 5 days for this parameter, use 5.00:00:00. The valid input range for this parameter is from 00:00:00 through 24855.03:14:07. Setting this parameter to 00:00:00 prevents the automatic removal of routing table log files because of their age.

    .PARAMETER RoutingTableLogMaxDirectorySize
        The RoutingTableLogMaxDirectorySize parameter specifies the maximum size of the routing table log directory. When the maximum directory size is reached, the server deletes the oldest log files first. The default value is 250 MB.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The valid input range for this parameter is from 1 through 9223372036854775807 bytes. If you enter a value of unlimited, no size limit is imposed on the routing table log directory.

    .PARAMETER RoutingTableLogPath
        The RoutingTableLogPath parameter specifies the directory location where routing table log files should be stored. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\Routing. Setting this parameter to $null disables routing table logging.

    .PARAMETER SendProtocolLogMaxAge
        The SendProtocolLogMaxAge parameter specifies the maximum age of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. Log files that are older than the specified value are automatically deleted.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:00 to 24855.03:14:07. The default value is 30.00:00:00 (30 days). The value 00:00:00 prevents the automatic removal of Send connector protocol log files because of their age.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxDirectorySize
        The SendProtocolLogMaxDirectorySize parameter specifies the maximum size of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When the maximum directory size is reached, the server deletes the oldest log files first.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 250 megabytes (262144000 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value of this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogMaxFileSize
        The SendProtocolLogMaxFileSize parameter specifies the maximum size of a protocol log file for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. When a log file reaches its maximum file size, a new log file is created.
        A valid value is a number up to 909.5 terabytes (999999999999999 bytes) or the value unlimited. The default value is 10 megabytes (10485760 bytes).
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)

        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The value this parameter must be less than or equal to the value of the SendProtocolLogMaxDirectorySize parameter.
        This parameter is only meaningful when the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet is set to the value Verbose.

    .PARAMETER SendProtocolLogPath
        The SendProtocolLogPath parameter specifies the location of the protocol log directory for the implicit and invisible intra-organization Send connector in the Mailbox Transport Submission service. The default location is %ExchangeInstallPath%TransportRoles\Logs\Mailbox\ProtocolLog\SmtpSend. Log files are automatically stored in the following subdirectories:
            * Submission: Protocol log files for the intra-organization Send connector in the Mailbox Transport Submission service.
            * Delivery: Protocol log files for side effect messages that are submitted after messages are delivered to mailboxes. For example, a message delivered to a mailbox triggers an Inbox rule that redirects the message to another recipient.

        Don't use the value $null for this parameter, because event log errors are generated if protocol logging is enabled for the intra-organization Send connector in the Mailbox Transport Submission service. To disable protocol logging for this connector, use the value None for the IntraOrgConnectorProtocolLoggingLevel parameter on the Set-TransportService cmdlet.
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
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryAgentLogPath,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorMaxInboundConnection,

        [Parameter()]
        [System.String]
        $MailboxDeliveryConnectorProtocolLoggingLevel,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryConnectorSMTPUtf8Enabled,

        [Parameter()]
        [System.Boolean]
        $MailboxDeliveryThrottlingLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxDeliveryThrottlingLogPath,

        [Parameter()]
        [System.Boolean]
        $MailboxSubmissionAgentLogEnabled,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxAge,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogMaxFileSize,

        [Parameter()]
        [System.String]
        $MailboxSubmissionAgentLogPath,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

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
        $SendProtocolLogPath
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -Verbose:$VerbosePreference

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    $testResults = $true

    if ($null -eq $mbxTransportService)
    {
        Write-Error -Message 'Unable to retrieve Mailbox Transport Service for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'ConnectivityLogEnabled' -Type 'Boolean' -ExpectedValue $ConnectivityLogEnabled -ActualValue $mbxTransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxAge' -Type 'Timespan' -ExpectedValue $ConnectivityLogMaxAge -ActualValue $mbxTransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $mbxTransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $mbxTransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogPath' -Type 'String' -ExpectedValue $ConnectivityLogPath -ActualValue $mbxTransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ContentConversionTracingEnabled' -Type 'Boolean' -ExpectedValue $ContentConversionTracingEnabled -ActualValue $mbxTransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryAgentLogEnabled' -Type 'Boolean' -ExpectedValue $MailboxDeliveryAgentLogEnabled -ActualValue $mbxTransportService.MailboxDeliveryAgentLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryAgentLogMaxAge' -Type 'TimeSpan' -ExpectedValue $MailboxDeliveryAgentLogMaxAge -ActualValue $mbxTransportService.MailboxDeliveryAgentLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryAgentLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $MailboxDeliveryAgentLogMaxDirectorySize -ActualValue $mbxTransportService.MailboxDeliveryAgentLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryAgentLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $MailboxDeliveryAgentLogMaxFileSize -ActualValue $mbxTransportService.MailboxDeliveryAgentLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryAgentLogPath' -Type 'String' -ExpectedValue $MailboxDeliveryAgentLogPath -ActualValue $mbxTransportService.MailboxDeliveryAgentLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryConnectorMaxInboundConnection' -Type 'Unlimited' -ExpectedValue $MailboxDeliveryConnectorMaxInboundConnection -ActualValue $mbxTransportService.MailboxDeliveryConnectorMaxInboundConnection -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryConnectorProtocolLoggingLevel' -Type 'String' -ExpectedValue $MailboxDeliveryConnectorProtocolLoggingLevel -ActualValue $mbxTransportService.MailboxDeliveryConnectorProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryConnectorSMTPUtf8Enabled' -Type 'Boolean' -ExpectedValue $MailboxDeliveryConnectorSMTPUtf8Enabled -ActualValue $mbxTransportService.MailboxDeliveryConnectorSMTPUtf8Enabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogEnabled' -Type 'Boolean' -ExpectedValue $MailboxDeliveryThrottlingLogEnabled -ActualValue $mbxTransportService.MailboxDeliveryThrottlingLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogMaxAge' -Type 'TimeSpan' -ExpectedValue $MailboxDeliveryThrottlingLogMaxAge -ActualValue $mbxTransportService.MailboxDeliveryThrottlingLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $MailboxDeliveryThrottlingLogMaxDirectorySize -ActualValue $mbxTransportService.MailboxDeliveryThrottlingLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $MailboxDeliveryThrottlingLogMaxFileSize -ActualValue $mbxTransportService.MailboxDeliveryThrottlingLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogPath' -Type 'String' -ExpectedValue $MailboxDeliveryThrottlingLogPath -ActualValue $mbxTransportService.MailboxDeliveryThrottlingLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxSubmissionAgentLogEnabled' -Type 'Boolean' -ExpectedValue $MailboxSubmissionAgentLogEnabled -ActualValue $mbxTransportService.MailboxSubmissionAgentLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxSubmissionAgentLogMaxAge' -Type 'TimeSpan' -ExpectedValue $MailboxSubmissionAgentLogMaxAge -ActualValue $mbxTransportService.MailboxSubmissionAgentLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxSubmissionAgentLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $MailboxSubmissionAgentLogMaxDirectorySize -ActualValue $mbxTransportService.MailboxSubmissionAgentLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxSubmissionAgentLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $MailboxSubmissionAgentLogMaxFileSize -ActualValue $mbxTransportService.MailboxSubmissionAgentLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxDeliveryThrottlingLogPath' -Type 'String' -ExpectedValue $MailboxSubmissionAgentLogPath -ActualValue $mbxTransportService.MailboxSubmissionAgentLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxDeliveries' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $mbxTransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxSubmissions' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $mbxTransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingEnabled' -Type 'Boolean' -ExpectedValue $PipelineTracingEnabled -ActualValue $mbxTransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingPath' -Type 'String' -ExpectedValue $PipelineTracingPath -ActualValue $mbxTransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingSenderAddress' -Type 'SMTPAddress' -ExpectedValue $PipelineTracingSenderAddress -ActualValue $mbxTransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $mbxTransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogPath' -Type 'String' -ExpectedValue $ReceiveProtocolLogPath -ActualValue $mbxTransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $SendProtocolLogMaxAge -ActualValue $mbxTransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $mbxTransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogPath' -Type 'String' -ExpectedValue $SendProtocolLogPath -ActualValue $mbxTransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
