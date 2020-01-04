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

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [System.String[]]
        $GrammarGenerationSchedule,

        [Parameter()]
        [ValidateSet('IPv4Only', 'IPv6Only', 'Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.String]
        $SIPAccessService,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMService' -SupportedVersions '2013', '2016'

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMService' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $umService = Get-UMService @PSBoundParameters

    if ($null -ne $umService)
    {
        $returnValue = @{
            Identity                    = [System.String] $Identity
            UMStartupMode               = [System.String] $umService.UMStartupMode
            DialPlans                   = [System.String[]] $umService.DialPlans
            GrammarGenerationSchedule   = [System.String[]] $umService.GrammarGenerationSchedule
            IPAddressFamily             = [System.String] $umService.IPAddressFamily
            IPAddressFamilyConfigurable = [System.Boolean] $umService.IPAddressFamilyConfigurable
            IrmLogEnabled               = [System.Boolean] $umService.IrmLogEnabled
            IrmLogMaxAge                = [System.String] $umService.IrmLogMaxAge
            IrmLogMaxDirectorySize      = [System.String] $umService.IrmLogMaxDirectorySize
            IrmLogMaxFileSize           = [System.String] $umService.IrmLogMaxFileSize
            IrmLogPath                  = [System.String] $umService.IrmLogPath
            MaxCallsAllowed             = [System.Int32] $umService.MaxCallsAllowed
            SIPAccessService            = [System.String] $umService.SIPAccessService
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [System.String[]]
        $GrammarGenerationSchedule,

        [Parameter()]
        [ValidateSet('IPv4Only', 'IPv6Only', 'Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.String]
        $SIPAccessService,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMService' -SupportedVersions '2013', '2016'

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMService' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential'

    Set-UMService @PSBoundParameters
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [System.String[]]
        $GrammarGenerationSchedule,

        [Parameter()]
        [ValidateSet('IPv4Only', 'IPv6Only', 'Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Boolean]
        $IrmLogEnabled,

        [Parameter()]
        [System.String]
        $IrmLogMaxAge,

        [Parameter()]
        [System.String]
        $IrmLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $IrmLogMaxFileSize,

        [Parameter()]
        [System.String]
        $IrmLogPath,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.String]
        $SIPAccessService,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMService' -SupportedVersions '2013', '2016'

    $umService = Get-TargetResource @PSBoundParameters

    $testResults = $true

    if ($null -eq $umService)
    {
        Write-Error -Message 'Unable to retrieve UM settings for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'UMStartupMode' -Type 'String' -ExpectedValue $UMStartupMode -ActualValue $umService.UMStartupMode -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DialPlans' -Type 'Array' -ExpectedValue $DialPlans -ActualValue $umService.DialPlans -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'GrammarGenerationSchedule' -Type 'Array' -ExpectedValue $GrammarGenerationSchedule -ActualValue $umService.GrammarGenerationSchedule -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IPAddressFamily' -Type 'String' -ExpectedValue $IPAddressFamily -ActualValue $umService.IPAddressFamily -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IPAddressFamilyConfigurable' -Type 'Boolean' -ExpectedValue $IPAddressFamilyConfigurable -ActualValue $umService.IPAddressFamilyConfigurable -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogEnabled' -Type 'Boolean' -ExpectedValue $IrmLogEnabled -ActualValue $umService.IrmLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxAge' -Type 'Timespan' -ExpectedValue $IrmLogMaxAge -ActualValue $umService.IrmLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxDirectorySize' -Type 'ByteQuantifiedSize' -ExpectedValue $IrmLogMaxDirectorySize -ActualValue $umService.IrmLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogMaxFileSize' -Type 'ByteQuantifiedSize' -ExpectedValue $IrmLogMaxFileSize -ActualValue $umService.IrmLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IrmLogPath' -Type 'String' -ExpectedValue $IrmLogPath -ActualValue $umService.IrmLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxCallsAllowed' -Type 'Int' -ExpectedValue $MaxCallsAllowed -ActualValue $umService.MaxCallsAllowed -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SIPAccessService' -Type 'String' -ExpectedValue $SIPAccessService -ActualValue $umService.SIPAccessService -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
