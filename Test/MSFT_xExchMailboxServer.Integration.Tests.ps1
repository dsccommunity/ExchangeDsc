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
            MaximumActiveDatabases = "36"
            MaximumPreferredActiveDatabases = "24"
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
            MaximumActiveDatabases = "36"
            MaximumPreferredActiveDatabases = "24"
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Clear DB Activation Blockers 1 and set MaxDBValues" -ExpectedGetResults $expectedGetResults
        

        #Block DB activation
        $testParams.DatabaseCopyActivationDisabledAndMoveNow = $true
        $testParams.DatabaseCopyAutoActivationPolicy = "Blocked"
        $testParams.MaximumActiveDatabases = "24"
        $testParams.MaximumPreferredActiveDatabases = "12"

        $expectedGetResults.DatabaseCopyActivationDisabledAndMoveNow = $true
        $expectedGetResults.DatabaseCopyAutoActivationPolicy = "Blocked"
        $expectedGetResults.MaximumActiveDatabases = "24"
        $expectedGetResults.MaximumPreferredActiveDatabases = "12"

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Block DB Activation and modify MaxDBValues" -ExpectedGetResults $expectedGetResults


        #Make sure DB activation is not blocked
        $testParams = @{
            Identity = $env:COMPUTERNAME
            Credential = $Global:ShellCredentials
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
            MaximumActiveDatabases = ''
            MaximumPreferredActiveDatabases = ''
        }

        $expectedGetResults = @{
            Identity = $env:COMPUTERNAME
            DatabaseCopyActivationDisabledAndMoveNow = $false
            DatabaseCopyAutoActivationPolicy = "Unrestricted"
            MaximumActiveDatabases = $null
            MaximumPreferredActiveDatabases = $null
        }

        Test-AllTargetResourceFunctions -Params $testParams -ContextLabel "Clear DB Activation Blockers 2 and clear MaxDBValues" -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
    
