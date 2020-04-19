<#
    .SYNOPSIS
        Gets the resource
    .PARAMETER Identity
        Identity of the Receive Connector. Needs to be in format SERVERNAME\CONNECTORNAME (no quotes)
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER Ensure
        Whether the connector should be present or not.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure
    )

    Assert-IdentityIsValid -Identity $Identity

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ReceiveConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $connector = Get-ReceiveConnector -Identity $Identity -ErrorAction SilentlyContinue

    if ($null -ne $connector)
    {
        $adPermissions = Get-ADExtendedPermissions -Identity $Identity.Split('\')[1]

        $returnValue = @{
            Identity                                = [System.String] $Identity
            AdvertiseClientSettings                 = [System.Boolean] $connector.AdvertiseClientSettings
            AuthTarpitInterval                      = [System.String] $connector.AuthTarpitInterval
            AuthMechanism                           = [System.String[]] $connector.AuthMechanism.ToString().Split(',').Trim()
            Banner                                  = [System.String] $connector.Banner
            BareLinefeedRejectionEnabled            = [System.Boolean] $connector.BareLinefeedRejectionEnabled
            BinaryMimeEnabled                       = [System.Boolean] $connector.BinaryMimeEnabled
            Bindings                                = [System.String[]] $connector.Bindings
            ChunkingEnabled                         = [System.Boolean] $connector.ChunkingEnabled
            Comment                                 = [System.String] $connector.Comment
            ConnectionInactivityTimeout             = [System.String] $connector.ConnectionInactivityTimeout
            ConnectionTimeout                       = [System.String] $connector.ConnectionTimeout
            DefaultDomain                           = [System.String] $connector.DefaultDomain
            DeliveryStatusNotificationEnabled       = [System.Boolean] $connector.DeliveryStatusNotificationEnabled
            DomainSecureEnabled                     = [System.Boolean] $connector.DomainSecureEnabled
            EightBitMimeEnabled                     = [System.Boolean] $connector.EightBitMimeEnabled
            EnableAuthGSSAPI                        = [System.Boolean] $connector.EnableAuthGSSAPI
            Enabled                                 = [System.Boolean] $connector.Enabled
            EnhancedStatusCodesEnabled              = [System.Boolean] $connector.EnhancedStatusCodesEnabled
            ExtendedProtectionPolicy                = [System.String] $connector.ExtendedProtectionPolicy
            ExtendedRightAllowEntries               = [Microsoft.Management.Infrastructure.CimInstance[]] $adPermissions['ExtendedRightAllowEntries']
            ExtendedRightDenyEntries                = [Microsoft.Management.Infrastructure.CimInstance[]] $adPermissions['ExtendedRightDenyEntries']
            Fqdn                                    = [System.String] $connector.Fqdn
            LongAddressesEnabled                    = [System.Boolean] $connector.LongAddressesEnabled
            MaxAcknowledgementDelay                 = [System.String] $connector.MaxAcknowledgementDelay
            MaxHeaderSize                           = [System.String] $connector.MaxHeaderSize
            MaxHopCount                             = [System.Int32] $connector.MaxHopCount
            MaxInboundConnection                    = [System.String] $connector.MaxInboundConnection
            MaxInboundConnectionPercentagePerSource = [System.Int32] $connector.MaxInboundConnectionPercentagePerSource
            MaxInboundConnectionPerSource           = [System.String] $connector.MaxInboundConnectionPerSource
            MaxLocalHopCount                        = [System.Int32] $connector.MaxLocalHopCount
            MaxLogonFailures                        = [System.Int32] $connector.MaxLogonFailures
            MaxMessageSize                          = [System.String] $connector.MaxMessageSize
            MaxProtocolErrors                       = [System.String] $connector.MaxProtocolErrors
            MaxRecipientsPerMessage                 = [System.Int32] $connector.MaxRecipientsPerMessage
            MessageRateLimit                        = [System.String] $connector.MessageRateLimit
            MessageRateSource                       = [System.String] $connector.MessageRateSource
            OrarEnabled                             = [System.Boolean] $connector.OrarEnabled
            PermissionGroups                        = [System.String[]] $connector.PermissionGroups.ToString().Split(',').Trim()
            PipeliningEnabled                       = [System.Boolean] $connector.PipeliningEnabled
            ProtocolLoggingLevel                    = [System.String] $connector.ProtocolLoggingLevel
            RemoteIPRanges                          = [System.String[]] $connector.RemoteIPRanges
            RequireEHLODomain                       = [System.Boolean] $connector.RequireEHLODomain
            RequireTLS                              = [System.Boolean] $connector.RequireTLS
            ServiceDiscoveryFqdn                    = [System.String] $connector.ServiceDiscoveryFqdn
            SizeEnabled                             = [System.String] $connector.SizeEnabled
            SuppressXAnonymousTls                   = [System.Boolean] $connector.SuppressXAnonymousTls
            TarpitInterval                          = [System.String] $connector.TarpitInterval
            TlsCertificateName                      = [System.String] $connector.TlsCertificateName
            TlsDomainCapabilities                   = [System.String[]] $connector.TlsDomainCapabilities
            TransportRole                           = [System.String] $connector.TransportRole
            Usage                                   = [System.String[]] $connector.Usage
            Ensure                                  = 'Present'
        }
    }
    else
    {
        $returnValue = @{
            Ensure = 'Absent'
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the resource
    .PARAMETER Identity
        Identity of the Receive Connector. Needs to be in format SERVERNAME\CONNECTORNAME (no quotes)
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER Ensure
        Whether the connector should be present or not.
    .PARAMETER AdvertiseClientSettings
        Specifies whether the SMTP server name,port number, and authentication settings for the Receive connector
        are displayed to users in the options of Outlook on the web.
    .PARAMETER AuthMechanism
        Specifies the advertised and accepted authentication mechanisms for the Receive connector.
    .PARAMETER AuthTarpitInterval
        Specifies the period of time to delay responses to failed authentication attempts from remote servers.
    .PARAMETER Banner
        Specifies a custom SMTP 220 banner that's displayed to remote messaging servers.
    .PARAMETER BareLinefeedRejectionEnabled
        Specifies whether this Receive connector rejects messages that contain line feed
    .PARAMETER BinaryMimeEnabled
        Specifies whether the BINARYMIME Extended SMTP extension is enabled or disabled.
    .PARAMETER Bindings
        Specifies the local IP address and TCP port number that's used by the Receive connector.
    .PARAMETER ChunkingEnabled
        Specifies whether the CHUNKING Extended SMTP extension is enabled or disabled.
    .PARAMETER Comment
        Specifies an optional comment.
    .PARAMETER ConnectionInactivityTimeout
        Specifies the maximum amount of idle time before a connection to the Receive connector is closed.
    .PARAMETER ConnectionTimeout
        Specifies the maximum time that the connection to the Receive connector can remain open
    .PARAMETER DefaultDomain
        Specifies the default accepted domain to use for the Exchange organization.
    .PARAMETER DeliveryStatusNotificationEnabled
        Specifies whether the DSN
    .PARAMETER DomainController
        Specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory.
    .PARAMETER DomainSecureEnabled
        Specifies whether to enable or disable mutual Transport Layer Security
    .PARAMETER EightBitMimeEnabled
        Specifies whether the 8BITMIME Extended SMTP extension is enabled or disabled.
    .PARAMETER EnableAuthGSSAPI
        enables or disables Kerberos when Integrated Windows authentication is available on the Receive connector.
    .PARAMETER Enabled
        Specifies whether to enable or disable the Receive connector.
    .PARAMETER EnhancedStatusCodesEnabled
        Specifies whether the ENHANCEDSTATUSCODES Extended SMTP extension is enabled or disabled.
    .PARAMETER ExtendedRightAllowEntries
        Additional allow permissions.
    .PARAMETER ExtendedRightDenyEntries
        Additional denz permissions.
    .PARAMETER ExtendedProtectionPolicy
        Specifies how you want to use Extended Protection for Authentication on the Receive connector.
    .PARAMETER Fqdn
        Specifies the destination FQDN that's shown to connected messaging servers.
    .PARAMETER LongAddressesEnabled
        Specifies whether the Receive connector accepts long X.400 email addresses.
    .PARAMETER MaxAcknowledgementDelay
        Specifies the period the transport server delays acknowledgement when receiving messages from a host that doesn't support shadow redundancy.
    .PARAMETER MaxHeaderSize
        Specifies the maximum size of the SMTP message header before the Receive connector closes the connection.
    .PARAMETER MaxHopCount
        Specifies the maximum number of hops that a message can take before the message is rejected by the Receive connector.
    .PARAMETER MaxInboundConnection
        Specifies the maximum number of inbound connections that this Receive connector serves at the same time.
    .PARAMETER MaxInboundConnectionPercentagePerSource
        Specifies the maximum number of connections that this Receive connector serves at the same time from a single IP address.
    .PARAMETER MaxInboundConnectionPerSource
        Specifies the maximum number of connections that a Receive connector serves at the same time from a single IP address
    .PARAMETER MaxLocalHopCount
        Specifies the maximum number of local hops that a message can take before the message is rejected by the Receive connector.
    .PARAMETER MaxLogonFailures
        pecifies the number of logon failures that the Receive connector retries before it closes the connection.
    .PARAMETER MaxMessageSize
        Specifies the maximum size of a message that's allowed through the Receive connector.
    .PARAMETER MaxProtocolErrors
        Specifies the maximum number of SMTP protocol errors that the Receive connector accepts before closing the connection.
    .PARAMETER MaxRecipientsPerMessage
        Specifies the maximum number of recipients per message that the Receive connector accepts before closing the connection.
    .PARAMETER MessageRateLimit
        Specifies the maximum number of messages that can be sent by a single client IP address per minute.
    .PARAMETER MessageRateSource
        Specifies how the message submission rate is calculated.
    .PARAMETER OrarEnabled
        enables or disables Originator Requested Alternate Recipient
    .PARAMETER PermissionGroups
        Specifies the well
    .PARAMETER PipeliningEnabled
        Specifies whether the PIPELINING Extended SMTP extension is enabled or disabled.
    .PARAMETER ProtocolLoggingLevel
        pecifies whether to enable or disable protocol logging.
    .PARAMETER RemoteIPRanges
        Specifies the remote IP addresses that the Receive connector accepts messages from.
    .PARAMETER RequireEHLODomain
        Specifies whether the client must provide a domain name in the EHLO handshake after the SMTP connection is established.
    .PARAMETER RequireTLS
        Specifies whether to require TLS transmission for inbound messages.
    .PARAMETER SizeEnabled
        Specifies how the SIZE Extended SMTP extension is used on the Receive connector.
    .PARAMETER SuppressXAnonymousTls
        Specifies whether the X
    .PARAMETER TarpitInterval
        Specifies the period of time to delay an SMTP response to a remote server that may be abusing the connection.
    .PARAMETER TlsCertificateName
        Specifies the X.509 certificate to use for TLS encryption.
    .PARAMETER TlsDomainCapabilities
        Specifies the capabilities that the Receive connector makes available to specific hosts outside of the organization.
    .PARAMETER TransportRole
        Specifies the transport service on the Mailbox server where the Receive connector is created.
    .PARAMETER Usage
        Specifies the default permission groups and authentication methods that are assigned to the Receive connector.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries = @(),

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries = @(),

        [Parameter()]
        [System.Boolean]
        $AdvertiseClientSettings,

        [Parameter()]
        [System.String]
        $AuthTarpitInterval,

        [Parameter()]
        [System.String[]]
        [ValidateSet('None', 'Tls', 'Integrated', 'BasicAuth', 'BasicAuthRequireTLS', 'ExchangeServer', 'ExternalAuthoritative')]
        $AuthMechanism,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [Parameter()]
        [System.Boolean]
        $BinaryMimeEnabled,

        [Parameter()]
        [System.String[]]
        $Bindings,

        [Parameter()]
        [System.Boolean]
        $ChunkingEnabled,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ConnectionInactivityTimeout,

        [Parameter()]
        [System.String]
        $ConnectionTimeout,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [Parameter()]
        [System.Boolean]
        $DomainSecureEnabled,

        [Parameter()]
        [System.Boolean]
        $EightBitMimeEnabled,

        [Parameter()]
        [System.Boolean]
        $EnableAuthGSSAPI,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String]
        $Fqdn,

        [Parameter()]
        [System.Boolean]
        $LongAddressesEnabled,

        [Parameter()]
        [System.String]
        $MaxAcknowledgementDelay,

        [Parameter()]
        [System.String]
        $MaxHeaderSize,

        [Parameter()]
        [System.Int32]
        $MaxHopCount,

        [Parameter()]
        [System.String]
        $MaxInboundConnection,

        [Parameter()]
        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [Parameter()]
        [System.String]
        $MaxInboundConnectionPerSource,

        [Parameter()]
        [System.Int32]
        $MaxLocalHopCount,

        [Parameter()]
        [System.Int32]
        $MaxLogonFailures,

        [Parameter()]
        [System.String]
        $MaxMessageSize,

        [Parameter()]
        [System.String]
        $MaxProtocolErrors,

        [Parameter()]
        [System.Int32]
        $MaxRecipientsPerMessage,

        [Parameter()]
        [System.String]
        $MessageRateLimit,

        [Parameter()]
        [ValidateSet('None', 'IPAddress', 'User', 'All')]
        [System.String]
        $MessageRateSource,

        [Parameter()]
        [System.Boolean]
        $OrarEnabled,

        [Parameter()]
        [ValidateSet('None', 'AnonymousUsers', 'ExchangeUsers', 'ExchangeServers', 'ExchangeLegacyServers', 'Partners', 'Custom')]
        [System.String[]]
        $PermissionGroups,

        [Parameter()]
        [System.Boolean]
        $PipeliningEnabled,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $ProtocolLoggingLevel,

        [Parameter()]
        [System.String[]]
        $RemoteIPRanges,

        [Parameter()]
        [System.Boolean]
        $RequireEHLODomain,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [System.String]
        $ServiceDiscoveryFqdn,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'EnabledWithoutValue')]
        [System.String]
        $SizeEnabled,

        [Parameter()]
        [System.Boolean]
        $SuppressXAnonymousTls,

        [Parameter()]
        [System.String]
        $TarpitInterval,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [System.String[]]
        $TlsDomainCapabilities,

        [Parameter()]
        [ValidateSet('FrontendTransport', 'HubTransport')]
        [System.String]
        $TransportRole,

        [Parameter()]
        [ValidateSet('Client', 'Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Assert-IdentityIsValid -Identity $Identity

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    $connector = Get-TargetResource -Identity $Identity -Credential $Credential -Ensure $Ensure

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*ReceiveConnector', '*ADPermission' -Verbose:$VerbosePreference

    if ($Ensure -eq 'Absent')
    {
        if ($connector['Ensure'] -eq 'Present')
        {
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'
            Write-Verbose -Message 'Removing the receive connector.'

            Remove-ReceiveConnector @PSBoundParameters -Confirm:$false
        }
    }
    else
    {
        # Remove Credential and Ensure so we don't pass it into the next command
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

        Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        # We need to create the new connector
        if ($connector['Ensure'] -eq 'Absent')
        {
            # Create a copy of the original parameters
            $originalPSBoundParameters = @{ } + $PSBoundParameters

            # The following aren't valid for New-ReceiveConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity', 'BareLinefeedRejectionEnabled'

            # Parse out the server name and connector name from the given Identity
            $serverName, $connectorName = $Identity.Split('\')

            # Add in server and name parameters
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
                'Server' = $serverName
                'Name'   = $connectorName
            }

            Write-Verbose -Message 'Creating the receive connector.'

            # Create the connector
            New-ReceiveConnector @PSBoundParameters

            # Add original props back
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

            # Remove the two props we added
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Server', 'Name', 'Usage'

            Write-Verbose -Message 'Setting the receive connector properties.'

            Set-ReceiveConnector @PSBoundParameters

            if ($ExtendedRightAllowEntries -or $ExtendedRightDenyEntries)
            {
                $splat = @{
                    ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                    ExtendedRightDenyEntries  = $ExtendedRightDenyEntries
                    DomainController          = $DomainController
                    Identity                  = $Identity.Split('\')[1]
                    NewObject                 = $true
                }

                Set-ADExtendedPermissions @splat -Verbose:$VerbosePreference
            }
        }
        else
        {
            # Usage is not a valid command for Set-ReceiveConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Usage', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

            Set-ReceiveConnector @PSBoundParameters

            # set AD permissions
            if ($ExtendedRightAllowEntries -or $ExtendedRightDenyEntries)
            {
                $splat = @{
                    ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                    ExtendedRightDenyEntries  = $ExtendedRightDenyEntries
                    DomainController          = $DomainController
                    Identity                  = $Identity.Split('\')[1]
                    NewObject                 = $false
                }

                Set-ADExtendedPermissions @splat -Verbose:$VerbosePreference
            }
        }
    }
}

<#
    .SYNOPSIS
        Tests the resource
    .PARAMETER Identity
        Identity of the Receive Connector. Needs to be in format SERVERNAME\CONNECTORNAME (no quotes)
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER Ensure
        Whether the connector should be present or not.
    .PARAMETER AdvertiseClientSettings
        Specifies whether the SMTP server name,port number, and authentication settings for the Receive connector
        are displayed to users in the options of Outlook on the web.
    .PARAMETER AuthMechanism
        Specifies the advertised and accepted authentication mechanisms for the Receive connector.
    .PARAMETER AuthTarpitInterval
        Specifies the period of time to delay responses to failed authentication attempts from remote servers.
    .PARAMETER Banner
        Specifies a custom SMTP 220 banner that's displayed to remote messaging servers.
    .PARAMETER BareLinefeedRejectionEnabled
        Specifies whether this Receive connector rejects messages that contain line feed
    .PARAMETER BinaryMimeEnabled
        Specifies whether the BINARYMIME Extended SMTP extension is enabled or disabled.
    .PARAMETER Bindings
        Specifies the local IP address and TCP port number that's used by the Receive connector.
    .PARAMETER ChunkingEnabled
        Specifies whether the CHUNKING Extended SMTP extension is enabled or disabled.
    .PARAMETER Comment
        Specifies an optional comment.
    .PARAMETER ConnectionInactivityTimeout
        Specifies the maximum amount of idle time before a connection to the Receive connector is closed.
    .PARAMETER ConnectionTimeout
        Specifies the maximum time that the connection to the Receive connector can remain open
    .PARAMETER DefaultDomain
        Specifies the default accepted domain to use for the Exchange organization.
    .PARAMETER DeliveryStatusNotificationEnabled
        Specifies whether the DSN
    .PARAMETER DomainController
        Specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory.
    .PARAMETER DomainSecureEnabled
        Specifies whether to enable or disable mutual Transport Layer Security
    .PARAMETER EightBitMimeEnabled
        Specifies whether the 8BITMIME Extended SMTP extension is enabled or disabled.
    .PARAMETER EnableAuthGSSAPI
        enables or disables Kerberos when Integrated Windows authentication is available on the Receive connector.
    .PARAMETER Enabled
        Specifies whether to enable or disable the Receive connector.
    .PARAMETER EnhancedStatusCodesEnabled
        Specifies whether the ENHANCEDSTATUSCODES Extended SMTP extension is enabled or disabled.
    .PARAMETER ExtendedRightAllowEntries
        Additional allow permissions.
    .PARAMETER ExtendedRightDenyEntries
        Additional deny permissions.
    .PARAMETER ExtendedProtectionPolicy
        Specifies how you want to use Extended Protection for Authentication on the Receive connector.
    .PARAMETER Fqdn
        Specifies the destination FQDN that's shown to connected messaging servers.
    .PARAMETER LongAddressesEnabled
        Specifies whether the Receive connector accepts long X.400 email addresses.
    .PARAMETER MaxAcknowledgementDelay
        Specifies the period the transport server delays acknowledgement when receiving messages from a host that doesn't support shadow redundancy.
    .PARAMETER MaxHeaderSize
        Specifies the maximum size of the SMTP message header before the Receive connector closes the connection.
    .PARAMETER MaxHopCount
        Specifies the maximum number of hops that a message can take before the message is rejected by the Receive connector.
    .PARAMETER MaxInboundConnection
        Specifies the maximum number of inbound connections that this Receive connector serves at the same time.
    .PARAMETER MaxInboundConnectionPercentagePerSource
        Specifies the maximum number of connections that this Receive connector serves at the same time from a single IP address.
    .PARAMETER MaxInboundConnectionPerSource
        Specifies the maximum number of connections that a Receive connector serves at the same time from a single IP address
    .PARAMETER MaxLocalHopCount
        Specifies the maximum number of local hops that a message can take before the message is rejected by the Receive connector.
    .PARAMETER MaxLogonFailures
        pecifies the number of logon failures that the Receive connector retries before it closes the connection.
    .PARAMETER MaxMessageSize
        Specifies the maximum size of a message that's allowed through the Receive connector.
    .PARAMETER MaxProtocolErrors
        Specifies the maximum number of SMTP protocol errors that the Receive connector accepts before closing the connection.
    .PARAMETER MaxRecipientsPerMessage
        Specifies the maximum number of recipients per message that the Receive connector accepts before closing the connection.
    .PARAMETER MessageRateLimit
        Specifies the maximum number of messages that can be sent by a single client IP address per minute.
    .PARAMETER MessageRateSource
        Specifies how the message submission rate is calculated.
    .PARAMETER OrarEnabled
        enables or disables Originator Requested Alternate Recipient
    .PARAMETER PermissionGroups
        Specifies the well
    .PARAMETER PipeliningEnabled
        Specifies whether the PIPELINING Extended SMTP extension is enabled or disabled.
    .PARAMETER ProtocolLoggingLevel
        pecifies whether to enable or disable protocol logging.
    .PARAMETER RemoteIPRanges
        Specifies the remote IP addresses that the Receive connector accepts messages from.
    .PARAMETER RequireEHLODomain
        Specifies whether the client must provide a domain name in the EHLO handshake after the SMTP connection is established.
    .PARAMETER RequireTLS
        Specifies whether to require TLS transmission for inbound messages.
    .PARAMETER SizeEnabled
        Specifies how the SIZE Extended SMTP extension is used on the Receive connector.
    .PARAMETER SuppressXAnonymousTls
        Specifies whether the X
    .PARAMETER TarpitInterval
        Specifies the period of time to delay an SMTP response to a remote server that may be abusing the connection.
    .PARAMETER TlsCertificateName
        Specifies the X.509 certificate to use for TLS encryption.
    .PARAMETER TlsDomainCapabilities
        Specifies the capabilities that the Receive connector makes available to specific hosts outside of the organization.
    .PARAMETER TransportRole
        Specifies the transport service on the Mailbox server where the Receive connector is created.
    .PARAMETER Usage
        Specifies the default permission groups and authentication methods that are assigned to the Receive connector.
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries = @(),

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries = @(),

        [Parameter()]
        [System.Boolean]
        $AdvertiseClientSettings,

        [Parameter()]
        [System.String]
        $AuthTarpitInterval,

        [Parameter()]
        [System.String[]]
        [ValidateSet('None', 'Tls', 'Integrated', 'BasicAuth', 'BasicAuthRequireTLS', 'ExchangeServer', 'ExternalAuthoritative')]
        $AuthMechanism,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [Parameter()]
        [System.Boolean]
        $BinaryMimeEnabled,

        [Parameter()]
        [System.String[]]
        $Bindings,

        [Parameter()]
        [System.Boolean]
        $ChunkingEnabled,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ConnectionInactivityTimeout,

        [Parameter()]
        [System.String]
        $ConnectionTimeout,

        [Parameter()]
        [System.String]
        $DefaultDomain,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [Parameter()]
        [System.Boolean]
        $DomainSecureEnabled,

        [Parameter()]
        [System.Boolean]
        $EightBitMimeEnabled,

        [Parameter()]
        [System.Boolean]
        $EnableAuthGSSAPI,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionPolicy,

        [Parameter()]
        [System.String]
        $Fqdn,

        [Parameter()]
        [System.Boolean]
        $LongAddressesEnabled,

        [Parameter()]
        [System.String]
        $MaxAcknowledgementDelay,

        [Parameter()]
        [System.String]
        $MaxHeaderSize,

        [Parameter()]
        [System.Int32]
        $MaxHopCount,

        [Parameter()]
        [System.String]
        $MaxInboundConnection,

        [Parameter()]
        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [Parameter()]
        [System.String]
        $MaxInboundConnectionPerSource,

        [Parameter()]
        [System.Int32]
        $MaxLocalHopCount,

        [Parameter()]
        [System.Int32]
        $MaxLogonFailures,

        [Parameter()]
        [System.String]
        $MaxMessageSize,

        [Parameter()]
        [System.String]
        $MaxProtocolErrors,

        [Parameter()]
        [System.Int32]
        $MaxRecipientsPerMessage,

        [Parameter()]
        [System.String]
        $MessageRateLimit,

        [Parameter()]
        [ValidateSet('None', 'IPAddress', 'User', 'All')]
        [System.String]
        $MessageRateSource,

        [Parameter()]
        [System.Boolean]
        $OrarEnabled,

        [Parameter()]
        [ValidateSet('None', 'AnonymousUsers', 'ExchangeUsers', 'ExchangeServers', 'ExchangeLegacyServers', 'Partners', 'Custom')]
        [System.String[]]
        $PermissionGroups,

        [Parameter()]
        [System.Boolean]
        $PipeliningEnabled,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $ProtocolLoggingLevel,

        [Parameter()]
        [System.String[]]
        $RemoteIPRanges,

        [Parameter()]
        [System.Boolean]
        $RequireEHLODomain,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [System.String]
        $ServiceDiscoveryFqdn,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled', 'EnabledWithoutValue')]
        [System.String]
        $SizeEnabled,

        [Parameter()]
        [System.Boolean]
        $SuppressXAnonymousTls,

        [Parameter()]
        [System.String]
        $TarpitInterval,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [System.String[]]
        $TlsDomainCapabilities,

        [Parameter()]
        [ValidateSet('FrontendTransport', 'HubTransport')]
        [System.String]
        $TransportRole,

        [Parameter()]
        [ValidateSet('Client', 'Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Assert-IdentityIsValid -Identity $Identity

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    $connector = Get-TargetResource -Identity $Identity -Credential $Credential -Ensure $Ensure

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ReceiveConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $testResults = $true

    if ($connector['Ensure'] -eq 'Absent')
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Receive Connector should exist, but does not.'
            $testResults = $false
        }
    }
    else
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Receive Connector should not exist, but does.'
            $testResults = $false
        }
        else
        {
            # Get AD permissions if necessary
            if (($ExtendedRightAllowEntries) -or ($ExtendedRightDenyEntries))
            {
                if ($PSBoundParameters.ContainsKey('DomainController'))
                {
                    $adPermissions = Get-ADPermission -Identity $Identity.Split('\')[1] -DomainController $DomainController | Where-Object { $_.IsInherited -eq $false }
                }
                else
                {
                    $adPermissions = Get-ADPermission -Identity $Identity.Split('\')[1] | Where-Object { $_.IsInherited -eq $false }
                }

                $splat = @{
                    ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                    ExtendedRightDenyEntries  = $ExtendedRightDenyEntries
                    ADPermissions             = $adPermissions
                }

                $testResults = Test-ExtendedRights @splat -Verbose:$VerbosePreference
            }

            # remove "Custom" from PermissionGroups
            $connector.PermissionGroups = ($connector.PermissionGroups -split ',' ) -notmatch 'Custom' -join ','

            if (!(Test-ExchangeSetting -Name 'AdvertiseClientSettings' -Type 'Boolean' -ExpectedValue $AdvertiseClientSettings -ActualValue $connector.AdvertiseClientSettings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'AuthMechanism' -Type 'Array' -ExpectedValue $AuthMechanism -ActualValue (Convert-StringToArray -StringIn "$($connector.AuthMechanism)" -Verbose:$VerbosePreference) -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'AuthTarpitInterval' -Type 'Timespan' -ExpectedValue $AuthTarpitInterval -ActualValue $connector.AuthTarpitInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Banner' -Type 'String' -ExpectedValue $Banner -ActualValue $connector.Banner -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'BareLinefeedRejectionEnabled' -Type 'Boolean' -ExpectedValue $BareLinefeedRejectionEnabled -ActualValue $connector.BareLinefeedRejectionEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'BinaryMimeEnabled' -Type 'Boolean' -ExpectedValue $BinaryMimeEnabled -ActualValue $connector.BinaryMimeEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Bindings' -Type 'Array' -ExpectedValue $Bindings -ActualValue $connector.Bindings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ChunkingEnabled' -Type 'Boolean' -ExpectedValue $ChunkingEnabled -ActualValue $connector.ChunkingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Comment' -Type 'String' -ExpectedValue $Comment -ActualValue $connector.Comment -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ConnectionInactivityTimeout' -Type 'Timespan' -ExpectedValue $ConnectionInactivityTimeout -ActualValue $connector.ConnectionInactivityTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ConnectionTimeout' -Type 'Timespan' -ExpectedValue $ConnectionTimeout -ActualValue $connector.ConnectionTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DefaultDomain' -Type 'String' -ExpectedValue $DefaultDomain -ActualValue $connector.DefaultDomain -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DeliveryStatusNotificationEnabled' -Type 'Boolean' -ExpectedValue $DeliveryStatusNotificationEnabled -ActualValue $connector.DeliveryStatusNotificationEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DomainSecureEnabled' -Type 'Boolean' -ExpectedValue $DomainSecureEnabled -ActualValue $connector.DomainSecureEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'EightBitMimeEnabled' -Type 'Boolean' -ExpectedValue $EightBitMimeEnabled -ActualValue $connector.EightBitMimeEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'EnableAuthGSSAPI' -Type 'Boolean' -ExpectedValue $EnableAuthGSSAPI -ActualValue $connector.EnableAuthGSSAPI -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Enabled' -Type 'Boolean' -ExpectedValue $Enabled -ActualValue $connector.Enabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'EnhancedStatusCodesEnabled' -Type 'Boolean' -ExpectedValue $EnhancedStatusCodesEnabled -ActualValue $connector.EnhancedStatusCodesEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ExtendedProtectionPolicy' -Type 'String' -ExpectedValue $ExtendedProtectionPolicy -ActualValue $connector.ExtendedProtectionPolicy -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Fqdn' -Type 'String' -ExpectedValue $Fqdn -ActualValue $connector.Fqdn -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'LongAddressesEnabled' -Type 'Boolean' -ExpectedValue $LongAddressesEnabled -ActualValue $connector.LongAddressesEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxHopCount' -Type 'Int' -ExpectedValue $MaxHopCount -ActualValue $connector.MaxHopCount -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxAcknowledgementDelay' -Type 'Timespan' -ExpectedValue $MaxAcknowledgementDelay -ActualValue $connector.MaxAcknowledgementDelay -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxInboundConnection' -Type 'String' -ExpectedValue $MaxInboundConnection -ActualValue $connector.MaxInboundConnection -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxInboundConnectionPercentagePerSource' -Type 'Int' -ExpectedValue $MaxInboundConnectionPercentagePerSource -ActualValue $connector.MaxInboundConnectionPercentagePerSource -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxInboundConnectionPerSource' -Type 'String' -ExpectedValue $MaxInboundConnectionPerSource -ActualValue $connector.MaxInboundConnectionPerSource -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxHeaderSize' -Type 'ByteQuantifiedSize' -ExpectedValue $MaxHeaderSize -ActualValue $connector.MaxHeaderSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxLocalHopCount' -Type 'Int' -ExpectedValue $MaxLocalHopCount -ActualValue $connector.MaxLocalHopCount -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxLogonFailures' -Type 'Int' -ExpectedValue $MaxLogonFailures -ActualValue $connector.MaxLogonFailures -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxMessageSize' -Type 'ByteQuantifiedSize' -ExpectedValue $MaxMessageSize -ActualValue $connector.MaxMessageSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxProtocolErrors' -Type 'String' -ExpectedValue $MaxProtocolErrors -ActualValue $connector.MaxProtocolErrors -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxRecipientsPerMessage' -Type 'Int' -ExpectedValue $MaxRecipientsPerMessage -ActualValue $connector.MaxRecipientsPerMessage -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MessageRateLimit' -Type 'String' -ExpectedValue $MessageRateLimit -ActualValue $connector.MessageRateLimit -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MessageRateSource' -Type 'String' -ExpectedValue $MessageRateSource -ActualValue $connector.MessageRateSource -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'OrarEnabled' -Type 'Boolean' -ExpectedValue $OrarEnabled -ActualValue $connector.OrarEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'PermissionGroups' -Type 'Array' -ExpectedValue $PermissionGroups -ActualValue (Convert-StringToArray -StringIn $connector.PermissionGroups -Separator ',') -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'PipeliningEnabled' -Type 'Boolean' -ExpectedValue $PipeliningEnabled -ActualValue $connector.PipeliningEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ProtocolLoggingLevel' -Type 'String' -ExpectedValue $ProtocolLoggingLevel -ActualValue $connector.ProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'RemoteIPRanges' -Type 'Array' -ExpectedValue $RemoteIPRanges -ActualValue $connector.RemoteIPRanges -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'RequireEHLODomain' -Type 'Boolean' -ExpectedValue $RequireEHLODomain -ActualValue $connector.RequireEHLODomain -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'RequireTLS' -Type 'Boolean' -ExpectedValue $RequireTLS -ActualValue $connector.RequireTLS -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ServiceDiscoveryFqdn' -Type 'String' -ExpectedValue $ServiceDiscoveryFqdn -ActualValue $connector.ServiceDiscoveryFqdn -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SizeEnabled' -Type 'String' -ExpectedValue $SizeEnabled -ActualValue $connector.SizeEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SuppressXAnonymousTls' -Type 'Boolean' -ExpectedValue $SuppressXAnonymousTls -ActualValue $connector.SuppressXAnonymousTls -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TarpitInterval' -Type 'Timespan' -ExpectedValue $TarpitInterval -ActualValue $connector.TarpitInterval -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsCertificateName' -Type 'String' -ExpectedValue $TlsCertificateName -ActualValue $connector.TlsCertificateName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsDomainCapabilities' -Type 'Array' -ExpectedValue $TlsDomainCapabilities -ActualValue $connector.TlsDomainCapabilities -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TransportRole' -Type 'String' -ExpectedValue $TransportRole -ActualValue $connector.TransportRole -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }
    }

    return $testResults
}

# Ensure that a connector Identity is in the proper form
function Assert-IdentityIsValid
{
    param
    (
        [Parameter()]
        [System.String]
        $Identity
    )

    if ([System.String]::IsNullOrEmpty($Identity) -or !($Identity.Contains('\')))
    {
        throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
    }
}

Export-ModuleMember -Function *-TargetResource
