$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchOutlookAnywhere'
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
        Describe 'MSFT_xExchOutlookAnywhere\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'OutlookAnywhere'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getOutlookAnywhereStandardOutput = @{
                ExtendedProtectionFlags            = [System.String[]] @()
                ExtendedProtectionSPNList          = [System.String[]] @()
                ExtendedProtectionTokenChecking    = [System.String] ''
                ExternalClientAuthenticationMethod = [System.String] ''
                ExternalClientsRequireSsl          = [System.Boolean] $false
                ExternalHostname                   = [System.String] ''
                IISAuthenticationMethods           = [System.String[]] @()
                InternalClientAuthenticationMethod = [System.String] ''
                InternalClientsRequireSsl          = [System.Boolean] $false
                InternalHostname                   = [System.String] ''
                SSLOffloading                      = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-OutlookAnywhereInternal -Verifiable -MockWith { return $getOutlookAnywhereStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

