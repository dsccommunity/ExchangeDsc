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
