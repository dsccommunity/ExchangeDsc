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
            Identity   = 'FrontendTransportService'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        $commonFrontendTransportServiceStandardOutput = @{
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
            MaxConnectionRatePerMinute                     = [System.Int32] 1
            ReceiveProtocolLogMaxAge                       = [System.String] ''
            ReceiveProtocolLogMaxDirectorySize             = [System.String] ''
            ReceiveProtocolLogMaxFileSize                  = [System.String] ''
            ReceiveProtocolLogPath                         = [System.String] ''
            RoutingTableLogMaxAge                          = [System.String] ''
            RoutingTableLogMaxDirectorySize                = [System.String] ''
            RoutingTableLogPath                            = [System.String] ''
            SendProtocolLogMaxAge                          = [System.String] ''
            SendProtocolLogMaxDirectorySize                = [System.String] ''
            SendProtocolLogMaxFileSize                     = [System.String] ''
            SendProtocolLogPath                            = [System.String] ''
            TransientFailureRetryCount                     = [System.Int32] 1
            TransientFailureRetryInterval                  = [System.String] ''
        }

        Mock -CommandName Write-FunctionEntry -Verifiable

        Describe 'MSFT_xExchFrontendTransportService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-FrontendTransportService {}

            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            Mock -CommandName Get-FrontendTransportService -Verifiable -MockWith { return $commonFrontendTransportServiceStandardOutput }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }
        Describe 'MSFT_xExchFrontendTransportService\Set-TargetResource' -Tag 'Set' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable
            function Set-FrontendTransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Identity            = 'FrontendTransportService'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AllowServiceRestart = $true
            }

            Context 'When Set-TargetResource is called' {
                It 'Should call expected functions when AllowServiceRestart is true' {
                    Mock -CommandName Set-FrontendTransportService -Verifiable
                    Mock -CommandName Restart-Service -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }

                It 'Should call expected functions when ExternalIPAddress is null' {
                    $ExternalIPAddress = $setTargetResourceParams.ExternalIPAddress
                    $setTargetResourceParams.ExternalIPAddress = $null
                    Mock -CommandName Set-FrontendTransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.ExternalIPAddress = $ExternalIPAddress
                }

                It 'Should call expected functions when InternalDNSServers is null' {
                    $InternalDNSServers = $setTargetResourceParams.InternalDNSServers
                    $setTargetResourceParams.InternalDNSServers = $null
                    Mock -CommandName Set-FrontendTransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.InternalDNSServers = $InternalDNSServers
                }

                It 'Should call expected functions when ExternalDNSServers is null' {
                    $ExternalDNSServers = $setTargetResourceParams.ExternalDNSServers
                    $setTargetResourceParams.ExternalDNSServers = $null
                    Mock -CommandName Set-FrontendTransportService -Verifiable

                    Set-TargetResource @setTargetResourceParams

                    $setTargetResourceParams.ExternalDNSServers = $ExternalDNSServers
                }

                It 'Should warn that a MSExchangeFrontEndTransport service restart is required' {
                    $AllowServiceRestart = $setTargetResourceParams.AllowServiceRestart
                    $setTargetResourceParams.AllowServiceRestart = $false
                    Mock -CommandName Set-FrontendTransportService -Verifiable
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter {$Message -eq 'The configuration will not take effect until the MSExchangeFrontEndTransport service is manually restarted.'}

                    Set-TargetResource @setTargetResourceParams
                    $setTargetResourceParams.AllowServiceRestart = $AllowServiceRestart
                }
            }
        }

        Describe 'MSFT_xExchFrontendTransportService\Test-TargetResource' -Tag 'Test' {
            # Override Exchange cmdlets
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            function Get-FrontendTransportService {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                It 'Should return False when Get-FrontendTransportService returns False' {
                    Mock -CommandName Get-FrontendTransportService -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }
                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-FrontendTransportService -Verifiable -MockWith { return $commonFrontendTransportServiceStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-FrontendTransportService -Verifiable -MockWith { return $commonFrontendTransportServiceStandardOutput }
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
