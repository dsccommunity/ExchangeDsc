$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchaVirtualDirectory'
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
        Describe 'DSC_ExchaVirtualDirectory\Get-TargetResource' -Tag 'Get' {
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
                ExternalDownloadHostName               = [System.String] ''
                ExternalUrl                            = [System.String] ''
                FormsAuthentication                    = [System.Boolean] $false
                GzipLevel                              = [System.String] ''
                InstantMessagingCertificateThumbprint  = [System.String] ''
                InstantMessagingEnabled                = [System.Boolean] $false
                InstantMessagingServerName             = [System.String] ''
                InstantMessagingType                   = [System.String] ''
                InternalDownloadHostName               = [System.String] ''
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
