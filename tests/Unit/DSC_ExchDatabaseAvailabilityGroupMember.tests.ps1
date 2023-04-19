$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchDatabaseAvailabilityGroupMember'
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
        Describe 'DSC_ExchDatabaseAvailabilityGroupMember\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-DatabaseAvailabilityGroup {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                MailboxServer = 'DatabaseAvailabilityGroupMember'
                Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                DAGName       = 'DatabaseAvailabilityGroup'
            }

            $getDatabaseAvailabilityGroupMemberStandardOutput = @{
                Name    = [System.String] $getTargetResourceParams.DAGName
                Servers = @{
                    Name = $getTargetResourceParams.MailboxServer
                }
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-DatabaseAvailabilityGroup -Verifiable -MockWith { return $getDatabaseAvailabilityGroupMemberStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
