$script:DSCModuleName = 'ExchangeDsc'
$script:DSCResourceName = 'DSC_ExchapiVirtualDirectory'
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
        Describe 'DSC_ExchapiVirtualDirectory\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity                 = 'MapiVirtualDirectory'
                Credential               = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                IISAuthenticationMethods = @('Negotiate', 'NTLM')
            }

            $getMapiVirtualDirectoryStandardOutput = @{
                IISAuthenticationMethods = [System.String[]] @()
                ExternalUrl              = [System.String] ''
                InternalUrl              = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-MapiVirtualDirectoryInternal -Verifiable -MockWith { return $getMapiVirtualDirectoryStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
