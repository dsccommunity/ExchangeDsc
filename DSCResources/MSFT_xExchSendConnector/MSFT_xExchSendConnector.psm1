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
        $RequireOorg,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth','BasicAuthRequireTLS','ExchangeServer','ExternalAuthoritative')]
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
        [ValidateSet('EncryptionOnly','CertificateValidation','DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.Boolean]
        $CloudServicesMailEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-SendConnector' -Verbose:$VerbosePreference

    $connector = Get-SendConnectorInternal $Identity -ErrorAction SilentlyContinue

    if ($null -ne $connector)
    {
        $returnValue = @{
            Identity                                = [System.String] $Identity
            AddressSpaces                           = [System.String[]] $connector.AddressSpaces
            Comment                                 = [System.String] $connector.Comment
            ConnectionInactivityTimeout             = [System.String] $connector.ConnectionInactivityTimeout
            ConnectorType                           = [System.String] $connector.ConnectorType
            DNSRoutingEnabled                       = [System.Boolean] $connector.DNSRoutingEnabled
            DomainSecureEnabled                     = [System.Boolean] $connector.DomainSecureEnabled
            Enabled                                 = [System.Boolean] $connector.Enabled
            ErrorPolicies                           = [System.String] $connector.ErrorPolicies
            ExtendedProtectionPolicy                = [System.String] $connector.ExtendedProtectionPolicy
            ExtendedRightAllowEntries               = [Microsoft.Management.Infrastructure.CimInstance[]] $ExtendedRightAllowEntries
            ExtendedRightDenyEntries                = [Microsoft.Management.Infrastructure.CimInstance[]] $ExtendedRightDenyEntries
            ForceHELO                               = [System.Boolean] $connector.ForceHELO
            FrontendProxyEnabled                    = [System.Boolean] $connector.FrontendProxyEnabled
            Fqdn                                    = [System.String] $connector.Fqdn
            IgnoreSTARTTLS                          = [System.Boolean] $connector.IgnoreSTARTTLS
            IsCoexistenceConnector                  = [System.Boolean] $connector.IsCoexistenceConnector
            IsScopedConnector                       = [System.Boolean] $connector.IsScopedConnector
            LinkedReceiveConnector                  = [System.String] $connector.LinkedReceiveConnector
            MaxMessageSize                          = [System.String] $connector.MaxMessageSize
            Port                                    = [System.Int32] $connector.Port
            ProtocolLoggingLevel                    = [System.String] $connector.ProtocolLoggingLevel
            RequireOorg                             = [System.Boolean] $connector.RequireOorg
            RequireTLS                              = [System.Boolean] $connector.RequireTLS
            SmartHostAuthMechanism                  = [System.String] $connector.SmartHostAuthMechanism
            SmartHosts                              = [System.String[]] $connector.SmartHosts
            SmtpMaxMessagesPerConnection            = [System.Int32] $connector.SmtpMaxMessagesPerConnection
            SourceIPAddress                         = [System.String] $connector.SourceIPAddress
            SourceTransportServers                  = [System.String[]] $connector.SourceTransportServers
            TlsDomain                               = [System.String] $connector.TlsDomain
            UseExternalDNSServersEnabled            = [System.Boolean] $connector.UseExternalDNSServersEnabled
            CloudServicesMailEnabled                = [System.Boolean] $connector.CloudServicesMailEnabled
            TlsCertificateName                      = [System.String] $connector.TlsCertificateName
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
        $RequireOorg,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth','BasicAuthRequireTLS','ExchangeServer','ExternalAuthoritative')]
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
        [ValidateSet('EncryptionOnly','CertificateValidation','DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.Boolean]
        $CloudServicesMailEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*SendConnector', '*ADPermission' -Verbose:$VerbosePreference

    $connector = Get-SendConnectorInternal @PSBoundParameters

    if ($Ensure -eq 'Absent')
    {
        if ($null -ne $connector)
        {
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

            Remove-SendConnector @PSBoundParameters -Confirm:$false
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

            # The following aren't valid for New-SendConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity', 'BareLinefeedRejectionEnabled', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

            # Set the connectorName as Identity name
            $connectorName = $Identity

            # Add in server and name parameters
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
                'Name' = $connectorName
            }

            # Create the connector
            $connector = New-SendConnector @PSBoundParameters

            # Ensure the connector exists, and if so, set us up so we can run Set-SendConnector next
            $connector = Get-SendConnectorInternal @PSBoundParameters
            if ($null -ne $connector)
            {
                # Remove the two props we added
                Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Name'

                # Add original props back
                Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters
            }
            else
            {
                throw 'Failed to create new Receive Connector.'
            }
        }

        # The connector already exists, so use Set-SendConnector
        if ($null -ne $connector)
        {
            # Usage is not a valid command for Set-SendConnector
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Usage', 'ExtendedRightAllowEntries', 'ExtendedRightDenyEntries'

            Set-SendConnector @PSBoundParameters

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
        $RequireOorg,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth','BasicAuthRequireTLS','ExchangeServer','ExternalAuthoritative')]
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
        [ValidateSet('EncryptionOnly','CertificateValidation','DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.Boolean]
        $CloudServicesMailEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
        [System.String]
        $Usage
    )

    #Assert-IdentityIsValid -Identity $Identity

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-SendConnector', 'Get-ADPermission' -Verbose:$VerbosePreference

    $connector = Get-SendConnectorInternal @PSBoundParameters

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

            if (!(Test-ExchangeSetting -Name 'RequireOorg' -Type 'Boolean' -ExpectedValue $RequireOorg -ActualValue $connector.RequireOorg -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

            if (!(Test-ExchangeSetting -Name 'SmartHosts' -Type 'String' -ExpectedValue $SmartHosts -ActualValue (Convert-StringToArray -StringIn $connector.SmartHosts -Separator ',') -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

            if (!(Test-ExchangeSetting -Name 'SourceTransportServers' -Type 'String' -ExpectedValue $SourceTransportServers -ActualValue (Convert-StringToArray -StringIn $connector.SourceTransportServers -Separator ',') -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

            if (!(Test-ExchangeSetting -Name 'CloudServicesMailEnabled' -Type 'Boolean' -ExpectedValue $CloudServicesMailEnabled -ActualValue $connector.CloudServicesMailEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'TlsCertificateName' -Type 'String' -ExpectedValue $TlsCertificateName -ActualValue $connector.TlsCertificateName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

# Runs Get-SendConnector, only specifying Identity, ErrorAction, and optionally DomainController
function Get-SendConnectorInternal
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
        $RequireOorg,

        [Parameter()]
        [System.Boolean]
        $RequireTLS,

        [Parameter()]
        [ValidateSet('None', 'BasicAuth','BasicAuthRequireTLS','ExchangeServer','ExternalAuthoritative')]
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
        [ValidateSet('EncryptionOnly','CertificateValidation','DomainValidation')]
        [System.String]
        $TlsAuthLevel,

        [Parameter()]
        [System.String]
        $TlsDomain,

        [Parameter()]
        [System.Boolean]
        $UseExternalDNSServersEnabled,

        [Parameter()]
        [System.Boolean]
        $CloudServicesMailEnabled,

        [Parameter()]
        [System.String]
        $TlsCertificateName,

        [Parameter()]
        [ValidateSet('Internal', 'Internet', 'Partner', 'Custom')]
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

    return (Get-SendConnector @getParams | Where-Object -FilterScript {$_.Identity -like $PSBoundParameters['Identity']})
}

# Ensure that a connector Identity is in the proper form
#function Assert-IdentityIsValid
#{
#    param
#    (
#        [Parameter()]
#        [System.String]
#        $Identity
#    )
#
#    if ([System.String]::IsNullOrEmpty($Identity) -or ($Identity.Contains))
#    {
#        throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
#    }
#}

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
