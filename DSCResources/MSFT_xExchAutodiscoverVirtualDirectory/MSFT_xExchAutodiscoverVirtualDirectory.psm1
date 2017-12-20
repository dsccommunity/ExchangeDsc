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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

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
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AutodiscoverVirtualDirectory' -VerbosePreference $VerbosePreference

    $autoDVdir = Get-AutodiscoverVirtualDirectoryWithCorrectParams @PSBoundParameters

    if ($null -ne $autoDVdir)
    {
        $returnValue = @{
            Identity = $Identity
            BasicAuthentication = $autoDVdir.BasicAuthentication
            DigestAuthentication = $autoDVdir.DigestAuthentication
            ExtendedProtectionFlags = [System.Array]$(ConvertTo-Array -InputObject $autoDVdir.ExtendedProtectionFlags)
            ExtendedProtectionSPNList = [System.Array]$(ConvertTo-Array -InputObject $autoDVdir.ExtendedProtectionSPNList)
            ExtendedProtectionTokenChecking = $autoDVdir.ExtendedProtectionTokenChecking
            OAuthAuthentication = $autoDVdir.OAuthAuthentication
            WindowsAuthentication = $autoDVdir.WindowsAuthentication
            WSSecurityAuthentication = $autoDVdir.WSSecurityAuthentication
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

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
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-AutodiscoverVirtualDirectory' -VerbosePreference $VerbosePreference
    
    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    #Remove Credential parameter does not exist on Set-OwaVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    #verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw "SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!"
    }

    Set-AutodiscoverVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart)
    {
        Write-Verbose "Recycling MSExchangeAutodiscoverAppPool"
        RestartAppPoolIfExists -Name MSExchangeAutodiscoverAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeAutodiscoverAppPool is manually recycled."
    }
}


function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

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
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AutodiscoverVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $autoDVdir = Get-AutodiscoverVirtualDirectoryWithCorrectParams @PSBoundParameters

    if ($null -eq $autoDVdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $autoDVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DigestAuthentication" -Type "Boolean" -ExpectedValue $DigestAuthentication -ActualValue $autoDVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionFlags" -Type "ExtendedProtection" -ExpectedValue $ExtendedProtectionFlags -ActualValue $autoDVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionSPNList" -Type "Array" -ExpectedValue $ExtendedProtectionSPNList -ActualValue $autoDVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionTokenChecking" -Type "String" -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $autoDVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "OAuthAuthentication" -Type "Boolean" -ExpectedValue $OAuthAuthentication -ActualValue $autoDVdir.OAuthAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthentication" -Type "Boolean" -ExpectedValue $WindowsAuthentication -ActualValue $autoDVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WSSecurityAuthentication" -Type "Boolean" -ExpectedValue $WSSecurityAuthentication -ActualValue $autoDVdir.WSSecurityAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    #If the code made it this far all properties are in a desired state
    return $true
}

function Get-AutodiscoverVirtualDirectoryWithCorrectParams
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

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

        [System.Boolean]
        $OAuthAuthentication,

        [System.Boolean]
        $WindowsAuthentication,

        [System.Boolean]
        $WSSecurityAuthentication
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-AutodiscoverVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
