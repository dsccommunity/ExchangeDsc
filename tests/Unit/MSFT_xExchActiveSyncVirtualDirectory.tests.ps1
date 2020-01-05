function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

# Begin Testing
try
{
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
