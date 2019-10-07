function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [ValidateSet('IPv4Only','IPv6Only','Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.Int32]
        $SipTcpListeningPort,

        [Parameter()]
        [System.Int32]
        $SipTlsListeningPort,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013', '2016'

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMCallRouterSettings' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server', 'DomainController'

    $umService = Get-UMCallRouterSettings @PSBoundParameters

    if ($null -ne $umService)
    {
        $returnValue = @{
            Server                      = [System.String] $Server
            UMStartupMode               = [System.String] $umService.UMStartupMode
            DialPlans                   = [System.String[]] $umService.DialPlans
            IPAddressFamily             = [System.String] $umService.IPAddressFamily
            IPAddressFamilyConfigurable = [System.Boolean] $umService.IPAddressFamilyConfigurable
            MaxCallsAllowed             = [System.Int32] $umService.MaxCallsAllowed
            SipTcpListeningPort         = [System.Int32] $umService.SipTcpListeningPort
            SipTlsListeningPort         = [System.Int32] $umService.SipTlsListeningPort
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
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [ValidateSet('IPv4Only','IPv6Only','Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.Int32]
        $SipTcpListeningPort,

        [Parameter()]
        [System.Int32]
        $SipTlsListeningPort,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013', '2016'

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMCallRouterSettings' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential'

    Set-UMCallRouterSettings @PSBoundParameters
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
        $Server,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String[]]
        $DialPlans,

        [Parameter()]
        [ValidateSet('IPv4Only','IPv6Only','Any')]
        [System.String]
        $IPAddressFamily,

        [Parameter()]
        [System.Boolean]
        $IPAddressFamilyConfigurable,

        [Parameter()]
        [System.Int32]
        $MaxCallsAllowed,

        [Parameter()]
        [System.Int32]
        $SipTcpListeningPort,

        [Parameter()]
        [System.Int32]
        $SipTlsListeningPort,

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP', 'TLS', 'Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{
        'Server' = $Server
    } -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013', '2016'

    $umService = Get-TargetResource @PSBoundParameters

    $testResults = $true

    if ($null -eq $umService)
    {
        Write-Error -Message 'Unable to retrieve UM Call Router settings for server'

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

        if (!(Test-ExchangeSetting -Name 'IPAddressFamily' -Type 'String' -ExpectedValue $IPAddressFamily -ActualValue $umService.IPAddressFamily -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IPAddressFamilyConfigurable' -Type 'Boolean' -ExpectedValue $IPAddressFamilyConfigurable -ActualValue $umService.IPAddressFamilyConfigurable -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxCallsAllowed' -Type 'Int' -ExpectedValue $MaxCallsAllowed -ActualValue $umService.MaxCallsAllowed -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SipTcpListeningPort' -Type 'Int' -ExpectedValue $SipTcpListeningPort -ActualValue $umService.SipTcpListeningPort -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SipTlsListeningPort' -Type 'Int' -ExpectedValue $SipTlsListeningPort -ActualValue $umService.SipTlsListeningPort -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
