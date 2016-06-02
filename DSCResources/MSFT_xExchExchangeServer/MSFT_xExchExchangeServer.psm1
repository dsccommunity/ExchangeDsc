function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $CustomerFeedbackEnabled,

        [System.String]
        $DomainController,

        [System.String]
        $InternetWebProxy,

        [System.String]
        $MonitoringGroup,

        [System.String]
        $ProductKey,

        [System.String]
        $WorkloadManagementPolicy
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ExchangeServer","Set-ExchangeServer" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("WorkloadManagementPolicy") -and (CheckForCmdletParameter -CmdletName "Set-ExchangeServer" -ParameterName "WorkloadManagementPolicy") -eq $false)
    {
        Write-Warning "WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored."
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "WorkloadManagementPolicy"
    }

    $server = GetExchangeServer @PSBoundParameters

    if ($null -ne $server)
    {
        #There's no way to read the product key that was sent in, so just mark it is "Licensed" if it is
        if ($server.IsExchangeTrialEdition -eq $false)
        {
            $ProductKey = "Licensed"
        }
        else
        {
            $ProductKey = ""
        }

        $returnValue = @{
            Identity = $Identity
            CustomerFeedbackEnabled = $server.CustomerFeedbackEnabled
            InternetWebProxy = $server.InternetWebProxy.AbsoluteUri
            MonitoringGroup = $server.MonitoringGroup
            ProductKey = $ProductKey
            WorkloadManagementPolicy = $server.WorkloadManagementPolicy
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $CustomerFeedbackEnabled,

        [System.String]
        $DomainController,

        [System.String]
        $InternetWebProxy,

        [System.String]
        $MonitoringGroup,

        [System.String]
        $ProductKey,

        [System.String]
        $WorkloadManagementPolicy
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ExchangeServer","Set-ExchangeServer" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("WorkloadManagementPolicy") -and (CheckForCmdletParameter -CmdletName "Set-ExchangeServer" -ParameterName "WorkloadManagementPolicy") -eq $false)
    {
        Write-Warning "WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored."
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "WorkloadManagementPolicy"
    }

    #Check existing config first to see if we are currently licensing a server
    $server = GetExchangeServer @PSBoundParameters

    $needRestart = $false

    if ($PSBoundParameters.ContainsKey("ProductKey") -and !([string]::IsNullOrEmpty($ProductKey)) -and $null -ne $server -and $server.IsExchangeTrialEdition -eq $true)
    {
        $needRestart = $true
    }

    #Setup params for next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-ExchangeServer @PSBoundParameters

    #Restart service if needed
    if ($needRestart)
    {
        if ($AllowServiceRestart -eq $true)
        {
            Write-Verbose "Restarting Information Store"

            Restart-Service MSExchangeIS
        }
        else
        {
            Write-Warning "The configuration will not take effect until MSExchangeIS is manually restarted."
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $CustomerFeedbackEnabled,

        [System.String]
        $DomainController,

        [System.String]
        $InternetWebProxy,

        [System.String]
        $MonitoringGroup,

        [System.String]
        $ProductKey,

        [System.String]
        $WorkloadManagementPolicy
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ExchangeServer","Set-ExchangeServer" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("WorkloadManagementPolicy") -and (CheckForCmdletParameter -CmdletName "Set-ExchangeServer" -ParameterName "WorkloadManagementPolicy") -eq $false)
    {
        Write-Warning "WorkloadManagementPolicy has been removed from the Set-ExchangeServer cmdlet. This parameter will be ignored."
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "WorkloadManagementPolicy"
    }

    $server = GetExchangeServer @PSBoundParameters

    if ($null -eq $server) #Couldn't find the server, which is bad
    {
        return $false
    }
    else #Validate server params
    {
        if (!(VerifySetting -Name "CustomerFeedbackEnabled" -Type "Boolean" -ExpectedValue $CustomerFeedbackEnabled -ActualValue $server.CustomerFeedbackEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if ($PSBoundParameters.ContainsKey("InternetWebProxy") -and !(CompareStrings -String1 $InternetWebProxy -String2 $server.InternetWebProxy.AbsoluteUri -IgnoreCase))
        {
            #The AbsolueUri that comes back from the server can have a trailing slash. Check if the AbsoluteUri at least contains the requested Uri
            if (($null -ne $server.InternetWebProxy -and $null -ne $server.InternetWebProxy.AbsoluteUri -and $server.InternetWebProxy.AbsoluteUri.Contains($InternetWebProxy)) -eq $false)
            {
                ReportBadSetting -SettingName "InternetWebProxy" -ExpectedValue $InternetWebProxy -ActualValue $server.InternetWebProxy -VerbosePreference $VerbosePreference
                return $false
            }
        }

        if (!(VerifySetting -Name "MonitoringGroup" -Type "String" -ExpectedValue $MonitoringGroup -ActualValue $server.MonitoringGroup -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if ($PSBoundParameters.ContainsKey("ProductKey") -and !([string]::IsNullOrEmpty($ProductKey)) -and $server.IsExchangeTrialEdition -eq $true)
        {
            ReportBadSetting -SettingName "ProductKey" -ExpectedValue $ProductKey -ActualValue $server.ProductKey -VerbosePreference $VerbosePreference
            return $false
        }

        if (!(VerifySetting -Name "WorkloadManagementPolicy" -Type "String" -ExpectedValue $WorkloadManagementPolicy -ActualValue $server.WorkloadManagementPolicy -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

#Runs Get-ExchangeServer, only specifying Identity, and optionally DomainController
function GetExchangeServer
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [System.Boolean]
        $CustomerFeedbackEnabled,

        [System.String]
        $DomainController,

        [System.String]
        $InternetWebProxy,

        [System.String]
        $MonitoringGroup,

        [System.String]
        $ProductKey,

        [System.String]
        $WorkloadManagementPolicy,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-ExchangeServer @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource



