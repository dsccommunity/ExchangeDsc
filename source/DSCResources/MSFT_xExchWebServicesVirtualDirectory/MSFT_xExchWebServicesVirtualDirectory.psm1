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

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $CertificateAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalNLBBypassUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $MRSProxyEnabled,

        [Parameter()]
        [System.Boolean]
        $OAuthAuthentication,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSecurityAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-WebServicesVirtualDirectory' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $EwsVdir = Get-WebServicesVirtualDirectory @PSBoundParameters

    if ($null -ne $EwsVdir)
    {
        $returnValue = @{
            Identity                        = [System.String] $Identity
            BasicAuthentication             = [System.Boolean] $EwsVdir.BasicAuthentication
            CertificateAuthentication       = [System.Boolean] $EwsVdir.CertificateAuthentication
            DigestAuthentication            = [System.Boolean] $EwsVdir.DigestAuthentication
            ExtendedProtectionFlags         = [System.String[]] $EwsVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList       = [System.String[]] $EwsVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking = [System.String] $EwsVdir.ExtendedProtectionTokenChecking
            ExternalUrl                     = [System.String] $EwsVdir.InternalUrl.AbsoluteUri
            GzipLevel                       = [System.String] $EwsVdir.GzipLevel
            InternalNLBBypassUrl            = [System.String] $EwsVdir.InternalNLBBypassUrl
            InternalUrl                     = [System.String] $EwsVdir.InternalUrl.AbsoluteUri
            MRSProxyEnabled                 = [System.Boolean] $EwsVdir.MRSProxyEnabled
            OAuthAuthentication             = [System.Boolean] $EwsVdir.OAuthAuthentication
            WSSecurityAuthentication        = [System.Boolean] $EwsVdir.WSSecurityAuthentication
            WindowsAuthentication           = [System.Boolean] $EwsVdir.WindowsAuthentication
        }
    }

    $returnValue
}

function Set-TargetResource
{
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

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $CertificateAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalNLBBypassUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $MRSProxyEnabled,

        [Parameter()]
        [System.Boolean]
        $OAuthAuthentication,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSecurityAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-WebServicesVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    # Remove Credential and AllowServiceRestart because those parameters do not exist on Set-WebServicesVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # Verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw 'SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
    }

    # Need to do -Force and -Confirm:$false here or else an unresolvable URL will prompt for confirmation
    Set-WebServicesVirtualDirectory @PSBoundParameters -Force -Confirm:$false

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeServicesAppPool'
        Restart-ExistingAppPool -Name MSExchangeServicesAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeServicesAppPool is manually recycled.'
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

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $CertificateAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalNLBBypassUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $MRSProxyEnabled,

        [Parameter()]
        [System.Boolean]
        $OAuthAuthentication,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSecurityAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-WebServicesVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $EwsVdir = Get-WebServicesVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $EwsVdir)
    {
        Write-Error -Message 'Unable to retrieve ActiveSync Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $EwsVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'CertificateAuthentication' -Type 'Boolean' -ExpectedValue $CertificateAuthentication -ActualValue $EwsVdir.CertificateAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $EwsVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionFlags' -Type 'ExtendedProtection' -ExpectedValue $ExtendedProtectionFlags -ActualValue $EwsVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionSPNList' -Type 'Array' -ExpectedValue $ExtendedProtectionSPNList -ActualValue $EwsVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionTokenChecking' -Type 'String' -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $EwsVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $EwsVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'GzipLevel' -Type 'String' -ExpectedValue $GzipLevel -ActualValue $EwsVdir.GzipLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalNLBBypassUrl' -Type 'String' -ExpectedValue $InternalNLBBypassUrl -ActualValue $EwsVdir.InternalNLBBypassUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $EwsVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MRSProxyEnabled' -Type 'Boolean' -ExpectedValue $MRSProxyEnabled -ActualValue $EwsVdir.MRSProxyEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'OAuthAuthentication' -Type 'Boolean' -ExpectedValue $OAuthAuthentication -ActualValue $EwsVdir.OAuthAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $EwsVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WSSecurityAuthentication' -Type 'Boolean' -ExpectedValue $WSSecurityAuthentication -ActualValue $EwsVdir.WSSecurityAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function Get-WebServicesVirtualDirectoryInternal
{
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

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $CertificateAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalNLBBypassUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $MRSProxyEnabled,

        [Parameter()]
        [System.Boolean]
        $OAuthAuthentication,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [System.Boolean]
        $WSSecurityAuthentication
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-WebServicesVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
