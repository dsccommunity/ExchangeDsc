#region HEADER
$script:DSCModuleName = 'xExchange'
$script:DSCHelperName = "xExchangeHelper"

# Unit Test Template Version: 1.2.2
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force

#endregion HEADER

function Invoke-TestSetup
{

}

function Invoke-TestCleanup
{

}

# Begin Testing
try
{
    Invoke-TestSetup

    InModuleScope $script:DSCHelperName {
        # Get a unique Guid that doesn't resolve to a local path
        # Use System.Guid, as New-Guid isn't available in PS4 and below
        do
        {
            $guid1 = [System.Guid]::NewGuid().ToString()
        } while (Test-Path -Path $guid1)

        # Get a unique Guid that doesn't resolve to a local path
        do
        {
            $guid2 = [System.Guid]::NewGuid().ToString()
        } while ((Test-Path -Path $guid2) -or $guid1 -like $guid2)

        Describe 'xExchangeHelper\Get-ExchangeInstallStatus' -Tag 'Helper' {
            # Used for calls to Get-InstallStatus
            $getInstallStatusParams = @{
                Path = 'C:\Exchange\setup.exe'
                Arguments = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
            }

            AfterEach {
                Assert-MockCalled -CommandName Test-ShouldInstallUMLanguagePack -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangeSetupRunning -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangeSetupComplete -Exactly -Times 1 -Scope It
                Assert-MockCalled -CommandName Test-ExchangePresent -Exactly -Times 1 -Scope It
            }

            Context 'When Exchange is not present on the system' {
                It 'Should only recommend starting the install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $false }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $false
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup has fully completed' {
                It 'Should indicate setup is complete and Exchange is present' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $true }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When Exchange Setup has partially completed' {
                It 'Should indicate that Exchange is present, but setup is not complete, and recommend starting an install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange Setup is currently running' {
                It 'Should indicate that Exchange is present and that setup is running' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $true }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $true
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $false
                }
            }

            Context 'When a Language Pack install is requested, and the Language Pack has not been installed' {
                It 'Should indicate that setup has completed and a language pack Should -Be installed' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $true }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $true }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $true
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $true
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }

            Context 'When Exchange upgrade is requested' {
                It 'Should recommend starting the install' {
                    Mock -CommandName Test-ShouldInstallUMLanguagePack -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupRunning -MockWith { return $false }
                    Mock -CommandName Test-ExchangeSetupComplete -MockWith { return $false }
                    Mock -CommandName Test-ExchangePresent -MockWith { return $true }
                    Mock -CommandName Test-ShouldUpgradeExchange -MockWith { return $true }

                    $getInstallStatusParams = @{
                        Path = 'C:\Exchange\setup.exe'
                        Arguments = '/mode:Upgrade /Iacceptexchangeserverlicenseterms'
                    }

                    $installStatus = Get-ExchangeInstallStatus @getInstallStatusParams

                    $installStatus.ShouldInstallLanguagePack | Should -Be $false
                    $installStatus.SetupRunning | Should -Be $false
                    $installStatus.SetupComplete | Should -Be $false
                    $installStatus.ExchangePresent | Should -Be $true
                    $installStatus.ShouldStartInstall | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Get-PreviousError' -Tag 'Helper' {
            Context 'After an error occurs' {
                It 'Should retrieve the most recent error' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Cause an error by trying to get a non-existent item
                    Get-ChildItem -Path $guid1 -ErrorAction SilentlyContinue

                    $firstError = Get-PreviousError

                    # Cause another error by trying to get a non-existent item
                    Get-ChildItem -Path $guid2 -ErrorAction SilentlyContinue

                    $secondError = Get-PreviousError

                    $initialError -ne $firstError | Should -Be $true
                    $secondError -ne $firstError | Should -Be $true
                    $firstError -eq $null | Should -Be $false
                    $secondError -eq $null | Should -Be $false
                }
            }

            Context 'When an error has not occurred' {
                It 'Should return the same previous error with each call' {
                    # Run Get-PreviousError twice in a row so we can later ensure results are the same
                    $error1 = Get-PreviousError
                    $error2 = Get-PreviousError

                    # Run a command that should always succeed
                    Get-ChildItem  | Out-Null

                    # Get the previous error one more time
                    $error3 = Get-PreviousError

                    $error1 -eq $error2 | Should -Be $true
                    $error1 -eq $error3 | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Assert-NoNewError' -Tag 'Helper' {
            Context 'After a new, unique error occurs' {
                It 'Should throw an exception' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Cause an error by trying to get a non-existent item
                    Get-ChildItem $guid1 -ErrorAction SilentlyContinue

                    { Assert-NoNewError -CmdletBeingRun "Get-ChildItem" -PreviousError $initialError } | Should -Throw
                }
            }

            Context 'When an error has not occurred' {
                It 'Should not throw an exception' {
                    # First get whatever error is currently on top of the stack
                    $initialError = Get-PreviousError

                    # Run a command that should always succeed
                    Get-ChildItem | Out-Null

                    { Assert-NoNewError -CmdletBeingRun "Get-ChildItem" -PreviousError $initialError } | Should -Not -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Assert-IsSupportedWithExchangeVersion' -Tag 'Helper' {
            $supportedVersionTestCases = @(
                @{Name='2013 Operation Supported on 2013';      ExchangeVersion='2013'; SupportedVersions='2013'}
                @{Name='2013 Operation Supported on 2013,2019'; ExchangeVersion='2013'; SupportedVersions='2013','2019'}
            )

            $notSupportedVersionTestCases = @(
                @{Name='2013 Operation Not Supported on 2016';      ExchangeVersion='2013'; SupportedVersions='2016'}
                @{Name='2013 Operation Not Supported on 2016,2019'; ExchangeVersion='2013'; SupportedVersions='2016','2019'}
            )

            Context 'When a supported version is passed' {
                It 'Should not throw an exception' -TestCases $supportedVersionTestCases {
                    param($Name, $ExchangeVersion, $SupportedVersions)

                    Mock -CommandName Get-ExchangeVersionYear -MockWith { return $ExchangeVersion }

                    { Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName $Name -SupportedVersions $SupportedVersions } | Should -Not -Throw
                }
            }

            Context 'When an unsupported version is passed' {
                It 'Should throw an exception' -TestCases $notSupportedVersionTestCases {
                    param($Name, $ExchangeVersion, $SupportedVersions)

                    Mock -CommandName Get-ExchangeVersionYear -MockWith { return $ExchangeVersion }

                    { Assert-IsSupportedWithExchangeVersion -ObjectOrOperationName $Name -SupportedVersions $SupportedVersions } | Should -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Compare-ADObjectIdToSmtpAddressString' -Tag 'Helper' {
            <#
                Define an empty function for Get-Recipient, so Pester has something to Mock.
                This cmdlet is normally loaded as part of GetRemoteExchangeSession.
            #>
            function Get-Recipient {}

            AfterEach {
                Assert-VerifiableMock
            }

            # Setup test objects for calls to Compare-ADObjectIdToSmtpAddressString
            $testADObjectID = New-Object -TypeName PSObject -Property @{DistinguishedName='CN=TestUser,DC=contoso,DC=local'}
            $testAddress = 'testuser@contoso.local'
            $testBadAddress = 'baduser@contoso.local'

            $testRecipient = New-Object -TypeName PSObject -Property @{
                EmailAddresses = New-Object -TypeName PSObject -Property @{
                    AddressString = $testAddress
                }
            }

            Context 'When comparing an ADObjectID to a corresponding SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $testRecipient }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testAddress

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing an ADObjectID to a non-corresponding SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $testRecipient }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing an ADObjectID to an empty SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString ''

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing an ADObjectID to a null SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $null

                    $compareResults | Should -Be $false
                }
            }

            Context 'When comparing a null ADObjectID to an empty SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString ''

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing a null ADObjectID to a null SMTP address' {
                It 'Should return $true' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $null

                    $compareResults | Should -Be $true
                }
            }

            Context 'When comparing a null ADObjectID to any SMTP address' {
                It 'Should return $false' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }

                    $compareResults = Compare-ADObjectIdToSmtpAddressString -ADObjectId $null -AddressString $testAddress

                    $compareResults | Should -Be $false
                }
            }

            Context 'When Get-Recipient returns $null' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return '' }
                    Mock -CommandName Get-Recipient -Verifiable -MockWith { return $null }

                    { Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress | Out-Null } | Should -Throw
                }
            }

            Context 'When Get-Command returns $null' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-Command -Verifiable -MockWith { return $null }

                    { Compare-ADObjectIdToSmtpAddressString -ADObjectId $testADObjectID -AddressString $testBadAddress | Out-Null } | Should -Throw
                }
            }
        }

        Describe 'xExchangeHelper\Invoke-DotSourcedScript' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Invoke-DotSourcedScript is called with no parameters' {
                It 'Should execute fine' {
                    $processes = Invoke-DotSourcedScript -ScriptPath 'Get-Process'

                    $processes.Count | Should -BeGreaterThan 0
                }
            }

            Context 'When Invoke-DotSourcedScript is called with parameters' {
                It 'Should execute fine' {
                    $testProcess = 'svchost'
                    $scriptParams = @{
                        Name = $testProcess
                    }

                    $processes = Invoke-DotSourcedScript -ScriptPath 'Get-Process' -ScriptParams $scriptParams

                    ($processes | Where-Object -FilterScript {$_.ProcessName -like $testProcess}).Count | Should -BeGreaterThan 0
                }
            }

            Context 'When Invoke-DotSourcedScript is called with SnapinsToRemove' {
                It 'Should call Remove-HelperSnapin' {
                    Mock -CommandName Remove-HelperSnapin -Verifiable

                    Invoke-DotSourcedScript -ScriptPath 'Get-Process' -SnapinsToRemove 'SomeSnapin' | Out-Null
                }
            }
        }

        Describe 'xExchangeHelper\Remove-HelperSnapin' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Remove-HelperSnapin is called and a snapin is loaded' {
                It 'Should remove the snapin' {
                    Mock -CommandName Get-PSSnapin -Verifiable -MockWith { return $true }
                    Mock -CommandName Remove-PSSnapin -Verifiable

                    Remove-HelperSnapin -SnapinsToRemove 'FakeSnapin'
                }
            }

            Context 'When Remove-HelperSnapin is called and a snapin is not loaded' {
                It 'Should execute without attempting to remove a snapin' {
                    Mock -CommandName Get-PSSnapin -Verifiable
                    Mock -CommandName Remove-PSSnapin

                    Remove-HelperSnapin -SnapinsToRemove 'FakeSnapin'

                    Assert-MockCalled -CommandName Remove-PSSnapin -Times 0
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangePresent' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $validExchangeYears = @(
                @{Year='2013'}
                @{Year='2016'}
                @{Year='2019'}
            )

            Context 'When Test-ExchangePresent is called with a valid Exchange Version' {
                It 'Should return True' -TestCases $validExchangeYears {
                    param
                    (
                        [System.Object]
                        $Year
                    )

                    Mock -CommandName Get-ExchangeVersion -Verifiable -MockWith { return $Year }

                    Test-ExchangePresent | Should -Be $true
                }
            }

            $inValidExchangeYears = @(
                @{Year='2012'}
                @{Year=''}
                @{Year='N/A'}
                @{Year=$null}
            )

            Context 'When Test-ExchangePresent is called with an invalid Exchange Version' {
                It 'Should return False' -TestCases $inValidExchangeYears {
                    param
                    (
                        [System.Object]
                        $Year
                    )

                    Mock -CommandName Get-ExchangeVersion -Verifiable -MockWith { return $Year }

                    Test-ExchangePresent | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupComplete' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $setupCompleteCases = @(
                @{
                    ExchangePresent   = $true
                    PartiallyComplete = $false
                }
            )

            Context 'When Test-ExchangeSetupComplete is called and setup is fully complete' {
                It 'Should return true' -TestCases $setupCompleteCases {
                    param
                    (
                        [System.Boolean]
                        $ExchangePresent,

                        [System.Boolean]
                        $PartiallyComplete
                    )

                    Mock -CommandName Test-ExchangePresent -Verifiable -MockWith { return $ExchangePresent }
                    Mock -CommandName Test-ExchangeSetupPartiallyCompleted -Verifiable -MockWith { return $PartiallyComplete }

                    Test-ExchangeSetupComplete | Should -Be $true
                }
            }

            $setupIncompleteCases = @(
                @{
                    ExchangePresent   = $false
                    PartiallyComplete = $false
                }
                @{
                    ExchangePresent   = $true
                    PartiallyComplete = $true
                }
                @{ # This last one shouldn't be possible, but let's test for it anyways
                    ExchangePresent   = $false
                    PartiallyComplete = $true
                }
            )

            Context 'When Test-ExchangeSetupComplete is called and setup is not fully complete' {
                It 'Should return false' -TestCases $setupIncompleteCases {
                    param
                    (
                        [System.Boolean]
                        $ExchangePresent,

                        [System.Boolean]
                        $PartiallyComplete
                    )

                    Mock -CommandName Test-ExchangePresent -Verifiable -MockWith { return $ExchangePresent }
                    Mock -CommandName Test-ExchangeSetupPartiallyCompleted -Verifiable -MockWith { return $PartiallyComplete }

                    Test-ExchangeSetupComplete | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupPartiallyCompleted' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ExchangeSetupPartiallyCompleted is called and no setup progress related registry keys remain' {
                It 'Should return false' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith {
                        return @{
                            UnpackedVersion   = 1
                            ConfiguredVersion = 1
                        }
                    }

                    Test-ExchangeSetupPartiallyCompleted | Should -Be $false
                }
            }

            $partiallyCompletedTestCases = @(
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Action            = 1
                }
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Watermark         = 1
                }
                @{
                    UnpackedVersion   = 1
                    ConfiguredVersion = 1
                    Action            = 1
                    Watermark         = 1
                }
                @{
                    UnpackedVersion   = 1
                    Action            = 1
                    Watermark         = 1
                }
            )

            Context 'When Test-ExchangeSetupPartiallyCompleted is called and setup progress related registry keys remain' {
                It 'Should return true' -TestCases $partiallyCompletedTestCases {
                    param
                    (
                        [Nullable[System.Int32]]
                        $UnpackedVersion,

                        [Nullable[System.Int32]]
                        $ConfiguredVersion,

                        [Nullable[System.Int32]]
                        $Action,

                        [Nullable[System.Int32]]
                        $Watermark
                    )

                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith {
                        return @{
                            UnpackedVersion   = $UnpackedVersion
                            ConfiguredVersion = $ConfiguredVersion
                            Action            = $Action
                            Watermark         = $Watermark
                        }
                    }

                    Test-ExchangeSetupPartiallyCompleted | Should -Be $true
                }
            }
        }

        Describe 'xExchangeHelper\Set-WSManConfigStatus' -Tag 'Helper' {
            # Define an empty winrm function so we can Mock calls to the winrm executable
            function winrm {}

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Set-WSManConfigStatus is called and the UpdatedConfig key does not exist' {
                It 'Should attempt to configure WinRM' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{SomeOtherProp = 'SomeOtherValue'} }
                    Mock -CommandName Set-Location -Verifiable
                    Mock -CommandName winrm -Verifiable

                    Set-WSManConfigStatus
                }
            }

            Context 'When Set-WSManConfigStatus is called and the UpdatedConfig key exists' {
                It 'Should execute without attempting to configure WinRM' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{UpdatedConfig = 'SomeValue'} }
                    Mock -CommandName winrm

                    Set-WSManConfigStatus

                    Assert-MockCalled -CommandName winrm -Times 0
                }
            }

            Context 'When Set-WSManConfigStatus is called and the WSMan key does not exist' {
                It 'Should throw an exception' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return $null }

                    { Set-WSManConfigStatus } | Should -Throw -ExpectedMessage 'Unable to find registry key: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN'
                }
            }
        }

        Describe 'xExchangeHelper\Test-UMLanguagePackInstalled' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $testCultureName = 'TestCulture'

            Context 'When Test-UMLanguagePackInstalled is called and the specified Culture key exists' {
                It 'Should return true' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{TestCulture = $testCultureName} }

                    Test-UMLanguagePackInstalled -Culture $testCultureName | Should -Be $true
                }
            }

            Context 'When Test-UMLanguagePackInstalled is called and the specified Culture key does not exist' {
                It 'Should return false' {
                    Mock -CommandName Get-ItemProperty -Verifiable -MockWith { return @{SomeOtherCulture = 'SomeOtherCulture'} }

                    Test-UMLanguagePackInstalled -Culture $testCultureName | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ShouldInstallUMLanguagePack' -Tag 'Helper' {
            $noLanguagePackArgs     = '/IAcceptExchangeServerLicenseTerms /mode:Install /r:MB'
            $singleLanguagePackArgs = '/AddUmLanguagePack:ja-JP /s:d:\Exchange\UMLanguagePacks /IAcceptExchangeServerLicenseTerms'
            $multiLanguagePackArgs  = '/AddUmLanguagePack:es-MX,de-DE /s:d:\Exchange\UMLanguagePacks /IAcceptExchangeServerLicenseTerms'

            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called and AddUMLanguagePack is not specified' {
                It 'Should return false' {
                    Test-ShouldInstallUMLanguagePack -Arguments $noLanguagePackArgs | Should -Be $false
                }
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called with AddUMLanguagePack, a language is specified, and the language pack is not installed' {
                It 'Should return true' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $false }

                    Test-ShouldInstallUMLanguagePack -Arguments $singleLanguagePackArgs | Should -Be $true
                }

                It 'Should return true' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $false }

                    Test-ShouldInstallUMLanguagePack -Arguments $multiLanguagePackArgs | Should -Be $true
                }
            }

            Context 'When Test-ShouldInstallUMLanguagePack is called with AddUMLanguagePack, a language is specified, and the language pack is installed' {
                It 'Should return false' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $true }

                    Test-ShouldInstallUMLanguagePack -Arguments $singleLanguagePackArgs | Should -Be $false
                }

                It 'Should return false' {
                    Mock -CommandName Test-UMLanguagePackInstalled -Verifiable -MockWith { return $true }

                    Test-ShouldInstallUMLanguagePack -Arguments $multiLanguagePackArgs | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Test-ExchangeSetupRunning' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Test-ExchangeSetupRunning is called and the setup process is running' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Test-ExchangeSetupRunning | Should -Be $true
                }
            }

            Context 'When Test-ExchangeSetupRunning is called and the setup process is not running' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Test-ExchangeSetupRunning | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Wait-ForProcessStart' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Wait-ForProcessStart is called and the given process is detected' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Wait-ForProcessStart -ProcessName 'SomeProcess' | Should -Be $true
                }
            }

            Context 'When Wait-ForProcessStart is called and the given process is not detected' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Wait-ForProcessStart -ProcessName 'SomeProcess' -SecondsPerSleep 0 -MaxSleepCycles 1 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Wait-ForProcessStop' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Wait-ForProcessStop is called and the given process stops' {
                It 'Should return true' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return $null }

                    Wait-ForProcessStop -ProcessName 'SomeProcess' | Should -Be $true
                }
            }

            Context 'When Wait-ForProcessStop is called and the given process does not stop' {
                It 'Should return false' {
                    Mock -CommandName Get-Process -Verifiable -MockWith { return 'SomeProcess' }

                    Wait-ForProcessStop -ProcessName 'SomeProcess' -SecondsPerSleep 0 -MaxSleepCycles 1 | Should -Be $false
                }
            }
        }

        Describe 'xExchangeHelper\Assert-ExchangeSetupArgumentsComplete' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called and setup is complete' {
                It 'Should execute without throwing an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            SetupComplete = $true
                        }
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path "c:\Exchange\setup.exe" -Arguments 'SetupArgs' } | Should -Not -Throw
                }
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called and setup is not complete' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $true
                    }

                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            SetupComplete = $false
                        }
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path "c:\Exchange\setup.exe" -Arguments 'SetupArgs' } | Should -Throw -ExpectedMessage 'Exchange setup did not complete successfully. See "<system drive>\ExchangeSetupLogs\ExchangeSetup.log" for details.'
                }
            }

            Context 'When Assert-ExchangeSetupArgumentsComplete is called with wrong file path' {
                It 'Should throw an exception' {
                    Mock -CommandName Test-Path -Verifiable -MockWith {
                        return $false
                    }

                    Mock -CommandName Get-ExchangeInstallStatus -Verifiable -MockWith {
                        return @{
                            SetupComplete = $true
                        }
                    }

                    { Assert-ExchangeSetupArgumentsComplete -Path "c:\Exchange\setup.exe" -Arguments 'SetupArgs' } | Should -Throw -ExpectedMessage "Path to Exchange setup 'c:\Exchange\setup.exe' does not exists."
                }
            }
        }

        Describe 'xExchangeHelper\Get-ExchangeVersionYear' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $validProductVersions = @(
                @{
                    VersionMajor = 15
                    VersionMinor = 0
                    Year         = '2013'
                }
                @{
                    VersionMajor = 15
                    VersionMinor = 1
                    Year         = '2016'
                }
                @{
                    VersionMajor = 15
                    VersionMinor = 2
                    Year         = '2019'
                }
            )

            $invalidProductVersions = @(
                @{
                    VersionMajor = 15
                    VersionMinor = 7
                    Year         = 'N/A'
                }
                @{
                    VersionMajor = 14
                    VersionMinor = 0
                    Year         = 'N/A'
                }
            )

            Context 'When Get-ExchangeVersionYear is called and finds a valid VersionMajor and VersionMinor' {
                It 'Should return the correct Exchange year' -TestCases $validProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    Get-ExchangeVersionYear | Should -Be $Year
                }
            }

            Context 'When Get-ExchangeVersionYear is called and finds an invalid VersionMajor or VersionMinor without ThrowIfUnknownVersion' {
                It 'Should return N/A' -TestCases $invalidProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    Get-ExchangeVersionYear | Should -Be $Year
                }
            }

            Context 'When Get-ExchangeVersionYear is called and finds an invalid VersionMajor or VersionMinor and ThrowIfUnknownVersion is specified' {
                It 'Should throw an exception' -TestCases $invalidProductVersions {
                    param
                    (
                        [System.Int32]
                        $VersionMajor,

                        [System.Int32]
                        $VersionMinor,

                        [System.String]
                        $Year
                    )

                    Mock -CommandName Get-DetailedInstalledVersion -Verifiable -MockWith {
                        return @{
                            VersionMajor = $VersionMajor
                            VersionMinor = $VersionMinor
                        }
                    }

                    { Get-ExchangeVersionYear -ThrowIfUnknownVersion $true } | Should -Throw -ExpectedMessage 'Failed to discover a known Exchange Version'
                }
            }
        }

        Describe 'xExchangeHelper\Get-ExchangeUninstallKey' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When Get-ExchangeUninstallKey is called and Exchange 2016 or 2019 is installed' {
                It 'Should return the 2016/2019 uninstall key' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter {$Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}'} -MockWith { return $true }

                    Get-ExchangeUninstallKey | Should -Be -Not $Null
                }
            }

            Context 'When Get-ExchangeUninstallKey is called and Exchange 2013 is installed' {
                It 'Should return the 2016/2019 uninstall key' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter {$Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}'} -MockWith { return $null }
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter {$Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4934D1EA-BE46-48B1-8847-F1AF20E892C1}'} -MockWith { return $true }

                    Get-ExchangeUninstallKey | Should -Be -Not $Null
                }
            }

            Context 'When Get-ExchangeUninstallKey is called and no Exchange is installed' {
                It 'Should return NULL' {
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter {$Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}'} -MockWith { return $null }
                    Mock -CommandName Get-Item -Verifiable -ParameterFilter {$Path -like 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4934D1EA-BE46-48B1-8847-F1AF20E892C1}'} -MockWith { return $null }

                    Get-ExchangeUninstallKey | Should -Be $Null
                }
            }
        }

        Describe 'xExchangeHelper\Get-DetailedInstalledVersion' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            Context 'When DetailedInstalledVersion is called and a valid key is returned by Get-ExchangeUninstallKey' {
                It 'Should return custom object with VersionMajor and VersionMinor properties' {
                    Mock -CommandName Get-ExchangeUninstallKey -Verifiable -MockWith { return @{Name = 'SomeKeyName'} }
                    Mock -CommandName Get-ItemProperty -Verifiable -ParameterFilter {$Name -eq 'VersionMajor'} -MockWith { return 15 }
                    Mock -CommandName Get-ItemProperty -Verifiable -ParameterFilter {$Name -eq 'VersionMinor'} -MockWith { return 1 }

                    $installedVersionDetails = Get-DetailedInstalledVersion

                    $installedVersionDetails.VersionMajor | Should -Be 15
                    $installedVersionDetails.VersionMinor | Should -Be 1
                }
            }

            Context 'When DetailedInstalledVersion is called and no valid key is returned by Get-ExchangeUninstallKey' {
                It 'Should return NULL' {
                    Mock -CommandName Get-ExchangeUninstallKey -Verifiable -MockWith { return $null }

                    Get-DetailedInstalledVersion | Should -Be $null
                }
            }
        }

        Describe 'Test-ShouldUpgradeExchange' -Tag 'Helper' {
            AfterEach {
                Assert-VerifiableMock
            }

            $cases = @(
                        @{
                            Case = 'Setup.exe is newer.'
                            SetupVersionMajor = 15
                            SetupVersionMinor = 1
                            SetupVersionBuild = 2000
                            ExchangeVersionMajor = 15
                            ExchangeVersionMinor = 1
                            ExchangeVersionBuild = 1800
                            Result            = $true
                        }
                        @{
                            Case = 'Setup.exe and installed Exchange version is the same.'
                            SetupVersionMajor = 15
                            SetupVersionMinor = 1
                            SetupVersionBuild = 2000
                            ExchangeVersionMajor = 15
                            ExchangeVersionMinor = 1
                            ExchangeVersionBuild = 2000
                            Result            = $false
                        }
                        @{
                            Case = 'Installed Exchange version is different than the setup.exe. e.g. 2013, 2016'
                            SetupVersionMajor = 15
                            SetupVersionMinor = 1
                            SetupVersionBuild = 2000
                            ExchangeVersionMajor = 15
                            ExchangeVersionMinor = 0
                            ExchangeVersionBuild = 2000
                            Result            = $false
                        }
                        @{
                            Case = 'Setup.exe version is different than the installed Exchange. e.g. 2013, 2016'
                            SetupVersionMajor = 15
                            SetupVersionMinor = 0
                            SetupVersionBuild = 2000
                            ExchangeVersionMajor = 15
                            ExchangeVersionMinor = 1
                            ExchangeVersionBuild = 2000
                            Result            = $false
                        }
                    )

            Context 'When Test-ShouldUpgradeExchange is called for different cases.' {
                It 'For case <Case> should return <Result>' -TestCases $cases {

                    Param(
                        [System.String]
                        $Case,

                        [System.Int32]
                        $SetupVersionMajor,

                        [System.Int32]
                        $SetupVersionMinor,

                        [System.Int32]
                        $SetupVersionBuild,

                        [System.Int32]
                        $ExchangeVersionMajor,

                        [System.Int32]
                        $ExchangeVersionMinor,

                        [System.Int32]
                        $ExchangeVersionBuild,

                        [System.Boolean]
                        $Result
                    )

                    Mock -CommandName Get-SetupExeVersion -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $SetupVersionMajor
                            VersionMinor = $SetupVersionMinor
                            VersionBuild = $SetupVersionBuild
                        }
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $ExchangeVersionMajor
                            VersionMinor = $ExchangeVersionMinor
                            VersionBuild = $ExchangeVersionBuild
                        }
                    }

                    Test-ShouldUpgradeExchange -Path 'test' | Should -Be $Result
                }
            }

            Context 'When Get-SetupExeVersion returns null within Test-ShouldUpgradeExchange.' {
                It 'Should return $false' {

                    Mock -CommandName Get-SetupExeVersion -MockWith {
                        return $null
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $ExchangeVersionMajor
                            VersionMinor = $ExchangeVersionMinor
                            VersionBuild = $ExchangeVersionBuild
                        }
                    }

                    Test-ShouldUpgradeExchange -Path 'test' | Should -Be $false
                }
            }

            Context 'When Get-DetailedInstalledVersion returns null within Test-ShouldUpgradeExchange.' {
                It 'Should show output of Write-Error and return with $false' {

                    Mock -CommandName Get-SetupExeVersion -MockWith {
                        return [PSCustomObject] @{
                            VersionMajor = $SetupVersionMajor
                            VersionMinor = $SetupVersionMinor
                            VersionBuild = $SetupVersionBuild
                        }
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -MockWith {
                        return $null
                    }

                    Test-ShouldUpgradeExchange -Path 'test' | Should -Be $false
                }
            }

            Context 'When Get-DetailedInstalledVersion and Get-SetupExeVersion return null within Test-ShouldUpgradeExchange.' {
                It 'Should show output of Write-Error and return with $false' {

                    Mock -CommandName Get-SetupExeVersion -MockWith {
                        return $false
                    }

                    Mock -CommandName Get-DetailedInstalledVersion -MockWith {
                        return $null
                    }

                    Test-ShouldUpgradeExchange -Path 'test' | Should -Be $false
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}
