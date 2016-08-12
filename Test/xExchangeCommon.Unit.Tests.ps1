###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Remove any existing Remote PowerShell sessions created by xExchange and verify they are gone
function RemoveExistingPSSessions
{
    Context 'Remove existing Remote PowerShell Session to Exchange' {
        RemoveExistingRemoteSession

        $Session = $null
        $Session = GetExistingExchangeSession

        It "Session Should Be Null" {
            $Session | Should BeNullOrEmpty
        }
    }
}

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Test Exchange Remote PowerShell Functions" {
        #Remove any existing Remote PS Sessions to Exchange before getting started
        RemoveExistingPSSessions


        #Verify we can setup a new Remote PS Session to Exchange
        Context 'Establish new Remote PowerShell Session to Exchange' {
            GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "Get-ExchangeServer"

            $Session = $null
            $Session = GetExistingExchangeSession

            It "Session Should Not Be Null" {
                ($null -ne $Session) | Should Be $true
            }
        }
        

        #Remove sessions again before continuing
        RemoveExistingPSSessions
        

        #Simulate that setup is running (using notepad.exe), and try to establish a new session. This should fail
        Context 'Make sure PS session is not established when setup process is running' {
            Start-Process Notepad.exe

            $caughtException = $false

            try
            {
                GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "Get-ExchangeServer" -SetupProcessName "notepad"
            }
            catch
            {
                $caughtException = $true
            }

            It "GetRemoteExchangeSession Should Throw Exception" {
                $caughtException | Should Be $true
            }

            $Session = $null
            $Session = GetExistingExchangeSession

            It "Session Should Be Null" {
                ($null -eq $Session) | Should Be $true
            }
        }
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
