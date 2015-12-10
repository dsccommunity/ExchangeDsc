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

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer" -VerbosePreference $VerbosePreference

    $server = GetMailboxServer @PSBoundParameters

    if ($server -ne $null)
    {
        $returnValue = @{
            Identity = $Identity
            DatabaseCopyActivationDisabledAndMoveNow = $server.DatabaseCopyActivationDisabledAndMoveNow
            DatabaseCopyAutoActivationPolicy = $server.DatabaseCopyAutoActivationPolicy
            MaximumActiveDatabases = $server.MaximumActiveDatabases
            MaximumPreferredActiveDatabases = $server.MaximumPreferredActiveDatabases
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

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MailboxServer" -VerbosePreference $VerbosePreference

    #Setup params for next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MailboxServer @PSBoundParameters

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

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer","Set-MailboxServer" -VerbosePreference $VerbosePreference

    $server = GetMailboxServer @PSBoundParameters

    if ($server -eq $null) #Couldn't find the server, which is bad
    {
        return $false
    }
    else #Validate server params
    {
        if (!(VerifySetting -Name "DatabaseCopyActivationDisabledAndMoveNow" -Type "Boolean" -ExpectedValue $DatabaseCopyActivationDisabledAndMoveNow -ActualValue $server.DatabaseCopyActivationDisabledAndMoveNow -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DatabaseCopyAutoActivationPolicy" -Type "String" -ExpectedValue $DatabaseCopyAutoActivationPolicy -ActualValue $server.DatabaseCopyAutoActivationPolicy -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumActiveDatabases" -Type "String" -ExpectedValue $MaximumActiveDatabases -ActualValue $server.MaximumActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumPreferredActiveDatabases" -Type "String" -ExpectedValue $MaximumPreferredActiveDatabases -ActualValue $server.MaximumPreferredActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

#Runs Get-MailboxServer, only specifying Identity, and optionally DomainController
function GetMailboxServer
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

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxServer @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource

