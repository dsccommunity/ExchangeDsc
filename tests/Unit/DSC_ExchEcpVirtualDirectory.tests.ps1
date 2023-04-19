$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchEcpVirtualDirectory'
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

        function Set-ECPVirtualDirectory { }

        Mock -CommandName Write-FunctionEntry -Verifiable

        $commonTargetResourceParams = @{
            Identity   = 'EcpVirtualDirectory'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        $commonEcpVirtualDirectoryStandardOutput = @{
            AdminEnabled                    = [System.Boolean] $false
            AdfsAuthentication              = [System.Boolean] $false
            BasicAuthentication             = [System.Boolean] $false
            DigestAuthentication            = [System.Boolean] $false
            ExtendedProtectionFlags         = [System.String[]] @()
            ExtendedProtectionSPNList       = [System.String[]] @()
            ExtendedProtectionTokenChecking = [System.String] ''
            ExternalAuthenticationMethods   = [System.String[]] @()
            ExternalUrl                     = [System.String] ''
            FormsAuthentication             = [System.Boolean] $false
            GzipLevel                       = [System.String] ''
            InternalUrl                     = [System.String] ''
            WindowsAuthentication           = [System.Boolean] $false
            OwaOptionsEnabled               = [System.Boolean] $false
        }

        Describe 'DSC_ExchEcpVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable -MockWith { return $commonEcpVirtualDirectoryStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }

        Describe 'DSC_ExchEcpVirtualDirectory\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-TargetResource is called' {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable

                It 'Should warn about restarting the MSExchangeECPAppPool' {
                    Mock -CommandName Set-ECPVirtualDirectory -Verifiable
                    Mock -CommandName Write-Warning -ParameterFilter {$Message -eq 'The configuration will not take effect until MSExchangeECPAppPool is manually recycled.'}

                    Set-TargetResource @commonTargetResourceParams
                }

                It 'Should call expected functions' {
                    $commonTargetResourceParams.AllowServiceRestart = $true

                    Mock -CommandName Set-ECPVirtualDirectory -Verifiable
                    Mock -CommandName Restart-ExistingAppPool -Verifiable

                    Set-TargetResource @commonTargetResourceParams

                    $commonTargetResourceParams.Remove('AllowServiceRestart')
                }

                It 'Should throw error about SPN' {
                    Mock -CommandName Test-ExtendedProtectionSPNList -Verifiable -MockWith { return $false }

                    { Set-TargetResource @commonTargetResourceParams } | Should -Throw -ExpectedMessage 'SPN list contains DotlessSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
                }
            }
        }

        Describe 'DSC_ExchEcpVirtualDirectory\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-TargetResource is called' {
                Mock -CommandName Get-RemoteExchangeSession -Verifiable

                It 'Should return False when Get-ECPVirtualDirectoryInternal returns False' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable

                    Test-TargetResource @commonTargetResourceParams -ErrorAction SilentlyContinue | Should -Be $false
                }

                It 'Should return False when Test-ExchangeSetting returns False' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable -MockWith { return $commonEcpVirtualDirectoryStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }

                It 'Should return True when Test-ExchangeSetting returns True' {
                    Mock -CommandName Get-EcpVirtualDirectoryInternal -Verifiable -MockWith { return $commonEcpVirtualDirectoryStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
