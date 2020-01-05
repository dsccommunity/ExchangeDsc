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
        Describe 'MSFT_xExchUMService\Get-TargetResource' -Tag 'Get' {
            # Override Exchange cmdlets
            function Get-UMService {}

            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                Identity      = 'UMServer'
                Credential    = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                UMStartupMode = 'TLS'
            }


            $getUMServiceStandardOutput = @{
                UMStartupMode               = [System.String] $getTargetResourceParams.UMStartupMode
                DialPlans                   = [System.String[]] @()
                GrammarGenerationSchedule   = [System.String[]] @('Sun.2:00 AM-Sun.2:30 AM', 'Mon.2:00 AM-Mon.2:30 AM', 'Tue.2:00 AM-Tue.2:30 AM')
                IPAddressFamily             = [System.String] 'Any'
                IPAddressFamilyConfigurable = [System.Boolean] $true
                IrmLogEnabled               = [System.Boolean] $true
                IrmLogMaxAge                = [System.String] '30.00:00:00'
                IrmLogMaxDirectorySize      = [System.String] 'C:\Program Files\Microsoft\Exchange Server\V15\Logging\IRMLogs'
                IrmLogMaxFileSize           = [System.String] '250 MB'
                IrmLogPath                  = [System.String] '10 MB'
                MaxCallsAllowed             = [System.Int32] '100'
                SIPAccessService            = [System.String] ''
            }

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Assert-IsSupportedWithExchangeVersion -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
                Mock -CommandName Get-UMService -Verifiable -MockWith { return $getUMServiceStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
