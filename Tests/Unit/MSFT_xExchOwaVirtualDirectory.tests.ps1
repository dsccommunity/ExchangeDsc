#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchOwaVirtualDirectory'

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
        Describe 'MSFT_xExchOwaVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity   = 'OwaVirtualDirectory'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getOwaVirtualDirectoryStandardOutput = @{
                ActionForUnknownFileAndMIMETypes       = [System.String] ''
                AdfsAuthentication                     = [System.Boolean] $false
                BasicAuthentication                    = [System.Boolean] $false
                ChangePasswordEnabled                  = [System.Boolean] $false
                DefaultDomain                          = [System.String] ''
                DigestAuthentication                   = [System.Boolean] $false
                ExternalAuthenticationMethods          = [System.String[]] @()
                ExternalUrl                            = [System.String] ''
                FormsAuthentication                    = [System.Boolean] $false
                GzipLevel                              = [System.String] ''
                InstantMessagingCertificateThumbprint  = [System.String] ''
                InstantMessagingEnabled                = [System.Boolean] $false
                InstantMessagingServerName             = [System.String] ''
                InstantMessagingType                   = [System.String] ''
                InternalUrl                            = [System.String] ''
                LogonFormat                            = [System.String] ''
                LogonPageLightSelectionEnabled         = [System.Boolean] $false
                LogonPagePublicPrivateSelectionEnabled = [System.Boolean] $false
                UNCAccessOnPublicComputersEnabled      = [System.Boolean] $false
                UNCAccessOnPrivateComputersEnabled     = [System.Boolean] $false
                WindowsAuthentication                  = [System.Boolean] $false
                WSSAccessOnPublicComputersEnabled      = [System.Boolean] $false
                WSSAccessOnPrivateComputersEnabled     = [System.Boolean] $false
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-OwaVirtualDirectoryInternal -Verifiable -MockWith { return $getOwaVirtualDirectoryStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
