[System.String] $script:moduleRoot = Split-Path -Path $PSScriptRoot -Parent

###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force

<#
    .SYNOPSIS
        Remove any existing Remote PowerShell sessions created by xExchange and
        verify they are gone.
#>
function Remove-ExistingPSSession
{
    param ()

    Context 'Remove existing Remote PowerShell Session to Exchange' {
        Remove-RemoteExchangeSession

        $Session = $null
        $Session = Get-ExistingRemoteExchangeSession

        It 'Session Should Be Null' {
            $Session | Should BeNullOrEmpty
        }
    }
}

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'Test Exchange Remote PowerShell Functions' {
        # Remove any existing Remote PS Sessions to Exchange before getting started
        Remove-ExistingPSSession


        # Verify we can setup a new Remote PS Session to Exchange
        Context 'Establish new Remote PowerShell Session to Exchange' {
            Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer'

            $Session = $null
            $Session = Get-ExistingRemoteExchangeSession

            It 'Session Should Not Be Null' {
                ($null -ne $Session) | Should Be $true
            }
        }


        # Remove sessions again before continuing
        Remove-ExistingPSSession


        # Simulate that setup is running (using notepad.exe), and try to establish a new session. This should fail
        Context 'Make sure PS session is not established when setup process is running' {
            Start-Process Notepad.exe

            $caughtException = $false

            try
            {
                Get-RemoteExchangeSession -Credential $shellCredentials -CommandsToLoad 'Get-ExchangeServer' -SetupProcessName 'notepad'
            }
            catch
            {
                $caughtException = $true
            }

            It 'Get-RemoteExchangeSession Should Throw Exception' {
                $caughtException | Should Be $true
            }

            $Session = $null
            $Session = Get-ExistingRemoteExchangeSession

            It 'Session Should Be Null' {
                ($null -eq $Session) | Should Be $true
            }
        }

        <#
            Test for issue (https://github.com/PowerShell/xExchange/issues/211)
            Calling Compare-UnlimitedToString when the Unlimited is of type [Microsoft.Exchange.Data.Unlimited`1[System.Int32]]
            and the string value contains a number throws an exception.
        #>
        Context 'Test Compare-UnlimitedToString with Int32 Unlimited and String Containing a Number' {
            $caughtException = $false

            [Microsoft.Exchange.Data.Unlimited`1[System.Int32]] $unlimitedInt32 = 1000

            try
            {
                Compare-UnlimitedToString -Unlimited $unlimitedInt32 -String '1000'
            }
            catch
            {
                $caughtException = $true
            }

            It 'Should not hit exception trying to test Compare-UnlimitedToString' {
                $caughtException | Should Be $false
            }
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
