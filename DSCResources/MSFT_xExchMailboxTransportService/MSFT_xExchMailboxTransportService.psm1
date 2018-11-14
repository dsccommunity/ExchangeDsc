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

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    if ($null -ne $mbxTransportService)
    {
        $returnValue = @{
            Identity                           = [System.String] $Identity
            ConnectivityLogEnabled             = [System.Boolean] $mbxTransportService.ConnectivityLogEnabled
            ConnectivityLogMaxAge              = [System.String] $mbxTransportService.ConnectivityLogMaxAge
            ConnectivityLogMaxDirectorySize    = [System.String] $mbxTransportService.ConnectivityLogMaxDirectorySize
            ConnectivityLogMaxFileSize         = [System.String] $mbxTransportService.ConnectivityLogMaxFileSize
            ConnectivityLogPath                = [System.String] $mbxTransportService.ConnectivityLogPath
            ContentConversionTracingEnabled    = [System.Boolean] $mbxTransportService.ContentConversionTracingEnabled
            MaxConcurrentMailboxDeliveries     = [System.Int32] $mbxTransportService.MaxConcurrentMailboxDeliveries
            MaxConcurrentMailboxSubmissions    = [System.Int32] $mbxTransportService.MaxConcurrentMailboxSubmissions
            PipelineTracingEnabled             = [System.Boolean] $mbxTransportService.PipelineTracingEnabled
            PipelineTracingPath                = [System.String] $mbxTransportService.PipelineTracingPath
            PipelineTracingSenderAddress       = [System.String] $mbxTransportService.PipelineTracingSenderAddress
            ReceiveProtocolLogMaxAge           = [System.String] $mbxTransportService.ReceiveProtocolLogMaxAge
            ReceiveProtocolLogMaxDirectorySize = [System.String] $mbxTransportService.ReceiveProtocolLogMaxDirectorySize
            ReceiveProtocolLogMaxFileSize      = [System.String] $mbxTransportService.ReceiveProtocolLogMaxFileSize
            ReceiveProtocolLogPath             = [System.String] $mbxTransportService.ReceiveProtocolLogPath
            SendProtocolLogMaxAge              = [System.String] $mbxTransportService.SendProtocolLogMaxAge
            SendProtocolLogMaxDirectorySize    = [System.String] $mbxTransportService.SendProtocolLogMaxDirectorySize
            SendProtocolLogMaxFileSize         = [System.String] $mbxTransportService.SendProtocolLogMaxFileSize
            SendProtocolLogPath                = [System.String] $mbxTransportService.SendProtocolLogPath
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

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-MailboxTransportService' -Verbose:$VerbosePreference

    # Remove Credential and Ensure so we don't pass it into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # If PipelineTracingSenderAddress exists and is empty, set it to $null so Set-MailboxTransportService nulls out the stored value
    if ($PSBoundParameters.ContainsKey('PipelineTracingSenderAddress') -and [System.String]::IsNullOrEmpty($PipelineTracingSenderAddress))
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

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxTransportService' -Verbose:$VerbosePreference

    $mbxTransportService = Get-MailboxTransportService $Identity -ErrorAction SilentlyContinue

    $testResults = $true

    if ($null -eq $mbxTransportService)
    {
        Write-Error -Message 'Unable to retrieve Mailbox Transport Service for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'ConnectivityLogEnabled' -Type 'Boolean' -ExpectedValue $ConnectivityLogEnabled -ActualValue $mbxTransportService.ConnectivityLogEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxAge' -Type 'Timespan' -ExpectedValue $ConnectivityLogMaxAge -ActualValue $mbxTransportService.ConnectivityLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxDirectorySize -ActualValue $mbxTransportService.ConnectivityLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ConnectivityLogMaxFileSize -ActualValue $mbxTransportService.ConnectivityLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ConnectivityLogPath' -Type 'String' -ExpectedValue $ConnectivityLogPath -ActualValue $mbxTransportService.ConnectivityLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ContentConversionTracingEnabled' -Type 'Boolean' -ExpectedValue $ContentConversionTracingEnabled -ActualValue $mbxTransportService.ContentConversionTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxDeliveries' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxDeliveries -ActualValue $mbxTransportService.MaxConcurrentMailboxDeliveries -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MaxConcurrentMailboxSubmissions' -Type 'Int' -ExpectedValue $MaxConcurrentMailboxSubmissions -ActualValue $mbxTransportService.MaxConcurrentMailboxSubmissions -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingEnabled' -Type 'Boolean' -ExpectedValue $PipelineTracingEnabled -ActualValue $mbxTransportService.PipelineTracingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingPath' -Type 'String' -ExpectedValue $PipelineTracingPath -ActualValue $mbxTransportService.PipelineTracingPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PipelineTracingSenderAddress' -Type 'SMTPAddress' -ExpectedValue $PipelineTracingSenderAddress -ActualValue $mbxTransportService.PipelineTracingSenderAddress -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $ReceiveProtocolLogMaxAge -ActualValue $mbxTransportService.ReceiveProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $ReceiveProtocolLogMaxFileSize -ActualValue $mbxTransportService.ReceiveProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReceiveProtocolLogPath' -Type 'String' -ExpectedValue $ReceiveProtocolLogPath -ActualValue $mbxTransportService.ReceiveProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxAge' -Type 'TimeSpan' -ExpectedValue $SendProtocolLogMaxAge -ActualValue $mbxTransportService.SendProtocolLogMaxAge -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxDirectorySize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxDirectorySize -ActualValue $mbxTransportService.SendProtocolLogMaxDirectorySize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogMaxFileSize' -Type 'Unlimited' -ExpectedValue $SendProtocolLogMaxFileSize -ActualValue $mbxTransportService.SendProtocolLogMaxFileSize -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'SendProtocolLogPath' -Type 'String' -ExpectedValue $SendProtocolLogPath -ActualValue $mbxTransportService.SendProtocolLogPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
