#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchAutodiscoverVirtualDirectory'

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
        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'AutodiscoverVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getAutodiscoverVirtualDirectoryInternalStandardOutput = @{
                BasicAuthentication             = [System.Boolean] $false
                DigestAuthentication            = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                OAuthAuthentication             = [System.Boolean] $false
                WindowsAuthentication           = [System.Boolean] $false
                WSSecurityAuthentication        = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-AutodiscoverVirtualDirectoryInternal -Verifiable -MockWith { return $getAutodiscoverVirtualDirectoryInternalStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }

        Describe 'MSFT_xExchAutodiscoverVirtualDirectory\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setTargetResourceParams = @{
                Identity   = 'AutodiscoverVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getAutodiscoverVirtualDirectoryInternalStandardOutput = @{
                BasicAuthentication             = [System.Boolean] $false
                DigestAuthentication            = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                OAuthAuthentication             = [System.Boolean] $false
                WindowsAuthentication           = [System.Boolean] $false
                WSSecurityAuthentication        = [System.Boolean] $false
            }

            Context 'When Set-TargetResource is called' {
                It 'Should warn about restarting the MSExchangeAutodiscoverAppPool' {
                    function Set-AutodiscoverVirtualDirectory{
                    }
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Set-AutodiscoverVirtualDirectory -Verifiable
                    Mock -CommandName Write-Warning -ParameterFilter {$message -eq 'The configuration will not take effect until MSExchangeAutodiscoverAppPool is manually recycled.'}
                    Set-TargetResource @setTargetResourceParams
                }

                It 'Should call expected functions' {
                    function Set-AutodiscoverVirtualDirectory{
                    }
                    $setTargetResourceParams.AllowServiceRestart = $true
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Set-AutodiscoverVirtualDirectory -Verifiable
                    Mock -CommandName Restart-ExistingAppPool -Verifiable
                    Set-TargetResource @setTargetResourceParams
                    $setTargetResourceParams.Remove('AllowServiceReset')
                }

                It 'Should throw error about SPN' {
                    Mock -CommandName Write-FunctionEntry -Verifiable
                    Mock -CommandName Get-RemoteExchangeSession -Verifiable
                    Mock -CommandName Test-ExtendedProtectionSPNList -Verifiable -MockWith { return $false }

                    Set-TargetResource @setTargetResourceParams | Should -Throw -ExpectedMessage 'SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
