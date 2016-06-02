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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    if ($null -ne $EcpVdir)
    {
        $returnValue = @{
            DigestAuthentication = $EcpVdir.DigestAuthentication
            AdfsAuthentication = $EcpVdir.AdfsAuthentication
            ExternalAuthenticationMethods = $EcpVdir.ExternalAuthenticationMethods
            Identity = $Identity
            InternalUrl = $EcpVdir.InternalUrl
            ExternalUrl = $EcpVdir.ExternalUrl
            FormsAuthentication = $EcpVdir.FormsAuthentication
            WindowsAuthentication = $EcpVdir.WindowsAuthentication
            BasicAuthentication = $EcpVdir.BasicAuthentication

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
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters  
  
    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-EcpVirtualDirectory @PSBoundParameters
  
    If($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeECPAppPool"

        RestartAppPoolIfExists -Name MSExchangeECPAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeECPAppPool is manually recycled."
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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session    
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    
    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    if ($null -eq $EcpVdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $EcpVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $EcpVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "FormsAuthentication" -Type "Boolean" -ExpectedValue $FormsAuthentication -ActualValue $EcpVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthentication" -Type "Boolean" -ExpectedValue $WindowsAuthentication -ActualValue $EcpVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $EcpVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DigestAuthentication" -Type "Boolean" -ExpectedValue $DigestAuthentication -ActualValue $EcpVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AdfsAuthentication" -Type "Boolean" -ExpectedValue $AdfsAuthentication -ActualValue $EcpVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalAuthenticationMethods" -Type "Array" -ExpectedValue $ExternalAuthenticationMethods -ActualValue $EcpVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    #If the code made it this for all properties are in a desired state    
    return $true 
}

function GetEcpVirtualDirectory
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

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $WindowsAuthentication
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-EcpVirtualDirectory @PSBoundParameters)
}


Export-ModuleMember -Function *-TargetResource



