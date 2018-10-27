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
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    # Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    $imap = GetImapSettings @PSBoundParameters

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
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    # Establish remote Powershell session
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
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Write-FunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    # Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ImapSettings' -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $imap = GetImapSettings @PSBoundParameters

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

function GetImapSettings
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
        [ValidateSet('PlainTextLogin', 'PlainTextAuthentication', 'SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server', 'DomainController'

    return (Get-ImapSettings @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
