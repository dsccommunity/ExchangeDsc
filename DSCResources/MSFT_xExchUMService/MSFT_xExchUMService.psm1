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
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMService' -SupportedVersions '2013', '2016'

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMService' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $umService = Get-UMService @PSBoundParameters

    if ($null -ne $umService)
    {
        $returnValue = @{
            Identity      = [System.String] $Identity
            UMStartupMode = [System.String] $umService.UMStartupMode
            DialPlans     = [System.String[]] $umService.DialPlans
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
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

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
        [System.String]
        $DomainController
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

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
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
