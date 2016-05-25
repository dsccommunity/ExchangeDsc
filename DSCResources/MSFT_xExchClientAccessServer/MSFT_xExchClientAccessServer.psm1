function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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

    if ($null -ne $cas)
    {
        if ($null -ne $cas.AutoDiscoverSiteScope)
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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
    
    $serverVersion = GetExchangeVersion -ThrowIfUnknownVersion $true

    if ($serverVersion -eq "2016")
    {
        Set-ClientAccessService @PSBoundParameters
    }
    elseif ($serverVersion -eq "2013")
    {
        Set-ClientAccessServer @PSBoundParameters
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
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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

    if ($null -eq $cas)
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
        [System.Management.Automation.Credential()]
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

    $serverVersion = GetExchangeVersion -ThrowIfUnknownVersion $true

    if ($serverVersion -eq "2016")
    {
        return (Get-ClientAccessService @PSBoundParameters)
    }
    elseif ($serverVersion -eq "2013")
    {
        return (Get-ClientAccessServer @PSBoundParameters)
    } 
}


Export-ModuleMember -Function *-TargetResource


