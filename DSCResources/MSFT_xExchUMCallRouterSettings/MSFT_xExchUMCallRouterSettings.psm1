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

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','TLS','Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013','2016'

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMCallRouterSettings' -Verbose:$VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Server','DomainController'

    $umService = Get-UMCallRouterSettings @PSBoundParameters

    if ($null -ne $umService)
    {
        $returnValue = @{
            Server        = [System.String] $Server
            UMStartupMode = [System.String] $umService.UMStartupMode
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

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','TLS','Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013','2016'

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad '*UMCallRouterSettings' -Verbose:$VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential'

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

        [Parameter(Mandatory = $true)]
        [ValidateSet('TCP','TLS','Dual')]
        [System.String]
        $UMStartupMode,

        [Parameter()]
        [System.String]
        $DomainController
    )

    LogFunctionEntry -Parameters @{'Server' = $Server} -Verbose:$VerbosePreference

    Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName 'xExchUMCallRouterSettings' -SupportedVersions '2013','2016'

    $umService = Get-TargetResource @PSBoundParameters

    $testResults = $true

    if ($null -eq $umService)
    {
        Write-Error -Message 'Unable to retrieve UM Call Router settings for server'

        $testResults = $false
    }
    else
    {
        if (!(VerifySetting -Name 'UMStartupMode' -Type 'String' -ExpectedValue $UMStartupMode -ActualValue $umService.UMStartupMode -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
