#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchSendConnector'

# Unit Test Template Version: 1.2.4
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests'))) -or `
    (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'DSCResource.Tests\TestHelper.psm1'))) )
{
    & git.exe @('clone', 'https://github.com/PowerShell/DscResource.Tests.git', (Join-Path -Path $script:moduleRoot -ChildPath 'DscResource.Tests'))
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
        function Get-ADPermission
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
        Describe 'MSFT_xExchSendConnector\Get-TargetResource' -Tag 'Get' {
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
                Name                = 'MySendConnector'
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
                Mock -CommandName Get-ADPermission

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When resource is not present' {
                It 'Should return Absent' {
                    Mock -CommandName Get-SendConnector -Verifiable
                    Mock -CommandName Get-ADPermission

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -be 'Absent'
                }
            }
            Context 'When resource is present' {
                It 'When Name matches' {
                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable

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

                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -Be 'Present'
                }

                Context 'Extended rights are present' {
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

                    Mock -CommandName Get-SendConnector -MockWith { $getSendConnectorOutput } -Verifiable
                    Mock -CommandName Get-ADPermission -MockWith {
                        return $ADPermissions
                    }

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

        Describe 'MSFT_xExchSendConnector\Set-TargetResource' -Tag 'Set' {
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
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient')
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
                                $ExtendedRights -eq 'ms-Exch-SMTP-Accept-Any-Recipient')
                        }

                        Set-TargetResource @setTargetResourcePermissions }
                }
            }
        }

        Describe 'MSFT_xExchSendConnector\Test-TargetResource' -Tag 'Test' {
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
                    Name                = 'MySendConnector'
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

                    Mock -CommandName 'Get-ADPermission' -MockWith { return $ADPermissions }
                    Mock -CommandName 'Get-TargetResource' -MockWith { return $getSendConnectorOutput }

                    Context 'When permissions do not match' {
                        It 'Should return $false' {
                            $TestTargetResourceParamsFalse = @{ } + $TestTargetResourceParams
                            $TestTargetResourceParamsFalse['ExtendedRightAllowEntries'] = (
                                New-CimInstance -ClassName 'MSFT_KeyValuePair' -Property @{
                                    key   = 'User1Allow'
                                    value = 'ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-Any-Sender'
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

