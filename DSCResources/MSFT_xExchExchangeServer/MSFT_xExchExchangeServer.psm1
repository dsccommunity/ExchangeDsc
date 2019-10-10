<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the GUID, distinguished name (DN), or
        name of the server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the Information Store service after
        licensing the server. Defaults to $false.

    .PARAMETER CustomerFeedbackEnabled
        The CustomerFeedbackEnabled parameter specifies whether the Exchange
        server is enrolled in the Microsoft Customer Experience Improvement
        Program (CEIP). The CEIP collects anonymous information about how you
        use Exchange and problems that you might encounter. If you decide not
        to participate in the CEIP, the servers are opted-out automatically.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ErrorReportingEnabled
        The ErrorReportingEnabled parameter specifies whether error reporting
        is enabled.

    .PARAMETER InternetWebProxy
        The InternetWebProxy parameter specifies the web proxy server that the
        Exchange server uses to reach the internet. A valid value for this
        parameter is the URL of the web proxy server.

    .PARAMETER InternetWebProxyBypassList
        The InternetWebProxyBypassList parameter specifies a list of servers
        that bypass the web proxy server specified by the InternetWebProxy
        parameter. You identify the servers by their FQDN (for example,
        server01.contoso.com).

    .PARAMETER MonitoringGroup
        The MonitoringGroup parameter specifies how to add your Exchange
        servers to monitoring groups. You can add your servers to an existing
        group or create a monitoring group based on location or deployment, or
        to partition monitoring responsibility among your servers.

    .PARAMETER ProductKey
        The ProductKey parameter specifies the server product key.

    .PARAMETER StaticConfigDomainController
        The StaticConfigDomainController parameter specifies whether to
        configure a domain controller to be used by the server via Directory
        Service Access (DSAccess).

    .PARAMETER StaticDomainControllers
        The StaticDomainControllers parameter specifies whether to configure a
        list of domain controllers to be used by the server via DSAccess.

    .PARAMETER StaticExcludedDomainControllers
        The StaticExcludedDomainControllers parameter specifies whether to
        exclude a list of domain controllers from being used by the server.

    .PARAMETER StaticGlobalCatalogs
        The StaticGlobalCatalogs parameter specifies whether to configure a
        list of global catalogs to be used by the server via DSAccess.

    .PARAMETER WorkloadManagementPolicy
        The *-ResourcePolicy, *-WorkloadManagementPolicy and *-WorkloadPolicy
        system workload management cmdlets have been deprecated. System
        workload management settings should be customized only under the
        direction of Microsoft Customer Service and Support.
#>
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
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String[]]
        $InternetWebProxyBypassList,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $StaticConfigDomainController,

        [Parameter()]
        [System.String[]]
        $StaticDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticExcludedDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticGlobalCatalogs,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $PSBoundParameters

    $server = Get-ExchangeServerInternal @PSBoundParameters

    if ($null -ne $server)
    {
        # There's no way to read the product key that was sent in, so just mark it is "Licensed" if it is
        if ($server.IsExchangeTrialEdition -eq $false)
        {
            $ProductKey = 'Licensed'
        }
        else
        {
            $ProductKey = ''
        }

        # Deal with array parameters that could be null
        if ($null -ne $server.InternetWebProxyBypassList)
        {
            $InternetWebProxyBypassList = $server.InternetWebProxyBypassList
        }
        else
        {
            $InternetWebProxyBypassList = @()
        }

        if ($server.StaticDomainControllers.Count -gt 0)
        {
            $StaticDomainControllers = $server.StaticDomainControllers
        }
        else
        {
            $StaticDomainControllers = @()
        }

        if ($server.StaticExcludedDomainControllers.Count -gt 0)
        {
            $StaticExcludedDomainControllers = $server.StaticExcludedDomainControllers
        }
        else
        {
            $StaticExcludedDomainControllers = @()
        }

        if ($server.StaticGlobalCatalogs.Count -gt 0)
        {
            $StaticGlobalCatalogs = $server.StaticGlobalCatalogs
        }
        else
        {
            $StaticGlobalCatalogs = @()
        }

        $returnValue = @{
            Identity                        = [System.String] $Identity
            CustomerFeedbackEnabled         = [System.Boolean] $server.CustomerFeedbackEnabled
            ErrorReportingEnabled           = [System.Boolean] $server.ErrorReportingEnabled
            InternetWebProxy                = [System.String] $server.InternetWebProxy.AbsoluteUri
            InternetWebProxyBypassList      = [System.String[]] $InternetWebProxyBypassList
            MonitoringGroup                 = [System.String] $server.MonitoringGroup
            ProductKey                      = [System.String] $ProductKey
            StaticConfigDomainController    = [System.String] $server.StaticConfigDomainController
            StaticDomainControllers         = [System.String[]] $StaticDomainControllers
            StaticExcludedDomainControllers = [System.String[]] $StaticExcludedDomainControllers
            StaticGlobalCatalogs            = [System.String[]] $StaticGlobalCatalogs
            WorkloadManagementPolicy        = [System.String] $server.WorkloadManagementPolicy
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the GUID, distinguished name (DN), or
        name of the server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the Information Store service after
        licensing the server. Defaults to $false.

    .PARAMETER CustomerFeedbackEnabled
        The CustomerFeedbackEnabled parameter specifies whether the Exchange
        server is enrolled in the Microsoft Customer Experience Improvement
        Program (CEIP). The CEIP collects anonymous information about how you
        use Exchange and problems that you might encounter. If you decide not
        to participate in the CEIP, the servers are opted-out automatically.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ErrorReportingEnabled
        The ErrorReportingEnabled parameter specifies whether error reporting
        is enabled.

    .PARAMETER InternetWebProxy
        The InternetWebProxy parameter specifies the web proxy server that the
        Exchange server uses to reach the internet. A valid value for this
        parameter is the URL of the web proxy server.

    .PARAMETER InternetWebProxyBypassList
        The InternetWebProxyBypassList parameter specifies a list of servers
        that bypass the web proxy server specified by the InternetWebProxy
        parameter. You identify the servers by their FQDN (for example,
        server01.contoso.com).

    .PARAMETER MonitoringGroup
        The MonitoringGroup parameter specifies how to add your Exchange
        servers to monitoring groups. You can add your servers to an existing
        group or create a monitoring group based on location or deployment, or
        to partition monitoring responsibility among your servers.

    .PARAMETER ProductKey
        The ProductKey parameter specifies the server product key.

    .PARAMETER StaticConfigDomainController
        The StaticConfigDomainController parameter specifies whether to
        configure a domain controller to be used by the server via Directory
        Service Access (DSAccess).

    .PARAMETER StaticDomainControllers
        The StaticDomainControllers parameter specifies whether to configure a
        list of domain controllers to be used by the server via DSAccess.

    .PARAMETER StaticExcludedDomainControllers
        The StaticExcludedDomainControllers parameter specifies whether to
        exclude a list of domain controllers from being used by the server.

    .PARAMETER StaticGlobalCatalogs
        The StaticGlobalCatalogs parameter specifies whether to configure a
        list of global catalogs to be used by the server via DSAccess.

    .PARAMETER WorkloadManagementPolicy
        The *-ResourcePolicy, *-WorkloadManagementPolicy and *-WorkloadPolicy
        system workload management cmdlets have been deprecated. System
        workload management settings should be customized only under the
        direction of Microsoft Customer Service and Support.
#>
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
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String[]]
        $InternetWebProxyBypassList,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $StaticConfigDomainController,

        [Parameter()]
        [System.String[]]
        $StaticDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticExcludedDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticGlobalCatalogs,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $PSBoundParameters

    # Check existing config first to see if we are currently licensing a server
    $server = Get-ExchangeServerInternal @PSBoundParameters

    $needRestart = $false

    if ($PSBoundParameters.ContainsKey('ProductKey') -and !([System.String]::IsNullOrEmpty($ProductKey)) -and $null -ne $server -and $server.IsExchangeTrialEdition -eq $true)
    {
        $needRestart = $true
    }

    # Setup params for next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-ExchangeServer @PSBoundParameters -Confirm:$false

    # Restart service if needed
    if ($needRestart)
    {
        if ($AllowServiceRestart -eq $true)
        {
            Write-Verbose -Message 'Restarting Information Store'

            Restart-Service MSExchangeIS
        }
        else
        {
            Write-Warning -Message 'The configuration will not take effect until MSExchangeIS is manually restarted.'
        }
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The Identity parameter specifies the GUID, distinguished name (DN), or
        name of the server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the Information Store service after
        licensing the server. Defaults to $false.

    .PARAMETER CustomerFeedbackEnabled
        The CustomerFeedbackEnabled parameter specifies whether the Exchange
        server is enrolled in the Microsoft Customer Experience Improvement
        Program (CEIP). The CEIP collects anonymous information about how you
        use Exchange and problems that you might encounter. If you decide not
        to participate in the CEIP, the servers are opted-out automatically.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ErrorReportingEnabled
        The ErrorReportingEnabled parameter specifies whether error reporting
        is enabled.

    .PARAMETER InternetWebProxy
        The InternetWebProxy parameter specifies the web proxy server that the
        Exchange server uses to reach the internet. A valid value for this
        parameter is the URL of the web proxy server.

    .PARAMETER InternetWebProxyBypassList
        The InternetWebProxyBypassList parameter specifies a list of servers
        that bypass the web proxy server specified by the InternetWebProxy
        parameter. You identify the servers by their FQDN (for example,
        server01.contoso.com).

    .PARAMETER MonitoringGroup
        The MonitoringGroup parameter specifies how to add your Exchange
        servers to monitoring groups. You can add your servers to an existing
        group or create a monitoring group based on location or deployment, or
        to partition monitoring responsibility among your servers.

    .PARAMETER ProductKey
        The ProductKey parameter specifies the server product key.

    .PARAMETER StaticConfigDomainController
        The StaticConfigDomainController parameter specifies whether to
        configure a domain controller to be used by the server via Directory
        Service Access (DSAccess).

    .PARAMETER StaticDomainControllers
        The StaticDomainControllers parameter specifies whether to configure a
        list of domain controllers to be used by the server via DSAccess.

    .PARAMETER StaticExcludedDomainControllers
        The StaticExcludedDomainControllers parameter specifies whether to
        exclude a list of domain controllers from being used by the server.

    .PARAMETER StaticGlobalCatalogs
        The StaticGlobalCatalogs parameter specifies whether to configure a
        list of global catalogs to be used by the server via DSAccess.

    .PARAMETER WorkloadManagementPolicy
        The *-ResourcePolicy, *-WorkloadManagementPolicy and *-WorkloadPolicy
        system workload management cmdlets have been deprecated. System
        workload management settings should be customized only under the
        direction of Microsoft Customer Service and Support.
#>
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
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String[]]
        $InternetWebProxyBypassList,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $StaticConfigDomainController,

        [Parameter()]
        [System.String[]]
        $StaticDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticExcludedDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticGlobalCatalogs,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $PSBoundParameters

    $server = Get-ExchangeServerInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $server)
    {
        # Couldn't find the server, which is bad
        Write-Error -Message 'Unable to retrieve Exchange Server settings for server'

        $testResults = $false
    }
    else
    {
        # Validate server params
        if (!(Test-ExchangeSetting -Name 'CustomerFeedbackEnabled' -Type 'Boolean' -ExpectedValue $CustomerFeedbackEnabled -ActualValue $server.CustomerFeedbackEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ErrorReportingEnabled' -Type 'Boolean' -ExpectedValue $ErrorReportingEnabled -ActualValue $server.ErrorReportingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if ($PSBoundParameters.ContainsKey('InternetWebProxy') -and !(Compare-StringToString -String1 $InternetWebProxy -String2 $server.InternetWebProxy.AbsoluteUri -IgnoreCase))
        {
            # The AbsolueUri that comes back from the server can have a trailing slash. Check if the AbsoluteUri at least contains the requested Uri
            if (($null -ne $server.InternetWebProxy -and $null -ne $server.InternetWebProxy.AbsoluteUri -and $server.InternetWebProxy.AbsoluteUri.Contains($InternetWebProxy)) -eq $false)
            {
                Write-InvalidSettingVerbose -SettingName 'InternetWebProxy' -ExpectedValue $InternetWebProxy -ActualValue $server.InternetWebProxy -Verbose:$VerbosePreference
                $testResults = $false
            }
        }

        if (!(Test-ExchangeSetting -Name 'InternetWebProxyBypassList' -Type 'Array' -ExpectedValue $InternetWebProxyBypassList -ActualValue $server.InternetWebProxyBypassList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MonitoringGroup' -Type 'String' -ExpectedValue $MonitoringGroup -ActualValue $server.MonitoringGroup -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if ($PSBoundParameters.ContainsKey('ProductKey') -and !([System.String]::IsNullOrEmpty($ProductKey)) -and $server.IsExchangeTrialEdition -eq $true)
        {
            Write-InvalidSettingVerbose -SettingName 'ProductKey' -ExpectedValue $ProductKey -ActualValue $server.ProductKey -Verbose:$VerbosePreference
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'StaticConfigDomainController' -Type 'String' -ExpectedValue $StaticConfigDomainController -ActualValue $server.StaticConfigDomainController -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'StaticDomainControllers' -Type 'Array' -ExpectedValue $StaticDomainControllers -ActualValue $server.StaticDomainControllers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'StaticExcludedDomainControllers' -Type 'Array' -ExpectedValue $StaticExcludedDomainControllers -ActualValue $server.StaticExcludedDomainControllers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'StaticGlobalCatalogs' -Type 'Array' -ExpectedValue $StaticGlobalCatalogs -ActualValue $server.StaticGlobalCatalogs -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WorkloadManagementPolicy' -Type 'String' -ExpectedValue $WorkloadManagementPolicy -ActualValue $server.WorkloadManagementPolicy -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-ExchangeServer. Runs
        Get-ExchangeServer, only specifying Identity, and
        optionally DomainController, and returns the results.

    .PARAMETER Identity
        The Identity parameter specifies the GUID, distinguished name (DN), or
        name of the server.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart the Information Store service after
        licensing the server. Defaults to $false.

    .PARAMETER CustomerFeedbackEnabled
        The CustomerFeedbackEnabled parameter specifies whether the Exchange
        server is enrolled in the Microsoft Customer Experience Improvement
        Program (CEIP). The CEIP collects anonymous information about how you
        use Exchange and problems that you might encounter. If you decide not
        to participate in the CEIP, the servers are opted-out automatically.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ErrorReportingEnabled
        The ErrorReportingEnabled parameter specifies whether error reporting
        is enabled.

    .PARAMETER InternetWebProxy
        The InternetWebProxy parameter specifies the web proxy server that the
        Exchange server uses to reach the internet. A valid value for this
        parameter is the URL of the web proxy server.

    .PARAMETER InternetWebProxyBypassList
        The InternetWebProxyBypassList parameter specifies a list of servers
        that bypass the web proxy server specified by the InternetWebProxy
        parameter. You identify the servers by their FQDN (for example,
        server01.contoso.com).

    .PARAMETER MonitoringGroup
        The MonitoringGroup parameter specifies how to add your Exchange
        servers to monitoring groups. You can add your servers to an existing
        group or create a monitoring group based on location or deployment, or
        to partition monitoring responsibility among your servers.

    .PARAMETER ProductKey
        The ProductKey parameter specifies the server product key.

    .PARAMETER StaticConfigDomainController
        The StaticConfigDomainController parameter specifies whether to
        configure a domain controller to be used by the server via Directory
        Service Access (DSAccess).

    .PARAMETER StaticDomainControllers
        The StaticDomainControllers parameter specifies whether to configure a
        list of domain controllers to be used by the server via DSAccess.

    .PARAMETER StaticExcludedDomainControllers
        The StaticExcludedDomainControllers parameter specifies whether to
        exclude a list of domain controllers from being used by the server.

    .PARAMETER StaticGlobalCatalogs
        The StaticGlobalCatalogs parameter specifies whether to configure a
        list of global catalogs to be used by the server via DSAccess.

    .PARAMETER WorkloadManagementPolicy
        The *-ResourcePolicy, *-WorkloadManagementPolicy and *-WorkloadPolicy
        system workload management cmdlets have been deprecated. System
        workload management settings should be customized only under the
        direction of Microsoft Customer Service and Support.
#>
function Get-ExchangeServerInternal
{
    [CmdletBinding()]
    [OutputType([System.Object])]
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
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $ErrorReportingEnabled,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String[]]
        $InternetWebProxyBypassList,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $StaticConfigDomainController,

        [Parameter()]
        [System.String[]]
        $StaticDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticExcludedDomainControllers,

        [Parameter()]
        [System.String[]]
        $StaticGlobalCatalogs,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-ExchangeServer @PSBoundParameters -Status)
}

<#
    .SYNOPSIS
        Inspects the input $PSBoundParametersIn hashtable, and removes any
        parameters that do not work with the version of Exchange on this
        server.

    .PARAMETER PSBoundParametersIn
        The $PSBoundParameters hashtable from the calling function.
#>
function Remove-NotApplicableParamsForCurrentState
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $PSBoundParametersIn
    )

    # Check for parameters that only exist in Exchange 2016
    Remove-NotApplicableParamsForVersion `
        -PSBoundParametersIn $PSBoundParametersIn `
        -ParamName 'InternetWebProxyBypassList' `
        -ResourceName 'xExchExchangeServer' `
        -ParamExistsInVersion '2016'

    if ($PSBoundParametersIn.ContainsKey('WorkloadManagementPolicy') -and (Test-CmdletHasParameter -CmdletName 'Set-ExchangeServer' -ParameterName 'WorkloadManagementPolicy') -eq $false)
    {
        Write-Warning -Message 'WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored.'
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParametersIn -ParamsToRemove 'WorkloadManagementPolicy'
    }

    if ($PSBoundParametersIn.ContainsKey('CustomerFeedbackEnabled'))
    {
        Write-Warning -Message 'CustomerFeedbackEnabled is no longer a usable parameter for Set-ExchangeServer. You must use Set-OrganizationConfig -CustomerFeedbackEnabled instead. This parameter will be removed from future versions of the xExchange module.'
    }

    if ($PSBoundParametersIn.ContainsKey('ErrorReportingEnabled') -and $PSBoundParametersIn.'ErrorReportingEnabled')
    {
        Write-Warning -Message 'ErrorReportingEnabled cannot be set to True using a script, as it requires administrator confirmation. Removing ErrorReportingEnabled from parameter set.'
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParametersIn -ParamsToRemove 'ErrorReportingEnabled'
    }
}

Export-ModuleMember -Function *-TargetResource
