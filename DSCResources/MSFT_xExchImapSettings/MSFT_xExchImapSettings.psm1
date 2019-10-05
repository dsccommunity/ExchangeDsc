<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Server
        The IMAP server to configure.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
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
        $Credential
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    $imapSettings = @(
        'AuthenticatedConnectionTimeout'
        'Banner'
        'CalendarItemRetrievalOption'
        'EnableExactRFC822Size'
        'EnableGSSAPIAndNTLMAuth'
        'EnforceCertificateErrors'
        'ExtendedProtectionPolicy'
        'ExternalConnectionSettings'
        'InternalConnectionSettings'
        'LogFileRollOverSettings'
        'LoginType'
        'LogPerFileSizeQuota'
        'MaxCommandSize'
        'MaxConnectionFromSingleIP'
        'MaxConnections'
        'MaxConnectionsPerUser'
        'MessageRetrievalMimeFormat'
        'PreAuthenticatedConnectionTimeout'
        'ProtocolLogEnabled'
        'ProtocolName'
        'ProxyTargetPort'
        'SSLBindings'
        'SuppressReadReceipt'
        'UnencryptedOrTLSBindings'
    )
    $imap = Get-ImapSettings -Server $Server | Select-Object -Property $imapSettings

    if ($null -ne $imap)
    {
        $returnValue = @{
            Server                            = [System.String] $Server
            AuthenticatedConnectionTimeout    = [System.String] $imap.AuthenticatedConnectionTimeout
            Banner                            = [System.String] $imap.Banner
            CalendarItemRetrievalOption       = [System.String] $imap.CalendarItemRetrievalOption
            EnableExactRFC822Size             = [System.Boolean] $imap.EnableExactRFC822Size
            EnableGSSAPIAndNTLMAuth           = [System.Boolean] $imap.EnableGSSAPIAndNTLMAuth
            EnforceCertificateErrors          = [System.Boolean] $imap.EnforceCertificateErrors
            ExtendedProtectionPolicy          = [System.String] $imap.ExtendedProtectionPolicy
            ExternalConnectionSettings        = [System.String[]] $imap.ExternalConnectionSettings
            InternalConnectionSettings        = [System.String[]] $imap.InternalConnectionSettings
            LogFileRollOverSettings           = [System.String] $imap.LogFileRollOverSettings
            LoginType                         = [System.String] $imap.LoginType
            MaxCommandSize                    = [System.Int32] $imap.MaxCommandSize
            MaxConnectionFromSingleIP         = [System.Int32] $imap.MaxConnectionFromSingleIP
            MaxConnections                    = [System.Int32] $imap.MaxConnections
            MaxConnectionsPerUser             = [System.Int32] $imap.MaxConnectionsPerUser
            PreAuthenticatedConnectionTimeout = [System.String] $imap.PreAuthenticatedConnectionTimeout
            ProtocolLogEnabled                = [System.Boolean] $imap.ProtocolLogEnabled
            ProxyTargetPort                   = [System.Int32] $imap.ProxyTargetPort
            SSLBindings                       = [System.String[]] $imap.SSLBindings
            UnencryptedOrTLSBindings          = [System.String[]] $imap.UnencryptedOrTLSBindings
            X509CertificateName               = [System.String] $imap.X509CertificateName
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.
    .PARAMETER Server
        The IMAP server to configure.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes. Defaults to
    .PARAMETER AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
    .PARAMETER Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients.
    .PARAMETER CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients.
    .PARAMETER EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients.
    .PARAMETER EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication
    .PARAMETER EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer
    .PARAMETER ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used.
    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name
    .PARAMETER InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name
    .PARAMETER LogFileRollOverSettings
        The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file.
    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections.
    .PARAMETER MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command.
    .PARAMETER MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address.
    .PARAMETER MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server.
    .PARAMETER MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user.
    .PARAMETER PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
    .PARAMETER ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4.
    .PARAMETER ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service.
    .PARAMETER SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL
    .PARAMETER UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections.
    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
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
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('iCalendar', 'intranetUrl', 'InternetUrl', 'Custom')]
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
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

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
        [System.String]
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ImapSettings' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-ImapSettings @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restarting IMAP Services'

        Get-Service MSExchangeIMAP4* | Restart-Service
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
        The IMAP server to configure.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the IMAP services after making changes. Defaults to
    .PARAMETER AuthenticatedConnectionTimeout
        The AuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle authenticated connection.
    .PARAMETER Banner
        The Banner parameter specifies the text string that's displayed to connecting IMAP4 clients.
    .PARAMETER CalendarItemRetrievalOption
        The CalendarItemRetrievalOption parameter specifies how calendar items are presented to IMAP4 clients.
    .PARAMETER EnableExactRFC822Size
        The EnableExactRFC822Size parameter specifies how message sizes are presented to IMAP4 clients.
    .PARAMETER EnableGSSAPIAndNTLMAuth
        The EnableGSSAPIAndNTLMAuth parameter specifies whether connections can use Integrated Windows authentication
    .PARAMETER EnforceCertificateErrors
        The EnforceCertificateErrors parameter specifies whether to enforce valid Secure Sockets Layer
    .PARAMETER ExtendedProtectionPolicy
        The ExtendedProtectionPolicy parameter specifies how Extended Protection for Authentication is used.
    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name
    .PARAMETER InternalConnectionSettings
        The InternalConnectionSettings parameter specifies the host name
    .PARAMETER LogFileRollOverSettings
        The LogFileRollOverSettings parameter specifies how frequently IMAP4 protocol logging creates a new log file.
    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4 connections.
    .PARAMETER MaxCommandSize
        The MaxCommandSize parameter specifies the maximum size in bytes of a single IMAP4 command.
    .PARAMETER MaxConnectionFromSingleIP
        The MaxConnectionFromSingleIP parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server from a single IP address.
    .PARAMETER MaxConnections
        The MaxConnections parameter specifies the maximum number of IMAP4 connections that are accepted by the Exchange server.
    .PARAMETER MaxConnectionsPerUser
        The MaxConnectionsPerUser parameter specifies the maximum number of IMAP4 connections that are allowed for each user.
    .PARAMETER PreAuthenticatedConnectionTimeout
        The PreAuthenticatedConnectionTimeout parameter specifies the period of time to wait before closing an idle IMAP4 connection that isn't authenticated.
    .PARAMETER ProtocolLogEnabled
        The ProtocolLogEnabled parameter specifies whether to enable protocol logging for IMAP4.
    .PARAMETER ProxyTargetPort
        The ProxyTargetPort parameter specifies the port on the Microsoft Exchange IMAP4 Backend service that listens for client connections that are proxied from the Microsoft Exchange IMAP4 service.
    .PARAMETER SSLBindings
        The SSLBindings parameter specifies the IP address and TCP port that's used for IMAP4 connection that's always encrypted by SSL
    .PARAMETER UnencryptedOrTLSBindings
        The UnencryptedOrTLSBindings parameter specifies the IP address and TCP port that's used for unencrypted IMAP4 connections.
    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used for encrypting IMAP4 client connections.
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
        $AuthenticatedConnectionTimeout,

        [Parameter()]
        [System.String]
        $Banner,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('iCalendar', 'intranetUrl', 'InternetUrl', 'Custom')]
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
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String[]]
        $InternalConnectionSettings,

        [Parameter()]
        [ValidateSet('Hourly', 'Daily', 'Weekly', 'Monthly')]
        [System.String]
        $LogFileRollOverSettings,

        [Parameter()]
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

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
        <<<<<<< HEAD
        [String]
        = = = = = = =
        [System.String]
        >>>>>>> 5b8f9ac... moving from Timespan to String
        $PreAuthenticatedConnectionTimeout,

        [Parameter()]
        [System.Boolean]
        $ProtocolLogEnabled,

        [Parameter()]
        [System.Int32]
        $ProxyTargetPort,

        [Parameter()]
        [System.String[]]
        $SSLBindings,

        [Parameter()]
        [System.String[]]
        $UnencryptedOrTLSBindings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $imap = Get-TargetResource -Server $Server -Credential $Credential

    $testResults = $true

    if ($null -eq $imap)
    {
        Write-Verbose -Message 'Unable to retrieve IMAP Settings for server.'
        $testResults = $false
    }
    else
    {
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose', 'Server'
        $differenceObjectHashTable = @{ } + $PSBoundParameters
        $differenceObject = [PSCustomObject] $differenceObjectHashTable
        $referenceObject = [PSCustomObject] $imap

        foreach ($property in $PSBoundParameters.Keys)
        {
            if (Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -Property $property)
            {
                Write-Verbose -Message ("Invalid setting '{0}'. Expected value: {1}. Actual value: {2}" -f $property, $PSBoundParameters[$property], $imap.$property)
                $testResults = $false
            }
        }
    }

    return $testResults
}
Export-ModuleMember -Function *-TargetResource
