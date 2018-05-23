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
        [ValidateSet('PlainTextLogin','PlainTextAuthentication','SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-PopSettings' -VerbosePreference $VerbosePreference

    $pop = GetPopSettings @PSBoundParameters

    if ($null -ne $pop)
    {
        $returnValue = @{
            Server = $Identity
            LoginType = $pop.LoginType
            ExternalConnectionSettings = $pop.ExternalConnectionSettings
            X509CertificateName = $pop.X509CertificateName
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
        [ValidateSet('PlainTextLogin','PlainTextAuthentication','SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-PopSettings' -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-PopSettings @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restarting POP Services'

        Get-Service MSExchangePOP4* | Restart-Service
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangePOP services are manually restarted.'
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
        [ValidateSet('PlainTextLogin','PlainTextAuthentication','SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-PopSettings' -VerbosePreference $VerbosePreference

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $pop = GetPopSettings @PSBoundParameters

    if ($null -eq $pop)
    {
        return $false
    }
    else
    {

        if (!(VerifySetting -Name 'LoginType' -Type 'String' -ExpectedValue $LoginType -ActualValue $pop.LoginType -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ExternalConnectionSettings' -Type 'Array' -ExpectedValue $ExternalConnectionSettings -ActualValue $pop.ExternalConnectionSettings -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'X509CertificateName' -Type 'String' -ExpectedValue $X509CertificateName -ActualValue $pop.X509CertificateName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

function GetPopSettings
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
        [ValidateSet('PlainTextLogin','PlainTextAuthentication','SecureLogin')]
        [System.String]
        $LoginType,

        [Parameter()]
        [System.String[]]
        $ExternalConnectionSettings,

        [Parameter()]
        [System.String]
        $X509CertificateName
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server','DomainController'

    return (Get-PopSettings @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
