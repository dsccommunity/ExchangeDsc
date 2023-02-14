$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchutlookAnywhere'
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
        Describe 'DSC_ExchutlookAnywhere\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'OutlookAnywhere'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getOutlookAnywhereStandardOutput = @{
                ExtendedProtectionFlags            = [System.String[]] @()
                ExtendedProtectionSPNList          = [System.String[]] @()
                ExtendedProtectionTokenChecking    = [System.String] ''
                ExternalClientAuthenticationMethod = [System.String] ''
                ExternalClientsRequireSsl          = [System.Boolean] $false
                ExternalHostname                   = [System.String] ''
                IISAuthenticationMethods           = [System.String[]] @()
                InternalClientAuthenticationMethod = [System.String] ''
                InternalClientsRequireSsl          = [System.Boolean] $false
                InternalHostname                   = [System.String] ''
                SSLOffloading                      = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-OutlookAnywhereInternal -Verifiable -MockWith { return $getOutlookAnywhereStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
