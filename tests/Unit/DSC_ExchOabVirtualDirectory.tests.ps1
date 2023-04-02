$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchOabVirtualDirectory'
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
        Describe 'DSC_ExchOabVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-OabVirtualDirectory {}
            function Get-OfflineAddressBook {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'OabVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getOabVirtualDirectoryStandardOutput = @{
                BasicAuthentication             = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                ExternalUrl                     = [System.String] ''
                InternalUrl                     = [System.String] ''
                OAuthAuthentication             = [System.Boolean] $false
                PollInterval                    = [System.Int32] 1
                RequireSSL                      = [System.Boolean] $false
                WindowsAuthentication           = [System.Boolean] $false
            }

            $getOfflineAddressBookStandardOutput = @(
                @{
                    Name               = 'Default Offline Address List'
                    VirtualDirectories = $getTargetResourceParams.Identity
                }
            )

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-OabVirtualDirectory -Verifiable -MockWith { return $getOabVirtualDirectoryStandardOutput }
                Mock -CommandName Get-OfflineAddressBook -Verifiable -MockWith { return $getOfflineAddressBookStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
