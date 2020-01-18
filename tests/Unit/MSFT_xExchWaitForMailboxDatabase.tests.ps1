[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
param()

$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchWaitForMailboxDatabase'
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Global -Force

$script:testEnvironment = Invoke-TestSetup -DSCModuleName $script:dscModuleName -DSCResourceName $script:dscResourceName

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

# Begin Testing
try
{
    InModuleScope $script:DSCResourceName {
        Describe 'MSFT_xExchWaitForMailboxDatabase\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Set-ADServerSettings
            {
            }

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity                        = 'MailboxDatabase'
                Credential                      = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                AdServerSettingsPreferredServer = 'PreferredDC'
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Set-ADServerSettings -Verifiable
                Mock -CommandName Get-MailboxDatabaseInternal -Verifiable -MockWith { return 'MailboxDatabase' }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
