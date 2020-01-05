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
        $basicTargetResourceParams = @{
            Identity   = 'DAGName'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        Describe 'MSFT_xExchWaitForDAG\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                Mock -CommandName Get-DAGComputerObject -Verifiable -MockWith { return 'Computer' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $basicTargetResourceParams
            }
        }

        Describe 'MSFT_xExchWaitForDAG\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When the wait for the DAG is successful' {
                It 'Should return without throwing an exception' {
                    Mock -CommandName Wait-ForDatabaseAvailabilityGroup -Verifiable -MockWith { return 'DAG' }

                    { Set-TargetResource @basicTargetResourceParams } | Should -Not -Throw
                }
            }

            Context 'When the wait for the DAG is not successful' {
                It 'Should throw an exception' {
                    Mock -CommandName Wait-ForDatabaseAvailabilityGroup -Verifiable

                    { Set-TargetResource @basicTargetResourceParams } | Should -Throw -ExpectedMessage 'Database Availability Group does not exist after waiting the specified amount of time.'
                }
            }
        }

        Describe 'MSFT_xExchWaitForDAG\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When the DAG does not exist' {
                It 'Should return false' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable
                    Mock -CommandName Get-DAGComputerObject -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    Test-TargetResource @basicTargetResourceParams | Should -Be $false
                }
            }

            Context 'When the DAG exists, the computer does not exist, and WaitForComputerObject is not specified' {
                It 'Should return true' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable

                    Test-TargetResource @basicTargetResourceParams | Should -Be $true
                }
            }

            Context 'When the DAG exists, the computer does not, and WaitForComputerObject is specified' {
                It 'Should return false' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    $basicTargetResourceParams.Add('WaitForComputerObject', $true)

                    Test-TargetResource @basicTargetResourceParams | Should -Be $false

                    $basicTargetResourceParams.Remove('WaitForComputerObject')
                }
            }

            Context 'When the DAG exists, the computer exists, and WaitForComputerObject is specified' {
                It 'Should return true' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable -MockWith { return 'Computer' }

                    $basicTargetResourceParams.Add('WaitForComputerObject', $true)

                    Test-TargetResource @basicTargetResourceParams | Should -Be $true

                    $basicTargetResourceParams.Remove('WaitForComputerObject')
                }
            }
        }

        Describe 'MSFT_xExchWaitForDAG\Get-DatabaseAvailabilityGroupInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Get-DatabaseAvailabilityGroup {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-DatabaseAvailabilityGroupInternal is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable
                    Mock -CommandName Get-DatabaseAvailabilityGroup -Verifiable

                    Get-DatabaseAvailabilityGroupInternal @basicTargetResourceParams
                }
            }
        }

        Describe 'MSFT_xExchWaitForDAG\Get-DAGComputerObject' -Tag 'Helper' {
            # Override Active Directory cmdlets
            function Get-ADComputer {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-DAGComputerObject is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Get-ADComputer -Verifiable

                    $basicTargetResourceParams.Add('DomainController', 'DC')

                    Get-DAGComputerObject @basicTargetResourceParams

                    $basicTargetResourceParams.Remove('DomainController')
                }
            }

            Context 'When Get-ADComputer throws an exception, and WaitForComputerObject is specified' {
                It 'Should write a warning' {
                    Mock -CommandName Get-ADComputer -Verifiable -MockWith { throw 'Exception' }
                    Mock -CommandName Write-Warning -Verifiable

                    $basicTargetResourceParams.Add('WaitForComputerObject', $true)

                    Get-DAGComputerObject @basicTargetResourceParams

                    $basicTargetResourceParams.Remove('WaitForComputerObject')
                }
            }
        }

        Describe 'MSFT_xExchWaitForDAG\Wait-ForDatabaseAvailabilityGroup' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $basicTargetResourceParams.Add('RetryIntervalSec', 1)
            $basicTargetResourceParams.Add('RetryCount', 1)

            Context 'When the DAG does not exist' {
                It 'Should return false' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable
                    Mock -CommandName Get-DAGComputerObject -Verifiable
                    Mock -CommandName Write-Warning -Verifiable
                    Mock -CommandName Start-Sleep -Verifiable

                    Wait-ForDatabaseAvailabilityGroup @basicTargetResourceParams | Should -Be $false
                }
            }

            Context 'When the DAG exists, the computer does not, and WaitForComputerObject is not specified' {
                It 'Should return true' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable

                    Wait-ForDatabaseAvailabilityGroup @basicTargetResourceParams | Should -Be $true
                }
            }

            Context 'When the DAG exists, the computer does not, and WaitForComputerObject is specified' {
                It 'Should return false' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable
                    Mock -CommandName Write-Warning -Verifiable
                    Mock -CommandName Start-Sleep -Verifiable

                    $basicTargetResourceParams.Add('WaitForComputerObject', $true)

                    Wait-ForDatabaseAvailabilityGroup @basicTargetResourceParams | Should -Be $false

                    $basicTargetResourceParams.Remove('WaitForComputerObject')
                }
            }

            Context 'When the DAG exists, the computer exists, and WaitForComputerObject is specified' {
                It 'Should return true' {
                    Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return 'DAG' }
                    Mock -CommandName Get-DAGComputerObject -Verifiable -MockWith { return 'Computer' }

                    $basicTargetResourceParams.Add('WaitForComputerObject', $true)

                    Wait-ForDatabaseAvailabilityGroup @basicTargetResourceParams | Should -Be $true

                    $basicTargetResourceParams.Remove('WaitForComputerObject')
                }
            }

            $basicTargetResourceParams.Remove('RetryIntervalSec')
            $basicTargetResourceParams.Remove('RetryCount')
        }
    }
}
finally
{
    Invoke-TestCleanup
}
