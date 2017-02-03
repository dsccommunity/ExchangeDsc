###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.
###This module has the following additional requirements;
### * Requires that the ActiveDirectory module is installed
### * Requires that the DAG computer account has been precreated
### * Requires that the Failover-Clustering feature has been installed, and the machine has since been rebooted

Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchDatabaseAvailabilityGroup\MSFT_xExchDatabaseAvailabilityGroup.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Removes the test DAG if it exists, and any associated databases
function PrepTestDAG
{
    [CmdletBinding()]
    param
    (
        [string]
        $TestServerName1,

        [string]
        $TestServerName2,

        [string]
        $TestDAGName,

        [string]
        $TestDBName
    )
    
    Write-Verbose "Cleaning up test DAG and related resources"

    $secondServerSpecified = (([String]::IsNullOrEmpty($TestServerName2)) -eq $false)

    GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad "*-MailboxDatabase","*-DatabaseAvailabilityGroup","Remove-DatabaseAvailabilityGroupServer","Get-MailboxDatabaseCopyStatus","Remove-MailboxDatabaseCopy"

    $existingDB = Get-MailboxDatabase -Identity "$($TestDBName)" -Status -ErrorAction SilentlyContinue

    #First remove the test database copies
    if ($null -ne $existingDB)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($TestDBName)" | Where-Object {$existingDB.MountedOnServer.ToLower().Contains($_.MailboxServer.ToLower()) -eq $false} | Remove-MailboxDatabaseCopy -Confirm:$false
    }

    #Now remove the actual DB's
    Get-MailboxDatabase | Where-Object {$_.Name -like "$($TestDBName)"} | Remove-MailboxDatabase -Confirm:$false

    #Remove the files
    Get-ChildItem -LiteralPath "\\$($TestServerName1)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue

    if ($secondServerSpecified)
    {
        Get-ChildItem -LiteralPath "\\$($TestServerName2)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($TestDBName)" -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }

    #Last remove the test DAG
    $dag = Get-DatabaseAvailabilityGroup -Identity "$($TestDAGName)" -ErrorAction SilentlyContinue

    if ($null -ne $dag)
    {
        Set-DatabaseAvailabilityGroup -Identity "$($TestDAGName)" -DatacenterActivationMode Off

        foreach ($server in $dag.Servers)
        {
            Remove-DatabaseAvailabilityGroupServer -MailboxServer "$($server.Name)" -Identity "$($TestDAGName)" -Confirm:$false
        }

        Remove-DatabaseAvailabilityGroup -Identity "$($TestDAGName)" -Confirm:$false
    }

    if ($null -ne (Get-DatabaseAvailabilityGroup -Identity "$($TestDAGName)" -ErrorAction SilentlyContinue))
    {
        throw "Failed to remove test DAG"
    }

    #Disable the DAG computer account
    $compAccount = Get-ADComputer -Identity $TestDAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount -and $compAccount.Enabled -eq $true)
    {
        $compAccount | Disable-ADAccount
    }

    Write-Verbose "Finished cleaning up test DAG and related resources"
}

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    if ($null -eq $Global:DAGName)
    {
        $Global:DAGName = Read-Host -Prompt "Enter the name of the DAG to use for testing"
    }

    $compAccount = Get-ADComputer -Identity $Global:DAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount)
    {
        #Check if Exchange is installed on this machine. If not, we can't run tests
        [bool]$exchangeInstalled = IsSetupComplete

        [string]$Global:TestDBName = "TestDAGDB1"

        if ($exchangeInstalled)
        {
            #Get required credentials to use for the test
            if ($null -eq $Global:ShellCredentials)
            {
                [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
            }

            #Get the Server FQDN for using in URL's
            if ($null -eq $Global:ServerFqdn)
            {
                $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
            }

            if ($null -eq $Global:SecondDAGMember)
            {
                $Global:SecondDAGMember = Read-Host -Prompt "Enter the host name of the second DAG member to use for testing, or press ENTER to skip."

                #If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $Global:SecondDAGMember)
                {
                    $Global:SecondDAGMember = ""
                }
            }

            while (([String]::IsNullOrEmpty($Global:Witness1)))
            {
                $Global:Witness1 = Read-Host -Prompt "Enter the FQDN of the first File Share Witness for testing"
            }

            #Allow for the second witness to not be specified
            if ($null -eq $Global:Witness2)
            {
                $Global:Witness2 = Read-Host -Prompt "Enter the FQDN of the second File Share Witness for testing, or press ENTER to skip."

                #If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $Global:Witness2)
                {
                    $Global:Witness2 = ""
                }
            }

            #Remove the existing DAG
            PrepTestDAG -TestServerName1 $env:COMPUTERNAME -TestServerName2 $Global:SecondDAGMember -TestDAGName $Global:DAGName -TestDBName $Global:TestDBName

            Describe "Test Creating and Modifying a DAG, adding DAG members, creating a DAG database, and adding database copies" {
                #Create a new DAG
                $dagTestParams = @{            
                    Name = $Global:DAGName
                    Credential = $Global:ShellCredentials
                    AutoDagAutoReseedEnabled = $true
                    AutoDagDatabaseCopiesPerDatabase = 2
                    AutoDagDatabaseCopiesPerVolume = 2
                    AutoDagDatabasesRootFolderPath = "C:\ExchangeDatabases"
                    AutoDagDiskReclaimerEnabled = $true
                    AutoDagTotalNumberOfServers = 2
                    AutoDagTotalNumberOfDatabases = 2
                    AutoDagVolumesRootFolderPath = "C:\ExchangeVolumes"
                    DatabaseAvailabilityGroupIpAddresses = "192.168.1.99","192.168.2.99"
                    DatacenterActivationMode = "DagOnly"
                    ManualDagNetworkConfiguration = $true
                    NetworkCompression = "Enabled"
                    NetworkEncryption = "InterSubnetOnly"
                    ReplayLagManagerEnabled = $true
                    SkipDagValidation = $true
                    WitnessDirectory = "C:\FSW"
                    WitnessServer = $Global:Witness1
                }

                #Skip checking DatacenterActivationMode until we have DAG members
                $dagExpectedGetResults = @{
                    Name = $Global:DAGName
                    AutoDagAutoReseedEnabled = $true
                    AutoDagDatabaseCopiesPerDatabase = 2
                    AutoDagDatabaseCopiesPerVolume = 2
                    AutoDagDatabasesRootFolderPath = "C:\ExchangeDatabases"
                    AutoDagDiskReclaimerEnabled = $true
                    AutoDagTotalNumberOfServers = 2
                    AutoDagTotalNumberOfDatabases = 2
                    AutoDagVolumesRootFolderPath = "C:\ExchangeVolumes"      
                    ManualDagNetworkConfiguration = $true
                    NetworkCompression = "Enabled"
                    NetworkEncryption = "InterSubnetOnly"
                    ReplayLagManagerEnabled = $true
                    WitnessDirectory = "C:\FSW"
                    WitnessServer = $Global:Witness1
                }

                if (!([String]::IsNullOrEmpty($Global:Witness2)))
                {
                    $dagTestParams.Add("AlternateWitnessServer", $Global:Witness2)
                    $dagTestParams.Add("AlternateWitnessDirectory", "C:\FSW")
                    $dagExpectedGetResults.Add("AlternateWitnessServer", $Global:Witness2)
                    $dagExpectedGetResults.Add("AlternateWitnessDirectory", "C:\FSW")
                }

                $serverVersion = GetExchangeVersion

                if ($serverVersion -eq "2016")
                {
                    $dagTestParams.Add("FileSystem", "ReFS")
                    $dagTestParams.Add("AutoDagAutoRedistributeEnabled", $true)
                    $dagTestParams.Add("PreferenceMoveFrequency", "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                    $dagExpectedGetResults.Add("FileSystem", "ReFS")
                    $dagExpectedGetResults.Add("AutoDagAutoRedistributeEnabled", $true)
                    $dagExpectedGetResults.Add("PreferenceMoveFrequency", "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                }

                Test-TargetResourceFunctionality -Params $dagTestParams -ContextLabel "Create the test DAG" -ExpectedGetResults $dagExpectedGetResults
                Test-ArrayContentsEqual -TestParams $dagTestParams -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses -GetResultParameterName "DatabaseAvailabilityGroupIpAddresses" -ContextLabel "Verify DatabaseAvailabilityGroupIpAddresses" -ItLabel "DatabaseAvailabilityGroupIpAddresses should contain two values"


                #Add this server as a DAG member
                Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchDatabaseAvailabilityGroupMember\MSFT_xExchDatabaseAvailabilityGroupMember.psm1
        
                $dagMemberTestParams = @{
                    MailboxServer = $env:COMPUTERNAME
                    Credential = $Global:ShellCredentials
                    DAGName = $Global:DAGName
                    SkipDagValidation = $true
                }

                $dagMemberExpectedGetResults = @{
                    MailboxServer = $env:COMPUTERNAME
                    DAGName = $Global:DAGName
                }

                Test-TargetResourceFunctionality -Params $dagMemberTestParams -ContextLabel "Add first member to the test DAG" -ExpectedGetResults $dagMemberExpectedGetResults

                #Do second DAG member tests if a second member was specified
                if (([String]::IsNullOrEmpty($Global:SecondDAGMember)) -eq $false)
                {               
                    #Add second DAG member
                    $dagMemberTestParams = @{
                        MailboxServer = $Global:SecondDAGMember
                        Credential = $Global:ShellCredentials
                        DAGName = $Global:DAGName
                        SkipDagValidation = $true
                    }

                    $dagMemberExpectedGetResults = @{
                        MailboxServer = $Global:SecondDAGMember
                        DAGName = $Global:DAGName
                    }

                    Test-TargetResourceFunctionality -Params $dagMemberTestParams -ContextLabel "Add second member to the test DAG" -ExpectedGetResults $dagMemberExpectedGetResults


                    #Test the DAG again, with props that only take effect once there are members
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchDatabaseAvailabilityGroup\MSFT_xExchDatabaseAvailabilityGroup.psm1

                    $dagExpectedGetResults.DatacenterActivationMode = "DagOnly"

                    Test-TargetResourceFunctionality -Params $dagTestParams -ContextLabel "Set remaining props on the test DAG" -ExpectedGetResults $dagExpectedGetResults
                    Test-ArrayContentsEqual -TestParams $dagTestParams -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses -GetResultParameterName "DatabaseAvailabilityGroupIpAddresses" -ContextLabel "Verify DatabaseAvailabilityGroupIpAddresses" -ItLabel "DatabaseAvailabilityGroupIpAddresses should contain two values"


                    #Create a new DAG database
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchMailboxDatabase\MSFT_xExchMailboxDatabase.psm1

                    $dagDBTestParams = @{
                        Name = $Global:TestDBName
                        Credential = $Global:ShellCredentials
                        AllowServiceRestart = $true
                        DatabaseCopyCount = 2        
                        EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($Global:TestDBName)\$($Global:TestDBName).edb"
                        LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($Global:TestDBName)"
                        Server = $env:COMPUTERNAME
                    }

                    $dagDBExpectedGetResults = @{
                        Name = $Global:TestDBName    
                        EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($Global:TestDBName)\$($Global:TestDBName).edb"
                        LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($Global:TestDBName)"
                        Server = $env:COMPUTERNAME
                    }

                    Test-TargetResourceFunctionality -Params $dagDBTestParams -ContextLabel "Create test database" -ExpectedGetResults $dagDBExpectedGetResults


                    #Add DB Copy
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchMailboxDatabaseCopy\MSFT_xExchMailboxDatabaseCopy.psm1

                    $dagDBCopyTestParams = @{
                        Identity = $Global:TestDBName
                        MailboxServer = $Global:SecondDAGMember
                        Credential = $Global:ShellCredentials
                        ActivationPreference = 2
                    }

                    $dagDBCopyExpectedGetResults = @{
                        Identity = $Global:TestDBName
                        MailboxServer = $Global:SecondDAGMember
                        ActivationPreference = 2
                    }

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams -ContextLabel "Add a database copy" -ExpectedGetResults $dagDBCopyExpectedGetResults
                }
            }
        }
        else
        {
            Write-Verbose "Tests in this file require that Exchange is installed to be run."
        }
    }
    else
    {
        Write-Verbose "Tests in this file require that the computer account for the DAG is precreated"
    }
}
else
{
    Write-Verbose "Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS"
}
    
