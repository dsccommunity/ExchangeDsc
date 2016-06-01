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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,    

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,
    
        [System.Boolean]
        $OAuthAuthentication,

        [System.Boolean]
        $WindowsAuthentication,

        [System.Boolean]
        $WSSecurityAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-WebServicesVirtualDirectory' -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $EwsVdir = Get-WebServicesVirtualDirectory @PSBoundParameters

    if ($null -ne $EwsVdir)
    {
        $returnValue = @{
            EwsVirtualDirectoryIdentity = $Identity
            InternalUrl = $EwsVdir.InternalUrl.AbsoluteUri
            ExternalUrl = $EwsVdir.InternalUrl.AbsoluteUri
            BasicAuthentication = $EwsVdir.BasicAuthentication
            CertificateAuthentication = $EwsVdir.CertificateAuthentication
            DigestAuthentication = $EwsVdir.DigestAuthentication
            OAuthAuthentication = $EwsVdir.OAuthAuthentication
            WSSecurityAuthentication = $EwsVdir.WSSecurityAuthentication
            InternalNLBBypassUrl = $EwsVdir.InternalNLBBypassUrl
            WindowsAuthentication = $EwsVdir.WindowsAuthentication
        }
    }

    $returnValue
}


function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,    

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,
    
        [System.Boolean]
        $OAuthAuthentication,

        [System.Boolean]
        $WindowsAuthentication,

        [System.Boolean]
        $WSSecurityAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-WebServicesVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-WebServicesVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    #Need to do -Force and -Confirm:$false here or else an unresolvable URL will prompt for confirmation
    Set-WebServicesVirtualDirectory @PSBoundParameters -Force -Confirm:$false
    
    if($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeServicesAppPool"
        RestartAppPoolIfExists -Name MSExchangeServicesAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeServicesAppPool is manually recycled."
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,    

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,
    
        [System.Boolean]
        $OAuthAuthentication,

        [System.Boolean]
        $WindowsAuthentication,

        [System.Boolean]
        $WSSecurityAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-WebServicesVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $EwsVdir = GetWebServicesVirtualDirectory @PSBoundParameters

    if ($null -eq $EwsVdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $EwsVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $EwsVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $EwsVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CertificateAuthentication" -Type "Boolean" -ExpectedValue $CertificateAuthentication -ActualValue $EwsVdir.CertificateAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DigestAuthentication" -Type "Boolean" -ExpectedValue $DigestAuthentication -ActualValue $EwsVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "OAuthAuthentication" -Type "Boolean" -ExpectedValue $OAuthAuthentication -ActualValue $EwsVdir.OAuthAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthentication" -Type "Boolean" -ExpectedValue $WindowsAuthentication -ActualValue $EwsVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WSSecurityAuthentication" -Type "Boolean" -ExpectedValue $WSSecurityAuthentication -ActualValue $EwsVdir.WSSecurityAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalNLBBypassUrl" -Type "String" -ExpectedValue $InternalNLBBypassUrl -ActualValue $EwsVdir.InternalNLBBypassUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }
    
    #If the code made it this for all properties are in a desired state    
    return $true
}

function GetWebServicesVirtualDirectory
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,    

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,
    
        [System.Boolean]
        $OAuthAuthentication,

        [System.Boolean]
        $WindowsAuthentication,

        [System.Boolean]
        $WSSecurityAuthentication
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-WebServicesVirtualDirectory @PSBoundParameters)
}


Export-ModuleMember -Function *-TargetResource




