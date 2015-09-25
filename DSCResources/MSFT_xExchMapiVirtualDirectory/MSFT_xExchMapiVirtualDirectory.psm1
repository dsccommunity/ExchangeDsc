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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [System.String]
        $InternalUrl
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetMapiVirtualDirectory @PSBoundParameters

    if ($vdir -ne $null)
    {
        $returnValue = @{
            Identity = $Identity
            IISAuthenticationMethods = $vdir.IISAuthenticationMethods
            ExternalUrl = $vdir.ExternalUrl.AbsoluteUri
            InternalUrl = $vdir.InternalUrl.AbsoluteUri
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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [System.String]
        $InternalUrl
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MapiVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool"

        RestartAppPoolIfExists -Name MSExchangeMapiFrontEndAppPool
        RestartAppPoolIfExists -Name MSExchangeMapiMailboxAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool are manually recycled."
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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [System.String]
        $InternalUrl
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetMapiVirtualDirectory @PSBoundParameters

    if ($vdir -eq $null)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "IISAuthenticationMethods" -Type "Array" -ExpectedValue $IISAuthenticationMethods -ActualValue $vdir.IISAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $vdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $vdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }    
    }
    
    return $true
}

function GetMapiVirtualDirectory
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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [System.String]
        $InternalUrl
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MapiVirtualDirectory @PSBoundParameters)
}


Export-ModuleMember -Function *-TargetResource



