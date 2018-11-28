#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchWaitForADPrep'

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
        Describe 'MSFT_xExchWaitForADPrep\Get-TargetResource' -Tag 'Get' {
            # Override Active Directory cmdlets
            function Get-ADRootDSE {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity = 'Identity'
            }

            Mock -CommandName Write-FunctionEntry -Verifiable

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-ADRootDSE -Verifiable -MockWith { return 'RootDSE' }
                Mock -CommandName Get-SchemaVersion -Verifiable -MockWith { return 1 }
                Mock -CommandName Get-OrganizationVersion -Verifiable -MockWith { return 1 }
                Mock -CommandName Get-DomainsVersion -Verifiable -MockWith { return @{} }
                Mock -CommandName Get-StringFromHashtable -Verifiable -MockWith { return '' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When a null ADRootDSE is returned from Get-ADRootDSEInternal' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-ADRootDSE -Verifiable

                    { Get-TargetResource @getTargetResourceParams } | Should -Throw -ExpectedMessage 'Unable to retrieve ADRootDSE'
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Set-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Identity = 'Identity'
            }

            Mock -CommandName Write-FunctionEntry -Verifiable

            Context 'When Wait-ForTrueTestTargetResource returns true' {
                It 'Should not throw' {
                    Mock -CommandName Wait-ForTrueTestTargetResource -MockWith { return $true }

                    { Set-TargetResource @setTargetResourceParams } | Should -Not -Throw
                }
            }

            Context 'When Wait-ForTrueTestTargetResource returns false' {
                It 'Should throw' {
                    Mock -CommandName Wait-ForTrueTestTargetResource -MockWith { return $false }

                    { Set-TargetResource @setTargetResourceParams } | Should -Throw 'AD has still not been prepped after the maximum amount of retries.'
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Test-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable

            Context 'When Test-TargetResource is called with only mandatory parameters' {
                It 'Should return true' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith { return 'Results' }

                    Test-TargetResource -Identity 'Identity' | Should -Be $true
                }
            }

            Context 'When SchemaVersion is less than the desired version' {
                It 'Should return false' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            SchemaVersion = 1023
                        }
                    }

                    Test-TargetResource -Identity 'Identity' -SchemaVersion 1024 | Should -Be $false
                }
            }

            Context 'When SchemaVersion is greater than or equal to the desired version' {
                It 'Should return true' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            SchemaVersion = 1024
                        }
                    }

                    Test-TargetResource -Identity 'Identity' -SchemaVersion 1024 | Should -Be $true
                    Test-TargetResource -Identity 'Identity' -SchemaVersion 1023 | Should -Be $true
                }
            }

            Context 'When OrganizationVersion is less than the desired version' {
                It 'Should return false' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            OrganizationVersion = 1023
                        }
                    }

                    Test-TargetResource -Identity 'Identity' -OrganizationVersion 1024 | Should -Be $false
                }
            }

            Context 'When OrganizationVersion is greater than or equal to the desired version' {
                It 'Should return true' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            OrganizationVersion = 1024
                        }
                    }

                    Test-TargetResource -Identity 'Identity' -OrganizationVersion 1024 | Should -Be $true
                    Test-TargetResource -Identity 'Identity' -OrganizationVersion 1023 | Should -Be $true
                }
            }

            Context 'When DomainVersion is less than the desired version' {
                It 'Should return false' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            DomainVersionHashtable = @{
                                'domain1.local' = 1023
                            }
                        }
                    }
                    Mock -CommandName Get-EachExchangeDomainFQDN -Verifiable -MockWith { return @('domain1.local') }

                    Test-TargetResource -Identity 'Identity' -DomainVersion 1024 | Should -Be $false
                }
            }

            Context 'When DomainVersion is greater than or equal to the desired version' {
                It 'Should return true' {
                    Mock -CommandName Get-TargetResource -Verifiable -MockWith {
                        return @{
                            DomainVersionHashtable = @{
                                'domain1.local' = 1024
                            }
                        }
                    }
                    Mock -CommandName Get-EachExchangeDomainFQDN -Verifiable -MockWith { return @('domain1.local') }

                    Test-TargetResource -Identity 'Identity' -DomainVersion 1024 | Should -Be $true
                    Test-TargetResource -Identity 'Identity' -DomainVersion 1023 | Should -Be $true
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-ADRootDSEInternal' -Tag 'Helper' {
            # Override Active Directory cmdlets
            function Get-ADRootDSE {}

            AfterEach {
                Assert-VerifiableMock
            }

            $testCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

            Context 'When Get-ADRootDSEInternal is called' {
                It 'Should return the Get-ADRootDSE results' {
                    Mock -CommandName Get-ADRootDSE -Verifiable -MockWith { return 'Results' }

                    Get-ADRootDSEInternal -Credential $testCreds | Should -Be -Not $null
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-ADObjectInternal' -Tag 'Helper' {
            # Override Active Directory cmdlets
            function Get-ADObject {}

            AfterEach {
                Assert-VerifiableMock
            }

            $testDN = 'TestDistinguishedName'
            $testProps = @('Prop1', 'Prop2')
            $testCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

            Context 'When Searching -eq False and Get-ADObject returns a valid object' {
                It 'Should return the object' {
                    Mock -CommandName Get-ADObject -Verifiable -MockWith { return 'SomeObject' }

                    Get-ADObjectInternal -DistinguishedName $testDN -Properties $testProps -Credential $testCreds | Should -Be -Not $null
                }
            }

            Context 'When Searching -eq True and Get-ADObject returns a valid object' {
                It 'Should return the object' {
                    Mock -CommandName Get-ADObject -Verifiable -MockWith { return 'SomeObject' }

                    Get-ADObjectInternal -DistinguishedName $testDN -Properties $testProps -Searching $true -Filter 'Filter' -SearchScope 'Scope' | Should -Be -Not $null
                }
            }

            Context 'When Get-ADObjectInternal is called and Get-ADObject throws an exception' {
                It 'Should write a warning and return null' {
                    Mock -CommandName Get-ADObject -Verifiable -MockWith { throw 'TestException' }
                    Mock -CommandName Write-Warning -Verifiable

                    Get-ADObjectInternal -DistinguishedName $testDN -Properties $testProps | Should -Be $null
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-SchemaVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ADObjectInternal returns a valid schema object' {
                It 'Should return an Int value' {
                    $rangeUpper = 1024

                    Mock -CommandName Get-ADObjectInternal -Verifiable -MockWith {
                        return @{
                            rangeUpper = $rangeUpper
                        }
                    }

                    Get-SchemaVersion -ADRootDSE 'NotNull' | Should -Be $rangeUpper
                }
            }

            Context 'When Get-ADObjectInternal returns null' {
                It 'Should return null' {
                    Mock -CommandName Get-ADObjectInternal -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    Get-SchemaVersion -ADRootDSE 'NotNull' | Should -Be $null
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-OrganizationVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When both Get-ADObjectInternal calls return valid objects' {
                It 'Should return an Int value' {
                    $rangeUpper = 1024
                    $objectVersion = 1025

                    Mock -CommandName Get-ADObjectInternal -ParameterFilter {$Properties.Contains('rangeUpper')} -Verifiable -MockWith {
                        return @{
                            rangeUpper = $rangeUpper
                        }
                    }

                    Mock -CommandName Get-ADObjectInternal -ParameterFilter {$Properties.Contains('objectVersion')} -Verifiable -MockWith {
                        return @{
                            objectVersion = $objectVersion
                        }
                    }

                    Get-OrganizationVersion -ADRootDSE 'NotNull' | Should -Be $objectVersion
                }
            }

            Context 'When the first Get-ADObjectInternal call returns null' {
                It 'Should return null' {
                    Mock -CommandName Get-ADObjectInternal -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    Get-OrganizationVersion -ADRootDSE 'NotNull' | Should -Be $null
                }
            }

            Context 'When Get-OrganizationVersion is called, the first Get-ADObjectInternal call succeeds, but the second does not' {
                It 'Should return null' {
                    $rangeUpper = 1024

                    Mock -CommandName Get-ADObjectInternal -ParameterFilter {$Properties.Contains('rangeUpper')} -Verifiable -MockWith {
                        return @{
                            rangeUpper = $rangeUpper
                        }
                    }

                    Mock -CommandName Get-ADObjectInternal -ParameterFilter {!$Properties.Contains('rangeUpper')} -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    Get-OrganizationVersion -ADRootDSE 'NotNull' | Should -Be $null
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-DomainsVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $domainVersion = 1024
            $domainVersions = @{
                'domain1.local' = $domainVersion
                'domain2.local' = $domainVersion
            }

            Mock -CommandName Get-EachExchangeDomainFQDN -Verifiable -MockWith { return $domainVersions.Keys }
            Mock -CommandName Get-DomainDNFromFQDN -Verifiable

            Context 'When domain information is successfully retrieved' {
                It 'Should return a Hashtable of domain versions' {
                    Mock -CommandName Get-ADObjectInternal -Verifiable -MockWith {
                        return @{
                            objectVersion = $domainVersion
                        }
                    }

                    $domainVersionsOut = Get-DomainsVersion

                    $domainVersionsOut.Count | Should -Be 2

                    foreach ($domain in $domainVersions.Keys)
                    {
                        $domainVersionsOut.ContainsKey($domain) | Should -Be $true
                        $domainVersionsOut[$domain] | Should -Be $domainVersion
                    }
                }
            }

            Context 'When domain information cannot be retrieved' {
                It 'Should return a Hashtable of domains with null values' {
                    Mock -CommandName Get-ADObjectInternal -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    $domainVersionsOut = Get-DomainsVersion

                    $domainVersionsOut.Count | Should -Be 2

                    foreach ($domain in $domainVersions.Keys)
                    {
                        $domainVersionsOut.ContainsKey($domain) | Should -Be $true
                        $domainVersionsOut[$domain] | Should -Be $null
                    }
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Get-EachExchangeDomainFQDN' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $machineDomain = 'domain1.local'

            Mock -CommandName Get-CimInstance -Verifiable -MockWith {
                return @{
                    Domain = $machineDomain
                }
            }

            Context 'When no ExchangeDomains are specified' {
                It 'Should return just the Exchange Server domain' {
                    $exchangeDomainFqdns = Get-EachExchangeDomainFQDN

                    $exchangeDomainFqdns.Count | Should -Be 1
                    $exchangeDomainFqdns.Contains($machineDomain.ToLower()) | Should -Be $true
                }
            }

            Context 'When ExchangeDomains are specified' {
                It 'Should return the Exchange Server domain plus any Exchange Domains' {
                    $exchangeDomains = @(
                        'domain2.local'
                        'domain3.local'
                    )

                    $exchangeDomainFqdns = Get-EachExchangeDomainFQDN -ExchangeDomains $exchangeDomains

                    $exchangeDomainFqdns.Count | Should -Be 3

                    $exchangeDomainFqdns.Contains($machineDomain.ToLower()) | Should -Be $true

                    foreach ($domain in $exchangeDomains)
                    {
                        $exchangeDomainFqdns.Contains($domain.ToLower()) | Should -Be $true
                    }
                }
            }
        }

        Describe 'MSFT_xExchWaitForADPrep\Wait-ForTrueTestTargetResource' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource returns true' {
                It 'Should return true' {
                    Mock -CommandName Test-TargetResource -Verifiable -MockWith { return $true }
                    Mock -CommandName Start-Sleep

                    Wait-ForTrueTestTargetResource -Identity 'Identity' -RetryIntervalSec 1 -RetryCount 1 | Should -Be $true

                    Assert-MockCalled -CommandName Start-Sleep -Times 0
                }
            }

            Context 'When Test-TargetResource returns false' {
                It 'Should return false' {
                    Mock -CommandName Test-TargetResource -Verifiable -MockWith { return $false }
                    Mock -CommandName Start-Sleep -Verifiable

                    Wait-ForTrueTestTargetResource -Identity 'Identity' -RetryIntervalSec 1 -RetryCount 1 | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
