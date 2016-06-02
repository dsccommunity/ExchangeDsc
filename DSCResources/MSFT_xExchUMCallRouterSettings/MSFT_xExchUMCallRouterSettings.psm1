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

        [parameter(Mandatory = $true)]
        [ValidateSet("TCP","TLS","Dual")]
        [System.String]
        $UMStartupMode,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*UMCallRouterSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Server","DomainController"

    $umService = Get-UMCallRouterSettings @PSBoundParameters

    if ($null -ne $umService)
    {
        $returnValue = @{
            Server = $Server
            UMStartupMode = $umService.UMStartupMode
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
        $Server,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("TCP","TLS","Dual")]
        [System.String]
        $UMStartupMode,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*UMCallRouterSettings" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    Set-UMCallRouterSettings @PSBoundParameters
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

        [parameter(Mandatory = $true)]
        [ValidateSet("TCP","TLS","Dual")]
        [System.String]
        $UMStartupMode,

        [System.String]
        $DomainController
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Server" = $Server} -VerbosePreference $VerbosePreference

    $umService = Get-TargetResource @PSBoundParameters

    if ($null -eq $umService)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "UMStartupMode" -Type "String" -ExpectedValue $UMStartupMode -ActualValue $umService.UMStartupMode -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }        
    }

    return $true
}


Export-ModuleMember -Function *-TargetResource



