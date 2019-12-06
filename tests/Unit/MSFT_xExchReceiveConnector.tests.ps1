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
        function Add-ADPermission
        {
            param(
                $Identity,
                $User,
                $ExtendedRights,
                [Switch]
                $Deny
            )
        }
        function Get-ADPermission
        {
            param()
        }
        function Get-ReceiveConnector
        {
            param ()
        }
        function Set-ReceiveConnector
        {
            param (
                $Identity
            )
        }
        function New-ReceiveConnector
        {
            param (
                $Name
            )
        }
        function Remove-ReceiveConnector
        {
            param (
                $Identity
            )
        }
        Describe 'MSFT_xExchReceiveConnector\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'Server1\ReceiveConnector'
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
                Identity                                = [System.String] 'Server1\ReceiveConnector'
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
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-ReceiveConnector -Verifiable -MockWith { return $getReceiveConnectorStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
                $results = Get-TargetResource @getTargetResourceParams
                $results['Ensure'] | Should -Be 'Present'
            }
            Context 'When receive connector does not exists' {
                It 'Should return Absent' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Get-ReceiveConnector -Verifiable

                    $results = Get-TargetResource @getTargetResourceParams
                    $results['Ensure'] | Should -Be 'Absent'
                }
            }
            Context 'When the identity is not correct' {
                It 'Should throw an exception' {
                    $getTargetResourceParamsWrong = @{ } + $getTargetResourceParams
                    $getTargetResourceParamsWrong['Identity'] = 'WrongIdentity'

                    { Get-TargetResource @getTargetResourceParamsWrong } | Should -Throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
                }
            }
        }
        Describe 'MSFT_xExchReceiveConnector\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $setTargetResourceParams = @{
                Identity            = 'Server1\ReceiveConnector'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                Ensure              = 'Present'
                DomainSecureEnabled = $false
                ConnectionTimeout   = '00:30:30'
            }

            Context 'When the receive connector is present' {
                Mock -CommandName Get-TargetResource -Verifiable -MockWith { return @{
                        Ensure = 'Present'
                    }
                }

                It 'Should remove the connector when Absent is specified' {

                    $setTargetResourceParamsAbsent = @{ } + $setTargetResourceParams
                    $setTargetResourceParamsAbsent['Ensure'] = 'Absent'

                    Mock -CommandName Remove-ReceiveConnector -ParameterFilter { $Identity -eq 'Server1\ReceiveConnector' } -Verifiable

                    Set-TargetResource @setTargetResourceParamsAbsent
                }
                It 'Should set the connector properites' {
                    Mock -CommandName Set-ReceiveConnector -ParameterFilter { $Identity -eq 'Server1\ReceiveConnector' } -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }
                It 'Should set the allow Permissions when specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightAllowEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'ReceiveConnector' -and
                        $User -eq 'User1Allow' -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    Set-TargetResource @setTargetResourcePermissions
                }
                It 'Should set the deny Permissions when specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightDenyEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                        $Identity -eq 'ReceiveConnector' -and
                        $User -eq 'User2Deny' -and
                        $Deny -eq $true -and
                        ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                            $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                    }

                    Set-TargetResource @setTargetResourcePermissions
                }
            }
            Context 'When the receive connector is not present' {
                Mock -CommandName Get-TargetResource -MockWith { return @{
                        Ensure = 'Absent'
                    }
                } -Verifiable

                It 'Should create the receive connector' {
                    Mock -CommandName New-ReceiveConnector -ParameterFilter { $Name -eq 'ReceiveConnector' } -Verifiable
                    Mock -CommandName Set-ReceiveConnector -ParameterFilter { $Identity -eq 'Server1\ReceiveConnector' } -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }

                Context 'When permissions are specified' {
                    Mock -CommandName New-ReceiveConnector -ParameterFilter { $Name -eq 'ReceiveConnector' } -Verifiable
                    Mock -CommandName Set-ReceiveConnector -ParameterFilter { $Identity -eq 'Server1\ReceiveConnector' } -Verifiable

                    It 'Should set the allow Permissions when specified' {
                        $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                        $setTargetResourcePermissions['ExtendedRightAllowEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                            key   = 'User1Allow'
                            value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                        } -ClientOnly

                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'ReceiveConnector' -and
                            $User -eq 'User1Allow' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                    It 'Should set the deny Permissions when specified' {
                        $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                        $setTargetResourcePermissions['ExtendedRightDenyEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                            key   = 'User2Deny'
                            value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                        } -ClientOnly

                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'ReceiveConnector' -and
                            $User -eq 'User2Deny' -and
                            $Deny -eq $true -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                }
            }
            Context 'When the identity is not correct' {
                It 'Should throw an exception' {
                    $setTargetResourceParamsWrong = @{ } + $setTargetResourceParams
                    $setTargetResourceParamsWrong['Identity'] = 'WrongIdentity'

                    { Set-TargetResource @setTargetResourceParamsWrong } | Should -Throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
                }
            }
        }
        Describe 'MSFT_xExchReceiveConnector\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $testTargetResourceParams = @{
                Identity            = 'Server1\ReceiveConnector'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                Ensure              = 'Present'
                DomainSecureEnabled = $false
                MaxHopCount         = 1
            }

            Context 'When the receive connector is present' {
                $getTargetRessourceOutput = @{
                    AdvertiseClientSettings                 = [System.Boolean] $false
                    AuthMechanism                           = [System.String[]] @()
                    Banner                                  = [System.String] ''
                    BareLinefeedRejectionEnabled            = [System.Boolean] $false
                    BinaryMimeEnabled                       = [System.Boolean] $false
                    Bindings                                = [System.String[]] @()
                    ChunkingEnabled                         = [System.Boolean] $false
                    Comment                                 = [System.String] ''
                    ConnectionInactivityTimeout             = [System.String] ''
                    ConnectionTimeout                       = [System.String] '00:30:30'
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
                    Identity                                = [System.String] 'Server1\ReceiveConnector'
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
                    Ensure                                  = 'Present'
                }

                Mock -CommandName Get-TargetResource -Verifiable -MockWith { return $getTargetRessourceOutput }

                It 'Should return false when Absent is specified' {

                    $testTargetResourceParamsAbsent = @{ } + $testTargetResourceParams
                    $testTargetResourceParamsAbsent['Ensure'] = 'Absent'

                    Test-TargetResource @testTargetResourceParamsAbsent | Should -Be $false
                }
                It 'Should return false when property does not match' {
                    $testTargetResourceParamsNewValues = @{ } + $testTargetResourceParams
                    $testTargetResourceParamsNewValues['MaxHopCount'] = 2
                    $testTargetResourceParamsNewValues['DomainSecureEnabled'] = $true

                    Test-TargetResource @testTargetResourceParamsNewValues | Should -Be $false
                }
                It 'Should return true when properties match' {
                    Test-TargetResource @testTargetResourceParams | Should -Be $true
                }
                Context 'When extended permissions are specified' {
                    $ADPermissions = @()
                    $permission += [PSCustomObject] @{
                        IsInherited    = $false
                        User           = [PSCustomObject] @{
                            RawIdentity = 'User1Allow'
                        }
                        Deny           = [System.Management.Automation.SwitchParameter]::new($false)
                        ExtendedRights = [PSCustomObject] @{
                            RawIdentity = 'ms-Exch-SMTP-Accept-Any-Recipient'
                        }
                    }
                    $ADPermissions += $permission

                    $permission = [PSCustomObject] @{
                        IsInherited    = $false
                        User           = [PSCustomObject] @{
                            RawIdentity = 'User1Allow'
                        }
                        Deny           = [System.Management.Automation.SwitchParameter]::new($false)
                        ExtendedRights = [PSCustomObject] @{
                            RawIdentity = 'ms-Exch-SMTP-Accept-Any-Sender'
                        }
                    }
                    $ADPermissions += $permission

                    $permission = [PSCustomObject] @{
                        IsInherited    = $false
                        User           = [PSCustomObject] @{
                            RawIdentity = 'User2Deny'
                        }
                        Deny           = [System.Management.Automation.SwitchParameter]::new($true)
                        ExtendedRights = [PSCustomObject] @{
                            RawIdentity = 'ms-Exch-SMTP-Accept-Any-Recipient'
                        }
                    }
                    $ADPermissions += $permission

                    $permission = [PSCustomObject] @{
                        IsInherited    = $false
                        User           = [PSCustomObject] @{
                            RawIdentity = 'User2Deny'
                        }
                        Deny           = [System.Management.Automation.SwitchParameter]::new($true)
                        ExtendedRights = [PSCustomObject] @{
                            RawIdentity = 'ms-Exch-SMTP-Accept-Any-Sender'
                        }
                    }
                    $ADPermissions += $permission

                    Mock -CommandName 'Get-ADPermission' -MockWith { return $ADPermissions }

                    Context 'When permissions are not compliant' {
                        It 'Should return $false when extended permissions do not match' {
                            $TestTargetResourceParamsFalse = @{ } + $TestTargetResourceParams
                            $TestTargetResourceParamsFalse['ExtendedRightAllowEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User1Allow'
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Authoritative-Domain-Sender'
                                } -ClientOnly
                            )

                            Test-TargetResource @TestTargetResourceParamsFalse | Should -Be $false
                        }
                        It 'Should return $false when permissions are not present' {
                            $TestTargetResourceParamsFalse = @{ } + $TestTargetResourceParams
                            $TestTargetResourceParamsFalse['ExtendedRightAllowEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User1Allow'
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                                } -ClientOnly
                            )

                            Mock -CommandName 'Get-ADPermission' -MockWith { return ($ADPermissions | Where-Object -FilterScript { $_.User.RawIdentity -eq 'User2Deny' }) }
                            Test-TargetResource @TestTargetResourceParamsFalse | Should -Be $false
                        }
                    }
                    Context 'When permissions match' {
                        It 'Should return $true' {
                            $TestTargetResourceParamsTrue = @{ } + $TestTargetResourceParams
                            $TestTargetResourceParamsTrue['ExtendedRightAllowEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User1Allow'
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                                } -ClientOnly
                            )
                            $TestTargetResourceParamsTrue['ExtendedRightDenyEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User2Deny'
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                                } -ClientOnly
                            )

                            Test-TargetResource @TestTargetResourceParamsTrue | Should -Be $true
                        }
                    }
                }
            }
            Context 'When the receive connector is not present' {
                Mock -CommandName Get-TargetResource -MockWith { return @{
                        Ensure = 'Absent'
                    }
                } -Verifiable

                It 'Should return false when Absent is not specified' {
                    Test-TargetResource @testTargetResourceParams | Should -Be $false
                }
                It 'Should return true when Absent is specified' {
                    $testTargetResourceParamsAbsent = @{ } + $testTargetResourceParams
                    $testTargetResourceParamsAbsent['Ensure'] = 'Absent'
                    Test-TargetResource @testTargetResourceParamsAbsent | Should -Be $true
                }
            }
            Context 'When the identity is not correct' {
                It 'Should throw an exception' {
                    $testTargetResourceParamsWrong = @{ } + $testTargetResourceParams
                    $testTargetResourceParamsWrong['Identity'] = 'WrongIdentity'

                    { Test-TargetResource @testTargetResourceParamsWrong } | Should -Throw "Identity must be in the format: 'SERVERNAME\Connector Name' (No quotes)"
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

