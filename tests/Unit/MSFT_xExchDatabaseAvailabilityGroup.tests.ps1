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
