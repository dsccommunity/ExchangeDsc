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
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('Allow', 'None', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [Parameter()]
        [System.Boolean]
        $ExternalClientsRequireSsl,

        [Parameter()]
        [System.String]
        $ExternalHostname,

        [Parameter()]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $InternalClientAuthenticationMethod,

        [Parameter()]
        [System.String]
        $InternalHostname,

        [Parameter()]
        [System.Boolean]
        $InternalClientsRequireSsl,

        [Parameter()]
        [System.Boolean]
        $SSLOffloading
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OutlookAnywhere' -Verbose:$VerbosePreference

    $RpcVdir = Get-OutlookAnywhereInternal @PSBoundParameters

    if ($null -ne $RpcVdir)
    {
        $returnValue = @{
            Identity                           = [System.String] $Identity
            ExtendedProtectionFlags            = [System.String[]] $RpcVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList          = [System.String[]] $RpcVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking    = [System.String] $RpcVdir.ExtendedProtectionTokenChecking
            ExternalClientAuthenticationMethod = [System.String] $RpcVdir.ExternalClientAuthenticationMethod
            ExternalClientsRequireSsl          = [System.Boolean] $RpcVdir.ExternalClientsRequireSsl
            ExternalHostname                   = [System.String] $RpcVdir.ExternalHostname.HostnameString
            IISAuthenticationMethods           = [System.String[]] $RpcVdir.IISAuthenticationMethods
            InternalClientAuthenticationMethod = [System.String] $RpcVdir.InternalClientAuthenticationMethod
            InternalClientsRequireSsl          = [System.Boolean] $RpcVdir.InternalClientsRequireSsl
            InternalHostname                   = [System.String] $RpcVdir.InternalHostname.HostnameString
            SSLOffloading                      = [System.Boolean] $RpcVdir.SSLOffloading
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
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('Allow', 'None', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [Parameter()]
        [System.Boolean]
        $ExternalClientsRequireSsl,

        [Parameter()]
        [System.String]
        $ExternalHostname,

        [Parameter()]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $InternalClientAuthenticationMethod,

        [Parameter()]
        [System.String]
        $InternalHostname,

        [Parameter()]
        [System.Boolean]
        $InternalClientsRequireSsl,

        [Parameter()]
        [System.Boolean]
        $SSLOffloading
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-OutlookAnywhere' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-OutlookAnywhere @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeRpcProxyAppPool and MSExchangeRpcProxyFrontEndAppPool'

        Restart-ExistingAppPool -Name MSExchangeRpcProxyAppPool
        Restart-ExistingAppPool -Name MSExchangeRpcProxyFrontEndAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeRpcProxyAppPool and MSExchangeRpcProxyFrontEndAppPool are manually recycled.'
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
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('Allow', 'None', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [Parameter()]
        [System.Boolean]
        $ExternalClientsRequireSsl,

        [Parameter()]
        [System.String]
        $ExternalHostname,

        [Parameter()]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $InternalClientAuthenticationMethod,

        [Parameter()]
        [System.String]
        $InternalHostname,

        [Parameter()]
        [System.Boolean]
        $InternalClientsRequireSsl,

        [Parameter()]
        [System.Boolean]
        $SSLOffloading
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OutlookAnywhere' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $RpcVdir = Get-OutlookAnywhereInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $RpcVdir)
    {
        Write-Error -Message 'Unable to retrieve Outlook Anywhere Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'InternalHostname' -Type 'String' -ExpectedValue $InternalHostname -ActualValue $RpcVdir.InternalHostname.HostnameString -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalHostname' -Type 'String' -ExpectedValue $ExternalHostname -ActualValue $RpcVdir.ExternalHostname.HostnameString -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalClientAuthenticationMethod' -Type 'String' -ExpectedValue $InternalClientAuthenticationMethod -ActualValue $RpcVdir.InternalClientAuthenticationMethod -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalClientAuthenticationMethod' -Type 'String' -ExpectedValue $ExternalClientAuthenticationMethod -ActualValue $RpcVdir.ExternalClientAuthenticationMethod -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExtendedProtectionTokenChecking' -Type 'String' -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $RpcVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        # ExternalClientsRequireSsl will only actually return as $true if ExternalHostname was also set
        if (![System.String]::IsNullOrEmpty($ExternalHostname) -and !(Test-ExchangeSetting -Name 'ExternalClientsRequireSsl' -Type 'Boolean' -ExpectedValue $ExternalClientsRequireSsl -ActualValue $RpcVdir.ExternalClientsRequireSsl -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'InternalClientsRequireSsl' -Type 'Boolean' -ExpectedValue $InternalClientsRequireSsl -ActualValue $RpcVdir.InternalClientsRequireSsl -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SSLOffloading' -Type 'Boolean' -ExpectedValue $SSLOffloading -ActualValue $RpcVdir.SSLOffloading -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IISAuthenticationMethods' -Type 'Array' -ExpectedValue $IISAuthenticationMethods -ActualValue $RpcVdir.IISAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExtendedProtectionFlags' -Type 'Array' -ExpectedValue $ExtendedProtectionFlags -ActualValue $RpcVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExtendedProtectionSPNList' -Type 'Array' -ExpectedValue $ExtendedProtectionSPNList -ActualValue $RpcVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    # If the code made it this far all properties are in a desired state
    return $testResults
}

function Get-OutlookAnywhereInternal
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
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('Allow', 'None', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [Parameter()]
        [System.Boolean]
        $ExternalClientsRequireSsl,

        [Parameter()]
        [System.String]
        $ExternalHostname,

        [Parameter()]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [ValidateSet('Ntlm', 'Basic', 'Negotiate')]
        [System.String]
        $InternalClientAuthenticationMethod,

        [Parameter()]
        [System.String]
        $InternalHostname,

        [Parameter()]
        [System.Boolean]
        $InternalClientsRequireSsl,

        [Parameter()]
        [System.Boolean]
        $SSLOffloading
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-OutlookAnywhere @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
