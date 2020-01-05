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
