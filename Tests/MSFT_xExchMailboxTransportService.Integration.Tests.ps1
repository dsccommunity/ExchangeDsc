###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchMailboxTransportService\MSFT_xExchMailboxTransportService.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $global:ShellCredentials)
    {
        [PSCredential]$global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Set and modify Mailbox Transport Service configuration" {
        #Set configuration with default values
        $testParams = @{
             Identity                                = $env:computername
             Credential                              = $global:ShellCredentials
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
             ConnectivityLogMaxDirectorySize         = '1000MB'
             ConnectivityLogMaxFileSize              = '10MB'
             ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity'
             ContentConversionTracingEnabled         = $false
             MaxConcurrentMailboxDeliveries          = '20'
             MaxConcurrentMailboxSubmissions         = '20'
             PipelineTracingEnabled                  = $false
             PipelineTracingPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing'
             PipelineTracingSenderAddress            = $null
             ReceiveProtocolLogMaxAge                = '30.00:00:00'
             ReceiveProtocolLogMaxDirectorySize      = '250MB'
             ReceiveProtocolLogMaxFileSize           = '10 MB'
             ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive'
             SendProtocolLogMaxAge                   = '30.00:00:00'
             SendProtocolLogMaxDirectorySize         = '250 MB'
             SendProtocolLogMaxFileSize              = '10MB'
             SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend'
        }

         Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set default Mailbox Transport Service configuration" -ExpectedGetResults $expectedGetResults
     
         #modify configuration
         $testParams.PipelineTracingSenderAddress = 'john.doe@contoso.com'
     
         $expectedGetResults.PipelineTracingSenderAddress = 'john.doe@contoso.com'

         Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Modify Mailbox Transport Service configuration" -ExpectedGetResults $expectedGetResults
     
         #modify configuration
         $testParams.PipelineTracingSenderAddress = ''
     
         $expectedGetResults.PipelineTracingSenderAddress = $null
     
         Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Revert Mailbox Transport Service configuration" -ExpectedGetResults $expectedGetResults
     }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
