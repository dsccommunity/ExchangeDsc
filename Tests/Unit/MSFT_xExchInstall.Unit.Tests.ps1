<#
    .SYNOPSIS
        Automated unit tests for xExchInstall DSC Resource.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchInstall'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#endregion HEADER

Describe 'Mocked Tests of xExchInstall and Related Methods' {
    $getInstallStatusParams = @{
        Arguments         = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
        VerbosePreference = 'SilentlyContinue'
    }

    $testTargetResourceParams = @{
        Path       = 'E:\Setup.exe'
        Arguments  = '/mode:Install /role:Mailbox /Iacceptexchangeserverlicenseterms'
        Credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist "fakeuser",(New-Object -TypeName System.Security.SecureString)
    }

    It 'Get-InstallStatus: No Exchange Present' {
        Mock -CommandName Get-ShouldInstallLanguagePack -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupRunning -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupComplete -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsExchangePresent -ModuleName xExchangeHelper -MockWith { return $false }

        $installStatus = Get-InstallStatus @getInstallStatusParams

        !$installStatus.ShouldInstallLanguagePack -and `
        !$installStatus.SetupRunning -and `
        !$installStatus.SetupComplete -and `
        !$installStatus.ExchangePresent -and `
        $installStatus.ShouldStartInstall | `
        Should Be $true
    }

    It 'Test-TargetResource: No Exchange Present' {
        Mock -CommandName Get-InstallStatus -ModuleName MSFT_xExchInstall -MockWith {
            return @{
                ShouldInstallLanguagePack = $false
                SetupRunning              = $false
                SetupComplete             = $false
                ExchangePresent           = $false
                ShouldStartInstall        = $true
            }
        }

        Test-TargetResource @testTargetResourceParams | Should Be $false
    }

    It 'Get-InstallStatus: Setup Fully Complete Test' {
        Mock -CommandName Get-ShouldInstallLanguagePack -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupRunning -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupComplete -ModuleName xExchangeHelper -MockWith { return $true }
        Mock -CommandName Get-IsExchangePresent -ModuleName xExchangeHelper -MockWith { return $true }

        $installStatus = Get-InstallStatus @getInstallStatusParams

        !$installStatus.ShouldInstallLanguagePack -and `
        !$installStatus.SetupRunning -and `
        $installStatus.SetupComplete -and `
        $installStatus.ExchangePresent -and `
        !$installStatus.ShouldStartInstall | `
        Should Be $true
    }

    It 'Test-TargetResource: Setup Fully Complete Test' {
        Mock -CommandName Get-InstallStatus -ModuleName MSFT_xExchInstall -MockWith {
            return @{
                ShouldInstallLanguagePack = $false
                SetupRunning              = $false
                SetupComplete             = $true
                ExchangePresent           = $true
                ShouldStartInstall        = $false
            }
        }

        Test-TargetResource @testTargetResourceParams | Should Be $true
    }

    It 'Get-InstallStatus: Setup Partially Complete Test' {
        Mock -CommandName Get-ShouldInstallLanguagePack -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupRunning -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupComplete -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsExchangePresent -ModuleName xExchangeHelper -MockWith { return $true }

        $installStatus = Get-InstallStatus @getInstallStatusParams

        !$installStatus.ShouldInstallLanguagePack -and `
        !$installStatus.SetupRunning -and `
        !$installStatus.SetupComplete -and `
        $installStatus.ExchangePresent -and `
        $installStatus.ShouldStartInstall | `
        Should Be $true
    }

    It 'Test-TargetResource: Setup Partially Complete Test' {
        Mock -CommandName Get-InstallStatus -ModuleName MSFT_xExchInstall -MockWith {
            return @{
                ShouldInstallLanguagePack = $false
                SetupRunning              = $false
                SetupComplete             = $false
                ExchangePresent           = $true
                ShouldStartInstall        = $true
            }
        }

        Test-TargetResource @testTargetResourceParams | Should Be $false
    }

    It 'Get-InstallStatus: Setup Running Test' {
        Mock -CommandName Get-ShouldInstallLanguagePack -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupRunning -ModuleName xExchangeHelper -MockWith { return $true }
        Mock -CommandName Get-IsSetupComplete -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsExchangePresent -ModuleName xExchangeHelper -MockWith { return $true }

        $installStatus = Get-InstallStatus @getInstallStatusParams

        !$installStatus.ShouldInstallLanguagePack -and `
        $installStatus.SetupRunning -and `
        !$installStatus.SetupComplete -and `
        $installStatus.ExchangePresent -and `
        !$installStatus.ShouldStartInstall | `
        Should Be $true
    }

    It 'Test-TargetResource: Setup Running Test' {
        Mock -CommandName Get-InstallStatus -ModuleName MSFT_xExchInstall -MockWith {
            return @{
                ShouldInstallLanguagePack = $false
                SetupRunning              = $true
                SetupComplete             = $false
                ExchangePresent           = $true
                ShouldStartInstall        = $false
            }
        }

        Test-TargetResource @testTargetResourceParams | Should Be $false
    }

    It 'Get-InstallStatus: Install Language Pack' {
        Mock -CommandName Get-ShouldInstallLanguagePack -ModuleName xExchangeHelper -MockWith { return $true }
        Mock -CommandName Get-IsSetupRunning -ModuleName xExchangeHelper -MockWith { return $false }
        Mock -CommandName Get-IsSetupComplete -ModuleName xExchangeHelper -MockWith { return $true }
        Mock -CommandName Get-IsExchangePresent -ModuleName xExchangeHelper -MockWith { return $true }

        $installStatus = Get-InstallStatus @getInstallStatusParams

        $installStatus.ShouldInstallLanguagePack -and `
        !$installStatus.SetupRunning -and `
        $installStatus.SetupComplete -and `
        $installStatus.ExchangePresent -and `
        $installStatus.ShouldStartInstall | `
        Should Be $true
    }

    It 'Test-TargetResource: Install Language Pack' {
        Mock -CommandName Get-InstallStatus -ModuleName MSFT_xExchInstall -MockWith {
            return @{
                ShouldInstallLanguagePack = $true
                SetupRunning              = $false
                SetupComplete             = $true
                ExchangePresent           = $true
                ShouldStartInstall        = $true
            }
        }

        Test-TargetResource @testTargetResourceParams | Should Be $false
    }
}
