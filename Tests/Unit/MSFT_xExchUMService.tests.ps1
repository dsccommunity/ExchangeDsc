#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchUMService'

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
        Describe 'MSFT_xExchUMService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-UMService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity      = 'UMServer'
                Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                UMStartupMode = 'TLS'
            }


            $getUMServiceStandardOutput = @{
                UMStartupMode               = [System.String] $getTargetResourceParams.UMStartupMode
                DialPlans                   = [System.String[]] @()
                GrammarGenerationSchedule   = [System.String[]] @('Sun.2:00 AM-Sun.2:30 AM', 'Mon.2:00 AM-Mon.2:30 AM', 'Tue.2:00 AM-Tue.2:30 AM')
                IPAddressFamily             = [System.String] 'Any'
                IPAddressFamilyConfigurable = [System.Boolean] $true
                IrmLogEnabled               = [System.Boolean] $true
                IrmLogMaxAge                = [System.String] '30.00:00:00'
                IrmLogMaxDirectorySize      = [System.String] 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\IRMLogs'
                IrmLogMaxFileSize           = [System.String] '250 MB'
                IrmLogPath                  = [System.String] '10 MB'
                MaxCallsAllowed             = [System.Int32] '100'
                SIPAccessService            = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-UMService -Verifiable -MockWith { return $getUMServiceStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
