$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchopSettings'
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
        Describe 'DSC_ExchopSettings\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Server     = 'Server'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getPopSettingsStandardOutput = @{
                ExternalConnectionSettings = [System.String[]] @()
                LoginType                  = [System.String] ''
                ProtocolLogEnabled         = [System.Boolean] $false
                X509CertificateName        = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-PopSettingsInternal -Verifiable -MockWith { return $getPopSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
