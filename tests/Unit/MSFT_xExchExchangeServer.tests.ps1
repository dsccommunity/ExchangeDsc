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
        $commonTargetResourceParams = @{
            Identity            = 'ActiveSyncVirtualDirectory'
            Credential          = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            AllowServiceRestart = $false
        }

        $getExchangeServerStandardOutput = @{
            CustomerFeedbackEnabled         = [System.Boolean] $false
            ErrorReportingEnabled           = [System.Boolean] $false
            InternetWebProxy                = [System.String] ''
            InternetWebProxyBypassList      = [System.String[]] $null
            IsExchangeTrialEdition          = [System.Boolean] $false
            MonitoringGroup                 = [System.String] ''
            StaticConfigDomainController    = [System.String] ''
            StaticDomainControllers         = [System.String[]] $null
            StaticExcludedDomainControllers = [System.String[]] $null
            StaticGlobalCatalogs            = [System.String[]] $null
            WorkloadManagementPolicy        = [System.String] ''
        }

        Mock -CommandName Write-FunctionEntry -Verifiable
        Mock -CommandName Get-RemoteExchangeSession -Verifiable

        Describe 'MSFT_xExchExchangeServer\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Remove-NotApplicableParamsForCurrentState -Verifiable

            Context 'When Get-TargetResource is called' {
                Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $commonTargetResourceParams
            }

            Context 'When IsExchangeTrialEdition is set to true' {
                It 'Should return an empty ProductKey' {
                    $defaultValue = $getExchangeServerStandardOutput.IsExchangeTrialEdition
                    $getExchangeServerStandardOutput.IsExchangeTrialEdition = $true

                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerStandardOutput }

                    (Get-TargetResource @commonTargetResourceParams).ProductKey | Should -Be ''

                    $getExchangeServerStandardOutput.IsExchangeTrialEdition = $defaultValue
                }
            }

            $getExchangeServerOutputNonNullArrays = @{
                CustomerFeedbackEnabled         = [System.Boolean] $false
                ErrorReportingEnabled           = [System.Boolean] $false
                InternetWebProxy                = [System.String] ''
                InternetWebProxyBypassList      = [System.String[]] @('contoso.com', 'northwindtraders.com')
                IsExchangeTrialEdition          = [System.Boolean] $false
                MonitoringGroup                 = [System.String] ''
                StaticConfigDomainController    = [System.String] ''
                StaticDomainControllers         = [System.String[]] @('dc1', 'dc2')
                StaticExcludedDomainControllers = [System.String[]] @('dc1', 'dc2')
                StaticGlobalCatalogs            = [System.String[]] @('dc1', 'dc2')
                WorkloadManagementPolicy        = [System.String] ''
            }

            Context 'When Get-TargetResource is called and Get-ExchangeServer returns non-null array members' {
                It 'Should return the non-null array members' {
                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerOutputNonNullArrays }

                    $getResults = Get-TargetResource @commonTargetResourceParams

                    $getResults.InternetWebProxyBypassList | Should -Be $getExchangeServerOutputNonNullArrays.InternetWebProxyBypassList
                    $getResults.StaticDomainControllers | Should -Be $getExchangeServerOutputNonNullArrays.StaticDomainControllers
                    $getResults.StaticExcludedDomainControllers | Should -Be $getExchangeServerOutputNonNullArrays.StaticExcludedDomainControllers
                    $getResults.StaticGlobalCatalogs | Should -Be $getExchangeServerOutputNonNullArrays.StaticGlobalCatalogs
                }
            }
        }

        Describe 'MSFT_xExchExchangeServer\Set-TargetResource' -Tag 'Set' {
            # Override Exchange cmdlets
            function Set-ExchangeServer {}

            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Remove-NotApplicableParamsForCurrentState -Verifiable
            Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable -ParameterFilter {$ParamsToRemove.Contains('AllowServiceRestart')}
            Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerStandardOutput }
            Mock -CommandName Set-EmptyStringParamsToNull -Verifiable
            Mock -CommandName Set-ExchangeServer -Verifiable

            Context 'When Set-TargetResource is called with default parameters' {
                It 'Should call the minimum set of expected functions' {
                    Set-TargetResource @commonTargetResourceParams
                }
            }

            #region Licensing Specific Tests
            $commonTargetResourceParams.Add('ProductKey', '12345-12345-12345-12345-12345')
            $originalIsExchangeTrialEdition = $getExchangeServerStandardOutput.IsExchangeTrialEdition
            $getExchangeServerStandardOutput.IsExchangeTrialEdition = $true

            Context 'When the server needs to be licensed, and allow restart is false' {
                It 'Should warn that a Information Store restart is required' {
                    Mock -CommandName Write-Warning -Verifiable -ParameterFilter {$Message -eq 'The configuration will not take effect until MSExchangeIS is manually restarted.'}

                    Set-TargetResource @commonTargetResourceParams
                }
            }

            Context 'When the server needs to be licensed, and allow restart is true' {
                It 'Should restart the Information Store' {
                    Mock -CommandName Restart-Service -Verifiable

                    $originalAllowServiceRestart = $commonTargetResourceParams.AllowServiceRestart
                    $commonTargetResourceParams.AllowServiceRestart = $true

                    Set-TargetResource @commonTargetResourceParams

                    $commonTargetResourceParams.AllowServiceRestart = $originalAllowServiceRestart
                }
            }

            $commonTargetResourceParams.Remove('ProductKey')
            $getExchangeServerStandardOutput.IsExchangeTrialEdition = $originalIsExchangeTrialEdition
            #endregion
        }

        Describe 'MSFT_xExchExchangeServer\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Remove-NotApplicableParamsForCurrentState -Verifiable

            Context 'When Test-ExchangeSetting returns true' {
                It 'Should return true' {
                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $true }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetting returns false' {
                It 'Should return false' {
                    Mock -CommandName Get-ExchangeServerInternal -Verifiable -MockWith { return $getExchangeServerStandardOutput }
                    Mock -CommandName Test-ExchangeSetting -Verifiable -MockWith { return $false }

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }
            }

            Context 'When Get-ExchangeServerInternal returns null' {
                It 'Should write an error and return false' {
                    Mock -CommandName Get-ExchangeServerInternal -Verifiable
                    Mock -CommandName Write-Error -Verifiable

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }
            }

            #region InternetWebProxy tests
            $commonTargetResourceParams.Add('InternetWebProxy', 'someproxy.local')
            $getExchangeServerStandardOutput.InternetWebProxy = @{
                AbsoluteUri = 'someproxy.local'
            }

            Context 'When InternetWebProxy is not empty, Compare-StringToString returns false, and the returned InternetWebProxy matches the input InternetWebProxy' {
                It 'Should return true' {
                    Mock -CommandName Get-ExchangeServerInternal -MockWith { return $getExchangeServerStandardOutput }
                    Mock -CommandName Compare-StringToString -MockWith { return $false}

                    Test-TargetResource @commonTargetResourceParams | Should -Be $true
                }
            }

            Context 'When InternetWebProxy is not empty, Compare-StringToString returns false, and the returned InternetWebProxy does not match the input InternetWebProxy' {
                It 'Should return false' {
                    $getExchangeServerStandardOutput.InternetWebProxy.AbsoluteUri = 'someotherproxy.local'

                    Mock -CommandName Get-ExchangeServerInternal -MockWith { return $getExchangeServerStandardOutput }
                    Mock -CommandName Compare-StringToString -MockWith { return $false}
                    Mock -CommandName Write-InvalidSettingVerbose

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }
            }

            $commonTargetResourceParams.Remove('InternetWebProxy')
            #endregion

            #region Licensing Specific Tests
            $commonTargetResourceParams.Add('ProductKey', '12345-12345-12345-12345-12345')
            $originalIsExchangeTrialEdition = $getExchangeServerStandardOutput.IsExchangeTrialEdition
            $getExchangeServerStandardOutput.IsExchangeTrialEdition = $true

            Context 'When the server needs to be licensed' {
                It 'Should return false' {
                    Mock -CommandName Get-ExchangeServerInternal -MockWith { return $getExchangeServerStandardOutput }
                    Mock -CommandName Write-InvalidSettingVerbose

                    Test-TargetResource @commonTargetResourceParams | Should -Be $false
                }
            }

            $commonTargetResourceParams.Remove('ProductKey')
            $getExchangeServerStandardOutput.IsExchangeTrialEdition = $originalIsExchangeTrialEdition
            #endregion
        }

        Describe 'MSFT_xExchExchangeServer\Get-ExchangeServerInternal' -Tag 'Helper' {
            # Override Exchange cmdlets
            function Get-ExchangeServer {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ExchangeServerInternal is called' {
                It 'Should call expected functions' {
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable
                    Mock -CommandName Get-ExchangeServer -Verifiable

                    Get-ExchangeServerInternal @commonTargetResourceParams
                }
            }
        }

        Describe 'MSFT_xExchExchangeServer\Remove-NotApplicableParamsForCurrentState' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-NotApplicableParamsForCurrentState is called with WorkloadManagementPolicy and it is not an available parameter' {
                It 'Should be removed from PSBoundParameters' {
                    Mock -CommandName Remove-NotApplicableParamsForVersion -Verifiable
                    Mock -CommandName Test-CmdletHasParameter -Verifiable -MockWith { return $false }
                    Mock -CommandName Write-Warning -Verifiable
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable

                    $commonTargetResourceParams.Add('WorkloadManagementPolicy', 'Policy')

                    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $commonTargetResourceParams

                    $commonTargetResourceParams.Remove('WorkloadManagementPolicy')
                }
            }

            Context 'When Remove-NotApplicableParamsForCurrentState is called with CustomerFeedbackEnabled' {
                It 'Should cause a warning to be output' {
                    Mock -CommandName Remove-NotApplicableParamsForVersion -Verifiable
                    Mock -CommandName Write-Warning -Verifiable

                    $commonTargetResourceParams.Add('CustomerFeedbackEnabled', $false)

                    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $commonTargetResourceParams

                    $commonTargetResourceParams.Remove('CustomerFeedbackEnabled')
                }
            }

            Context 'When Remove-NotApplicableParamsForCurrentState is called with ErrorReportingEnabled set to true' {
                It 'Should be removed from PSBoundParameters' {
                    Mock -CommandName Remove-NotApplicableParamsForVersion -Verifiable
                    Mock -CommandName Write-Warning -Verifiable
                    Mock -CommandName Remove-FromPSBoundParametersUsingHashtable -Verifiable

                    $commonTargetResourceParams.Add('ErrorReportingEnabled', $true)

                    Remove-NotApplicableParamsForCurrentState -PSBoundParametersIn $commonTargetResourceParams

                    $commonTargetResourceParams.Remove('ErrorReportingEnabled')
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
