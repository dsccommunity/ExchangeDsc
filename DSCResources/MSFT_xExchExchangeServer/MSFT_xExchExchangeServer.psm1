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
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('WorkloadManagementPolicy') -and (Test-CmdletHasParameter -CmdletName 'Set-ExchangeServer' -ParameterName 'WorkloadManagementPolicy') -eq $false)
    {
        Write-Warning -Message 'WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored.'
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'WorkloadManagementPolicy'
    }

    $server = GetExchangeServer @PSBoundParameters

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

        $returnValue = @{
            Identity                 = [System.String] $Identity
            CustomerFeedbackEnabled  = [System.Boolean] $server.CustomerFeedbackEnabled
            InternetWebProxy         = [System.String] $server.InternetWebProxy.AbsoluteUri
            MonitoringGroup          = [System.String] $server.MonitoringGroup
            ProductKey               = [System.String] $ProductKey
            WorkloadManagementPolicy = [System.String] $server.WorkloadManagementPolicy
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
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('WorkloadManagementPolicy') -and (Test-CmdletHasParameter -CmdletName 'Set-ExchangeServer' -ParameterName 'WorkloadManagementPolicy') -eq $false)
    {
        Write-Warning -Message 'WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored.'
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'WorkloadManagementPolicy'
    }

    # Check existing config first to see if we are currently licensing a server
    $server = GetExchangeServer @PSBoundParameters

    $needRestart = $false

    if ($PSBoundParameters.ContainsKey('ProductKey') -and !([System.String]::IsNullOrEmpty($ProductKey)) -and $null -ne $server -and $server.IsExchangeTrialEdition -eq $true)
    {
        $needRestart = $true
    }

    # Setup params for next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-ExchangeServer @PSBoundParameters

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
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeServer', 'Set-ExchangeServer' -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('WorkloadManagementPolicy') -and (Test-CmdletHasParameter -CmdletName 'Set-ExchangeServer' -ParameterName 'WorkloadManagementPolicy') -eq $false)
    {
        Write-Warning -Message 'WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored.'
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'WorkloadManagementPolicy'
    }

    $server = GetExchangeServer @PSBoundParameters

    $testResults = $true

    if ($null -eq $server) # Couldn't find the server, which is bad
    {
        Write-Error -Message 'Unable to retrieve Exchange Server settings for server'

        $testResults = $false
    }
    else # Validate server params
    {
        if (!(Test-ExchangeSetting -Name 'CustomerFeedbackEnabled' -Type 'Boolean' -ExpectedValue $CustomerFeedbackEnabled -ActualValue $server.CustomerFeedbackEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

        if (!(Test-ExchangeSetting -Name 'MonitoringGroup' -Type 'String' -ExpectedValue $MonitoringGroup -ActualValue $server.MonitoringGroup -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if ($PSBoundParameters.ContainsKey('ProductKey') -and !([System.String]::IsNullOrEmpty($ProductKey)) -and $server.IsExchangeTrialEdition -eq $true)
        {
            Write-InvalidSettingVerbose -SettingName 'ProductKey' -ExpectedValue $ProductKey -ActualValue $server.ProductKey -Verbose:$VerbosePreference
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WorkloadManagementPolicy' -Type 'String' -ExpectedValue $WorkloadManagementPolicy -ActualValue $server.WorkloadManagementPolicy -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

# Runs Get-ExchangeServer, only specifying Identity, and optionally DomainController
function GetExchangeServer
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.Boolean]
        $CustomerFeedbackEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $InternetWebProxy,

        [Parameter()]
        [System.String]
        $MonitoringGroup,

        [Parameter()]
        [System.String]
        $ProductKey,

        [Parameter()]
        [System.String]
        $WorkloadManagementPolicy,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-ExchangeServer @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
