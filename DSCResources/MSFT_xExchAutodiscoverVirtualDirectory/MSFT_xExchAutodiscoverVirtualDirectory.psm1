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
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AutodiscoverVirtualDirectory' -Verbose:$VerbosePreference

    $autoDVdir = Get-AutodiscoverVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $autoDVdir)
    {
        $returnValue = @{
            Identity                        = [System.String] $Identity
            BasicAuthentication             = [System.Boolean] $autoDVdir.BasicAuthentication
            DigestAuthentication            = [System.Boolean] $autoDVdir.DigestAuthentication
            ExtendedProtectionFlags         = [System.String[]] $autoDVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList       = [System.String[]] $autoDVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking = [System.String] $autoDVdir.ExtendedProtectionTokenChecking
            OAuthAuthentication             = [System.Boolean] $autoDVdir.OAuthAuthentication
            WindowsAuthentication           = [System.Boolean] $autoDVdir.WindowsAuthentication
            WSSecurityAuthentication        = [System.Boolean] $autoDVdir.WSSecurityAuthentication
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
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-AutodiscoverVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    # Remove Credential parameter does not exist on Set-OwaVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # Verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw 'SPN list contains DotlessSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
    }

    Set-AutodiscoverVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart)
    {
        Write-Verbose -Message 'Recycling MSExchangeAutodiscoverAppPool'
        Restart-ExistingAppPool -Name MSExchangeAutodiscoverAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeAutodiscoverAppPool is manually recycled.'
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
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AutodiscoverVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $autoDVdir = Get-AutodiscoverVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $autoDVdir)
    {
        Write-Error -Message 'Unable to retrieve AutoDiscover Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $autoDVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $autoDVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionFlags' -Type 'ExtendedProtection' -ExpectedValue $ExtendedProtectionFlags -ActualValue $autoDVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionSPNList' -Type 'Array' -ExpectedValue $ExtendedProtectionSPNList -ActualValue $autoDVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionTokenChecking' -Type 'String' -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $autoDVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'OAuthAuthentication' -Type 'Boolean' -ExpectedValue $OAuthAuthentication -ActualValue $autoDVdir.OAuthAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $autoDVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WSSecurityAuthentication' -Type 'Boolean' -ExpectedValue $WSSecurityAuthentication -ActualValue $autoDVdir.WSSecurityAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function Get-AutodiscoverVirtualDirectoryInternal
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

    return (Get-AutodiscoverVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
