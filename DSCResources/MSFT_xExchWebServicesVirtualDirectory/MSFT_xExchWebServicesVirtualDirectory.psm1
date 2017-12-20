[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

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

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,    

        [ValidateSet("Off", "Low", "High", "Error")]
        [System.String]
        $GzipLevel,

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $MRSProxyEnabled,

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
            Identity = $Identity
            BasicAuthentication = $EwsVdir.BasicAuthentication
            CertificateAuthentication = $EwsVdir.CertificateAuthentication
            DigestAuthentication = $EwsVdir.DigestAuthentication
            ExtendedProtectionFlags = [System.Array]$(ConvertTo-Array -InputObject $EwsVdir.ExtendedProtectionFlags)
            ExtendedProtectionSPNList = [System.Array]$(ConvertTo-Array -InputObject $EwsVdir.ExtendedProtectionSPNList)
            ExtendedProtectionTokenChecking = $EwsVdir.ExtendedProtectionTokenChecking
            ExternalUrl = $EwsVdir.InternalUrl.AbsoluteUri
            GzipLevel = $EwsVdir.GzipLevel
            InternalNLBBypassUrl = $EwsVdir.InternalNLBBypassUrl
            InternalUrl = $EwsVdir.InternalUrl.AbsoluteUri
            MRSProxyEnabled = $EwsVdir.MRSProxyEnabled
            OAuthAuthentication = $EwsVdir.OAuthAuthentication
            WSSecurityAuthentication = $EwsVdir.WSSecurityAuthentication
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

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,    

        [ValidateSet("Off", "Low", "High", "Error")]
        [System.String]
        $GzipLevel,

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $MRSProxyEnabled,

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

    #verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw "SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!"
    }

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

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,    

        [ValidateSet("Off", "Low", "High", "Error")]
        [System.String]
        $GzipLevel,

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $MRSProxyEnabled,

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

        if (-not (VerifySetting -Name "ExtendedProtectionFlags" -Type "ExtendedProtection" -ExpectedValue $ExtendedProtectionFlags -ActualValue $EwsVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionSPNList" -Type "Array" -ExpectedValue $ExtendedProtectionSPNList -ActualValue $EwsVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionTokenChecking" -Type "String" -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $EwsVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $EwsVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "GzipLevel" -Type "Boolean" -ExpectedValue $GzipLevel -ActualValue $EwsVdir.GzipLevel -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalNLBBypassUrl" -Type "String" -ExpectedValue $InternalNLBBypassUrl -ActualValue $EwsVdir.InternalNLBBypassUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $EwsVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MRSProxyEnabled" -Type "Boolean" -ExpectedValue $MRSProxyEnabled -ActualValue $EwsVdir.MRSProxyEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
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

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,    

        [ValidateSet("Off", "Low", "High", "Error")]
        [System.String]
        $GzipLevel,

        [System.String]
        $InternalNLBBypassUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $MRSProxyEnabled,

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




