#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCResourceName = 'MSFT_xExchAddressList'

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
        function Remove-AddressList
        {
            $Identity,
            [bool]$confirm
        }
        function Set-AddressList
        {
            $Identity,
            $DisplayName,
            $RecipientFilter,
            $IncludedRecipient
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

            $getAddressListInternalStandardOutput = @{
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

                Mock -CommandName Get-AddressList -Verifiable -MockWith { return $getAddressListInternalStandardOutput }

                Test-CommonGetTargetResourceFunctionality -GetTargetResourceParams $getTargetResourceParams
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
            AfterEach {
                Assert-VerifiableMock
            }

            Mock -CommandName Write-FunctionEntry -Verifiable
            Mock -CommandName Get-RemoteExchangeSession -Verifiable

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
                Mock -CommandName 'Get-TargetResource' -Verifiable -MockWith {
                    return @{
                        Ensure = 'Present'
                        Name   = 'MyCustomAddressList'
                    }
                }

                Context 'When "Absent" is specified' {

                    Mock -CommandName 'Remove-AddressList' -Verifiable -ParameterFilter { $Identity -eq 'MyCustomAddressList' }

                    $setTargetResourceParams = @{
                        Name       = 'MyCustomAddressList'
                        Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'fakeuser', (New-Object -TypeName System.Security.SecureString)
                        Ensure     = 'Absent'
                    }

                    It 'Should call Remove-AddressList' {
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
    }
}
finally
{
    Invoke-TestCleanup
}
