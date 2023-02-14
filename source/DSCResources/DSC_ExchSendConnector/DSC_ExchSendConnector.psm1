<#
    .SYNOPSIS
        Gets the resource state.
     .PARAMETER Name
        Specifies a descriptive name for the connector.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AddressSpaces
        Specifies the domain names to which the Send connector routes mail.
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AddressSpaces
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-SendConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $connector = Get-SendConnector -ErrorAction SilentlyContinue | Where-Object -Property 'Identity' -eq $Name

    if ($null -ne $connector)
    {
        $adPermissions = Get-ADExtendedPermissions -Identity $Name

        $returnValue = @{
            Name                         = [System.String] $connector.Name
            AddressSpaces                = [System.String[]] $connector.AddressSpaces
            Comment                      = [System.String] $connector.Comment
            ConnectionInactivityTimeout  = [System.String] $connector.ConnectionInactivityTimeout
            ConnectorType                = [System.String] $connector.ConnectorType
            DNSRoutingEnabled            = [System.Boolean] $connector.DNSRoutingEnabled
            DomainSecureEnabled          = [System.Boolean] $connector.DomainSecureEnabled
            Enabled                      = [System.Boolean] $connector.Enabled
            ErrorPolicies                = [System.String] $connector.ErrorPolicies
            ExtendedProtectionPolicy     = [System.String] $connector.ExtendedProtectionPolicy
            ExtendedRightAllowEntries    = [Microsoft.Management.Infrastructure.CimInstance[]] $adPermissions['ExtendedRightAllowEntries']
            ExtendedRightDenyEntries     = [Microsoft.Management.Infrastructure.CimInstance[]] $adPermissions['ExtendedRightDenyEntries']
            ForceHELO                    = [System.Boolean] $connector.ForceHELO
            FrontendProxyEnabled         = [System.Boolean] $connector.FrontendProxyEnabled
            Fqdn                         = [System.String] $connector.Fqdn
            IgnoreSTARTTLS               = [System.Boolean] $connector.IgnoreSTARTTLS
            IsCoexistenceConnector       = [System.Boolean] $connector.IsCoexistenceConnector
            IsScopedConnector            = [System.Boolean] $connector.IsScopedConnector
            LinkedReceiveConnector       = [System.String] $connector.LinkedReceiveConnector
            MaxMessageSize               = [System.String] $connector.MaxMessageSize
            Port                         = [System.Int32] $connector.Port
            ProtocolLoggingLevel         = [System.String] $connector.ProtocolLoggingLevel
            RequireTLS                   = [System.Boolean] $connector.RequireTLS
            SmartHostAuthMechanism       = [System.String] $connector.SmartHostAuthMechanism
            SmartHosts                   = [System.String[]] $connector.SmartHosts
            SmtpMaxMessagesPerConnection = [System.Int32] $connector.SmtpMaxMessagesPerConnection
            SourceIPAddress              = [System.String] $connector.SourceIPAddress
            SourceTransportServers       = [System.String[]] $connector.SourceTransportServers
            TlsDomain                    = [System.String] $connector.TlsDomain
            TlsAuthLevel                 = [System.String] $connector.TlsAuthLevel
            UseExternalDNSServersEnabled = [System.Boolean] $connector.UseExternalDNSServersEnabled
            TlsCertificateName           = [System.String] $connector.TlsCertificateName
            Ensure                       = 'Present'
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
        Sets the resource state.
    .PARAMETER Name
        Specifies a descriptive name for the connector.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER Ensure
        Whether the connector should be present or not.
    .PARAMETER AddressSpaces
        Specifies the domain names to which the Send connector routes mail.
    .PARAMETER AuthenticationCredential
        Specifies the username and password that's required to use the connector.
    .PARAMETER Comment
        Specifies an optional comment.
    .PARAMETER ConnectionInactivityTimeout
        Specifies the maximum time an idle connection can remain open.
    .PARAMETER ConnectorType
        Specifies whether the connector is used in hybrid deployments to send messages to Office 365.
    .PARAMETER DNSRoutingEnabled
        Specifies whether the Send connector uses Domain Name System
    .PARAMETER DomainController
        Specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory.
    .PARAMETER DomainSecureEnabled
        Enables mutual Transport Layer Security
    .PARAMETER Enabled
        Specifies whether to enable the Send connector to process email messages.
    .PARAMETER ErrorPolicies
        Specifies how communication errors are treated.
    .PARAMETER ExtendedRightAllowEntries
        Additional allow permissions.
    .PARAMETER ExtendedRightDenyEntries
        Additional deny permissions.
    .PARAMETER ForceHELO
        Specifies whether HELO is sent instead of the default EHLO.
    .PARAMETER FrontendProxyEnabled
        Routes outbound messages through the CAS server
    .PARAMETER Fqdn
        Specifies the FQDN used as the source server.
    .PARAMETER IgnoreSTARTTLS
        Specifies whether to ignore the StartTLS option offered by a remote sending server.
    .PARAMETER IsCoexistenceConnector
        Specifies whether this Send connector is used for secure mail flow between your on
    .PARAMETER IsScopedConnector
        Specifies the availability of the connector to other Mailbox servers with the Transport service.
    .PARAMETER LinkedReceiveConnector
        Specifies whether to force all messages received by the specified Receive connector out through this Send connector.
    .PARAMETER MaxMessageSize
        Specifies the maximum size of a message that can pass through a connector.
    .PARAMETER Port
        Specifies the port number for smart host forwarding.
    .PARAMETER ProtocolLoggingLevel
        Specifies whether to enable protocol logging.
    .PARAMETER RequireTLS
        Specifies whether all messages sent through this connector must be transmitted using TLS.
    .PARAMETER SmartHostAuthMechanism
        Specifies the smart host authentication mechanism to use for authentication.
    .PARAMETER SmartHosts
        Specifies the smart hosts the Send connector uses to route mail.
    .PARAMETER SmtpMaxMessagesPerConnection
        Specifies the maximum number of messages the server can send per connection.
    .PARAMETER SourceIPAddress
        Specifies the local IP address to use as the endpoint for an SMTP connection.
    .PARAMETER SourceTransportServers
        Specifies the names of the Mailbox servers that can use this Send connector.
    .PARAMETER TlsAuthLevel
        Specifies the TLS authentication level that is used for outbound TLS connections.
    .PARAMETER TlsDomain
        Specifies the domain name that the Send connector uses to verify the FQDN of the target certificate.
    .PARAMETER UseExternalDNSServersEnabled
        Specifies whether the connector uses the external DNS list specified by the ExternalDNSServers parameter of the Set
    .PARAMETER TlsCertificateName
        Specifies the X.509 certificate to use for TLS encryption.
    .PARAMETER Usage
        Specifies the default permissions and authentication methods assigned to the Send connector.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $AuthenticationCredential,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries = @(),

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries = @(),

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AddressSpaces,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ConnectionInactivityTimeout,

        [Parameter()]
        [ValidateSet('Default', 'XPremises')]
        [System.String]
        $ConnectorType,

        [Parameter()]
        [System.Boolean]
        $DNSRoutingEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $DomainSecureEnabled,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [ValidateSet('Default', 'DowngradeAuthFailures', 'DowngradeDNSFailures')]
        [System.String]
        $ErrorPolicies,

        [Parameter()]
        [System.Boolean]
        $ForceHELO,

        [Parameter()]
        [System.Boolean]
        $FrontendProxyEnabled,

        [Parameter()]
        [System.String]
        $Fqdn,

        [Parameter()]
        [System.Boolean]
        $IgnoreSTARTTLS,

        [Parameter()]
        [System.Boolean]
        $IsCoexistenceConnector,

        [Parameter()]
        [System.Boolean]
        $IsScopedConnector,

        [Parameter()]
        [System.String]
        $LinkedReceiveConnector,

        [Parameter()]
        [System.String]
        $MaxMessageSize,

        [Parameter()]
        [System.Int32]
        $Port,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $ProtocolLoggingLevel,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth', 'BasicAuthRequireTLS', 'ExchangeServer', 'ExternalAuthoritative')]
        [System.String]
        $SmartHostAuthMechanism,

        [Parameter()]
        [System.String[]]
        $SmartHosts,

        [Parameter()]
        [System.Int32]
        $SmtpMaxMessagesPerConnection,

        [Parameter()]
        [System.String]
        $SourceIPAddress,

        [Parameter()]
        [System.String[]]
        $SourceTransportServers,

        [Parameter()]
        [ValidateSet('EncryptionOnly', 'CertificateValidation', 'DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    $connector = Get-TargetResource -Name $Name -Credential $Credential -AddressSpaces $AddressSpaces

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*SendConnector', '*ADPermission' -Verbose:$VerbosePreference

    if ($Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Removing send connector $Name."

        Remove-SendConnector -Identity $Name -DomainController $PSBoundParameters['DomainController'] -Confirm:$false
    }
    else
    {
        # Remove Credential and Ensure so we don't pass it into the next command
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

        Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        # We need to create the new connector
        if ($connector['Ensure'] -eq 'Absent')
        {
            # Create the connector
            Write-Verbose -Message "Creating send connector $Name."

            New-SendConnector @PSBoundParameters

            if (($ExtendedRightAllowEntries -or $ExtendedRightDenyEntries) -and $null -eq $PSBoundParameters['DomainController'])
            {
                $sendConnectorFound = Get-ADPermission -Identity $Name -ErrorAction SilentlyContinue
                $itt = 0

                while ($null -eq $sendConnectorFound -and $itt -le 3)
                {
                    Write-Verbose -Message 'Extended AD permissions were specified and the new connector is still not found in AD. Sleeping for 30 seconds.'
                    Start-Sleep -Seconds 30
                    $itt++
                    $sendConnectorFound = Get-ADPermission -Identity $Name -ErrorAction SilentlyContinue
                }

                if ($null -eq $sendConnectorFound)
                {
                    throw 'The new send connector was not found after 2 minutes of wait time. Please check AD replication!'
                }
            }
            if ($null -ne $PSBoundParameters['DomainController'])
            {
                Write-Verbose -Message 'Setting domain controller as default parameter.'
                $PSDefaultParameterValues = @{
                    'Add-ADPermission:DomainController' = $DomainController
                }
            }
            if ($ExtendedRightAllowEntries)
            {
                Write-Verbose -Message "Setting ExtendedRightAllowEntries for send connector: $Name."

                foreach ($ExtendedRightAllowEntry in $ExtendedRightAllowEntries)
                {
                    foreach ($Value in $($ExtendedRightAllowEntry.Value.Split(',')))
                    {
                        Add-ADPermission -Identity $Name -User $ExtendedRightAllowEntry.Key -ExtendedRights $Value
                    }
                }
            }

            if ($ExtendedRightDenyEntries)
            {
                Write-Verbose -Message "Setting ExtendedRightDenyEntries for send connector: $Name."

                foreach ($ExtendedRightDenyEntry in $ExtendedRightDenyEntries)
                {
                    foreach ($Value in $($ExtendedRightDenyEntry.Value.Split(',')))
                    {
                        Add-ADPermission -Identity $Name -User $ExtendedRightDenyEntry.Key -ExtendedRights $Value -Deny -Confirm:$false
                    }
                }
            }
        }
        else
        {
            Write-Verbose -Message "Send connector $Name not compliant. Setting the properties."

            # Usage is not a valid command for Set-SendConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Ensure', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries' , 'Name', 'Usage'

            $PSBoundParameters['Identity'] = $Name
            Set-SendConnector  @PSBoundParameters

            if ($null -ne $PSBoundParameters['DomainController'])
            {
                $PSDefaultParameterValues = @{
                    'Add-ADPermission:DomainController' = $DomainController
                }
            }
            # Set AD permissions
            if ($ExtendedRightAllowEntries)
            {
                foreach ($ExtendedRightAllowEntry in $ExtendedRightAllowEntries)
                {
                    foreach ($Value in $($ExtendedRightAllowEntry.Value.Split(',')))
                    {
                        Add-ADPermission -Identity $Name -User $ExtendedRightAllowEntry.Key -ExtendedRights $Value
                    }
                }
            }

            if ($ExtendedRightDenyEntries)
            {
                foreach ($ExtendedRightDenyEntry in $ExtendedRightDenyEntries)
                {
                    foreach ($Value in $($ExtendedRightDenyEntry.Value.Split(',')))
                    {
                        Add-ADPermission -Identity $Name -User $ExtendedRightDenyEntry.Key -ExtendedRights $Value -Deny -Confirm:$false
                    }
                }
            }
        }
    }
}

<#
    .SYNOPSIS
        Tets the resource state.
    .PARAMETER Name
        Specifies a descriptive name for the connector.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER Ensure
        Whether the connector should be present or not.
    .PARAMETER AddressSpaces
        Specifies the domain names to which the Send connector routes mail.
    .PARAMETER AuthenticationCredential
        Specifies the username and password that's required to use the connector.
    .PARAMETER Comment
        Specifies an optional comment.
    .PARAMETER ConnectionInactivityTimeout
        Specifies the maximum time an idle connection can remain open.
    .PARAMETER ConnectorType
        Specifies whether the connector is used in hybrid deployments to send messages to Office 365.
    .PARAMETER DNSRoutingEnabled
        Specifies whether the Send connector uses Domain Name System
    .PARAMETER DomainController
        Specifies the domain controller that's used by this cmdlet to read data from or write data to Active Directory.
    .PARAMETER DomainSecureEnabled
        Enables mutual Transport Layer Security
    .PARAMETER Enabled
        Specifies whether to enable the Send connector to process email messages.
    .PARAMETER ErrorPolicies
        Specifies how communication errors are treated.
    .PARAMETER ExtendedRightAllowEntries
        Additional allow permissions.
    .PARAMETER ExtendedRightDenyEntries
        Additional deny permissions.
    .PARAMETER ForceHELO
        Specifies whether HELO is sent instead of the default EHLO.
    .PARAMETER FrontendProxyEnabled
        Routes outbound messages through the CAS server
    .PARAMETER Fqdn
        Specifies the FQDN used as the source server.
    .PARAMETER IgnoreSTARTTLS
        Specifies whether to ignore the StartTLS option offered by a remote sending server.
    .PARAMETER IsCoexistenceConnector
        Specifies whether this Send connector is used for secure mail flow between your on
    .PARAMETER IsScopedConnector
        Specifies the availability of the connector to other Mailbox servers with the Transport service.
    .PARAMETER LinkedReceiveConnector
        Specifies whether to force all messages received by the specified Receive connector out through this Send connector.
    .PARAMETER MaxMessageSize
        Specifies the maximum size of a message that can pass through a connector.
    .PARAMETER Port
        Specifies the port number for smart host forwarding.
    .PARAMETER ProtocolLoggingLevel
        Specifies whether to enable protocol logging.
    .PARAMETER RequireTLS
        Specifies whether all messages sent through this connector must be transmitted using TLS.
    .PARAMETER SmartHostAuthMechanism
        Specifies the smart host authentication mechanism to use for authentication.
    .PARAMETER SmartHosts
        Specifies the smart hosts the Send connector uses to route mail.
    .PARAMETER SmtpMaxMessagesPerConnection
        Specifies the maximum number of messages the server can send per connection.
    .PARAMETER SourceIPAddress
        Specifies the local IP address to use as the endpoint for an SMTP connection.
    .PARAMETER SourceTransportServers
        Specifies the names of the Mailbox servers that can use this Send connector.
    .PARAMETER TlsAuthLevel
        Specifies the TLS authentication level that is used for outbound TLS connections.
    .PARAMETER TlsDomain
        Specifies the domain name that the Send connector uses to verify the FQDN of the target certificate.
    .PARAMETER UseExternalDNSServersEnabled
        Specifies whether the connector uses the external DNS list specified by the ExternalDNSServers parameter of the Set
    .PARAMETER TlsCertificateName
        Specifies the X.509 certificate to use for TLS encryption.
    .PARAMETER Usage
        Specifies the default permissions and authentication methods assigned to the Send connector.
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $AuthenticationCredential,

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries = @(),

        [Parameter()]
        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries = @(),

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $AddressSpaces,

        [Parameter()]
        [System.String]
        $Comment,

        [Parameter()]
        [System.String]
        $ConnectionInactivityTimeout,

        [Parameter()]
        [ValidateSet('Default', 'XPremises')]
        [System.String]
        $ConnectorType,

        [Parameter()]
        [System.Boolean]
        $DNSRoutingEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $DomainSecureEnabled,

        [Parameter()]
        [System.Boolean]
        $Enabled,

        [Parameter()]
        [ValidateSet('Default', 'DowngradeAuthFailures', 'DowngradeDNSFailures')]
        [System.String]
        $ErrorPolicies,

        [Parameter()]
        [System.Boolean]
        $ForceHELO,

        [Parameter()]
        [System.Boolean]
        $FrontendProxyEnabled,

        [Parameter()]
        [System.String]
        $Fqdn,

        [Parameter()]
        [System.Boolean]
        $IgnoreSTARTTLS,

        [Parameter()]
        [System.Boolean]
        $IsCoexistenceConnector,

        [Parameter()]
        [System.Boolean]
        $IsScopedConnector,

        [Parameter()]
        [System.String]
        $LinkedReceiveConnector,

        [Parameter()]
        [System.String]
        $MaxMessageSize,

        [Parameter()]
        [System.Int32]
        $Port,

        [Parameter()]
        [ValidateSet('None', 'Verbose')]
        [System.String]
        $ProtocolLoggingLevel,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth', 'BasicAuthRequireTLS', 'ExchangeServer', 'ExternalAuthoritative')]
        [System.String]
        $SmartHostAuthMechanism,

        [Parameter()]
        [System.String[]]
        $SmartHosts,

        [Parameter()]
        [System.Int32]
        $SmtpMaxMessagesPerConnection,

        [Parameter()]
        [System.String]
        $SourceIPAddress,

        [Parameter()]
        [System.String[]]
        $SourceTransportServers,

        [Parameter()]
        [ValidateSet('EncryptionOnly', 'CertificateValidation', 'DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    $connector = Get-TargetResource -Name $Name -Credential $Credential -AddressSpaces $AddressSpaces

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-SendConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $testResults = $true

    if ($connector['Ensure'] -eq 'Absent')
    {
        if ($Ensure -eq 'Present')
        {
            Write-Verbose -Message 'Send Connector should exist, but does not.'
            $testResults = $false
        }
    }
    else
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message 'Send Connector should not exist, but does.'
            $testResults = $false
        }
        else
        {
            # Get AD permissions if necessary
            if (($ExtendedRightAllowEntries) -or ($ExtendedRightDenyEntries))
            {
                if ($PSBoundParameters.ContainsKey('DomainController'))
                {
                    $adPermissions = Get-ADPermission -Identity $Name -DomainController $DomainController | Where-Object { $_.IsInherited -eq $false }
                }
                else
                {
                    $adPermissions = Get-ADPermission -Identity $Name | Where-Object { $_.IsInherited -eq $false }
                }

                $splat = @{
                    ExtendedRightAllowEntries = $ExtendedRightAllowEntries
                    ExtendedRightDenyEntries  = $ExtendedRightDenyEntries
                    ADPermissions             = $adPermissions
                }

                $testResults = Test-ExtendedRights @splat
            }

            if (!(Test-ExchangeSetting -Name 'AddressSpaces' -Type 'Array' -ExpectedValue $AddressSpaces -ActualValue $connector.AddressSpaces -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Comment' -Type 'String' -ExpectedValue $Comment -ActualValue $connector.Comment -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ConnectorType' -Type 'String' -ExpectedValue $ConnectorType -ActualValue $connector.ConnectorType -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DNSRoutingEnabled' -Type 'Boolean' -ExpectedValue $DNSRoutingEnabled -ActualValue $connector.DNSRoutingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DomainSecureEnabled' -Type 'Boolean' -ExpectedValue $DomainSecureEnabled -ActualValue $connector.DomainSecureEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ConnectionInactivityTimeout' -Type 'Timespan' -ExpectedValue $ConnectionInactivityTimeout -ActualValue $connector.ConnectionInactivityTimeout -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

            if (!(Test-ExchangeSetting -Name 'Enabled' -Type 'Boolean' -ExpectedValue $Enabled -ActualValue $connector.Enabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ErrorPolicies' -Type 'String' -ExpectedValue $ErrorPolicies -ActualValue $connector.ErrorPolicies -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ForceHELO' -Type 'Boolean' -ExpectedValue $ForceHELO -ActualValue $connector.ForceHELO -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'FrontendProxyEnabled' -Type 'Boolean' -ExpectedValue $FrontendProxyEnabled -ActualValue $connector.FrontendProxyEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Fqdn' -Type 'String' -ExpectedValue $Fqdn -ActualValue $connector.Fqdn -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'IgnoreSTARTTLS' -Type 'Boolean' -ExpectedValue $IgnoreSTARTTLS -ActualValue $connector.IgnoreSTARTTLS -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'IsCoexistenceConnector' -Type 'Boolean' -ExpectedValue $IsCoexistenceConnector -ActualValue $connector.IsCoexistenceConnector -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'IsScopedConnector' -Type 'Boolean' -ExpectedValue $IsScopedConnector -ActualValue $connector.IsScopedConnector -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'LinkedReceiveConnector' -Type 'String' -ExpectedValue $LinkedReceiveConnector -ActualValue $connector.LinkedReceiveConnector -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'MaxMessageSize' -Type 'ByteQuantifiedSize' -ExpectedValue $MaxMessageSize -ActualValue $connector.MaxMessageSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Port' -Type 'Int' -ExpectedValue $Port -ActualValue $connector.Port -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ProtocolLoggingLevel' -Type 'String' -ExpectedValue $ProtocolLoggingLevel -ActualValue $connector.ProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'RequireTLS' -Type 'Boolean' -ExpectedValue $RequireTLS -ActualValue $connector.RequireTLS -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SmartHostAuthMechanism' -Type 'String' -ExpectedValue $SmartHostAuthMechanism -ActualValue $connector.SmartHostAuthMechanism -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SmartHosts' -Type 'Array' -ExpectedValue $SmartHosts -ActualValue $connector.SmartHosts -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SmtpMaxMessagesPerConnection' -Type 'Int' -ExpectedValue $SmtpMaxMessagesPerConnection -ActualValue $connector.SmtpMaxMessagesPerConnection -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SourceIPAddress' -Type 'String' -ExpectedValue $SourceIPAddress -ActualValue $connector.SourceIPAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'SourceTransportServers' -Type 'Array' -ExpectedValue $SourceTransportServers -ActualValue $connector.SourceTransportServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsAuthLevel' -Type 'String' -ExpectedValue $TlsAuthLevel -ActualValue $connector.TlsAuthLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsDomain' -Type 'String' -ExpectedValue $TlsDomain -ActualValue $connector.TlsDomain -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'UseExternalDNSServersEnabled' -Type 'Boolean' -ExpectedValue $UseExternalDNSServersEnabled -ActualValue $connector.UseExternalDNSServersEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsCertificateName' -Type 'String' -ExpectedValue $TlsCertificateName -ActualValue $connector.TlsCertificateName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }
    }

    return $testResults
}
