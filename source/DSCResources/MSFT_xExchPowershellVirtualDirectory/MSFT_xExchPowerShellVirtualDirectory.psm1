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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $RequireSSL,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-PowerShellVirtualDirectory' -Verbose:$VerbosePreference

    $vdir = Get-PowerShellVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $vdir)
    {
        $returnValue = @{
            Identity                  = [System.String] $Identity
            BasicAuthentication       = [System.Boolean] $vdir.BasicAuthentication
            CertificateAuthentication = [System.Boolean] $vdir.CertificateAuthentication
            ExternalUrl               = [System.String] $vdir.ExternalUrl.AbsoluteUri
            InternalUrl               = [System.String] $vdir.InternalUrl.AbsoluteUri
            RequireSSL                = [System.Boolean] $vdir.RequireSSL
            WindowsAuthentication     = [System.Boolean] $vdir.WindowsAuthentication
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $RequireSSL,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-PowerShellVirtualDirectory' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-PowerShellVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        # Remove existing PS sessions, as we're about to break them
        Remove-RemoteExchangeSession -Verbose:$VerbosePreference

        Write-Verbose -Message 'Recycling MSExchangePowerShellAppPool and MSExchangePowerShellFrontEndAppPool'

        Restart-ExistingAppPool -Name MSExchangePowerShellAppPool
        Restart-ExistingAppPool -Name MSExchangePowerShellFrontEndAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangePowerShellAppPool and MSExchangePowerShellFrontEndAppPool are manually recycled.'
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $RequireSSL,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-PowerShellVirtualDirectory' -Verbose:$VerbosePreference

    $vdir = Get-PowerShellVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $vdir)
    {
        Write-Error -Message 'Unable to retrieve PowerShell Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $vdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'CertificateAuthentication' -Type 'Boolean' -ExpectedValue $CertificateAuthentication -ActualValue $vdir.CertificateAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

        if (!(Test-ExchangeSetting -Name 'RequireSSL' -Type 'Boolean' -ExpectedValue $RequireSSL -ActualValue $vdir.RequireSSL -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $vdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function Get-PowerShellVirtualDirectoryInternal
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $RequireSSL,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-PowerShellVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
