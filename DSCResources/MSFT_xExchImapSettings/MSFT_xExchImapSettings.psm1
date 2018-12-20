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
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    $imap = Get-ImapSettingsInternal @PSBoundParameters

    if ($null -ne $imap)
    {
        $returnValue = @{
            Server                     = [System.String] $Server
            ExternalConnectionSettings = [System.String[]] $imap.ExternalConnectionSettings
            LoginType                  = [System.String] $imap.LoginType
            X509CertificateName        = [System.String] $imap.X509CertificateName
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
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ImapSettings' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

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
        $X509CertificateName
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
        $X509CertificateName
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server', 'DomainController'

    return (Get-ImapSettings @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
