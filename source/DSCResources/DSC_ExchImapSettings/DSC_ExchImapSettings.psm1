<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Server
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes.
        Defaults to $false.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .Parameter AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:30 to 1:00:00. The default setting is 00:30:00 (30 minutes).

    .Parameter Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients. The default value is: The Microsoft Exchange IMAP4 service is ready.

    .Parameter CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients. Valid values are:
            * 0 or iCalendar. This is the default value.
            * 1 or IntranetUrl
            * 2 or InternetUrl
            * 3 or Custom
        If you specify 3 or Custom, you need to specify a value for the OwaServerUrl parameter setting.

    .Parameter EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients. Valid values are:
            * $true: Calculate the exact message size. Because this setting can negatively affect performance, you should configure it only if it's required by your IMAP4 clients.
            * $false: Use an estimated message size. This is the default value.

    .Parameter EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication (NTLM) using the Generic Security Services application programming interface (GSSAPI). This setting applies to connections where Transport Layer Security (TLS) is disabled. Valid values are:
            * $true: NTLM for IMAP4 connections is enabled. This is the default value.
            * $false: NTLM for IMAP4 connections is disabled.

    .Parameter EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer (SSL) certificate validation failures. Valid values are:
        The default setting is $false.
            * $true: If the certificate isn't valid or doesn't match the target IMAP4 server's FQDN, the connection attempt fails.
            * $false: The server doesn't deny IMAP4 connections based on certificate errors. This is the default value.

    .Parameter ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used. Valid values are:
            * None: Extended Protection for Authentication isn't used. This is the default value.
            * Allow: Extended Protection for Authentication is used only if it's supported by the incoming IMAP4 connection. If it's not, Extended Protection for Authentication isn't used.
            * Require: Extended Protection for Authentication is required for all IMAP4 connections. If the incoming IMAP4 connection doesn't support it, the connection is rejected.
        Extended Protection for Authentication enhances the protection and handling of credentials by Integrated Windows authentication (also known as NTLM), so we strongly recommend that you use it if it's supported by your clients (default installations of Windows 7 or later and Windows Server 2008 R2 or later support it).

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by external IMAP4 clients (IMAP4 connections from outside your corporate network).
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is blank ($null), which means no external IMAP4 connection settings are configured.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by internal IMAP4 clients (IMAP4 connections from inside your corporate network). This setting is also used when a IMAP4 connection is forwarded to another Exchange server that's running the Microsoft Exchange IMAP4 service.
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is <ServerFQDN>:993:SSL,<ServerFQDN>:143:TLS.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter LogFileLocation
        The LogFileLocation parameter specifies the location for the IMAP4 protocol log files. The default location is %ExchangeInstallPath%Logging\Imap4.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .Parameter LogFileRollOverSettings
    The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file. Valid values are:
        * 1 or Hourly.
        * 2 or Daily. This is the default value
        * 3 or Weekly.
        * 4 or Monthly.
    This parameter is only meaningful when the LogPerFileSizeQuota parameter value is 0, and the ProtocolLogEnabled parameter value is $true.

    .Parameter LogPerFileSizeQuota
        The LogPerFileSizeQuota parameter specifies the maximum size of a IMAP4 protocol log file.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)
        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The default value is 0, which means a new IMAP4 protocol log file is created at the frequency that's specified by the LogFileRollOverSettings parameter.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections. Valid values are:
            * 1 or PlainTextLogin.
            * 2 or PlainTextAuthentication.
            * 3 or SecureLogin. This is the default value.

    .Parameter MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command. Valid values are from 40 through 1024. The default value is 512.

    .Parameter MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user. Valid values are from 1 through 2147483647. The default value is 16.

    .Parameter MessageRetrievalMimeFormat
        The MessageRetrievalMimeFormat parameter specifies the MIME encoding of messages. Valid values are:
            * 0 or TextOnly.
            * 1 or HtmlOnly.
            * 2 or HtmlAndTextAlternative.
            * 3 or TextEnrichedOnly.
            * 4 or TextEnrichedAndTextAlternative.
            * 5 or BestBodyFormat. This is the default value.
            * 6 or Tnef.

    .Parameter OwaServerUrl
        The OwaServerUrl parameter specifies the URL that's used to retrieve calendar information for instances of custom Outlook on the web calendar items.

    .Parameter PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are00:00:30 to 1:00:00. The default value is 00:01:00 (one minute).

    .Parameter ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4. Valid values are:
            * $true: IMAP4 protocol logging is enabled.
            * $false: IMAP4 protocol logging is disabled. This is the default value.

    .Parameter ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service. The default value is 1993.

    .Parameter ShowHiddenFoldersEnabled
        The ShowHiddenFoldersEnabled parameter specifies whether hidden mailbox folders are visible. Valid values are:
            * $true: Hidden folders are visible.
            * $false: Hidden folders aren't visible. This is the default value.

    .Parameter SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL/TLS. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:993,0.0.0.0:993.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .Parameter SuppressReadReceipt
        The SuppressReadReceipt parameter specifies whether to stop duplicate read receipts from being sent to IMAP4 clients that have the Send read receipts for messages I send setting configured in their IMAP4 email program. Valid values are:
            * $true: The sender receives a read receipt only when the recipient opens the message.
            * $false: The sender receives a read receipt when the recipient downloads the message, and when the recipient opens the message. This is the default value.

    .Parameter UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections, or IMAP4 connections that are encrypted by using opportunistic TLS (STARTTLS) after the initial unencrypted protocol handshake. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:143,0.0.0.0:143.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
        A valid value for this parameter is the FQDN from the ExternalConnectionSettings or InternalConnectionSettings parameters (for example, mail.contoso.com or mailbox01.contoso.com).
        If you use a single subject certificate or a subject alternative name (SAN) certificate, you also need to assign the certificate to the Exchange IMAP service by using the Enable-ExchangeCertificate cmdlet.
        If you use a wildcard certificate, you don't need to assign the certificate to the Exchange IMAP service.
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
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String]
        $X509CertificateName,

        [Parameter()]
        [System.String]
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [ValidateSet('iCalendar', 'IntranetUrl', 'InternetUrl', 'Custom')]
        [System.String]
        $CalendarItemRetrievalOption,

        [Parameter()]
        [System.Boolean]
        $EnableExactRFC822Size,

        [Parameter()]
        [System.Boolean]
        $EnableGSSAPIAndNTLMAuth,

        [Parameter()]
        [System.Boolean]
        $EnforceCertificateErrors,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [System.String]
        $LogFileLocation,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [System.String]
        $LogPerFileSizeQuota,

        [Parameter()]
        [System.Int32]
        $MaxCommandSize,

        [Parameter()]
        [System.Int32]
        $MaxConnectionFromSingleIP,

        [Parameter()]
        [System.Int32]
        $MaxConnections,

        [Parameter()]
        [System.Int32]
        $MaxConnectionsPerUser,

        [Parameter()]
        [ValidateSet('TextOnly', 'HtmlOnly', 'HtmlAndTextAlternative', 'TextEnrichedOnly', 'TextEnrichedAndTextAlternative', 'BestBodyFormat', 'Tnef')]
        [System.String]
        $MessageRetrievalMimeFormat,

        [Parameter()]
        [System.String]
        $OwaServerUrl,

        [Parameter()]
        [System.String]
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.Boolean]
        $ShowHiddenFoldersEnabled,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.Boolean]
        $SuppressReadReceipt,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    $imap = Get-ImapSettingsInternal @PSBoundParameters

    if ($null -ne $imap)
    {
        $returnValue = @{
            Server                            = [System.String] $Server
            ExternalConnectionSettings        = [System.String[]] $imap.ExternalConnectionSettings
            LoginType                         = [System.String] $imap.LoginType
            X509CertificateName               = [System.String] $imap.X509CertificateName
            AuthenticatedConnectionTimeout    = [System.String] $imap.AuthenticatedConnectionTimeout
            Banner                            = [System.String] $imap.Banner
            CalendarItemRetrievalOption       = [System.String] $imap.CalendarItemRetrievalOption
            EnableExactRFC822Size             = [System.Boolean] $imap.EnableExactRFC822Size
            EnableGSSAPIAndNTLMAuth           = [System.Boolean] $imap.EnableGSSAPIAndNTLMAuth
            EnforceCertificateErrors          = [System.Boolean] $imap.EnforceCertificateErrors
            ExtendedProtectionPolicy          = [System.String] $imap.ExtendedProtectionPolicy
            InternalConnectionSettings        = [System.String[]] $imap.InternalConnectionSettings
            LogFileLocation                   = [System.String] $imap.LogFileLocation
            LogFileRollOverSettings           = [System.String] $imap.LogFileRollOverSettings
            LogPerFileSizeQuota               = [System.String] $imap.LogPerFileSizeQuota
            MaxCommandSize                    = [System.Int32] $imap.MaxCommandSize
            MaxConnectionFromSingleIP         = [System.Int32] $imap.MaxConnectionFromSingleIP
            MaxConnections                    = [System.Int32] $imap.MaxConnections
            MaxConnectionsPerUser             = [System.Int32] $imap.MaxConnectionsPerUser
            MessageRetrievalMimeFormat        = [System.String] $imap.MessageRetrievalMimeFormat
            OwaServerUrl                      = [System.String] $imap.OwaServerUrl
            PreAuthenticatedConnectionTimeout = [System.String] $imap.PreAuthenticatedConnectionTimeout
            ProtocolLogEnabled                = [System.Boolean] $imap.ProtocolLogEnabled
            ProxyTargetPort                   = [System.Int32] $imap.ProxyTargetPort
            ShowHiddenFoldersEnabled          = [System.Boolean] $imap.ShowHiddenFoldersEnabled
            SSLBindings                       = [System.String[]] $imap.SSLBindings
            SuppressReadReceipt               = [System.Boolean] $imap.SuppressReadReceipt
            UnencryptedOrTLSBindings          = [System.String[]] $imap.UnencryptedOrTLSBindings
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Server
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes.
        Defaults to $false.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .Parameter AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:30 to 1:00:00. The default setting is 00:30:00 (30 minutes).

    .Parameter Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients. The default value is: The Microsoft Exchange IMAP4 service is ready.

    .Parameter CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients. Valid values are:
            * 0 or iCalendar. This is the default value.
            * 1 or IntranetUrl
            * 2 or InternetUrl
            * 3 or Custom
        If you specify 3 or Custom, you need to specify a value for the OwaServerUrl parameter setting.

    .Parameter EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients. Valid values are:
            * $true: Calculate the exact message size. Because this setting can negatively affect performance, you should configure it only if it's required by your IMAP4 clients.
            * $false: Use an estimated message size. This is the default value.

    .Parameter EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication (NTLM) using the Generic Security Services application programming interface (GSSAPI). This setting applies to connections where Transport Layer Security (TLS) is disabled. Valid values are:
            * $true: NTLM for IMAP4 connections is enabled. This is the default value.
            * $false: NTLM for IMAP4 connections is disabled.

    .Parameter EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer (SSL) certificate validation failures. Valid values are:
        The default setting is $false.
            * $true: If the certificate isn't valid or doesn't match the target IMAP4 server's FQDN, the connection attempt fails.
            * $false: The server doesn't deny IMAP4 connections based on certificate errors. This is the default value.

    .Parameter ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used. Valid values are:
            * None: Extended Protection for Authentication isn't used. This is the default value.
            * Allow: Extended Protection for Authentication is used only if it's supported by the incoming IMAP4 connection. If it's not, Extended Protection for Authentication isn't used.
            * Require: Extended Protection for Authentication is required for all IMAP4 connections. If the incoming IMAP4 connection doesn't support it, the connection is rejected.
        Extended Protection for Authentication enhances the protection and handling of credentials by Integrated Windows authentication (also known as NTLM), so we strongly recommend that you use it if it's supported by your clients (default installations of Windows 7 or later and Windows Server 2008 R2 or later support it).

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by external IMAP4 clients (IMAP4 connections from outside your corporate network).
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is blank ($null), which means no external IMAP4 connection settings are configured.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by internal IMAP4 clients (IMAP4 connections from inside your corporate network). This setting is also used when a IMAP4 connection is forwarded to another Exchange server that's running the Microsoft Exchange IMAP4 service.
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is <ServerFQDN>:993:SSL,<ServerFQDN>:143:TLS.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter LogFileLocation
        The LogFileLocation parameter specifies the location for the IMAP4 protocol log files. The default location is %ExchangeInstallPath%Logging\Imap4.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .Parameter LogFileRollOverSettings
    The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file. Valid values are:
        * 1 or Hourly.
        * 2 or Daily. This is the default value
        * 3 or Weekly.
        * 4 or Monthly.
    This parameter is only meaningful when the LogPerFileSizeQuota parameter value is 0, and the ProtocolLogEnabled parameter value is $true.

    .Parameter LogPerFileSizeQuota
        The LogPerFileSizeQuota parameter specifies the maximum size of a IMAP4 protocol log file.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)
        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The default value is 0, which means a new IMAP4 protocol log file is created at the frequency that's specified by the LogFileRollOverSettings parameter.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections. Valid values are:
            * 1 or PlainTextLogin.
            * 2 or PlainTextAuthentication.
            * 3 or SecureLogin. This is the default value.

    .Parameter MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command. Valid values are from 40 through 1024. The default value is 512.

    .Parameter MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user. Valid values are from 1 through 2147483647. The default value is 16.

    .Parameter MessageRetrievalMimeFormat
        The MessageRetrievalMimeFormat parameter specifies the MIME encoding of messages. Valid values are:
            * 0 or TextOnly.
            * 1 or HtmlOnly.
            * 2 or HtmlAndTextAlternative.
            * 3 or TextEnrichedOnly.
            * 4 or TextEnrichedAndTextAlternative.
            * 5 or BestBodyFormat. This is the default value.
            * 6 or Tnef.

    .Parameter OwaServerUrl
        The OwaServerUrl parameter specifies the URL that's used to retrieve calendar information for instances of custom Outlook on the web calendar items.

    .Parameter PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are00:00:30 to 1:00:00. The default value is 00:01:00 (one minute).

    .Parameter ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4. Valid values are:
            * $true: IMAP4 protocol logging is enabled.
            * $false: IMAP4 protocol logging is disabled. This is the default value.

    .Parameter ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service. The default value is 1993.

    .Parameter ShowHiddenFoldersEnabled
        The ShowHiddenFoldersEnabled parameter specifies whether hidden mailbox folders are visible. Valid values are:
            * $true: Hidden folders are visible.
            * $false: Hidden folders aren't visible. This is the default value.

    .Parameter SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL/TLS. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:993,0.0.0.0:993.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .Parameter SuppressReadReceipt
        The SuppressReadReceipt parameter specifies whether to stop duplicate read receipts from being sent to IMAP4 clients that have the Send read receipts for messages I send setting configured in their IMAP4 email program. Valid values are:
            * $true: The sender receives a read receipt only when the recipient opens the message.
            * $false: The sender receives a read receipt when the recipient downloads the message, and when the recipient opens the message. This is the default value.

    .Parameter UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections, or IMAP4 connections that are encrypted by using opportunistic TLS (STARTTLS) after the initial unencrypted protocol handshake. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:143,0.0.0.0:143.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
        A valid value for this parameter is the FQDN from the ExternalConnectionSettings or InternalConnectionSettings parameters (for example, mail.contoso.com or mailbox01.contoso.com).
        If you use a single subject certificate or a subject alternative name (SAN) certificate, you also need to assign the certificate to the Exchange IMAP service by using the Enable-ExchangeCertificate cmdlet.
        If you use a wildcard certificate, you don't need to assign the certificate to the Exchange IMAP service.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String]
        $X509CertificateName,

        [Parameter()]
        [System.String]
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [ValidateSet('iCalendar', 'IntranetUrl', 'InternetUrl', 'Custom')]
        [System.String]
        $CalendarItemRetrievalOption,

        [Parameter()]
        [System.Boolean]
        $EnableExactRFC822Size,

        [Parameter()]
        [System.Boolean]
        $EnableGSSAPIAndNTLMAuth,

        [Parameter()]
        [System.Boolean]
        $EnforceCertificateErrors,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [System.String]
        $LogFileLocation,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [System.String]
        $LogPerFileSizeQuota,

        [Parameter()]
        [System.Int32]
        $MaxCommandSize,

        [Parameter()]
        [System.Int32]
        $MaxConnectionFromSingleIP,

        [Parameter()]
        [System.Int32]
        $MaxConnections,

        [Parameter()]
        [System.Int32]
        $MaxConnectionsPerUser,

        [Parameter()]
        [ValidateSet('TextOnly', 'HtmlOnly', 'HtmlAndTextAlternative', 'TextEnrichedOnly', 'TextEnrichedAndTextAlternative', 'BestBodyFormat', 'Tnef')]
        [System.String]
        $MessageRetrievalMimeFormat,

        [Parameter()]
        [System.String]
        $OwaServerUrl,

        [Parameter()]
        [System.String]
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.Boolean]
        $ShowHiddenFoldersEnabled,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.Boolean]
        $SuppressReadReceipt,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ImapSettings' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-ImapSettings @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restarting IMAP Services'
        Restart-Service -Name  MSExchangeIMAP4* -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeIMAP4 services are manually restarted.'
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Server
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes.
        Defaults to $false.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .Parameter AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:30 to 1:00:00. The default setting is 00:30:00 (30 minutes).

    .Parameter Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients. The default value is: The Microsoft Exchange IMAP4 service is ready.

    .Parameter CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients. Valid values are:
            * 0 or iCalendar. This is the default value.
            * 1 or IntranetUrl
            * 2 or InternetUrl
            * 3 or Custom
        If you specify 3 or Custom, you need to specify a value for the OwaServerUrl parameter setting.

    .Parameter EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients. Valid values are:
            * $true: Calculate the exact message size. Because this setting can negatively affect performance, you should configure it only if it's required by your IMAP4 clients.
            * $false: Use an estimated message size. This is the default value.

    .Parameter EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication (NTLM) using the Generic Security Services application programming interface (GSSAPI). This setting applies to connections where Transport Layer Security (TLS) is disabled. Valid values are:
            * $true: NTLM for IMAP4 connections is enabled. This is the default value.
            * $false: NTLM for IMAP4 connections is disabled.

    .Parameter EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer (SSL) certificate validation failures. Valid values are:
        The default setting is $false.
            * $true: If the certificate isn't valid or doesn't match the target IMAP4 server's FQDN, the connection attempt fails.
            * $false: The server doesn't deny IMAP4 connections based on certificate errors. This is the default value.

    .Parameter ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used. Valid values are:
            * None: Extended Protection for Authentication isn't used. This is the default value.
            * Allow: Extended Protection for Authentication is used only if it's supported by the incoming IMAP4 connection. If it's not, Extended Protection for Authentication isn't used.
            * Require: Extended Protection for Authentication is required for all IMAP4 connections. If the incoming IMAP4 connection doesn't support it, the connection is rejected.
        Extended Protection for Authentication enhances the protection and handling of credentials by Integrated Windows authentication (also known as NTLM), so we strongly recommend that you use it if it's supported by your clients (default installations of Windows 7 or later and Windows Server 2008 R2 or later support it).

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by external IMAP4 clients (IMAP4 connections from outside your corporate network).
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is blank ($null), which means no external IMAP4 connection settings are configured.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by internal IMAP4 clients (IMAP4 connections from inside your corporate network). This setting is also used when a IMAP4 connection is forwarded to another Exchange server that's running the Microsoft Exchange IMAP4 service.
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is <ServerFQDN>:993:SSL,<ServerFQDN>:143:TLS.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter LogFileLocation
        The LogFileLocation parameter specifies the location for the IMAP4 protocol log files. The default location is %ExchangeInstallPath%Logging\Imap4.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .Parameter LogFileRollOverSettings
    The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file. Valid values are:
        * 1 or Hourly.
        * 2 or Daily. This is the default value
        * 3 or Weekly.
        * 4 or Monthly.
    This parameter is only meaningful when the LogPerFileSizeQuota parameter value is 0, and the ProtocolLogEnabled parameter value is $true.

    .Parameter LogPerFileSizeQuota
        The LogPerFileSizeQuota parameter specifies the maximum size of a IMAP4 protocol log file.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)
        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The default value is 0, which means a new IMAP4 protocol log file is created at the frequency that's specified by the LogFileRollOverSettings parameter.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections. Valid values are:
            * 1 or PlainTextLogin.
            * 2 or PlainTextAuthentication.
            * 3 or SecureLogin. This is the default value.

    .Parameter MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command. Valid values are from 40 through 1024. The default value is 512.

    .Parameter MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user. Valid values are from 1 through 2147483647. The default value is 16.

    .Parameter MessageRetrievalMimeFormat
        The MessageRetrievalMimeFormat parameter specifies the MIME encoding of messages. Valid values are:
            * 0 or TextOnly.
            * 1 or HtmlOnly.
            * 2 or HtmlAndTextAlternative.
            * 3 or TextEnrichedOnly.
            * 4 or TextEnrichedAndTextAlternative.
            * 5 or BestBodyFormat. This is the default value.
            * 6 or Tnef.

    .Parameter OwaServerUrl
        The OwaServerUrl parameter specifies the URL that's used to retrieve calendar information for instances of custom Outlook on the web calendar items.

    .Parameter PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are00:00:30 to 1:00:00. The default value is 00:01:00 (one minute).

    .Parameter ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4. Valid values are:
            * $true: IMAP4 protocol logging is enabled.
            * $false: IMAP4 protocol logging is disabled. This is the default value.

    .Parameter ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service. The default value is 1993.

    .Parameter ShowHiddenFoldersEnabled
        The ShowHiddenFoldersEnabled parameter specifies whether hidden mailbox folders are visible. Valid values are:
            * $true: Hidden folders are visible.
            * $false: Hidden folders aren't visible. This is the default value.

    .Parameter SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL/TLS. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:993,0.0.0.0:993.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .Parameter SuppressReadReceipt
        The SuppressReadReceipt parameter specifies whether to stop duplicate read receipts from being sent to IMAP4 clients that have the Send read receipts for messages I send setting configured in their IMAP4 email program. Valid values are:
            * $true: The sender receives a read receipt only when the recipient opens the message.
            * $false: The sender receives a read receipt when the recipient downloads the message, and when the recipient opens the message. This is the default value.

    .Parameter UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections, or IMAP4 connections that are encrypted by using opportunistic TLS (STARTTLS) after the initial unencrypted protocol handshake. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:143,0.0.0.0:143.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
        A valid value for this parameter is the FQDN from the ExternalConnectionSettings or InternalConnectionSettings parameters (for example, mail.contoso.com or mailbox01.contoso.com).
        If you use a single subject certificate or a subject alternative name (SAN) certificate, you also need to assign the certificate to the Exchange IMAP service by using the Enable-ExchangeCertificate cmdlet.
        If you use a wildcard certificate, you don't need to assign the certificate to the Exchange IMAP service.
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
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String]
        $X509CertificateName,

        [Parameter()]
        [System.String]
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [ValidateSet('iCalendar', 'IntranetUrl', 'InternetUrl', 'Custom')]
        [System.String]
        $CalendarItemRetrievalOption,

        [Parameter()]
        [System.Boolean]
        $EnableExactRFC822Size,

        [Parameter()]
        [System.Boolean]
        $EnableGSSAPIAndNTLMAuth,

        [Parameter()]
        [System.Boolean]
        $EnforceCertificateErrors,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [System.String]
        $LogFileLocation,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [System.String]
        $LogPerFileSizeQuota,

        [Parameter()]
        [System.Int32]
        $MaxCommandSize,

        [Parameter()]
        [System.Int32]
        $MaxConnectionFromSingleIP,

        [Parameter()]
        [System.Int32]
        $MaxConnections,

        [Parameter()]
        [System.Int32]
        $MaxConnectionsPerUser,

        [Parameter()]
        [ValidateSet('TextOnly', 'HtmlOnly', 'HtmlAndTextAlternative', 'TextEnrichedOnly', 'TextEnrichedAndTextAlternative', 'BestBodyFormat', 'Tnef')]
        [System.String]
        $MessageRetrievalMimeFormat,

        [Parameter()]
        [System.String]
        $OwaServerUrl,

        [Parameter()]
        [System.String]
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.Boolean]
        $ShowHiddenFoldersEnabled,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.Boolean]
        $SuppressReadReceipt,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $imap = Get-ImapSettingsInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $imap)
    {
        Write-Error -Message 'Unable to retrieve IMAP Settings for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'LoginType' -Type 'String' -ExpectedValue $LoginType -ActualValue $imap.LoginType -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalConnectionSettings' -Type 'Array' -ExpectedValue $ExternalConnectionSettings -ActualValue $imap.ExternalConnectionSettings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'X509CertificateName' -Type 'String' -ExpectedValue $X509CertificateName -ActualValue $imap.X509CertificateName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AuthenticatedConnectionTimeout' -Type 'Timespan' -ExpectedValue $AuthenticatedConnectionTimeout -ActualValue $imap.AuthenticatedConnectionTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'Banner' -Type 'String' -ExpectedValue $Banner -ActualValue $imap.Banner -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'CalendarItemRetrievalOption' -Type 'String' -ExpectedValue $CalendarItemRetrievalOption -ActualValue $imap.CalendarItemRetrievalOption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'EnableExactRFC822Size' -Type 'Boolean' -ExpectedValue $EnableExactRFC822Size -ActualValue $imap.EnableExactRFC822Size -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'EnableGSSAPIAndNTLMAuth' -Type 'Boolean' -ExpectedValue $EnableGSSAPIAndNTLMAuth -ActualValue $imap.EnableGSSAPIAndNTLMAuth -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'EnforceCertificateErrors' -Type 'Boolean' -ExpectedValue $EnforceCertificateErrors -ActualValue $imap.EnforceCertificateErrors -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExtendedProtectionPolicy' -Type 'String' -ExpectedValue $ExtendedProtectionPolicy -ActualValue $imap.ExtendedProtectionPolicy -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalConnectionSettings' -Type 'Array' -ExpectedValue $InternalConnectionSettings -ActualValue $imap.InternalConnectionSettings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogFileLocation' -Type 'String' -ExpectedValue $LogFileLocation -ActualValue $imap.LogFileLocation -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogFileRollOverSettings' -Type 'String' -ExpectedValue $LogFileRollOverSettings -ActualValue $imap.LogFileRollOverSettings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogPerFileSizeQuota' -Type 'String' -ExpectedValue $LogPerFileSizeQuota -ActualValue $imap.LogPerFileSizeQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxCommandSize' -Type 'Int' -ExpectedValue $MaxCommandSize -ActualValue $imap.MaxCommandSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConnectionFromSingleIP' -Type 'Int' -ExpectedValue $MaxConnectionFromSingleIP -ActualValue $imap.MaxConnectionFromSingleIP -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConnections' -Type 'Int' -ExpectedValue $MaxConnections -ActualValue $imap.MaxConnections -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConnectionsPerUser' -Type 'Int' -ExpectedValue $MaxConnectionsPerUser -ActualValue $imap.MaxConnectionsPerUser -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MessageRetrievalMimeFormat' -Type 'String' -ExpectedValue $MessageRetrievalMimeFormat -ActualValue $imap.MessageRetrievalMimeFormat -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'OwaServerUrl' -Type 'String' -ExpectedValue $OwaServerUrl -ActualValue $imap.OwaServerUrl -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PreAuthenticatedConnectionTimeout' -Type 'Timespan' -ExpectedValue $PreAuthenticatedConnectionTimeout -ActualValue $imap.PreAuthenticatedConnectionTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ProtocolLogEnabled' -Type 'Boolean' -ExpectedValue $ProtocolLogEnabled -ActualValue $imap.ProtocolLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ProxyTargetPort' -Type 'Int' -ExpectedValue $ProxyTargetPort -ActualValue $imap.ProxyTargetPort -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ShowHiddenFoldersEnabled' -Type 'Boolean' -ExpectedValue $ShowHiddenFoldersEnabled -ActualValue $imap.ShowHiddenFoldersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SSLBindings' -Type 'Array' -ExpectedValue $SSLBindings -ActualValue $imap.SSLBindings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SuppressReadReceipt' -Type 'Boolean' -ExpectedValue $SuppressReadReceipt -ActualValue $imap.SuppressReadReceipt -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'UnencryptedOrTLSBindings' -Type 'Array' -ExpectedValue $UnencryptedOrTLSBindings -ActualValue $imap.UnencryptedOrTLSBindings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-ImapSettings. Runs
        Get-ImapSettings, only specifying Server, and
        optionally DomainController, and returns the results.

    .PARAMETER Server
        The Server parameter specifies the Exchange server where you want to run this command. You can use any value that uniquely identifies the server. For example:
            * Name
            * FQDN
            * Distinguished name (DN)
            * Exchange Legacy DN
        If you don't use this parameter, the command is run on the local server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes.
        Defaults to $false.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .Parameter AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are 00:00:30 to 1:00:00. The default setting is 00:30:00 (30 minutes).

    .Parameter Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients. The default value is: The Microsoft Exchange IMAP4 service is ready.

    .Parameter CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients. Valid values are:
            * 0 or iCalendar. This is the default value.
            * 1 or IntranetUrl
            * 2 or InternetUrl
            * 3 or Custom
        If you specify 3 or Custom, you need to specify a value for the OwaServerUrl parameter setting.

    .Parameter EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients. Valid values are:
            * $true: Calculate the exact message size. Because this setting can negatively affect performance, you should configure it only if it's required by your IMAP4 clients.
            * $false: Use an estimated message size. This is the default value.

    .Parameter EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication (NTLM) using the Generic Security Services application programming interface (GSSAPI). This setting applies to connections where Transport Layer Security (TLS) is disabled. Valid values are:
            * $true: NTLM for IMAP4 connections is enabled. This is the default value.
            * $false: NTLM for IMAP4 connections is disabled.

    .Parameter EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer (SSL) certificate validation failures. Valid values are:
        The default setting is $false.
            * $true: If the certificate isn't valid or doesn't match the target IMAP4 server's FQDN, the connection attempt fails.
            * $false: The server doesn't deny IMAP4 connections based on certificate errors. This is the default value.

    .Parameter ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used. Valid values are:
            * None: Extended Protection for Authentication isn't used. This is the default value.
            * Allow: Extended Protection for Authentication is used only if it's supported by the incoming IMAP4 connection. If it's not, Extended Protection for Authentication isn't used.
            * Require: Extended Protection for Authentication is required for all IMAP4 connections. If the incoming IMAP4 connection doesn't support it, the connection is rejected.
        Extended Protection for Authentication enhances the protection and handling of credentials by Integrated Windows authentication (also known as NTLM), so we strongly recommend that you use it if it's supported by your clients (default installations of Windows 7 or later and Windows Server 2008 R2 or later support it).

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by external IMAP4 clients (IMAP4 connections from outside your corporate network).
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is blank ($null), which means no external IMAP4 connection settings are configured.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name, port, and encryption method that's used by internal IMAP4 clients (IMAP4 connections from inside your corporate network). This setting is also used when a IMAP4 connection is forwarded to another Exchange server that's running the Microsoft Exchange IMAP4 service.
        This parameter uses the syntax <HostName>:<Port>:[<TLS | SSL>]. The encryption method value is optional (blank indicates unencrypted connections).
        The default value is <ServerFQDN>:993:SSL,<ServerFQDN>:143:TLS.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.
        The combination of encryption methods and ports that are specified for this parameter need to match the corresponding encryption methods and ports that are specified by the SSLBindings and UnencryptedOrTLSBindings parameters.

    .Parameter LogFileLocation
        The LogFileLocation parameter specifies the location for the IMAP4 protocol log files. The default location is %ExchangeInstallPath%Logging\Imap4.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .Parameter LogFileRollOverSettings
    The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file. Valid values are:
        * 1 or Hourly.
        * 2 or Daily. This is the default value
        * 3 or Weekly.
        * 4 or Monthly.
    This parameter is only meaningful when the LogPerFileSizeQuota parameter value is 0, and the ProtocolLogEnabled parameter value is $true.

    .Parameter LogPerFileSizeQuota
        The LogPerFileSizeQuota parameter specifies the maximum size of a IMAP4 protocol log file.
        When you enter a value, qualify the value with one of the following units:
            * B (bytes)
            * KB (kilobytes)
            * MB (megabytes)
            * GB (gigabytes)
            * TB (terabytes)
        Unqualified values are typically treated as bytes, but small values may be rounded up to the nearest kilobyte.
        The default value is 0, which means a new IMAP4 protocol log file is created at the frequency that's specified by the LogFileRollOverSettings parameter.
        This parameter is only meaningful when the ProtocolLogEnabled parameter value is $true.

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections. Valid values are:
            * 1 or PlainTextLogin.
            * 2 or PlainTextAuthentication.
            * 3 or SecureLogin. This is the default value.

    .Parameter MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command. Valid values are from 40 through 1024. The default value is 512.

    .Parameter MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server. Valid values are from 1 through 2147483647. The default value is 2147483647.

    .Parameter MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user. Valid values are from 1 through 2147483647. The default value is 16.

    .Parameter MessageRetrievalMimeFormat
        The MessageRetrievalMimeFormat parameter specifies the MIME encoding of messages. Valid values are:
            * 0 or TextOnly.
            * 1 or HtmlOnly.
            * 2 or HtmlAndTextAlternative.
            * 3 or TextEnrichedOnly.
            * 4 or TextEnrichedAndTextAlternative.
            * 5 or BestBodyFormat. This is the default value.
            * 6 or Tnef.

    .Parameter OwaServerUrl
        The OwaServerUrl parameter specifies the URL that's used to retrieve calendar information for instances of custom Outlook on the web calendar items.

    .Parameter PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
        To specify a value, enter it as a time span: dd.hh:mm:ss where dd = days, hh = hours, mm = minutes, and ss = seconds.
        Valid values are00:00:30 to 1:00:00. The default value is 00:01:00 (one minute).

    .Parameter ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4. Valid values are:
            * $true: IMAP4 protocol logging is enabled.
            * $false: IMAP4 protocol logging is disabled. This is the default value.

    .Parameter ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service. The default value is 1993.

    .Parameter ShowHiddenFoldersEnabled
        The ShowHiddenFoldersEnabled parameter specifies whether hidden mailbox folders are visible. Valid values are:
            * $true: Hidden folders are visible.
            * $false: Hidden folders aren't visible. This is the default value.

    .Parameter SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL/TLS. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:993,0.0.0.0:993.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .Parameter SuppressReadReceipt
        The SuppressReadReceipt parameter specifies whether to stop duplicate read receipts from being sent to IMAP4 clients that have the Send read receipts for messages I send setting configured in their IMAP4 email program. Valid values are:
            * $true: The sender receives a read receipt only when the recipient opens the message.
            * $false: The sender receives a read receipt when the recipient downloads the message, and when the recipient opens the message. This is the default value.

    .Parameter UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections, or IMAP4 connections that are encrypted by using opportunistic TLS (STARTTLS) after the initial unencrypted protocol handshake. This parameter uses the syntax <IPv4OrIPv6Address>:<Port>.
        The default value is [::]:143,0.0.0.0:143.
        To enter multiple values and overwrite any existing entries, use the following syntax: <value1>,<value2>,...<valueN>. If the values contain spaces or otherwise require quotation marks, you need to use the following syntax: "<value1>","<value2>",..."<valueN>".
        To add or remove one or more values without affecting any existing entries, use the following syntax: @{Add="<value1>","<value2>"...; Remove="<value1>","<value2>"...}.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
        A valid value for this parameter is the FQDN from the ExternalConnectionSettings or InternalConnectionSettings parameters (for example, mail.contoso.com or mailbox01.contoso.com).
        If you use a single subject certificate or a subject alternative name (SAN) certificate, you also need to assign the certificate to the Exchange IMAP service by using the Enable-ExchangeCertificate cmdlet.
        If you use a wildcard certificate, you don't need to assign the certificate to the Exchange IMAP service.
#>
function Get-ImapSettingsInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String]
        $X509CertificateName,

        [Parameter()]
        [System.String]
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [ValidateSet('iCalendar', 'IntranetUrl', 'InternetUrl', 'Custom')]
        [System.String]
        $CalendarItemRetrievalOption,

        [Parameter()]
        [System.Boolean]
        $EnableExactRFC822Size,

        [Parameter()]
        [System.Boolean]
        $EnableGSSAPIAndNTLMAuth,

        [Parameter()]
        [System.Boolean]
        $EnforceCertificateErrors,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [System.String]
        $LogFileLocation,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [System.String]
        $LogPerFileSizeQuota,

        [Parameter()]
        [System.Int32]
        $MaxCommandSize,

        [Parameter()]
        [System.Int32]
        $MaxConnectionFromSingleIP,

        [Parameter()]
        [System.Int32]
        $MaxConnections,

        [Parameter()]
        [System.Int32]
        $MaxConnectionsPerUser,

        [Parameter()]
        [ValidateSet('TextOnly', 'HtmlOnly', 'HtmlAndTextAlternative', 'TextEnrichedOnly', 'TextEnrichedAndTextAlternative', 'BestBodyFormat', 'Tnef')]
        [System.String]
        $MessageRetrievalMimeFormat,

        [Parameter()]
        [System.String]
        $OwaServerUrl,

        [Parameter()]
        [System.String]
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.Boolean]
        $ShowHiddenFoldersEnabled,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.Boolean]
        $SuppressReadReceipt,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server', 'DomainController'

    return (Get-ImapSettings @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
