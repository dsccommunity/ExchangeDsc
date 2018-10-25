#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchActiveSyncVirtualDirectory'

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
        Describe 'MSFT_xExchActiveSyncVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'ActiveSyncVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getActiveSyncVirtualDirectoryInternalStandardOutput = @{
                ActiveSyncServer                           = [System.String] ''
                BadItemReportingEnabled                    = [System.Boolean] $false
                BasicAuthEnabled                           = [System.Boolean] $false
                ClientCertAuth                             = [System.String] 'Ignore'
                CompressionEnabled                         = [System.Boolean] $false
                ExtendedProtectionFlags                    = [System.String[]] @()
                ExtendedProtectionSPNList                  = [System.String[]] @()
                ExtendedProtectionTokenChecking            = [System.String] ''
                ExternalAuthenticationMethods              = [System.String[]] @()
                ExternalUrl                                = [System.String] ''
                InternalAuthenticationMethods              = [System.String[]] @()
                InternalUrl                                = [System.String] ''
                MobileClientCertificateAuthorityURL        = [System.String] ''
                MobileClientCertificateProvisioningEnabled = [System.Boolean] $false
                MobileClientCertTemplateName               = [System.String] ''
                Name                                       = [System.String] ''
                RemoteDocumentsActionForUnknownServers     = [System.String] ''
                RemoteDocumentsAllowedServers              = [System.String[]] @()
                RemoteDocumentsBlockedServers              = [System.String[]] @()
                RemoteDocumentsInternalDomainSuffixList    = [System.String[]] @()
                SendWatsonReport                           = [System.Boolean] $false
                WindowsAuthEnabled                         = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Test-ISAPIFilter -Verifiable -MockWith { return $false }
                Mock -CommandName Get-ActiveSyncVirtualDirectoryInternal -Verifiable -MockWith { return $getActiveSyncVirtualDirectoryInternalStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
