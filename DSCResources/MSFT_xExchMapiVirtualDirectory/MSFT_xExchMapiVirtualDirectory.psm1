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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MapiVirtualDirectory' -Verbose:$VerbosePreference

    $vdir = Get-MapiVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $vdir)
    {
        $returnValue = @{
            Identity                 = [System.String] $Identity
            IISAuthenticationMethods = [System.String[]] $vdir.IISAuthenticationMethods
            ExternalUrl              = [System.String] $vdir.ExternalUrl.AbsoluteUri
            InternalUrl              = [System.String] $vdir.InternalUrl.AbsoluteUri
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-MapiVirtualDirectory' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential", "AllowServiceRestart"

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MapiVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool'

        Restart-ExistingAppPool -Name MSExchangeMapiFrontEndAppPool
        Restart-ExistingAppPool -Name MSExchangeMapiMailboxAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool are manually recycled."
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MapiVirtualDirectory' -Verbose:$VerbosePreference

    $vdir = Get-MapiVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $vdir)
    {
        Write-Error -Message 'Unable to retrieve MAPI Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'IISAuthenticationMethods' -Type 'Array' -ExpectedValue $IISAuthenticationMethods -ActualValue $vdir.IISAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $vdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $vdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function Get-MapiVirtualDirectoryInternal
{
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity", "DomainController"

    return (Get-MapiVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
