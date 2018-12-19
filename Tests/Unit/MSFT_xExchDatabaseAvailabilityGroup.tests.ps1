#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchDatabaseAvailabilityGroup'

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
        Describe 'MSFT_xExchDatabaseAvailabilityGroup\Get-TargetResource' -Tag 'Get' {
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
