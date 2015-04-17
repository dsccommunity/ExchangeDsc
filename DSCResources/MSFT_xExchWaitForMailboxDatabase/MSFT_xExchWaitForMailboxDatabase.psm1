function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    if ($db -ne $null)
    {
        $returnValue = @{
            Identity = $Identity
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
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        if ($db -eq $null)
        {
            Write-Warning "Database '$($Identity)' does not yet exist. Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec

            $db = GetMailboxDatabase @PSBoundParameters
        }
        else
        {
            break
        }
    }
    
    if ($db -eq $null)
    {
        throw "Database '$($Identity)' does not yet exist. This will prevent resources that are dependant on this resource from executing. If you are running the DSC configuration in push mode, you will need to re-run the configuration once the database has been created."
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
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    return ($db -ne $null)
}

function GetMailboxDatabase
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue)
}


Export-ModuleMember -Function *-TargetResource



