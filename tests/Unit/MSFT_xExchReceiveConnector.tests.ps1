$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchReceiveConnector'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$script:testEnvironment = Invoke-TestSetup -DSCModuleName $script:dscModuleName -DSCResourceName $script:dscResourceName

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchReceiveConnector\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'ReceiveConnector'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                Ensure     = 'Present'
            }

            $getReceiveConnectorStandardOutput = @{
                AdvertiseClientSettings                 = [System.Boolean] $false
                AuthMechanism                           = [System.String[]] @()
                Banner                                  = [System.String] ''
                BareLinefeedRejectionEnabled            = [System.Boolean] $false
                BinaryMimeEnabled                       = [System.Boolean] $false
                Bindings                                = [System.String[]] @()
                ChunkingEnabled                         = [System.Boolean] $false
                Comment                                 = [System.String] ''
                ConnectionInactivityTimeout             = [System.String] ''
                ConnectionTimeout                       = [System.String] ''
                DefaultDomain                           = [System.String] ''
                DeliveryStatusNotificationEnabled       = [System.Boolean] $false
                DomainSecureEnabled                     = [System.Boolean] $false
                EightBitMimeEnabled                     = [System.Boolean] $false
                EnableAuthGSSAPI                        = [System.Boolean] $false
                Enabled                                 = [System.Boolean] $false
                EnhancedStatusCodesEnabled              = [System.Boolean] $false
                ExtendedProtectionPolicy                = [System.String] ''
                ExtendedRightAllowEntries               = [Microsoft.Management.Infrastructure.CimInstance[]] @()
                ExtendedRightDenyEntries                = [Microsoft.Management.Infrastructure.CimInstance[]] @()
                Fqdn                                    = [System.String] ''
                LongAddressesEnabled                    = [System.Boolean] $false
                MaxAcknowledgementDelay                 = [System.String] ''
                MaxHeaderSize                           = [System.String] ''
                MaxHopCount                             = [System.Int32] 1
                MaxInboundConnection                    = [System.String] ''
                MaxInboundConnectionPercentagePerSource = [System.Int32] 1
                MaxInboundConnectionPerSource           = [System.String] ''
                MaxLocalHopCount                        = [System.Int32] 1
                MaxLogonFailures                        = [System.Int32] 1
                MaxMessageSize                          = [System.String] ''
                MaxProtocolErrors                       = [System.String] ''
                MaxRecipientsPerMessage                 = [System.Int32] 1
                MessageRateLimit                        = [System.String] ''
                MessageRateSource                       = [System.String] ''
                OrarEnabled                             = [System.Boolean] $false
                PermissionGroups                        = [System.String[]] @()
                PipeliningEnabled                       = [System.Boolean] $false
                ProtocolLoggingLevel                    = [System.String] ''
                RemoteIPRanges                          = [System.String[]] @()
                RequireEHLODomain                       = [System.Boolean] $false
                RequireTLS                              = [System.Boolean] $false
                ServiceDiscoveryFqdn                    = [System.String] ''
                SizeEnabled                             = [System.String] ''
                SuppressXAnonymousTls                   = [System.Boolean] $false
                TarpitInterval                          = [System.String] ''
                TlsCertificateName                      = [System.String] ''
                TlsDomainCapabilities                   = [System.String[]] @()
                TransportRole                           = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Assert-IdentityIsValid -Verifiable
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-ReceiveConnectorInternal -Verifiable -MockWith { return $getReceiveConnectorStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

