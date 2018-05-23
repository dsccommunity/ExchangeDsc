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
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath $PSScriptRoot).Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $mbxTransportService)
    {
        $returnValue = @{
            Identity                                        = $Identity
            ConnectivityLogEnabled                          = $mbxTransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge                           = $mbxTransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize                 = $mbxTransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize                      = $mbxTransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                             = $mbxTransportService.ConnectivityLogPath
            ContentConversionTracingEnabled                 = $mbxTransportService.ContentConversionTracingEnabled
            MaxConcurrentMailboxDeliveries                  = $mbxTransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions                 = $mbxTransportService.MaxConcurrentMailboxSubmissions
            PipelineTracingEnabled                          = $mbxTransportService.PipelineTracingEnabled
            PipelineTracingPath                             = $mbxTransportService.PipelineTracingPath
            PipelineTracingSenderAddress                    = $mbxTransportService.PipelineTracingSenderAddress
            ReceiveProtocolLogMaxAge                        = $mbxTransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize              = $mbxTransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize                   = $mbxTransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath                          = $mbxTransportService.ReceiveProtocolLogPath
            SendProtocolLogMaxAge                           = $mbxTransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize                 = $mbxTransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize                      = $mbxTransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                             = $mbxTransportService.SendProtocolLogPath
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
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath $PSScriptRoot).Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-MailboxTransportService' -VerbosePreference $VerbosePreference

    #Remove Credential and Ensure so we don't pass it into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    #if PipelineTracingSenderAddress exists and is empty, set it to $null so Set-MailboxTransportService nulls out the stored value
    if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress') -and [string]::IsNullOrEmpty($PipelineTracingSenderAddress))
    {
        $PSBoundParameters['PipelineTracingSenderAddress'] = $null
    }

    Set-MailboxTransportService @PSBoundParameters
    
    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Restart service MSExchangeDelivery'
        Restart-Service -Name MSExchangeDelivery -WarningAction SilentlyContinue

        Write-Verbose -Message 'Restart service MSExchangeSubmission'
        Restart-Service -Name MSExchangeSubmission -WarningAction SilentlyContinue
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until the MSExchangeDelivery and/or MSExchangeSubmission services are manually restarted.'
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
        $ConnectivityLogEnabled,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxAge,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ConnectivityLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ConnectivityLogPath,

        [Parameter()]
        [System.Boolean]
        $ContentConversionTracingEnabled,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxDeliveries,

        [Parameter()]
        [System.Int32]
        $MaxConcurrentMailboxSubmissions,

        [Parameter()]
        [System.Boolean]
        $PipelineTracingEnabled,

        [Parameter()]
        [System.String]
        $PipelineTracingPath,

        [Parameter()]
        [System.String]
        $PipelineTracingSenderAddress,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $ReceiveProtocolLogPath,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxAge,

        [Parameter()]
        [System.String]
        $RoutingTableLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $RoutingTableLogPath,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxAge,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxDirectorySize,

        [Parameter()]
        [System.String]
        $SendProtocolLogMaxFileSize,

        [Parameter()]
        [System.String]
        $SendProtocolLogPath
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath $PSScriptRoot).Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -VerbosePreference $VerbosePreference

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $mbxTransportService)
    {
        if (!(VerifySetting -Name 'ConnectivityLogEnabled' -Type 'Boolean' -ExpectedValue $ConnectivityLogEnabled -ActualValue $mbxTransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ConnectivityLogMaxAge' -Type 'Timespan' -ExpectedValue $ConnectivityLogMaxAge -ActualValue $mbxTransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ConnectivityLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $mbxTransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ConnectivityLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $mbxTransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ConnectivityLogPath' -Type 'String' -ExpectedValue $ConnectivityLogPath -ActualValue $mbxTransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ContentConversionTracingEnabled' -Type 'Boolean' -ExpectedValue $ContentConversionTracingEnabled -ActualValue $mbxTransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'MaxConcurrentMailboxDeliveries' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $mbxTransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'MaxConcurrentMailboxSubmissions' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $mbxTransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'PipelineTracingEnabled' -Type 'Boolean' -ExpectedValue $PipelineTracingEnabled -ActualValue $mbxTransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'PipelineTracingPath' -Type 'String' -ExpectedValue $PipelineTracingPath -ActualValue $mbxTransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'PipelineTracingSenderAddress' -Type 'SMTPAddress' -ExpectedValue $PipelineTracingSenderAddress -ActualValue $mbxTransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ReceiveProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $mbxTransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ReceiveProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ReceiveProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'ReceiveProtocolLogPath' -Type 'String' -ExpectedValue $ReceiveProtocolLogPath -ActualValue $mbxTransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'SendProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $SendProtocolLogMaxAge -ActualValue $mbxTransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'SendProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'SendProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $mbxTransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name 'SendProtocolLogPath' -Type 'String' -ExpectedValue $SendProtocolLogPath -ActualValue $mbxTransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
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
