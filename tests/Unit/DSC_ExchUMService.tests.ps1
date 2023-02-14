$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchService'
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
        Describe 'DSC_ExchService\Get-TargetResource' -Tag 'Get' {
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
