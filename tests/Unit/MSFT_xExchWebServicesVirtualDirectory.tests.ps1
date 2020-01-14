$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchWebServicesVirtualDirectory'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

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
        Describe 'MSFT_xExchWebServicesVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-WebServicesVirtualDirectory {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'WebServicesVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getWebServicesVirtualDirectoryStandardOutput = @{
                BasicAuthentication             = [System.Boolean] $false
                CertificateAuthentication       = [System.Boolean] $false
                DigestAuthentication            = [System.Boolean] $false
                ExtendedProtectionFlags         = [System.String[]] @()
                ExtendedProtectionSPNList       = [System.String[]] @()
                ExtendedProtectionTokenChecking = [System.String] ''
                ExternalUrl                     = [System.String] ''
                GzipLevel                       = [System.String] ''
                InternalNLBBypassUrl            = [System.String] ''
                InternalUrl                     = [System.String] ''
                MRSProxyEnabled                 = [System.Boolean] $false
                OAuthAuthentication             = [System.Boolean] $false
                WSSecurityAuthentication        = [System.Boolean] $false
                WindowsAuthentication           = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-WebServicesVirtualDirectory -Verifiable -MockWith { return $getWebServicesVirtualDirectoryStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

