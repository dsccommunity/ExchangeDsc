#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchTransportService'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
}

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResource.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$TestEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:DSCModuleName `
    -DSCResourceName $script:DSCResourceName `
    -ResourceType 'Mof' `
    -TestType Unit

#endregion HEADER

function Invoke-TestSetup
{

}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchTransportService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-TransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'TransportService'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getTransportServiceStandardOutput = @{
                ActiveUserStatisticsLogMaxAge                   = [System.String] ''
                ActiveUserStatisticsLogMaxDirectorySize         = [System.String] ''
                ActiveUserStatisticsLogMaxFileSize              = [System.String] ''
                ActiveUserStatisticsLogPath                     = [System.String] ''
                AgentLogEnabled                                 = [System.Boolean] $false
                AgentLogMaxAge                                  = [System.String] ''
                AgentLogMaxDirectorySize                        = [System.String] ''
                AgentLogMaxFileSize                             = [System.String] ''
                AgentLogPath                                    = [System.String] ''
                ConnectivityLogEnabled                          = [System.Boolean] $false
                ConnectivityLogMaxAge                           = [System.String] ''
                ConnectivityLogMaxDirectorySize                 = [System.String] ''
                ConnectivityLogMaxFileSize                      = [System.String] ''
                ConnectivityLogPath                             = [System.String] ''
                ContentConversionTracingEnabled                 = [System.Boolean] $false
                DelayNotificationTimeout                        = [System.String] ''
                DnsLogEnabled                                   = [System.Boolean] $false
                DnsLogMaxAge                                    = [System.String] ''
                DnsLogMaxDirectorySize                          = [System.String] ''
                DnsLogMaxFileSize                               = [System.String] ''
                DnsLogPath                                      = [System.String] ''
                ExternalDNSAdapterEnabled                       = [System.Boolean] $false
                ExternalDNSAdapterGuid                          = [System.String] ''
                ExternalDNSProtocolOption                       = [System.String] ''
                ExternalDNSServers                              = [System.String[]] @()
                ExternalIPAddress                               = [System.String] ''
                InternalDNSAdapterEnabled                       = [System.Boolean] $false
                InternalDNSAdapterGuid                          = [System.String] ''
                InternalDNSProtocolOption                       = [System.String] ''
                InternalDNSServers                              = [System.String[]] @()
                IntraOrgConnectorProtocolLoggingLevel           = [System.String] ''
                IntraOrgConnectorSmtpMaxMessagesPerConnection   = [System.Int32] 1
                IrmLogEnabled                                   = [System.Boolean] $false
                IrmLogMaxAge                                    = [System.String] ''
                IrmLogMaxDirectorySize                          = [System.String] ''
                IrmLogMaxFileSize                               = [System.String] ''
                IrmLogPath                                      = [System.String] ''
                MaxConcurrentMailboxDeliveries                  = [System.Int32] 1
                MaxConcurrentMailboxSubmissions                 = [System.Int32] 1
                MaxConnectionRatePerMinute                      = [System.Int32] 1
                MaxOutboundConnections                          = [System.String] ''
                MaxPerDomainOutboundConnections                 = [System.String] ''
                MessageExpirationTimeout                        = [System.String] ''
                MessageRetryInterval                            = [System.String] ''
                MessageTrackingLogEnabled                       = [System.Boolean] $false
                MessageTrackingLogMaxAge                        = [System.String] ''
                MessageTrackingLogMaxDirectorySize              = [System.String] ''
                MessageTrackingLogMaxFileSize                   = [System.String] ''
                MessageTrackingLogPath                          = [System.String] ''
                MessageTrackingLogSubjectLoggingEnabled         = [System.Boolean] $false
                OutboundConnectionFailureRetryInterval          = [System.String] ''
                PickupDirectoryMaxHeaderSize                    = [System.String] ''
                PickupDirectoryMaxMessagesPerMinute             = [System.Int32] 1
                PickupDirectoryMaxRecipientsPerMessage          = [System.Int32] 1
                PickupDirectoryPath                             = [System.String] ''
                PipelineTracingEnabled                          = [System.Boolean] $false
                PipelineTracingPath                             = [System.String] ''
                PipelineTracingSenderAddress                    = [System.String] ''
                PoisonMessageDetectionEnabled                   = [System.Boolean] $false
                PoisonThreshold                                 = [System.Int32] 1
                QueueLogMaxAge                                  = [System.String] ''
                QueueLogMaxDirectorySize                        = [System.String] ''
                QueueLogMaxFileSize                             = [System.String] ''
                QueueLogPath                                    = [System.String] ''
                QueueMaxIdleTime                                = [System.String] ''
                ReceiveProtocolLogMaxAge                        = [System.String] ''
                ReceiveProtocolLogMaxDirectorySize              = [System.String] ''
                ReceiveProtocolLogMaxFileSize                   = [System.String] ''
                ReceiveProtocolLogPath                          = [System.String] ''
                RecipientValidationCacheEnabled                 = [System.Boolean] $false
                ReplayDirectoryPath                             = [System.String] ''
                RootDropDirectoryPath                           = [System.String] ''
                RoutingTableLogMaxAge                           = [System.String] ''
                RoutingTableLogMaxDirectorySize                 = [System.String] ''
                RoutingTableLogPath                             = [System.String] ''
                SendProtocolLogMaxAge                           = [System.String] ''
                SendProtocolLogMaxDirectorySize                 = [System.String] ''
                SendProtocolLogMaxFileSize                      = [System.String] ''
                SendProtocolLogPath                             = [System.String] ''
                ServerStatisticsLogMaxAge                       = [System.String] ''
                ServerStatisticsLogMaxDirectorySize             = [System.String] ''
                ServerStatisticsLogMaxFileSize                  = [System.String] ''
                ServerStatisticsLogPath                         = [System.String] ''
                TransientFailureRetryCount                      = [System.Int32] 1
                TransientFailureRetryInterval                   = [System.String] ''
                UseDowngradedExchangeServerAuth                 = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-TransportService -Verifiable -MockWith { return $getTransportServiceStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
