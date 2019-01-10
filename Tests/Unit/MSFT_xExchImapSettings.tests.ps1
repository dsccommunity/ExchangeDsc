#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchImapSettings'

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

        Mock -CommandName Write-FunctionEntry -Verifiable

        $commonTargetResourceParams = @{
            Server     = 'Server'
            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
        }

        $commonImapSettingsStandardOutput = @{
            ExternalConnectionSettings        = [System.String[]] @()
            LoginType                         = [System.String] ''
            X509CertificateName               = [System.String] ''
            AuthenticatedConnectionTimeout    = [System.String] ''
            Banner                            = [System.String] ''
            CalendarItemRetrievalOption       = [System.String] ''
            EnableExactRFC822Size             = [System.Boolean] $false
            EnableGSSAPIAndNTLMAuth           = [System.Boolean] $false
            EnforceCertificateErrors          = [System.Boolean] $false
            ExtendedProtectionPolicy          = [System.String] ''
            InternalConnectionSettings        = [System.String[]] @()
            LogFileLocation                   = [System.String] ''
            LogFileRollOverSettings           = [System.String] ''
            LogPerFileSizeQuota               = [System.String[]] @()
            MaxCommandSize                    = [System.Int32] 1
            MaxConnectionFromSingleIP         = [System.Int32] 1
            MaxConnections                    = [System.Int32] 1
            MaxConnectionsPerUser             = [System.Int32] 1
            MessageRetrievalMimeFormat        = [System.String] ''
            OwaServerUrl                      = [System.String] ''
            PreAuthenticatedConnectionTimeout = [System.String] ''
            ProtocolLogEnabled                = [System.Boolean] $false
            ProxyTargetPort                   = [System.Int32] 1
            ShowHiddenFoldersEnabled          = [System.Boolean] $false
            SSLBindings                       = [System.String[]] @()
            SuppressReadReceipt               = [System.Boolean] $false
            UnencryptedOrTLSBindings          = [System.String[]] @()
        }
        Describe 'MSFT_xExchImapSettings\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-TargetResource is called' {

                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-ImapSettingsInternal -Verifiable -MockWith { return $commonImapSettingsStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
