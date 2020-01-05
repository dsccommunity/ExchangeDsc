<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchMailboxTransportService DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchMailboxTransportService'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'Set and modify Mailbox Transport Service configuration' {
        # Set configuration with default values
        $testParams = @{
             Identity                                = $env:computername
             Credential                              = $shellCredentials
             AllowServiceRestart                     = $true
             ConnectivityLogEnabled                  = $true
             ConnectivityLogMaxAge                   = '30.00:00:00'
             ConnectivityLogMaxDirectorySize         = '1000MB'
             ConnectivityLogMaxFileSize              = '10MB'
             ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity'
             ContentConversionTracingEnabled         = $false
             MaxConcurrentMailboxDeliveries          = '20'
             MaxConcurrentMailboxSubmissions         = '20'
             PipelineTracingEnabled                  = $false
             PipelineTracingPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing'
             PipelineTracingSenderAddress            = ''
             ReceiveProtocolLogMaxAge                = '30.00:00:00'
             ReceiveProtocolLogMaxDirectorySize      = '250MB'
             ReceiveProtocolLogMaxFileSize           = '10 MB'
             ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive'
             SendProtocolLogMaxAge                   = '30.00:00:00'
             SendProtocolLogMaxDirectorySize         = '250MB'
             SendProtocolLogMaxFileSize              = '10MB'
             SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend'
        }

        $expectedGetResults = @{
             ConnectivityLogEnabled                  = $true
             ConnectivityLogMaxAge                   = '30.00:00:00'
             ConnectivityLogMaxDirectorySize         = '1000 MB (1,048,576,000 bytes)'
             ConnectivityLogMaxFileSize              = '10 MB (10,485,760 bytes)'
             ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity'
             ContentConversionTracingEnabled         = $false
             MaxConcurrentMailboxDeliveries          = '20'
             MaxConcurrentMailboxSubmissions         = '20'
             PipelineTracingEnabled                  = $false
             PipelineTracingPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing'
             PipelineTracingSenderAddress            = ''
             ReceiveProtocolLogMaxAge                = '30.00:00:00'
             ReceiveProtocolLogMaxDirectorySize      = '250 MB (262,144,000 bytes)'
             ReceiveProtocolLogMaxFileSize           = '10 MB (10,485,760 bytes)'
             ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive'
             SendProtocolLogMaxAge                   = '30.00:00:00'
             SendProtocolLogMaxDirectorySize         = '250 MB (262,144,000 bytes)'
             SendProtocolLogMaxFileSize              = '10 MB (10,485,760 bytes)'
             SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend'
        }

         Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set default Mailbox Transport Service configuration' -ExpectedGetResults $expectedGetResults

         # modify configuration
         $testParams.PipelineTracingSenderAddress = 'john.doe@contoso.com'
         $expectedGetResults.PipelineTracingSenderAddress = 'john.doe@contoso.com'
         Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Modify Mailbox Transport Service configuration' -ExpectedGetResults $expectedGetResults

         # modify configuration
         $testParams.PipelineTracingSenderAddress = ''
         $expectedGetResults.PipelineTracingSenderAddress = ''
         Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Revert Mailbox Transport Service configuration' -ExpectedGetResults $expectedGetResults
     }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
