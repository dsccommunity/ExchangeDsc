###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchTransportService\MSFT_xExchTransportService.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Set and modify Transport Service configuration" {
    #Set configuration with default values
    $testParams = @{
         Identity                                = $env:computername
         Credential                              = $Global:ShellCredentials
         AllowServiceRestart                     = $true
         ActiveUserStatisticsLogMaxAge           = '30.00:00:00'
         ActiveUserStatisticsLogMaxDirectorySize = '250MB'
         ActiveUserStatisticsLogMaxFileSize      = '10MB'
         ActiveUserStatisticsLogPath             = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ActiveUsersStats'
         AgentLogEnabled                         = $true
         AgentLogMaxAge                          = '7.00:00:00'
         AgentLogMaxDirectorySize                = '250MB'
         AgentLogMaxFileSize                     = '10MB'
         AgentLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\AgentLog'
         ConnectivityLogEnabled                  = $true
         ConnectivityLogMaxAge                   = '30.00:00:00'
         ConnectivityLogMaxDirectorySize         = '1000MB'
         ConnectivityLogMaxFileSize              = '10MB'
         ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity'
         ContentConversionTracingEnabled         = $false
         DelayNotificationTimeout                = '04:00:00'
         DnsLogEnabled                           = $false
         DnsLogMaxAge                            = '7.00:00:00'
         DnsLogMaxDirectorySize                  = '100 MB'
         DnsLogMaxFileSize                       = '10 MB'
         DnsLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\DNS'
         ExternalDNSAdapterEnabled               = $true
         ExternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         ExternalDNSProtocolOption               = 'any'
         ExternalDNSServers                      = ''
         ExternalIPAddress                       = ''
         InternalDNSAdapterEnabled               = $true          
         InternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         InternalDNSProtocolOption               = 'any'
         InternalDNSServers                      = ''
         IntraOrgConnectorProtocolLoggingLevel   = 'none'
         IntraOrgConnectorSmtpMaxMessagesPerConnection = '20'
         IrmLogEnabled                           = $true
         IrmLogMaxAge                            = '30.00:00:00'
         IrmLogMaxDirectorySize                  = '250MB'
         IrmLogMaxFileSize                       = '10MB'
         IrmLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\IRMLogs'
         MaxConcurrentMailboxDeliveries          = '20'
         MaxConcurrentMailboxSubmissions         = '20'
         MaxConnectionRatePerMinute              = '1200'
         MaxOutboundConnections                  = '1000'
         MaxPerDomainOutboundConnections         = '20'
         MessageExpirationTimeout                = '2.00:00:00'
         MessageRetryInterval                    = '00:15:00'
         MessageTrackingLogEnabled               = $true
         MessageTrackingLogMaxAge                = '30.00:00:00'
         MessageTrackingLogMaxDirectorySize      = '1000MB'
         MessageTrackingLogMaxFileSize           = '10 MB'
         MessageTrackingLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\MessageTracking'
         MessageTrackingLogSubjectLoggingEnabled = $true
         OutboundConnectionFailureRetryInterval  = '00:10:00'
         PickupDirectoryMaxHeaderSize            = '64 KB'
         PickupDirectoryMaxMessagesPerMinute     = '100'
         PickupDirectoryMaxRecipientsPerMessage  = '100'
         PickupDirectoryPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Pickup'
         PipelineTracingEnabled                  = $false
         PipelineTracingPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing'
         PipelineTracingSenderAddress            = ''
         PoisonMessageDetectionEnabled           = $true
         PoisonThreshold                         = '2'
         QueueLogMaxAge                          = '7.00:00:00'
         QueueLogMaxDirectorySize                = '200MB'
         QueueLogMaxFileSize                     = '10MB'
         QueueLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\QueueViewer'
         QueueMaxIdleTime                        = '00:03:00'
         ReceiveProtocolLogMaxAge                = '30.00:00:00'
         ReceiveProtocolLogMaxDirectorySize      = '250MB'
         ReceiveProtocolLogMaxFileSize           = '10 MB'
         ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive'
         RecipientValidationCacheEnabled         = $false
         ReplayDirectoryPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Replay'
         RootDropDirectoryPath                   = ''
         RoutingTableLogMaxAge                   = '7.00:00:00'
         RoutingTableLogMaxDirectorySize         = '50 MB'
         RoutingTableLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Routing'
         SendProtocolLogMaxAge                   = '30.00:00:00'
         SendProtocolLogMaxDirectorySize         = '250MB'
         SendProtocolLogMaxFileSize              = '10MB'
         SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend'
         ServerStatisticsLogMaxAge               = '30.00:00:00'
         ServerStatisticsLogMaxDirectorySize     = '250MB'
         ServerStatisticsLogMaxFileSize          = '10 MB'
         ServerStatisticsLogPath                 = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ServerStats'
         TransientFailureRetryCount              = '6'
         TransientFailureRetryInterval           = '00:05:00'
         UseDowngradedExchangeServerAuth         = $false
    }

    $expectedGetResults = @{
         ActiveUserStatisticsLogMaxAge           = '30.00:00:00'
         ActiveUserStatisticsLogMaxDirectorySize = '250MB'
         ActiveUserStatisticsLogMaxFileSize      = '10MB'
         ActiveUserStatisticsLogPath             = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ActiveUsersStats'
         AgentLogEnabled                         = $true
         AgentLogMaxAge                          = '7.00:00:00'
         AgentLogMaxDirectorySize                = '250MB'
         AgentLogMaxFileSize                     = '10MB'
         AgentLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\AgentLog'
         ConnectivityLogEnabled                  = $true
         ConnectivityLogMaxAge                   = '30.00:00:00'
         ConnectivityLogMaxDirectorySize         = '1000MB'
         ConnectivityLogMaxFileSize              = '10MB'
         ConnectivityLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Connectivity'
         ContentConversionTracingEnabled         = $false
         DelayNotificationTimeout                = '04:00:00'
         DnsLogEnabled                           = $false
         DnsLogMaxAge                            = '7.00:00:00'
         DnsLogMaxDirectorySize                  = '100 MB'
         DnsLogMaxFileSize                       = '10 MB'
         DnsLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\DNS'
         ExternalDNSAdapterEnabled               = $true
         ExternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         ExternalDNSProtocolOption               = 'any'
         ExternalDNSServers                      = $null
         ExternalIPAddress                       = $null
         InternalDNSAdapterEnabled               = $true          
         InternalDNSAdapterGuid                  = '00000000-0000-0000-0000-000000000000'
         InternalDNSProtocolOption               = 'any'
         InternalDNSServers                      = $null
         IntraOrgConnectorProtocolLoggingLevel   = 'none'
         IntraOrgConnectorSmtpMaxMessagesPerConnection = '20'
         IrmLogEnabled                           = $true
         IrmLogMaxAge                            = '30.00:00:00'
         IrmLogMaxDirectorySize                  = '250MB'
         IrmLogMaxFileSize                       = '10MB'
         IrmLogPath                              = 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\IRMLogs'
         MaxConcurrentMailboxDeliveries          = '20'
         MaxConcurrentMailboxSubmissions         = '20'
         MaxConnectionRatePerMinute              = '1200'
         MaxOutboundConnections                  = '1000'
         MaxPerDomainOutboundConnections         = '20'
         MessageExpirationTimeout                = '2.00:00:00'
         MessageRetryInterval                    = '00:15:00'
         MessageTrackingLogEnabled               = $true
         MessageTrackingLogMaxAge                = '30.00:00:00'
         MessageTrackingLogMaxDirectorySize      = '1000MB'
         MessageTrackingLogMaxFileSize           = '10 MB'
         MessageTrackingLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\MessageTracking'
         MessageTrackingLogSubjectLoggingEnabled = $true
         OutboundConnectionFailureRetryInterval  = '00:10:00'
         PickupDirectoryMaxHeaderSize            = '64 KB'
         PickupDirectoryMaxMessagesPerMinute     = '100'
         PickupDirectoryMaxRecipientsPerMessage  = '100'
         PickupDirectoryPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Pickup'
         PipelineTracingEnabled                  = $false
         PipelineTracingPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\PipelineTracing'
         PipelineTracingSenderAddress            = $null
         PoisonMessageDetectionEnabled           = $true
         PoisonThreshold                         = '2'
         QueueLogMaxAge                          = '7.00:00:00'
         QueueLogMaxDirectorySize                = '200MB'
         QueueLogMaxFileSize                     = '10MB'
         QueueLogPath                            = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\QueueViewer'
         QueueMaxIdleTime                        = '00:03:00'
         ReceiveProtocolLogMaxAge                = '30.00:00:00'
         ReceiveProtocolLogMaxDirectorySize      = '250MB'
         ReceiveProtocolLogMaxFileSize           = '10 MB'
         ReceiveProtocolLogPath                  = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpReceive'
         RecipientValidationCacheEnabled         = $false
         ReplayDirectoryPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Replay'
         RootDropDirectoryPath                   = ''
         RoutingTableLogMaxAge                   = '7.00:00:00'
         RoutingTableLogMaxDirectorySize         = '50 MB'
         RoutingTableLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\Routing'
         SendProtocolLogMaxAge                   = '30.00:00:00'
         SendProtocolLogMaxDirectorySize         = '250 MB'
         SendProtocolLogMaxFileSize              = '10MB'
         SendProtocolLogPath                     = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ProtocolLog\SmtpSend'
         ServerStatisticsLogMaxAge               = '30.00:00:00'
         ServerStatisticsLogMaxDirectorySize     = '250MB'
         ServerStatisticsLogMaxFileSize          = '10 MB'
         ServerStatisticsLogPath                 = 'C:\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\Hub\ServerStats'
         TransientFailureRetryCount              = '6'
         TransientFailureRetryInterval           = '00:05:00'
         UseDowngradedExchangeServerAuth         = $false
    }

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Set default Transport Service configuration" -ExpectedGetResults $expectedGetResults
     
     #modify configuration
     $testParams.InternalDNSServers = '192.168.1.10'
     $testParams.ExternalDNSServers = '10.1.1.10'
     $testParams.PipelineTracingSenderAddress = 'john.doe@contoso.com'
     
     $expectedGetResults.InternalDNSServers = '192.168.1.10'
     $expectedGetResults.ExternalDNSServers = '10.1.1.10'
     $expectedGetResults.PipelineTracingSenderAddress = 'john.doe@contoso.com'

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Modify Transport Service configuration" -ExpectedGetResults $expectedGetResults
     
     #modify configuration
     $testParams.InternalDNSServers = ''
     $testParams.ExternalDNSServers = ''
     $testParams.PipelineTracingSenderAddress = ''
     
     $expectedGetResults.InternalDNSServers = $null
     $expectedGetResults.ExternalDNSServers = $null
     $expectedGetResults.PipelineTracingSenderAddress = $null
     
     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Revert Transport Service configuration" -ExpectedGetResults $expectedGetResults
     }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
