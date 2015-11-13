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
        $AutoDiscoverServiceInternalUri,

        [System.String[]]
        $AutoDiscoverSiteScope,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ClientAccessServ*" -VerbosePreference $VerbosePreference

    $cas = GetClientAccessServer @PSBoundParameters

    if ($cas -ne $null)
    {
        if ($cas.AutoDiscoverSiteScope -ne $null)
        {
            $sites = $cas.AutoDiscoverSiteScope.ToArray()
        }

        $returnValue = @{
            Identity = $Identity
            AutoDiscoverServiceInternalUri = $cas.AutoDiscoverServiceInternalUri
            AutoDiscoverSiteScope = $sites
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
        $AutoDiscoverServiceInternalUri,

        [System.String[]]
        $AutoDiscoverSiteScope,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-ClientAccessServ*" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    
    $exchange2013Present = IsExchange2013Present

    if ($exchange2013Present -eq $false)
    {
        Set-ClientAccessService @PSBoundParameters
    }
    else
    {
        Set-ClientAccessServer @PSBoundParameters
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
        $AutoDiscoverServiceInternalUri,

        [System.String[]]
        $AutoDiscoverSiteScope,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ClientAccessServ*" -VerbosePreference $VerbosePreference

    $cas = GetClientAccessServer @PSBoundParameters

    if ($cas -eq $null)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "AutoDiscoverServiceInternalUri" -Type "String" -ExpectedValue $AutoDiscoverServiceInternalUri -ActualValue $cas.AutoDiscoverServiceInternalUri.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDiscoverSiteScope" -Type "Array" -ExpectedValue $AutoDiscoverSiteScope -ActualValue $cas.AutoDiscoverSiteScope -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

#Runs Get-ClientAcccessServer, only specifying Identity, and optionally DomainController
function GetClientAccessServer
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
        $AutoDiscoverServiceInternalUri,

        [System.String[]]
        $AutoDiscoverSiteScope,

        [System.String]
        $DomainController
    )

    #Remove params we don't want to pass into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $exchange2013Present = IsExchange2013Present

    if ($exchange2013Present -eq $false)
    {
        return (Get-ClientAccessService @PSBoundParameters)
    }
    else
    {
        return (Get-ClientAccessServer @PSBoundParameters)
    }   
}


Export-ModuleMember -Function *-TargetResource


