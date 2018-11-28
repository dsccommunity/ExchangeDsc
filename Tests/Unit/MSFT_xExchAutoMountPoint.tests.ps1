#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchAutoMountPoint'

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
        Describe 'MSFT_xExchAutoMountPoint\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity                       = 'AutodiscoverVirtualDirectory'
                AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
                AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
                DiskToDBMap                    = @('DB1,DB2,DB3,DB4')
                SpareVolumeCount               = 1
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-DiskInfo -Verifiable -MockWith { return @{} }
                Mock -CommandName Get-DiskToDBMap -Verifiable -MockWith { return $getTargetResourceParams.DiskToDBMap }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
