#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchOabVirtualDirectory'

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
        Describe 'MSFT_xExchOabVirtualDirectory\Get-TargetResource' -Tag 'Get' {
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
