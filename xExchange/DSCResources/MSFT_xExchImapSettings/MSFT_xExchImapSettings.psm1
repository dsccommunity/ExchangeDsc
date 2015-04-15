function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ImapSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Server","DomainController"

    $imap = Get-ImapSettings @PSBoundParameters

    if ($imap -ne $null)
    {
        $returnValue = @{
            Server = $Identity
            LoginType = $imap.LoginType
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
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-ImapSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

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
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [ValidateSet("PlainTextLogin","PlainTextAuthentication","SecureLogin")]
        [System.String]
        $LoginType
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ImapSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Server","DomainController"

    $imap = Get-ImapSettings @PSBoundParameters

    if ($imap -eq $null)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "LoginType" -Type "String" -ExpectedValue $LoginType -ActualValue $imap.LoginType -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }   
    }

    return $true
}


Export-ModuleMember -Function *-TargetResource



