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
        $AdfsAuthentication,

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
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -Verbose:$VerbosePreference

    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    if ($null -ne $EcpVdir)
    {
        $returnValue = @{
            Identity                      = [System.String] $Identity
            AdfsAuthentication            = [System.Boolean] $EcpVdir.AdfsAuthentication
            BasicAuthentication           = [System.Boolean] $EcpVdir.BasicAuthentication
            DigestAuthentication          = [System.Boolean] $EcpVdir.DigestAuthentication
            ExternalAuthenticationMethods = [System.String[]] $EcpVdir.ExternalAuthenticationMethods
            ExternalUrl                   = [System.String] $EcpVdir.ExternalUrl
            FormsAuthentication           = [System.Boolean] $EcpVdir.FormsAuthentication
            InternalUrl                   = [System.String] $EcpVdir.InternalUrl
            WindowsAuthentication         = [System.Boolean] $EcpVdir.WindowsAuthentication
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
        $AdfsAuthentication,

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
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-EcpVirtualDirectory' -Verbose:$VerbosePreference

    #Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-EcpVirtualDirectory @PSBoundParameters

    If($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeECPAppPool'

        Restart-ExistingAppPool -Name MSExchangeECPAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeECPAppPool is manually recycled.'
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
        $AdfsAuthentication,

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
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -Verbose:$VerbosePreference

    #Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    $testResults = $true

    if ($null -eq $EcpVdir)
    {
        Write-Error -Message 'Unable to retrieve ECP Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $EcpVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $EcpVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'FormsAuthentication' -Type 'Boolean' -ExpectedValue $FormsAuthentication -ActualValue $EcpVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $EcpVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $EcpVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $EcpVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AdfsAuthentication' -Type 'Boolean' -ExpectedValue $AdfsAuthentication -ActualValue $EcpVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $EcpVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function GetEcpVirtualDirectory
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
        $AdfsAuthentication,

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
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity','DomainController'

    return (Get-EcpVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
