$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchClientAccessServer'
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
        Describe 'DSC_ExchClientAccessServer\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'ClientAccessServer'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getClientAccessServerStandardOutput = @{
                BasicAuthentication                  = [System.Boolean] $false
                DigestAuthentication                 = [System.Boolean] $false
                ExtendedProtectionFlags              = [System.String[]] @()
                ExtendedProtectionSPNList            = [System.String[]] @()
                ExtendedProtectionTokenChecking      = [System.String] ''
                OAuthAuthentication                  = [System.Boolean] $false
                WindowsAuthentication                = [System.Boolean] $false
                WSSecurityAuthentication             = [System.Boolean] $false
                AlternateServiceAccountConfiguration = @{
                    EffectiveCredentials = @{
                        Credential = $getTargetResourceParams.Credential
                    }
                }
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-ClientAccessServerInternal -Verifiable -MockWith { return $getClientAccessServerStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When AutoDiscoverSiteScope is not null' {
                It 'Should try to convert AutoDiscoverSiteScope to an array' {
                    $siteScopeOut = @('Site1', 'Site2')

                    Mock -CommandName Get-ClientAccessServerInternal -Verifiable -MockWith {
                        $siteScopeVar = New-Object -TypeName PSObject

                        Add-Member -MemberType ScriptMethod -InputObject $siteScopeVar -Name 'ToArray' -Value { return @('Site1', 'Site2') }

                        return @{
                            AutoDiscoverSiteScope = $siteScopeVar
                        }
                    }

                    $getResult = Get-TargetResource @getTargetResourceParams

                    $getResult.AutoDiscoverSiteScope | Should -Be $siteScopeOut
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
