###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchMailboxServer\MSFT_xExchMailboxServer.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($Global:ShellCredentials -eq $null)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Test Setting Properties with xExchMailboxServer" {
        #Make sure DB activation is not blocked
        $testParams = @{
            Identity = $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Clear DB Activation Blockers 1" -ExpectedGetResults $expectedGetResults
        

        #Block DB activation
        $testParams.DatabaseCopyActivationDisabledAndMoveNow = $true
        $testParams.DatabaseCopyAutoActivationPolicy = "Blocked"

        $expectedGetResults.DatabaseCopyActivationDisabledAndMoveNow = $true
        $expectedGetResults.DatabaseCopyAutoActivationPolicy = "Blocked"

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Block DB Activation" -ExpectedGetResults $expectedGetResults


        #Make sure DB activation is not blocked
        $testParams = @{
            Identity = $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Clear DB Activation Blockers 2" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    