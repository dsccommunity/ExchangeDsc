$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchctiveSyncVirtualDirectory'
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
        Describe 'DSC_ExchctiveSyncVirtualDirectory\Get-TargetResource' -Tag 'Get' {
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
