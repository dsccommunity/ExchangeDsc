#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchClientAccessServer'

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
        Describe 'MSFT_xExchClientAccessServer\Get-TargetResource' -Tag 'Get' {
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
                    $siteScopeOut = @('Site1','Site2')

                    Mock -CommandName Get-ClientAccessServerInternal -Verifiable -MockWith {
                        $siteScopeVar = New-Object -TypeName PSObject

                        Add-Member -MemberType ScriptMethod -InputObject $siteScopeVar -Name 'ToArray' -Value { return @('Site1','Site2') }

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
