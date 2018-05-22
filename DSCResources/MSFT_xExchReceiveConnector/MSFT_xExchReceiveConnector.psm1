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
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries,

        [System.Boolean]
        $AdvertiseClientSettings,

        [System.String[]]
        $AuthMechanism,

        [System.String]
        $Banner,

        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [System.Boolean]
        $BinaryMimeEnabled,

        [System.String[]]
        $Bindings,

        [System.Boolean]
        $ChunkingEnabled,

        [System.String]
        $Comment,

        [System.String]
        $ConnectionInactivityTimeout,

        [System.String]
        $ConnectionTimeout,

        [System.String]
        $DefaultDomain,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [System.Boolean]
        $DomainSecureEnabled,

        [System.Boolean]
        $EightBitMimeEnabled,

        [System.Boolean]
        $EnableAuthGSSAPI,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionPolicy,

        [System.String]
        $Fqdn,

        [System.Boolean]
        $LongAddressesEnabled,

        [System.String]
        $MaxAcknowledgementDelay,

        [System.String]
        $MaxHeaderSize,

        [System.Int32]
        $MaxHopCount,

        [System.String]
        $MaxInboundConnection,

        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [System.String]
        $MaxInboundConnectionPerSource,

        [System.Int32]
        $MaxLocalHopCount,

        [System.Int32]
        $MaxLogonFailures,

        [System.String]
        $MaxMessageSize,

        [System.String]
        $MaxProtocolErrors,

        [System.Int32]
        $MaxRecipientsPerMessage,

        [System.String]
        $MessageRateLimit,

        [ValidateSet("None","IPAddress","User","All")]
        [System.String]
        $MessageRateSource,

        [System.Boolean]
        $OrarEnabled,

        [System.String[]]
        $PermissionGroups,

        [System.Boolean]
        $PipeliningEnabled,

        [ValidateSet("None","Verbose")]
        [System.String]
        $ProtocolLoggingLevel,

        [System.String[]]
        $RemoteIPRanges,

        [System.Boolean]
        $RequireEHLODomain,

        [System.Boolean]
        $RequireTLS,

        [System.String]
        $ServiceDiscoveryFqdn,

        [ValidateSet("Enabled","Disabled","EnabledWithoutValue")]
        [System.String]
        $SizeEnabled,

        [System.Boolean]
        $SuppressXAnonymousTls,

        [System.String]
        $TarpitInterval,

        [System.String]
        $TlsCertificateName,

        [System.String[]]
        $TlsDomainCapabilities,

        [ValidateSet("FrontendTransport","HubTransport")]
        [System.String]
        $TransportRole,

        [ValidateSet("Client","Internal","Internet","Partner","Custom")]
        [System.String]
        $Usage
    )

    ValidateIdentity -Identity $Identity

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ReceiveConnector" -VerbosePreference $VerbosePreference

    $connector = GetReceiveConnector @PSBoundParameters

    if ($null -ne $connector)
    {
        $returnValue = @{
            Identity = $Identity
            AdvertiseClientSettings = $connector.AdvertiseClientSettings
            AuthMechanism = $connector.AuthMechanism
            Banner = $connector.Banner
            BareLinefeedRejectionEnabled = $connector.BareLinefeedRejectionEnabled
            BinaryMimeEnabled = $connector.BinaryMimeEnabled
            Bindings = $connector.Bindings
            ChunkingEnabled = $connector.ChunkingEnabled
            Comment = $connector.Comment
            ConnectionInactivityTimeout = $connector.ConnectionInactivityTimeout
            ConnectionTimeout = $connector.ConnectionTimeout
            DefaultDomain = $connector.DefaultDomain
            DeliveryStatusNotificationEnabled = $connector.DeliveryStatusNotificationEnabled
            DomainSecureEnabled = $connector.DomainSecureEnabled
            EightBitMimeEnabled = $connector.EightBitMimeEnabled
            EnableAuthGSSAPI = $connector.EnableAuthGSSAPI
            Enabled = $connector.Enabled
            EnhancedStatusCodesEnabled = $connector.EnhancedStatusCodesEnabled
            ExtendedProtectionPolicy = $connector.ExtendedProtectionPolicy
            ExtendedRightAllowEntries = $ExtendedRightAllowEntries | ForEach-Object {"$($_.key)=$($_.Value)"}
            ExtendedRightDenyEntries = $ExtendedRightDenyEntries | ForEach-Object {"$($_.key)=$($_.Value)"}
            Fqdn = $connector.Fqdn
            LongAddressesEnabled = $connector.LongAddressesEnabled
            MaxAcknowledgementDelay = $connector.MaxAcknowledgementDelay
            MaxHeaderSize = $connector.MaxHeaderSize
            MaxHopCount = $connector.MaxHopCount
            MaxInboundConnection = $connector.MaxInboundConnection
            MaxInboundConnectionPercentagePerSource = $connector.MaxInboundConnectionPercentagePerSource
            MaxInboundConnectionPerSource = $connector.MaxInboundConnectionPerSource
            MaxLocalHopCount = $connector.MaxLocalHopCount
            MaxLogonFailures = $connector.MaxLogonFailures
            MaxMessageSize = $connector.MaxMessageSize
            MaxProtocolErrors = $connector.MaxProtocolErrors
            MaxRecipientsPerMessage = $connector.MaxRecipientsPerMessage
            MessageRateLimit = $connector.MessageRateLimit
            MessageRateSource = $connector.MessageRateSource
            OrarEnabled = $connector.OrarEnabled
            PermissionGroups = $connector.PermissionGroups
            PipeliningEnabled = $connector.PipeliningEnabled
            ProtocolLoggingLevel = $connector.ProtocolLoggingLevel
            RemoteIPRanges = $connector.RemoteIPRanges
            RequireEHLODomain = $connector.RequireEHLODomain
            RequireTLS = $connector.RequireTLS
            ServiceDiscoveryFqdn = $connector.ServiceDiscoveryFqdn
            SizeEnabled = $connector.SizeEnabled
            SuppressXAnonymousTls = $connector.SuppressXAnonymousTls
            TarpitInterval = $connector.TarpitInterval
            TlsCertificateName = $connector.TlsCertificateName
            TlsDomainCapabilities = $connector.TlsDomainCapabilities
            TransportRole = $connector.TransportRole
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries,

        [System.Boolean]
        $AdvertiseClientSettings,

        [System.String[]]
        $AuthMechanism,

        [System.String]
        $Banner,

        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [System.Boolean]
        $BinaryMimeEnabled,

        [System.String[]]
        $Bindings,

        [System.Boolean]
        $ChunkingEnabled,

        [System.String]
        $Comment,

        [System.String]
        $ConnectionInactivityTimeout,

        [System.String]
        $ConnectionTimeout,

        [System.String]
        $DefaultDomain,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [System.Boolean]
        $DomainSecureEnabled,

        [System.Boolean]
        $EightBitMimeEnabled,

        [System.Boolean]
        $EnableAuthGSSAPI,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionPolicy,

        [System.String]
        $Fqdn,

        [System.Boolean]
        $LongAddressesEnabled,

        [System.String]
        $MaxAcknowledgementDelay,

        [System.String]
        $MaxHeaderSize,

        [System.Int32]
        $MaxHopCount,

        [System.String]
        $MaxInboundConnection,

        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [System.String]
        $MaxInboundConnectionPerSource,

        [System.Int32]
        $MaxLocalHopCount,

        [System.Int32]
        $MaxLogonFailures,

        [System.String]
        $MaxMessageSize,

        [System.String]
        $MaxProtocolErrors,

        [System.Int32]
        $MaxRecipientsPerMessage,

        [System.String]
        $MessageRateLimit,

        [ValidateSet("None","IPAddress","User","All")]
        [System.String]
        $MessageRateSource,

        [System.Boolean]
        $OrarEnabled,

        [System.String[]]
        $PermissionGroups,

        [System.Boolean]
        $PipeliningEnabled,

        [ValidateSet("None","Verbose")]
        [System.String]
        $ProtocolLoggingLevel,

        [System.String[]]
        $RemoteIPRanges,

        [System.Boolean]
        $RequireEHLODomain,

        [System.Boolean]
        $RequireTLS,

        [System.String]
        $ServiceDiscoveryFqdn,

        [ValidateSet("Enabled","Disabled","EnabledWithoutValue")]
        [System.String]
        $SizeEnabled,

        [System.Boolean]
        $SuppressXAnonymousTls,

        [System.String]
        $TarpitInterval,

        [System.String]
        $TlsCertificateName,

        [System.String[]]
        $TlsDomainCapabilities,

        [ValidateSet("FrontendTransport","HubTransport")]
        [System.String]
        $TransportRole,

        [ValidateSet("Client","Internal","Internet","Partner","Custom")]
        [System.String]
        $Usage
    )

    ValidateIdentity -Identity $Identity

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*ReceiveConnector","*ADPermission" -VerbosePreference $VerbosePreference

    $connector = GetReceiveConnector @PSBoundParameters

    if ($Ensure -eq "Absent")
    {
        if ($null -ne $connector)
        {
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

            Remove-ReceiveConnector @PSBoundParameters -Confirm:$false
        }
    }
    else
    {
        #Remove Credential and Ensure so we don't pass it into the next command
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","Ensure"
       
        SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        #We need to create the new connector
        if ($null -eq $connector)
        {
            #Create a copy of the original parameters
            $originalPSBoundParameters = @{} + $PSBoundParameters

            #The following aren't valid for New-ReceiveConnector 
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Identity","BareLinefeedRejectionEnabled","ExtendedRightAllowEntries","ExtendedRightDenyEntries"

            #Parse out the server name and connector name from the given Identity
            $serverName = $Identity.Substring(0, $Identity.IndexOf("\"))
            $connectorName = $Identity.Substring($Identity.IndexOf("\") + 1)

            #Add in server and name parameters
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Server" = $serverName; "Name" = $connectorName}

            #Create the connector
            $connector = New-ReceiveConnector @PSBoundParameters

            #Ensure the connector exists, and if so, set us up so we can run Set-ReceiveConnector next
            if ($null -ne $connector)
            {
                #Remove the two props we added
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Server","Name"
                
                #Add original props back
                AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters                          
            }
            else
            {
                throw "Failed to create new Receive Connector."
            }
        }

        #The connector already exists, so use Set-ReceiveConnector
        if ($null -ne $connector)
        {
            #Usage is not a valid command for Set-ReceiveConnector
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Usage","ExtendedRightAllowEntries","ExtendedRightDenyEntries"

            Set-ReceiveConnector @PSBoundParameters
            
            #set AD permissions
            if ($ExtendedRightAllowEntries)
            {
                foreach ($ExtendedRightAllowEntry in $ExtendedRightAllowEntries) {
                    foreach ($Value in $($ExtendedRightAllowEntry.Value.Split(","))) {
                        $connector | Add-ADPermission -User $ExtendedRightAllowEntry.Key -ExtendedRights $Value
                    }
                }
            }
            
            if ($ExtendedRightDenyEntries)
            {
                foreach ($ExtendedRightDenyEntry in $ExtendedRightDenyEntries) {
                    foreach ($Value in $($ExtendedRightDenyEntry.Value.Split(","))) {
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries,

        [System.Boolean]
        $AdvertiseClientSettings,

        [System.String[]]
        $AuthMechanism,

        [System.String]
        $Banner,

        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [System.Boolean]
        $BinaryMimeEnabled,

        [System.String[]]
        $Bindings,

        [System.Boolean]
        $ChunkingEnabled,

        [System.String]
        $Comment,

        [System.String]
        $ConnectionInactivityTimeout,

        [System.String]
        $ConnectionTimeout,

        [System.String]
        $DefaultDomain,

        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [System.String]
        $DomainController,

        [System.Boolean]
        $DomainSecureEnabled,

        [System.Boolean]
        $EightBitMimeEnabled,

        [System.Boolean]
        $EnableAuthGSSAPI,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionPolicy,

        [System.String]
        $Fqdn,

        [System.Boolean]
        $LongAddressesEnabled,

        [System.String]
        $MaxAcknowledgementDelay,

        [System.String]
        $MaxHeaderSize,

        [System.Int32]
        $MaxHopCount,

        [System.String]
        $MaxInboundConnection,

        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [System.String]
        $MaxInboundConnectionPerSource,

        [System.Int32]
        $MaxLocalHopCount,

        [System.Int32]
        $MaxLogonFailures,

        [System.String]
        $MaxMessageSize,

        [System.String]
        $MaxProtocolErrors,

        [System.Int32]
        $MaxRecipientsPerMessage,

        [System.String]
        $MessageRateLimit,

        [ValidateSet("None","IPAddress","User","All")]
        [System.String]
        $MessageRateSource,

        [System.Boolean]
        $OrarEnabled,

        [System.String[]]
        $PermissionGroups,

        [System.Boolean]
        $PipeliningEnabled,

        [ValidateSet("None","Verbose")]
        [System.String]
        $ProtocolLoggingLevel,

        [System.String[]]
        $RemoteIPRanges,

        [System.Boolean]
        $RequireEHLODomain,

        [System.Boolean]
        $RequireTLS,

        [System.String]
        $ServiceDiscoveryFqdn,

        [ValidateSet("Enabled","Disabled","EnabledWithoutValue")]
        [System.String]
        $SizeEnabled,

        [System.Boolean]
        $SuppressXAnonymousTls,

        [System.String]
        $TarpitInterval,

        [System.String]
        $TlsCertificateName,

        [System.String[]]
        $TlsDomainCapabilities,

        [ValidateSet("FrontendTransport","HubTransport")]
        [System.String]
        $TransportRole,

        [ValidateSet("Client","Internal","Internet","Partner","Custom")]
        [System.String]
        $Usage
    )

    ValidateIdentity -Identity $Identity

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ReceiveConnector","Get-ADPermission" -VerbosePreference $VerbosePreference

    $connector = GetReceiveConnector @PSBoundParameters

    #get AD permissions if necessary
    if (($ExtendedRightAllowEntries) -or ($ExtendedRightDenyEntries))
    {
        $ADPermissions = $connector | Get-ADPermission | Where-Object {$_.IsInherited -eq $false}
    }
    
    if ($null -eq $connector)
    {
        if ($Ensure -eq "Present")
        {
            return $false
        }
        else
        {
            return $true
        }
    }
    else
    {
        if ($Ensure -eq "Absent")
        {
            return $false
        }
        else
        {
            #remove "Custom" from PermissionGroups
            $connector.PermissionGroups = ($connector.PermissionGroups -split "," ) -notmatch "Custom" -join ","

            if (!(VerifySetting -Name "AdvertiseClientSettings" -Type "Boolean" -ExpectedValue $AdvertiseClientSettings -ActualValue $connector.AdvertiseClientSettings -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "AuthMechanism" -Type "Array" -ExpectedValue $AuthMechanism -ActualValue (StringToArray -StringIn "$($connector.AuthMechanism)" -Separator ',') -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Banner" -Type "String" -ExpectedValue $Banner -ActualValue $connector.Banner -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "BareLinefeedRejectionEnabled" -Type "Boolean" -ExpectedValue $BareLinefeedRejectionEnabled -ActualValue $connector.BareLinefeedRejectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "BinaryMimeEnabled" -Type "Boolean" -ExpectedValue $BinaryMimeEnabled -ActualValue $connector.BinaryMimeEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Bindings" -Type "Array" -ExpectedValue $Bindings -ActualValue $connector.Bindings -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ChunkingEnabled" -Type "Boolean" -ExpectedValue $ChunkingEnabled -ActualValue $connector.ChunkingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Comment" -Type "String" -ExpectedValue $Comment -ActualValue $connector.Comment -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ConnectionInactivityTimeout" -Type "Timespan" -ExpectedValue $ConnectionInactivityTimeout -ActualValue $connector.ConnectionInactivityTimeout -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ConnectionTimeout" -Type "Timespan" -ExpectedValue $ConnectionTimeout -ActualValue $connector.ConnectionTimeout -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "DefaultDomain" -Type "String" -ExpectedValue $DefaultDomain -ActualValue $connector.DefaultDomain -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "DeliveryStatusNotificationEnabled" -Type "Boolean" -ExpectedValue $DeliveryStatusNotificationEnabled -ActualValue $connector.DeliveryStatusNotificationEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "DomainSecureEnabled" -Type "Boolean" -ExpectedValue $DomainSecureEnabled -ActualValue $connector.DomainSecureEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "EightBitMimeEnabled" -Type "Boolean" -ExpectedValue $EightBitMimeEnabled -ActualValue $connector.EightBitMimeEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "EnableAuthGSSAPI" -Type "Boolean" -ExpectedValue $EnableAuthGSSAPI -ActualValue $connector.EnableAuthGSSAPI -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Enabled" -Type "Boolean" -ExpectedValue $Enabled -ActualValue $connector.Enabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "EnhancedStatusCodesEnabled" -Type "Boolean" -ExpectedValue $EnhancedStatusCodesEnabled -ActualValue $connector.EnhancedStatusCodesEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ExtendedProtectionPolicy" -Type "String" -ExpectedValue $ExtendedProtectionPolicy -ActualValue $connector.ExtendedProtectionPolicy -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Fqdn" -Type "String" -ExpectedValue $Fqdn -ActualValue $connector.Fqdn -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "LongAddressesEnabled" -Type "Boolean" -ExpectedValue $LongAddressesEnabled -ActualValue $connector.LongAddressesEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxHopCount" -Type "Int" -ExpectedValue $MaxHopCount -ActualValue $connector.MaxHopCount -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxAcknowledgementDelay" -Type "Timespan" -ExpectedValue $MaxAcknowledgementDelay -ActualValue $connector.MaxAcknowledgementDelay -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxInboundConnection" -Type "String" -ExpectedValue $MaxInboundConnection -ActualValue $connector.MaxInboundConnection -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxInboundConnectionPercentagePerSource" -Type "Int" -ExpectedValue $MaxInboundConnectionPercentagePerSource -ActualValue $connector.MaxInboundConnectionPercentagePerSource -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxInboundConnectionPerSource" -Type "String" -ExpectedValue $MaxInboundConnectionPerSource -ActualValue $connector.MaxInboundConnectionPerSource -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxHeaderSize" -Type "ByteQuantifiedSize" -ExpectedValue $MaxHeaderSize -ActualValue $connector.MaxHeaderSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxLocalHopCount" -Type "Int" -ExpectedValue $MaxLocalHopCount -ActualValue $connector.MaxLocalHopCount -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxLogonFailures" -Type "Int" -ExpectedValue $MaxLogonFailures -ActualValue $connector.MaxLogonFailures -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxMessageSize" -Type "ByteQuantifiedSize" -ExpectedValue $MaxMessageSize -ActualValue $connector.MaxMessageSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxProtocolErrors" -Type "String" -ExpectedValue $MaxProtocolErrors -ActualValue $connector.MaxProtocolErrors -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MaxRecipientsPerMessage" -Type "Int" -ExpectedValue $MaxRecipientsPerMessage -ActualValue $connector.MaxRecipientsPerMessage -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MessageRateLimit" -Type "String" -ExpectedValue $MessageRateLimit -ActualValue $connector.MessageRateLimit -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "MessageRateSource" -Type "String" -ExpectedValue $MessageRateSource -ActualValue $connector.MessageRateSource -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "OrarEnabled" -Type "Boolean" -ExpectedValue $OrarEnabled -ActualValue $connector.OrarEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "PermissionGroups" -Type "Array" -ExpectedValue $PermissionGroups -ActualValue (StringToArray -StringIn $connector.PermissionGroups -Separator ',') -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "PipeliningEnabled" -Type "Boolean" -ExpectedValue $PipeliningEnabled -ActualValue $connector.PipeliningEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ProtocolLoggingLevel" -Type "String" -ExpectedValue $ProtocolLoggingLevel -ActualValue $connector.ProtocolLoggingLevel -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "RemoteIPRanges" -Type "Array" -ExpectedValue $RemoteIPRanges -ActualValue $connector.RemoteIPRanges -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "RequireEHLODomain" -Type "Boolean" -ExpectedValue $RequireEHLODomain -ActualValue $connector.RequireEHLODomain -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "RequireTLS" -Type "Boolean" -ExpectedValue $RequireTLS -ActualValue $connector.RequireTLS -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ServiceDiscoveryFqdn" -Type "String" -ExpectedValue $ServiceDiscoveryFqdn -ActualValue $connector.ServiceDiscoveryFqdn -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "SizeEnabled" -Type "String" -ExpectedValue $SizeEnabled -ActualValue $connector.SizeEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "SuppressXAnonymousTls" -Type "Boolean" -ExpectedValue $SuppressXAnonymousTls -ActualValue $connector.SuppressXAnonymousTls -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "TarpitInterval" -Type "Timespan" -ExpectedValue $TarpitInterval -ActualValue $connector.TarpitInterval -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "TlsCertificateName" -Type "String" -ExpectedValue $TlsCertificateName -ActualValue $connector.TlsCertificateName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "TlsDomainCapabilities" -Type "Array" -ExpectedValue $TlsDomainCapabilities -ActualValue $connector.TlsDomainCapabilities -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "TransportRole" -Type "String" -ExpectedValue $TransportRole -ActualValue $connector.TransportRole -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }
            
            #check AD permissions if necessary
            if ($ExtendedRightAllowEntries)
            {
                if (!(ExtendedRightExists -ADPermissions $ADPermissions -ExtendedRights $ExtendedRightAllowEntries -ShouldbeTrue:$True -VerbosePreference $VerbosePreference))
                {
                    return $false
                }
            }
            
            if ($ExtendedRightDenyEntries)
            {
                if (ExtendedRightExists -ADPermissions $ADPermissions -ExtendedRights $ExtendedRightDenyEntries -ShouldbeTrue:$false -VerbosePreference $VerbosePreference)
                {
                    return $false
                }
            }
        }
    }

    #If we made it here, all tests passed
    return $true
}

#Runs Get-ReceiveConnector, only specifying Identity, ErrorAction, and optionally DomainController
function GetReceiveConnector
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightAllowEntries,

        [Microsoft.Management.Infrastructure.CimInstance[]]
        $ExtendedRightDenyEntries,

        [System.Boolean]
        $AdvertiseClientSettings,

        [System.String[]]
        $AuthMechanism,

        [System.String]
        $Banner,

        [System.Boolean]
        $BareLinefeedRejectionEnabled,

        [System.Boolean]
        $BinaryMimeEnabled,

        [System.String[]]
        $Bindings,

        [System.Boolean]
        $ChunkingEnabled,

        [System.String]
        $Comment,

        [System.String]
        $ConnectionInactivityTimeout,

        [System.String]
        $ConnectionTimeout,

        [System.String]
        $DefaultDomain,

        [System.Boolean]
        $DeliveryStatusNotificationEnabled,

        [System.Boolean]
        $DomainSecureEnabled,

        [System.Boolean]
        $EightBitMimeEnabled,

        [System.Boolean]
        $EnableAuthGSSAPI,

        [System.Boolean]
        $Enabled,

        [System.Boolean]
        $EnhancedStatusCodesEnabled,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionPolicy,

        [System.String]
        $Fqdn,

        [System.Boolean]
        $LongAddressesEnabled,

        [System.String]
        $MaxAcknowledgementDelay,

        [System.String]
        $MaxHeaderSize,

        [System.Int32]
        $MaxHopCount,

        [System.String]
        $MaxInboundConnection,

        [System.Int32]
        $MaxInboundConnectionPercentagePerSource,

        [System.String]
        $MaxInboundConnectionPerSource,

        [System.Int32]
        $MaxLocalHopCount,

        [System.Int32]
        $MaxLogonFailures,

        [System.String]
        $MaxMessageSize,

        [System.String]
        $MaxProtocolErrors,

        [System.Int32]
        $MaxRecipientsPerMessage,

        [System.String]
        $MessageRateLimit,

        [ValidateSet("None","IPAddress","User","All")]
        [System.String]
        $MessageRateSource,

        [System.Boolean]
        $OrarEnabled,

        [System.String[]]
        $PermissionGroups,

        [System.Boolean]
        $PipeliningEnabled,

        [ValidateSet("None","Verbose")]
        [System.String]
        $ProtocolLoggingLevel,

        [System.String[]]
        $RemoteIPRanges,

        [System.Boolean]
        $RequireEHLODomain,

        [System.Boolean]
        $RequireTLS,

        [System.String]
        $ServiceDiscoveryFqdn,

        [ValidateSet("Enabled","Disabled","EnabledWithoutValue")]
        [System.String]
        $SizeEnabled,

        [System.Boolean]
        $SuppressXAnonymousTls,

        [System.String]
        $TarpitInterval,

        [System.String]
        $TlsCertificateName,

        [System.String[]]
        $TlsDomainCapabilities,

        [ValidateSet("FrontendTransport","HubTransport")]
        [System.String]
        $TransportRole,

        [ValidateSet("Client","Internal","Internet","Partner","Custom")]
        [System.String]
        $Usage
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-ReceiveConnector @PSBoundParameters -ErrorAction SilentlyContinue)
}

#Ensure that a connector Identity is in the proper form
function ValidateIdentity
{
    param([string]$Identity)

    if ([string]::IsNullOrEmpty($Identity) -or !($Identity.Contains("\")))
    {
        throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
    }
}

#check a connector for specific extended rights
function ExtendedRightExists
{
    [cmdletbinding()]
    [OutputType([System.Boolean])]
    param(
    $ADPermissions,
    [Microsoft.Management.Infrastructure.CimInstance[]]$ExtendedRights,
    [boolean]$ShouldbeTrue,
    $VerbosePreference
    )
    $returnvalue = $false
    foreach ($Right in $ExtendedRights)
    {
        foreach ($Value in $($Right.Value.Split(",")))
        {
            if ($null -ne ($ADPermissions | Where-Object {($_.User.RawIdentity -eq $Right.Key) -and ($_.ExtendedRights.RawIdentity -eq $Value)}))
            {
                $returnvalue = $true
                if (!($ShouldbeTrue))
                {
                    Write-Verbose "Should report exist!"
                    ReportBadSetting -SettingName "ExtendedRight" -ExpectedValue "User:$($Right.Key) Value:$($Value)" -ActualValue "Present" -VerbosePreference $VerbosePreference
                    return $returnvalue
                    exit;
                }
            }
            else
            {
                $returnvalue = $false
                if ($ShouldbeTrue)
                {
                    ReportBadSetting -SettingName "ExtendedRight" -ExpectedValue "User:$($Right.Key) Value:$($Value)" -ActualValue "Absent" -VerbosePreference $VerbosePreference
                    return $returnvalue
                    exit;
                }
            }
        }
    }
return $returnvalue
}

Export-ModuleMember -Function *-TargetResource
