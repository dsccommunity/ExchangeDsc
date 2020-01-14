$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchMaintenanceMode'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

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
        Describe 'MSFT_xExchMaintenanceMode\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Enabled    = $true
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getMaintenanceModeStatusStandardOutput = @{
                ServerComponentState = @(
                    @{
                        Component = 'Component1'
                        State     = 'Active'
                    }
                    @{
                        Component = 'Component2'
                        State     = 'Active'
                    }
                )
                ClusterNode = @{
                    State = 'Paused'
                }
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-MaintenanceModeStatus -Verifiable -MockWith { return $getMaintenanceModeStatusStandardOutput }
                Mock -CommandName Test-ExchangeAtDesiredVersion -Verifiable -MockWith { return $true }
                Mock -CommandName Get-ActiveDBCount -Verifiable -MockWith { return 0 }
                Mock -CommandName Get-UMCallCount -Verifiable -MockWith { return 0 }
                Mock -CommandName Get-QueueMessageCount -Verifiable -MockWith { return 0 }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

