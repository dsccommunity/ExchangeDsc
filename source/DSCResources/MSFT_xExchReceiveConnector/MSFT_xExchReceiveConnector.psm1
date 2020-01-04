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
        [System.String[]]
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

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ReceiveConnector' -Verbose:$VerbosePreference

    $connector = Get-ReceiveConnectorInternal @PSBoundParameters

    if ($null -ne $connector)
    {
        $returnValue = @{
            Identity                                = [System.String] $Identity
            AdvertiseClientSettings                 = [System.Boolean] $connector.AdvertiseClientSettings
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
            ExtendedRightAllowEntries               = [Microsoft.Management.Infrastructure.CimInstance[]] $ExtendedRightAllowEntries
            ExtendedRightDenyEntries                = [Microsoft.Management.Infrastructure.CimInstance[]] $ExtendedRightDenyEntries
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
        }
    }

    $returnValue
}

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
        [System.String[]]
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

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*ReceiveConnector', '*ADPermission' -Verbose:$VerbosePreference

    $connector = Get-ReceiveConnectorInternal @PSBoundParameters

    if ($Ensure -eq 'Absent')
    {
        if ($null -ne $connector)
        {
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

            Remove-ReceiveConnector @PSBoundParameters -Confirm:$false
        }
    }
    else
    {
        # Remove Credential and Ensure so we don't pass it into the next command
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure'

        Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        # We need to create the new connector
        if ($null -eq $connector)
        {
            # Create a copy of the original parameters
            $originalPSBoundParameters = @{} + $PSBoundParameters

            # The following aren't valid for New-ReceiveConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity', 'BareLinefeedRejectionEnabled', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

            # Parse out the server name and connector name from the given Identity
            $serverName = $Identity.Substring(0, $Identity.IndexOf('\'))
            $connectorName = $Identity.Substring($Identity.IndexOf('\') + 1)

            # Add in server and name parameters
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
                'Server' = $serverName
                'Name' = $connectorName
            }

            # Create the connector
            $connector = New-ReceiveConnector @PSBoundParameters

            # Ensure the connector exists, and if so, set us up so we can run Set-ReceiveConnector next
            if ($null -ne $connector)
            {
                # Remove the two props we added
                Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Server', 'Name'

                # Add original props back
                Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters
            }
            else
            {
                throw 'Failed to create new Receive Connector.'
            }
        }

        # The connector already exists, so use Set-ReceiveConnector
        if ($null -ne $connector)
        {
            # Usage is not a valid command for Set-ReceiveConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Usage', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

            Set-ReceiveConnector @PSBoundParameters

            # set AD permissions
            if ($ExtendedRightAllowEntries)
            {
                foreach ($ExtendedRightAllowEntry in $ExtendedRightAllowEntries)
                {
                    foreach ($Value in $($ExtendedRightAllowEntry.Value.Split(',')))
                    {
                        $connector | Add-ADPermission -User $ExtendedRightAllowEntry.Key -ExtendedRights $Value
                    }
                }
            }

            if ($ExtendedRightDenyEntries)
            {
                foreach ($ExtendedRightDenyEntry in $ExtendedRightDenyEntries)
                {
                    foreach ($Value in $($ExtendedRightDenyEntry.Value.Split(',')))
                    {
                        $connector | Remove-ADPermission -User $ExtendedRightDenyEntry.Key -ExtendedRights $Value -Confirm:$false
                    }
                }
            }
        }
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
        [System.String[]]
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

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ReceiveConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $connector = Get-ReceiveConnectorInternal @PSBoundParameters

    # get AD permissions if necessary
    if (($ExtendedRightAllowEntries) -or ($ExtendedRightDenyEntries))
    {
        $ADPermissions = $connector | Get-ADPermission | Where-Object {$_.IsInherited -eq $false}
    }

    $testResults = $true

    if ($null -eq $connector)
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
            # remove "Custom" from PermissionGroups
            $connector.PermissionGroups = ($connector.PermissionGroups -split ',' ) -notmatch 'Custom' -join ','

            if (!(Test-ExchangeSetting -Name 'AdvertiseClientSettings' -Type 'Boolean' -ExpectedValue $AdvertiseClientSettings -ActualValue $connector.AdvertiseClientSettings -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'AuthMechanism' -Type 'Array' -ExpectedValue $AuthMechanism -ActualValue (Convert-StringToArray -StringIn "$($connector.AuthMechanism)" -Separator ',') -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

            # check AD permissions if necessary
            if ($ExtendedRightAllowEntries)
            {
                if (!(Test-ExtendedRightsPresent -ADPermissions $ADPermissions -ExtendedRights $ExtendedRightAllowEntries -ShouldbeTrue:$True -Verbose:$VerbosePreference))
                {
                    $testResults = $false
                }
            }

            if ($ExtendedRightDenyEntries)
            {
                if (Test-ExtendedRightsPresent -ADPermissions $ADPermissions -ExtendedRights $ExtendedRightDenyEntries -ShouldbeTrue:$false -Verbose:$VerbosePreference)
                {
                    $testResults = $false
                }
            }
        }
    }

    return $testResults
}

# Runs Get-ReceiveConnector, only specifying Identity, ErrorAction, and optionally DomainController
function Get-ReceiveConnectorInternal
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries,

        [Parameter()]
        [System.Boolean]
        $AdvertiseClientSettings,

        [Parameter()]
        [System.String[]]
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

    $getParams = @{
        Server      = $env:COMPUTERNAME
        ErrorAction = 'SilentlyContinue'
    }

    if ($PSBoundParameters.ContainsKey('DomainController') -and ![String]::IsNullOrEmpty($PSBoundParameters['DomainController']))
    {
        $getParams.Add('DomainController', $PSBoundParameters['DomainController'])
    }

    return (Get-ReceiveConnector @getParams | Where-Object -FilterScript {$_.Identity -like $PSBoundParameters['Identity']})
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

# check a connector for specific extended rights
function Test-ExtendedRightsPresent
{
    [cmdletbinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        $ADPermissions,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRights,

        [Parameter()]
        [System.Boolean]
        $ShouldbeTrue
    )

    $returnvalue = $false

    foreach ($Right in $ExtendedRights)
    {
        foreach ($Value in $($Right.Value.Split(',')))
        {
            if ($null -ne ($ADPermissions | Where-Object {($_.User.RawIdentity -eq $Right.Key) -and ($_.ExtendedRights.RawIdentity -eq $Value)}))
            {
                $returnvalue = $true

                if (!($ShouldbeTrue))
                {
                    Write-Verbose -Message 'Should report exist!'
                    Write-InvalidSettingVerbose -SettingName 'ExtendedRight' -ExpectedValue "User:$($Right.Key) Value:$Value" -ActualValue 'Present' -Verbose:$VerbosePreference
                    return $returnvalue
                    exit
                }
            }
            else
            {
                $returnvalue = $false

                if ($ShouldbeTrue)
                {
                    Write-InvalidSettingVerbose -SettingName 'ExtendedRight' -ExpectedValue "User:$($Right.Key) Value:$Value" -ActualValue 'Absent' -Verbose:$VerbosePreference
                    return $returnvalue
                    exit
                }
            }
        }
    }

    return $returnvalue
}

Export-ModuleMember -Function *-TargetResource
