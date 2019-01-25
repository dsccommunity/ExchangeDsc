<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Server
        The IMAP server to configure.

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

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port,
        and encryption method that's used by external IMAP4 clients (IMAP4
        connections from outside your corporate network).

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4
        connections.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used
        for encrypting IMAP4 client connections.
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

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

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
        The IMAP server to configure.

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

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port,
        and encryption method that's used by external IMAP4 clients (IMAP4
        connections from outside your corporate network).

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4
        connections.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used
        for encrypting IMAP4 client connections.
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

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

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
        The IMAP server to configure.

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

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port,
        and encryption method that's used by external IMAP4 clients (IMAP4
        connections from outside your corporate network).

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4
        connections.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used
        for encrypting IMAP4 client connections.
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

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

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
        The IMAP server to configure.

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

    .PARAMETER ExternalConnectionSettings
        The ExternalConnectionSettings parameter specifies the host name, port,
        and encryption method that's used by external IMAP4 clients (IMAP4
        connections from outside your corporate network).

    .PARAMETER LoginType
        The LoginType parameter specifies the authentication method for IMAP4
        connections.

    .PARAMETER X509CertificateName
        The X509CertificateName parameter specifies the certificate that's used
        for encrypting IMAP4 client connections.
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
