function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
        InModuleScope $script:DSCResourceName {

        $commonTargetResourceParams = @{
            Identity   = 'TransportService'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        $commonTransportServiceStandardOutput = @{
            ActiveUserStatisticsLogMaxAge                  = [System.String] ''
            ActiveUserStatisticsLogMaxDirectorySize        = [System.String] ''
            ActiveUserStatisticsLogMaxFileSize             = [System.String] ''
            ActiveUserStatisticsLogPath                    = [System.String] ''
            AgentLogEnabled                                = [System.Boolean] $false
            AgentLogMaxAge                                 = [System.String] ''
            AgentLogMaxDirectorySize                       = [System.String] ''
            AgentLogMaxFileSize                            = [System.String] ''
            AgentLogPath                                   = [System.String] ''
            AntispamAgentsEnabled                          = [System.Boolean] $false
            ConnectivityLogEnabled                         = [System.Boolean] $false
            ConnectivityLogMaxAge                          = [System.String] ''
            ConnectivityLogMaxDirectorySize                = [System.String] ''
            ConnectivityLogMaxFileSize                     = [System.String] ''
            ConnectivityLogPath                            = [System.String] ''
            ContentConversionTracingEnabled                = [System.Boolean] $false
            DelayNotificationTimeout                       = [System.String] ''
            DnsLogEnabled                                  = [System.Boolean] $false
            DnsLogMaxAge                                   = [System.String] ''
            DnsLogMaxDirectorySize                         = [System.String] ''
            DnsLogMaxFileSize                              = [System.String] ''
            DnsLogPath                                     = [System.String] ''
            ExternalDNSAdapterEnabled                      = [System.Boolean] $false
            ExternalDNSAdapterGuid                         = [System.String] ''
            ExternalDNSProtocolOption                      = [System.String] ''
            ExternalDNSServers                             = [System.String[]] @('externaldns.contoso.com')
            ExternalIPAddress                              = [System.String] '1.2.3.4'
            InternalDNSAdapterEnabled                      = [System.Boolean] $false
            InternalDNSAdapterGuid                         = [System.String] ''
            InternalDNSProtocolOption                      = [System.String] ''
            InternalDNSServers                             = [System.String[]] @('internaldns.contoso.com')
            IntraOrgConnectorProtocolLoggingLevel          = [System.String] ''
            IntraOrgConnectorSmtpMaxMessagesPerConnection  = [System.Int32] 1
            IrmLogEnabled                                  = [System.Boolean] $false
            IrmLogMaxAge                                   = [System.String] ''
            IrmLogMaxDirectorySize                         = [System.String] ''
            IrmLogMaxFileSize                              = [System.String] ''
            IrmLogPath                                     = [System.String] ''
            MaxConcurrentMailboxDeliveries                 = [System.Int32] 1
            MaxConcurrentMailboxSubmissions                = [System.Int32] 1
            MaxConnectionRatePerMinute                     = [System.Int32] 1
            MaxOutboundConnections                         = [System.String] ''
            MaxPerDomainOutboundConnections                = [System.String] ''
            MessageExpirationTimeout                       = [System.String] ''
            MessageRetryInterval                           = [System.String] ''
            MessageTrackingLogEnabled                      = [System.Boolean] $false
            MessageTrackingLogMaxAge                       = [System.String] ''
            MessageTrackingLogMaxDirectorySize             = [System.String] ''
            MessageTrackingLogMaxFileSize                  = [System.String] ''
            MessageTrackingLogPath                         = [System.String] ''
            MessageTrackingLogSubjectLoggingEnabled        = [System.Boolean] $false
            OutboundConnectionFailureRetryInterval         = [System.String] ''
            PickupDirectoryMaxHeaderSize                   = [System.String] ''
            PickupDirectoryMaxMessagesPerMinute            = [System.Int32] 1
            PickupDirectoryMaxRecipientsPerMessage         = [System.Int32] 1
            PickupDirectoryPath                            = [System.String] ''
            PipelineTracingEnabled                         = [System.Boolean] $false
            PipelineTracingPath                            = [System.String] ''
            PipelineTracingSenderAddress                   = [System.String] 'pipeline@contoso.com'
            PoisonMessageDetectionEnabled                  = [System.Boolean] $false
            PoisonThreshold                                = [System.Int32] 1
            QueueLogMaxAge                                 = [System.String] ''
            QueueLogMaxDirectorySize                       = [System.String] ''
            QueueLogMaxFileSize                            = [System.String] ''
            QueueLogPath                                   = [System.String] ''
            QueueMaxIdleTime                               = [System.String] ''
            ReceiveProtocolLogMaxAge                       = [System.String] ''
            ReceiveProtocolLogMaxDirectorySize             = [System.String] ''
            ReceiveProtocolLogMaxFileSize                  = [System.String] ''
            ReceiveProtocolLogPath                         = [System.String] ''
            RecipientValidationCacheEnabled                = [System.Boolean] $false
            ReplayDirectoryPath                            = [System.String] ''
            RootDropDirectoryPath                          = [System.String] ''
            RoutingTableLogMaxAge                          = [System.String] ''
            RoutingTableLogMaxDirectorySize                = [System.String] ''
            RoutingTableLogPath                            = [System.String] ''
            SendProtocolLogMaxAge                          = [System.String] ''
            SendProtocolLogMaxDirectorySize                = [System.String] ''
            SendProtocolLogMaxFileSize                     = [System.String] ''
            SendProtocolLogPath                            = [System.String] ''
            ServerStatisticsLogMaxAge                      = [System.String] ''
            ServerStatisticsLogMaxDirectorySize            = [System.String] ''
            ServerStatisticsLogMaxFileSize                 = [System.String] ''
            ServerStatisticsLogPath                        = [System.String] ''
            TransientFailureRetryCount                     = [System.Int32] 1
            TransientFailureRetryInterval                  = [System.String] ''
            UseDowngradedExchangeServerAuth                = [System.Boolean] $false
        }

        Mock -CommandName Write-FunctionEntry -Verifiable

        Describe 'MSFT_xExchTransportService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-TransportService {}

            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            Mock -CommandName Get-TransportService -Verifiable -MockWith { return $commonTransportServiceStandardOutput }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }
        Describe 'MSFT_xExchTransportService\Set-TargetResource' -Tag 'Set' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            function Set-TransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Identity            = 'TransportService'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AllowServiceRestart = $true
            }

            Context 'When Set-TargetResource is called' {
                It 'Should call expected functions when AllowServiceRestart is true' {
                    Mock -CommandName Set-TransportService -Verifiable
                    Mock -CommandName Restart-Service -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }

                It 'Should call expected functions when PipelineTracingSenderAddress is null' {
                    $PipelineTracingSenderAddress = $setTargetResourceParams.PipelineTracingSenderAddress
                    $setTargetResourceParams.PipelineTracingSenderAddress = $null
                    Mock -CommandName Set-TransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.PipelineTracingSenderAddress = $PipelineTracingSenderAddress
                }

                It 'Should call expected functions when ExternalIPAddress is null' {
                    $ExternalIPAddress = $setTargetResourceParams.ExternalIPAddress
                    $setTargetResourceParams.ExternalIPAddress = $null
                    Mock -CommandName Set-TransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.ExternalIPAddress = $ExternalIPAddress
                }

                It 'Should call expected functions when InternalDNSServers is null' {
                    $InternalDNSServers = $setTargetResourceParams.InternalDNSServers
                    $setTargetResourceParams.InternalDNSServers = $null
                    Mock -CommandName Set-TransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.InternalDNSServers = $InternalDNSServers
                }

                It 'Should call expected functions when ExternalDNSServers is null' {
                    $ExternalDNSServers = $setTargetResourceParams.ExternalDNSServers
                    $setTargetResourceParams.ExternalDNSServers = $null
                    Mock -CommandName Set-TransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.ExternalDNSServers = $ExternalDNSServers
                }

                It 'Should warn that a MSExchangeTransport service restart is required' {
                    $AllowServiceRestart = $setTargetResourceParams.AllowServiceRestart
                    $setTargetResourceParams.AllowServiceRestart = $false
                    Mock -CommandName Set-TransportService -Verifiable
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter {$Message -eq 'The configuration will not take effect until the MSExchangeTransport service is manually restarted.'}

                    Set-TargetResource @setTargetResourceParams
                    $setTargetResourceParams.AllowServiceRestart = $AllowServiceRestart
                }
            }
        }

        Describe 'MSFT_xExchTransportService\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            function Get-TransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                It 'Should return False when Get-TransportService returns False' {
                    Mock -CommandName Get-TransportService -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }
                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-TransportService -Verifiable -MockWith { return $commonTransportServiceStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-TransportService -Verifiable -MockWith { return $commonTransportServiceStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
