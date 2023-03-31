$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchSendConnector'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'ExchangeDscTestHelper.psm1'))) -Global -Force

$script:testEnvironment = Invoke-TestSetup -DSCModuleName $script:dscModuleName -DSCResourceName $script:dscResourceName

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
        function Get-ADPermission
        {
            param(
                $Identity
            )
        }
        function Get-DomainController
        {

        }
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
        function Get-SendConnector
        {
            param ()
        }
        function Set-SendConnector
        {
            param (
                $Identity
            )
        }
        function Remove-SendConnector
        {
            param (
                $Identity
            )
        }
        function New-SendConnector
        {
            param (
                $AddressSpace,
                $Name
            )
        }
        Describe 'DSC_ExchSendConnector\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Name          = 'MySendConnector'
                Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AddressSpaces = @(
                    'SMTP:contoso.com; 1',
                    'SMTP:tailspintoys.com; 1'
                )
            }

            $getSendConnectorOutput = @{
                Identity            = 'MySendConnector'
                AddressSpaces       = 'contoso.com'
                DNSRoutingEnabled   = $true
                DomainSecureEnabled = $true
                Enabled             = $true
                IgnoreSTARTTLS      = $false
                MaxMessageSize      = '100 MB'
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When Get-TargetResource is called and resource is present' {
                Mock -CommandName Get-SendConnector -Verifiable -MockWith { return [PSCustomObject] $getSendConnectorOutput }

                Mock -CommandName Get-ADPermission -ModuleName 'ExchangeDscHelper'

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
            Context 'When resource is not present' {
                It 'Should return Absent' {
                    Mock -CommandName Get-SendConnector -Verifiable
                    Mock -CommandName Get-ADPermission -ModuleName 'ExchangeDscHelper'

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -be 'Absent'
                }
            }
            Context 'When resource is present' {
                It 'When Name matches' {
                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable
                    Mock -CommandName Get-ADPermission -ModuleName 'ExchangeDscHelper'

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -Be 'Present'
                }
                It 'When AddressSpaces matches' {
                    $getSendConnectorAddressSpaces = @{ } + $getSendConnectorOutput
                    $getSendConnectorAddressSpaces['Name'] = 'WrongSendConnectorName'
                    $getSendConnectorAddressSpaces['AddressSpaces'] = @(
                        'SMTP:contoso.com; 1',
                        'SMTP:tailspintoys.com; 1'
                    )

                    Mock -CommandName Get-ADPermission -ModuleName 'ExchangeDscHelper'
                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -Be 'Present'
                }

                Context 'Extended rights are present' {
                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable
                    Mock -CommandName Get-ADPermission -MockWith {
                        $ADPermissions = @()
                        $permission += [PSCustomObject] @{
                            IsInherited    = $false
                            User           = [PSCustomObject] @{
                                RawIdentity = 'User1Allow'
                            }
                            Deny           = $false
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
                            Deny           = $false
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
                            Deny           = $true
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
                            Deny           = $true
                            ExtendedRights = [PSCustomObject] @{
                                RawIdentity = 'ms-Exch-SMTP-Accept-Any-Sender'
                            }
                        }
                        $ADPermissions += $permission

                        return $ADPermissions
                    } -ModuleName 'ExchangeDscHelper'

                    It 'Should yield the correct pemissions' {
                        $result = Get-TargetResource @getTargetResourceParams
                        $result['ExtendedRightAllowEntries'].Key | Should -Be 'User1Allow'
                        $result['ExtendedRightAllowEntries'].Value | Should -Be 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'

                        $result['ExtendedRightDenyEntries'].Key | Should -Be 'User2Deny'
                        $result['ExtendedRightDenyEntries'].Value | Should -Be 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    }
                }
            }
        }

        Describe 'DSC_ExchSendConnector\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Name                = 'MySendConnector'
                AddressSpaces       = 'contoso.com'
                DNSRoutingEnabled   = $true
                DomainSecureEnabled = $true
                Enabled             = $true
                IgnoreSTARTTLS      = $false
                MaxMessageSize      = '100 MB'
                Ensure              = 'Present'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When resource is present' {
                $getSendConnectorOutput = @{
                    Ensure = 'Present'
                }

                Mock -CommandName Get-TargetResource -MockWith { return $getSendConnectorOutput }

                Context 'When Absent is specified' {
                    $setTargetResourceAbsent = @{ } + $setTargetResourceParams
                    $setTargetResourceAbsent['Ensure'] = 'Absent'

                    It 'Should call Remove-SendConnector' {
                        Mock -CommandName Remove-SendConnector -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable

                        Set-TargetResource @setTargetResourceAbsent
                    }
                }
                Context 'When properties are not correct' {
                    It 'Should call Set-Sendconnector' {
                        Mock -CommandName Set-SendConnector -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }
                Context 'When extended allow permissions are specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightAllowEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User1Allow' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                }
                Context 'When extended deny permissions are specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightDenyEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User2Deny' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                        }

                        Set-TargetResource @setTargetResourcePermissions }
                }
            }
            Context 'When resource is not present' {
                $getSendConnectorOutput = @{
                    Ensure = 'Absent'
                }

                Mock -CommandName Get-TargetResource -MockWith { return $getSendConnectorOutput }

                It 'Should call New-SendConnector' {
                    Mock -CommandName New-SendConnector -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }

                Context 'When extended allow permissions are specified and no DC is specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightAllowEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Get-ADPermission' -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable -MockWith {
                            return $setTargetResourcePermissions['ExtendedRightAllowEntries']
                        }
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User1Allow' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient')
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                    It 'Should throw if the connector was not found after 2 minutes' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Get-ADPermission' -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable

                        { Set-TargetResource @setTargetResourcePermissions } | Should -Throw 'The new send connector was not found after 2 minutes of wait time. Please check AD replication!'
                    }
                }

                Context 'When extended allow permissions are specified and DC is specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightAllowEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User1Allow'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly
                    $setTargetResourcePermissions['DomainController'] = 'dc.contoso.com'

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User1Allow' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient') -and
                            $DomainController -eq 'dc.contoso.com'
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                }

                Context 'When extended deny permissions are specified and no DC is specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightDenyEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Get-ADPermission' -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable -MockWith {
                            return $setTargetResourcePermissions['ExtendedRightDenyEntries']
                        }
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User2Deny' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Sender')
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                    It 'Should throw if the connector was not found after 2 minutes' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Get-ADPermission' -ParameterFilter { $Identity -eq 'MySendConnector' } -Verifiable

                        { Set-TargetResource @setTargetResourcePermissions } | Should -Throw 'The new send connector was not found after 2 minutes of wait time. Please check AD replication!'
                    }
                }

                Context 'When extended deny permissions are specified and DC is specified' {
                    $setTargetResourcePermissions = @{ } + $setTargetResourceParams
                    $setTargetResourcePermissions['ExtendedRightDenyEntries'] = New-CimInstance -ClassName MSFT_KeyValuePair -Property @{
                        key   = 'User2Deny'
                        value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
                    } -ClientOnly
                    $setTargetResourcePermissions['DomainController'] = 'dc.contoso.com'

                    It 'Should call the Add-ADPermission' {
                        Mock -CommandName 'New-SendConnector' -ParameterFilter { $Name -eq 'MySendConnector' } -Verifiable
                        Mock -CommandName 'Add-ADPermission' -Verifiable -ParameterFilter {
                            $Identity -eq 'MySendConnector' -and
                            $User -eq 'User2Deny' -and
                            ($ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient' -or
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient') -and
                            $DomainController -eq 'dc.contoso.com'
                        }

                        Set-TargetResource @setTargetResourcePermissions
                    }
                }
            }
        }

        Describe 'DSC_ExchSendConnector\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            $TestTargetResourceParams = @{
                Name                = 'MySendConnector'
                AddressSpaces       = @('contoso.com' , 'SMTP:tailspintoys.com:1')
                DNSRoutingEnabled   = $true
                DomainSecureEnabled = $true
                Enabled             = $true
                IgnoreSTARTTLS      = $false
                Ensure              = 'Present'
                Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When resource does not exist' {
                $getSendConnectorOutput = @{
                    Ensure = 'Absent'
                }

                Mock -CommandName Get-TargetResource -MockWith { return $getSendConnectorOutput }

                Test-TargetResource @TestTargetResourceParams | Should -Be $false
            }
            Context 'When resource exists' {

                $getSendConnectorOutput = @{
                    Identity            = 'MySendConnector'
                    AddressSpaces       = @('contoso.com' , 'SMTP:tailspintoys.com:1')
                    DNSRoutingEnabled   = $true
                    DomainSecureEnabled = $true
                    Enabled             = $true
                    IgnoreSTARTTLS      = $false
                    Ensure              = 'Present'
                    Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                }

                Context 'When Absent is specified' {
                    It 'Should return false' {
                        $TestTargetResourceParamsAbsent = @{ } + $TestTargetResourceParams
                        $TestTargetResourceParamsAbsent['Ensure'] = 'Absent'

                        Mock -CommandName Get-TargetResource -MockWith { return $getSendConnectorOutput }

                        Test-TargetResource @TestTargetResourceParamsAbsent | Should -Be $false
                    }
                }

                Context 'When a property does not match' {
                    It 'Should return false' {
                        $getSendConnectorOutputFalse = @{ } + $getSendConnectorOutput
                        $getSendConnectorOutputFalse['DNSRoutingEnabled'] = $false

                        Mock -CommandName 'Get-TargetResource' -MockWith { return $getSendConnectorOutputFalse }

                        Test-TargetResource @TestTargetResourceParams | Should -Be $false
                    }
                }

                Context 'When all properties match' {
                    It 'Should return true' {
                        Mock -CommandName 'Get-TargetResource' -MockWith { return $getSendConnectorOutput }

                        Test-TargetResource @TestTargetResourceParams | Should -Be $true
                    }
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
                    Mock -CommandName 'Get-TargetResource' -MockWith { return $getSendConnectorOutput }

                    Context 'When permissions do not match' {
                        It 'Should return $false' {
                            $TestTargetResourceParamsFalse = @{ } + $TestTargetResourceParams
                            $TestTargetResourceParamsFalse['ExtendedRightAllowEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User1Allow'
                                    # Picking 2 random permissions to test with
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Authoritative-Domain-Sender'
                                } -ClientOnly
                            )

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
        }
    }
}
finally
{
    Invoke-TestCleanup
}
