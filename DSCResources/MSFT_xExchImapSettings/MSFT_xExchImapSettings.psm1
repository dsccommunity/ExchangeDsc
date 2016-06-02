function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType,

        [System.String[]]
        $ExternalConnectionSettings,

        [System.String]
        $X509CertificateName
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ImapSettings" -VerbosePreference $VerbosePreference

    $imap = GetImapSettings @PSBoundParameters

    if ($null -ne $imap)
    {
        $returnValue = @{
            Server = $Identity
            LoginType = $imap.LoginType
            ExternalConnectionSettings = $imap.ExternalConnectionSettings
            X509CertificateName = $imap.X509CertificateName
        }
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType,

        [System.String[]]
        $ExternalConnectionSettings,

        [System.String]
        $X509CertificateName
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-ImapSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    Set-ImapSettings @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Restarting IMAP Services"

        Get-Service MSExchangeIMAP4* | Restart-Service
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeIMAP4 services are manually restarted."
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
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType,

        [System.String[]]
        $ExternalConnectionSettings,

        [System.String]
        $X509CertificateName
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ImapSettings" -VerbosePreference $VerbosePreference

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $imap = GetImapSettings @PSBoundParameters

    if ($null -eq $imap)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "LoginType" -Type "String" -ExpectedValue $LoginType -ActualValue $imap.LoginType -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }  
        
        if (!(VerifySetting -Name "ExternalConnectionSettings" -Type "Array" -ExpectedValue $ExternalConnectionSettings -ActualValue $imap.ExternalConnectionSettings -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        } 
        
        if (!(VerifySetting -Name "X509CertificateName" -Type "String" -ExpectedValue $X509CertificateName -ActualValue $imap.X509CertificateName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }  
    }

    return $true
}

function GetImapSettings
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType,

        [System.String[]]
        $ExternalConnectionSettings,

        [System.String]
        $X509CertificateName
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Server","DomainController"

    return (Get-ImapSettings @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource



