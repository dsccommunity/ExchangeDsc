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
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxTransportService" -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    $MbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $MbxTransportService)
    {
        $returnValue = @{
            Identity                                        = $Identity
            ConnectivityLogEnabled                          = $MbxTransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                           = $MbxTransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize                 = $MbxTransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize                      = $MbxTransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                             = $MbxTransportService.ConnectivityLogPath
            ContentConversionTracingEnabled                 = $MbxTransportService.ContentConversionTracingEnabled
            MaxConcurrentMailboxDeliveries                  = $MbxTransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions                 = $MbxTransportService.MaxConcurrentMailboxSubmissions
            PipelineTracingEnabled                          = $MbxTransportService.PipelineTracingEnabled
            PipelineTracingPath                             = $MbxTransportService.PipelineTracingPath
            PipelineTracingSenderAddress                    = $MbxTransportService.PipelineTracingSenderAddress
            ReceiveProtocolLogMaxAge                        = $MbxTransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize              = $MbxTransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize                   = $MbxTransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                          = $MbxTransportService.ReceiveProtocolLogPath
            SendProtocolLogMaxAge                           = $MbxTransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize                 = $MbxTransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize                      = $MbxTransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                             = $MbxTransportService.SendProtocolLogPath
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
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
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MailboxTransportService" -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    #if PipelineTracingSenderAddress exists and is empty, set it to $null so Set-MailboxTransportService nulls out the stored value
    if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress') -and [string]::IsNullOrEmpty($PipelineTracingSenderAddress))
    {
        $PSBoundParameters['PipelineTracingSenderAddress'] = $null
    }

    Set-MailboxTransportService @PSBoundParameters
    
    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Restart service MSExchangeDelivery"
        Restart-Service -Name MSExchangeDelivery -WarningAction SilentlyContinue

        Write-Verbose "Restart service MSExchangeSubmission"
        Restart-Service -Name MSExchangeSubmission -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning "The configuration will not take effect until the MSExchangeDelivery and/or MSExchangeSubmission services are manually restarted."
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
        $ConnectivityLogEnabled,

        [System.String]
        $ConnectivityLogMaxAge,

        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [System.String]
        $ConnectivityLogMaxFileSize,

        [System.String]
        $ConnectivityLogPath,

        [System.Boolean]
        $ContentConversionTracingEnabled,

        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [System.Boolean]
        $PipelineTracingEnabled,

        [System.String]
        $PipelineTracingPath,

        [System.String]
        $PipelineTracingSenderAddress,

        [System.String]
        $ReceiveProtocolLogMaxAge,

        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [System.String]
        $ReceiveProtocolLogPath,

        [System.String]
        $RoutingTableLogMaxAge,

        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [System.String]
        $RoutingTableLogPath,

        [System.String]
        $SendProtocolLogMaxAge,

        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [System.String]
        $SendProtocolLogMaxFileSize,

        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxTransportService" -VerbosePreference $VerbosePreference

    $MbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $MbxTransportService)
    {
        if (!(VerifySetting -Name "ConnectivityLogEnabled" -Type "Boolean" -ExpectedValue $ConnectivityLogEnabled -ActualValue $MbxTransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxAge" -Type "Timespan" -ExpectedValue $ConnectivityLogMaxAge -ActualValue $MbxTransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $MbxTransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogMaxFileSize" -Type "Unlimited" -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $MbxTransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ConnectivityLogPath" -Type "String" -ExpectedValue $ConnectivityLogPath -ActualValue $MbxTransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ContentConversionTracingEnabled" -Type "Boolean" -ExpectedValue $ContentConversionTracingEnabled -ActualValue $MbxTransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxConcurrentMailboxDeliveries" -Type "Int" -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $MbxTransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaxConcurrentMailboxSubmissions" -Type "Int" -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $MbxTransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PipelineTracingEnabled" -Type "Boolean" -ExpectedValue $PipelineTracingEnabled -ActualValue $MbxTransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PipelineTracingPath" -Type "String" -ExpectedValue $PipelineTracingPath -ActualValue $MbxTransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PipelineTracingSenderAddress" -Type "SMTPAddress" -ExpectedValue $PipelineTracingSenderAddress -ActualValue $MbxTransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxAge" -Type "TimeSpan" -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $MbxTransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $MbxTransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogMaxFileSize" -Type "Unlimited" -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $MbxTransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReceiveProtocolLogPath" -Type "String" -ExpectedValue $ReceiveProtocolLogPath -ActualValue $MbxTransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxAge" -Type "TimeSpan" -ExpectedValue $SendProtocolLogMaxAge -ActualValue $MbxTransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxDirectorySize" -Type "Unlimited" -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $MbxTransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogMaxFileSize" -Type "Unlimited" -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $MbxTransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SendProtocolLogPath" -Type "String" -ExpectedValue $SendProtocolLogPath -ActualValue $MbxTransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }
    else
    {
        return $false
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
