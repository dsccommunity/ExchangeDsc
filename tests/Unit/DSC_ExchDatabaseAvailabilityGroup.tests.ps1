$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchatabaseAvailabilityGroup'
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
        Describe 'DSC_ExchatabaseAvailabilityGroup\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Name                        = 'DatabaseAvailabilityGroup'
                Credential                  = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AutoDagTotalNumberOfServers = 1
            }

            $getDatabaseAvailabilityGroupStandardOutput = @{
                AlternateWitnessDirectory            = [System.String] ''
                AlternateWitnessServer               = [System.String] ''
                AutoDagAutoReseedEnabled             = [System.Boolean] $false
                AutoDagDatabaseCopiesPerDatabase     = [System.Int32] 1
                AutoDagDatabaseCopiesPerVolume       = [System.Int32] 1
                AutoDagDatabasesRootFolderPath       = [System.String] ''
                AutoDagDiskReclaimerEnabled          = [System.Boolean] $false
                AutoDagTotalNumberOfDatabases        = [System.Int32] 1
                AutoDagTotalNumberOfServers          = [System.Int32] 1
                AutoDagVolumesRootFolderPath         = [System.String] ''
                DatabaseAvailabilityGroupIpAddresses = [System.String[]] @()
                DatacenterActivationMode             = [System.String] ''
                ManualDagNetworkConfiguration        = [System.Boolean] $false
                NetworkCompression                   = [System.String] ''
                NetworkEncryption                    = [System.String] ''
                ReplayLagManagerEnabled              = [System.Boolean] $false
                ReplicationPort                      = [System.UInt16] 1
                WitnessDirectory                     = [System.String] ''
                WitnessServer                        = [System.String] ''
                AutoDagAutoRedistributeEnabled       = [System.Boolean] $false
                FileSystem                           = [System.String] ''
                PreferenceMoveFrequency              = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-DatabaseAvailabilityGroupInternal -Verifiable -MockWith { return $getDatabaseAvailabilityGroupStandardOutput }
                Mock -CommandName Get-ExchangeVersionYear -Verifiable -MockWith { return '2016' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
