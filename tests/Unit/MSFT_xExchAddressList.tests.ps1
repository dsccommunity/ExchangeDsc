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
        function Remove-AddressList
        {
            param(
                $Identity
            )
        }
        function Set-AddressList
        {
            Param(
                $Identity,
                $DisplayName,
                $RecipientFilter,
                $IncludedRecipient,
                $Container
            )
        }

        Describe 'MSFT_xExchAddressList.tests\Get-TargetResource' -Tag 'Get' {
            AfterEach {
                Assert-VerifiableMock
            }

            function  Get-AddressList
            {
            }
            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

            $getTargetResourceParams = @{
                Name       = 'MyCustomAddressList'
                Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
            }

            $getAddressPrecannedOutput = @{
                Name                         = [System.String] 'MyCustomAddressList'
                IncludedRecipients           = [System.String[]] 'MailboxUsers'
                ConditionalCompany           = [System.String[]] ''
                ConditionalCustomAttribute1  = [System.String[]] ''
                ConditionalCustomAttribute10 = [System.String[]] ''
                ConditionalCustomAttribute11 = [System.String[]] ''
                ConditionalCustomAttribute12 = [System.String[]] ''
                ConditionalCustomAttribute13 = [System.String[]] ''
                ConditionalCustomAttribute14 = [System.String[]] ''
                ConditionalCustomAttribute15 = [System.String[]] ''
                ConditionalCustomAttribute2  = [System.String[]] ''
                ConditionalCustomAttribute3  = [System.String[]] ''
                ConditionalCustomAttribute4  = [System.String[]] ''
                ConditionalCustomAttribute5  = [System.String[]] ''
                ConditionalCustomAttribute6  = [System.String[]] ''
                ConditionalCustomAttribute7  = [System.String[]] ''
                ConditionalCustomAttribute8  = [System.String[]] ''
                ConditionalCustomAttribute9  = [System.String[]] ''
                ConditionalDepartment        = [System.String[]] ''
                ConditionalStateOrProvince   = [System.String[]] ''
                Container                    = [System.String] '\'
                DisplayName                  = [System.String] 'MyCustomAddressList'
                RecipientContainer           = [System.String[]] ''
                RecipientFilter              = [System.String[]] ''
            }

            Context 'When Get-TargetResource is called' {

                Mock -CommandName Get-AddressList -Verifiable -MockWith { return [PSCustomObject] $getAddressPrecannedOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
            }

            Context 'When Get-TargetResource is called and custom filter is specifed' {
                $getAddressCustomFilterOutput = @{ } + $getAddressPrecannedOutput
                $getAddressCustomFilterOutput['IncludedRecipients'] = ''
                $getAddressCustomFilterOutput['RecipientFilter'] = '(RecipientType -eq "UserMailbox")'

                Mock -CommandName Get-AddressList -Verifiable -MockWith { return [PSCustomObject] $getAddressCustomFilterOutput }

                $returnValue = Get-TargetResource @getTargetResourceParams
                $returnValue['RecipientFilter'] | Should -Be '{(RecipientType -eq "UserMailbox")}'
            }

            Context 'When Addresslist is not present' {
                It 'Should return "Absent"' {
                    Mock -CommandName Get-AddressList -Verifiable

                    $result = Get-TargetResource @getTargetResourceParams
                    $result['Ensure'] | Should -Be 'Absent'
                }
            }
        }

        Describe 'MSFT_xExchAddressList.tests\Set-TargetResource' -Tag 'Set' {
            BeforeAll {
                Mock -CommandName Write-FunctionEntry -Verifiable
                Mock -CommandName Get-RemoteExchangeSession -Verifiable
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'Customized filters and precanned filters are used simultaneously' {
                It 'Should throw' {
                    $setTargetResourceParams = @{
                        Name               = 'MyCustomAddressList'
                        Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        RecipientFilter    = "(RecipientType -eq 'UserMailbox')"
                        IncludedRecipients = 'MailUsers'
                    }

                    { Set-TargetResource @setTargetResourceParams } | Should -Throw
                }
            }

            Context 'Address list is present' {
                Mock -CommandName 'Get-TargetResource' -MockWith {
                    return @{
                        Ensure = [System.String] 'Present'
                        Name   = [System.String] 'MyCustomAddressList'
                    }
                }

                Context 'When "Absent" is specified' {
                    It 'Should call Remove-AddressList' {
                        Mock -CommandName 'Remove-AddressList' -Verifiable -ParameterFilter { $Identity -eq 'MyCustomAddressList' }

                        $setTargetResourceParams = @{
                            Name       = 'MyCustomAddressList'
                            Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                            Ensure     = 'Absent'
                        }

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'DisplayName is not specified' {
                    $setTargetResourceParams = @{
                        Name               = 'MyCustomAddressList'
                        Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        IncludedRecipients = 'MailUsers'
                    }

                    It 'Should call all functions' {
                        Mock -CommandName 'Set-AddressList' -Verifiable -ParameterFilter { $DisplayName -eq 'MyCustomAddressList' -and $IncludedRecipients -contains 'MailUsers' }

                        Set-TargetResource @setTargetResourceParams
                    }
                }

                Context 'RecipientFilter is specified' {
                    $setTargetResourceParams = @{
                        Name            = 'MyCustomAddressList'
                        DisplayName     = 'MyCustomAddressList'
                        Credential      = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        RecipientFilter = "(RecipientType -eq 'UserMailbox')"
                        Container       = '\'
                    }

                    It 'Should call all functions' {
                        Mock -CommandName 'Set-AddressList' -Verifiable -ParameterFilter { $RecipientFilter.ToString() -eq "(RecipientType -eq 'UserMailbox')" }

                        Set-TargetResource @setTargetResourceParams
                    }
                }
            }

            Context 'Address list is not present' {
                function New-AddressList
                {
                }

                $setTargetResourceParams = @{
                    Name               = 'MyCustomAddressList'
                    Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                    IncludedRecipients = 'MailUsers'
                }

                Mock -CommandName 'Get-TargetResource' -Verifiable -MockWith {
                    return @{
                        Ensure = 'Absent'
                    }
                }
                Mock -CommandName 'New-AddressList' -Verifiable -ParameterFilter { $Name -eq 'MyCustomAddressList' }

                It 'Should call all functions' {
                    Set-TargetResource @setTargetResourceParams
                }
            }
        }

        Describe 'MSFT_xExchAddressList.tests\Test-TargetResource' -Tag 'Test' {
            BeforeAll {
                Mock -CommandName Write-FunctionEntry -Verifiable
            }

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When the address list is present' {
                Mock -CommandName 'Get-TargetResource' -MockWith {
                    return @{
                        Name               = [System.String] 'MyCustomAddressList'
                        IncludedRecipients = [System.String[]] 'MailboxUsers'
                        DisplayName        = [System.String] 'MyCustomAddressList'
                        Container          = '\'
                        Ensure             = 'Present'
                    }
                }

                Context 'When Displyname and Container are not specified' {
                    $testTargetInput = @{
                        Name               = [System.String] 'MyCustomAddressList'
                        IncludedRecipients = [System.String[]] 'MailboxUsers'
                        Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                    }
                    It 'Should return True when all properties match' {
                        Test-TargetResource @testTargetInput | Should -Be $true
                    }
                    It 'Should return False when prorites do not match' {
                        $testTargetInput['Name'] = 'MyCustomWrongAddressList'

                        Test-TargetResource @testTargetInput | Should -Be $false
                    }
                }

                Context 'When Displyname and Container are specified' {
                    $testTargetInput = @{
                        Name               = [System.String] 'MyCustomAddressList'
                        IncludedRecipients = [System.String[]] 'MailboxUsers'
                        DisplayName        = [System.String] 'MyCustomAddressList'
                        Container          = '\'
                        Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                    }

                    It 'Should return True when all properties match' {
                        Test-TargetResource @testTargetInput | Should -Be $true
                    }
                    It 'Should return False when prorites do not match' {
                        $testTargetInput['Container'] = '\Wrong'

                        Test-TargetResource @testTargetInput | Should -Be $false
                    }
                }

                Context 'When Absent is specified' {
                    $testTargetInput = @{
                        Name       = [System.String] 'MyCustomAddressList'
                        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        Ensure     = 'Absent'
                    }

                    It 'Should return True when all properties match' {
                        Test-TargetResource @testTargetInput | Should -Be $false
                    }
                }
            }

            Context 'When the address list is not present' {
                Mock -CommandName 'Get-TargetResource' -MockWith {
                    return @{
                        Esure = 'Absent'
                    }
                }

                It 'Should return false' {
                    $testTargetInput = @{
                        Name               = [System.String] 'MyCustomAddressList'
                        IncludedRecipients = [System.String[]] 'MailboxUsers'
                        Credential         = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                    }

                    Test-TargetResource @testTargetInput | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
