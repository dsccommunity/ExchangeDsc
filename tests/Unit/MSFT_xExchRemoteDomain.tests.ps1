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
        function Get-RemoteDomain
        {
            param ()
        }
        function Set-RemoteDomain
        {
            param (
                $Identity
            )
        }
        function Remove-RemoteDomain
        {
            param (
                $Identity
            )
        }
        function New-RemoteDomain
        {
            param (
                $DomainName,
                $Name
            )
        }
        Describe 'MSFT_xExchRemoteDomain\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            $getTargetResourceParams = @{
                DomainName = 'fakeremotedomain.com'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getRemoteDomainOutput = @{
                DomainName                        = 'fakeremotedomain.com'
                Name                              = 'MyFakeRemoteDomain'
                AllowedOOFType                    = 'External'
                AutoForwardEnabled                = $false
                AutoReplyEnabled                  = $true
                ContentType                       = ''
                DeliveryReportEnabled             = $false
                DisplaySenderName                 = $true
                IsInternal                        = $false
                MeetingForwardNotificationEnabled = $true
                NDREnabled                        = $false
                NonMimeCharacterSet               = ''
                UseSimpleDisplayName              = $true
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            Context 'When Get-TargetResource is called and resource is present' {
                Mock -CommandName Get-RemoteDomain -Verifiable -MockWith { return [PSCustomObject] $getRemoteDomainOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When resource is not present' {
                It 'Should return Absent' {
                    Mock -CommandName Get-RemoteDomain -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -be 'Absent'
                }
            }

            Context 'When resource is present' {
                It 'Should call all functions' {
                    Mock -CommandName Get-RemoteDomain -MockWith { $getRemoteDomainOutput } -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -Be 'Present'
                }
            }
        }

        Describe 'MSFT_xExchRemoteDomain\Set-TargetResource' -Tag 'Set' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $getRemoteDomainOutput = @{
                DomainName                        = 'fakeremotedomain.com'
                Name                              = 'MyFakeRemoteDomain'
                AllowedOOFType                    = 'External'
                AutoForwardEnabled                = $false
                AutoReplyEnabled                  = $true
                DeliveryReportEnabled             = $false
                DisplaySenderName                 = $true
                IsInternal                        = $false
                MeetingForwardNotificationEnabled = $true
                NDREnabled                        = $false
                UseSimpleDisplayName              = $true
                Ensure                            = 'Present'
            }

            Context 'When domain is present and Absent is specified' {
                It 'Should call Remove-RemoteDomain' {
                    $setTargetResourceParams = @{
                        DomainName = 'MyFakeRemoteDomain'
                        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        Ensure     = 'Absent'
                    }
                    Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                    Mock -CommandName Remove-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable

                    Set-TargetResource @setTargetResourceParams
                }
            }

            Context 'When domain is present' {
                Context 'Domain name change is required and name was specified' {
                    It 'Should call all functions' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['DomainName'] = 'newfakeremotedomain.com'
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName Remove-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable
                        Mock -CommandName New-RemoteDomain -ParameterFilter { $Name -eq 'MyFakeRemoteDomain' -and $DomainName -eq 'newfakeremotedomain.com' } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'Domain name change is required and name was not specified' {
                    It 'Should call all functions' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['DomainName'] = 'newfakeremotedomain.com'
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        $setTargetResourceParams.Remove('Name')

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName Remove-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable
                        Mock -CommandName New-RemoteDomain -ParameterFilter { $Name -eq 'newfakeremotedomain.com' -and $DomainName -eq 'newfakeremotedomain.com' } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'newfakeremotedomain.com' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'Domain name change is required and name was specified' {
                    It 'Should call all functions' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['DomainName'] = 'newfakeremotedomain.com'
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName Remove-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable
                        Mock -CommandName New-RemoteDomain -ParameterFilter { $Name -eq 'MyFakeRemoteDomain' -and $DomainName -eq 'newfakeremotedomain.com' } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'Domain is not compliant' {
                    It 'Should call all functions' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }
            }

            Context 'When domain is not present' {
                Context 'When name is not specified' {
                    It 'Should call all functions' {
                        $getRemoteDomainOutput = @{
                            Ensure = 'Absent'
                        }
                        $setTargetResourceParams = @{
                            DomainName = 'fakeremotedomain.com'
                            Ensure     = 'Present'
                            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        }

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName New-RemoteDomain -ParameterFilter { $Name -eq 'fakeremotedomain.com' -and $DomainName -eq 'fakeremotedomain.com' } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'fakeremotedomain.com' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'When name is specified' {
                    It 'Should call all functions' {
                        $getRemoteDomainOutput = @{
                            Ensure = 'Absent'
                        }
                        $setTargetResourceParams = @{
                            DomainName = 'fakeremotedomain.com'
                            Name       = 'MyFakeRemoteDomain'
                            Ensure     = 'Present'
                            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        }

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable
                        Mock -CommandName New-RemoteDomain -ParameterFilter { $Name -eq 'MyFakeRemoteDomain' -and $DomainName -eq 'fakeremotedomain.com' } -Verifiable
                        Mock -CommandName Set-RemoteDomain -ParameterFilter { $Identity -eq 'MyFakeRemoteDomain' } -Verifiable

                        Set-TargetResource @setTargetResourceParams
                    }
                }
            }
        }

        Describe 'MSFT_xExchRemoteDomain\Test-TargetResource' -Tag 'Test' {
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable

            $getRemoteDomainOutput = @{
                DomainName                        = 'fakeremotedomain.com'
                Name                              = 'MyFakeRemoteDomain'
                AllowedOOFType                    = 'External'
                AutoForwardEnabled                = $false
                AutoReplyEnabled                  = $true
                DeliveryReportEnabled             = $false
                DisplaySenderName                 = $true
                IsInternal                        = $false
                MeetingForwardNotificationEnabled = $true
                NDREnabled                        = $false
                UseSimpleDisplayName              = $true
                Ensure                            = 'Present'
            }

            Context 'When domain is not present' {
                It 'Should return false' {
                    $getRemoteDomainOutput = @{
                        Ensure = 'Absent'
                    }
                    $setTargetResourceParams = @{
                        DomainName = 'MyFakeRemoteDomain'
                        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        Ensure     = 'Present'
                    }

                    Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                    Test-TargetResource @setTargetResourceParams | Should -Be $false
                }
            }

            Context 'When domain is present' {
                Context 'Absent is specified' {
                    It 'Should return false' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['Ensure'] = 'Absent'
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                        Test-TargetResource @setTargetResourceParams | Should -Be $false
                    }
                }

                Context 'Name was not specified' {
                    It 'Should return false when a property does not match' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams.Remove('Name')
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                        Test-TargetResource @setTargetResourceParams | Should -be $false
                    }
                    It 'Should return true when all properties match' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams.Remove('Name')
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        $getRemoteDomainOutput['Name'] = 'fakeremotedomain.com'

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                        Test-TargetResource @setTargetResourceParams | Should -be $true
                    }
                }

                Context 'Name was specified' {
                    It 'Should return false when a property does not match' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['AllowedOOFType'] = 'InternalLegacy'
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                        Test-TargetResource @setTargetResourceParams | Should -be $false
                    }
                    It 'Should return true when all properties match' {
                        $setTargetResourceParams = @{ } + $getRemoteDomainOutput
                        $setTargetResourceParams['Credential'] = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)

                        Mock -CommandName Get-TargetResource -MockWith { $getRemoteDomainOutput } -Verifiable

                        Test-TargetResource @setTargetResourceParams | Should -be $true
                    }
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
