<#
    .SYNOPSIS
        Automated unit integration for MSFT_xExchDatabaseAvailabilityGroup DSC Resource
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
        This module has the following additional requirements;
            * Requires that the ActiveDirectory module is installed
            * Requires that the DAG computer account has been precreated
            * Requires that the Failover-Clustering feature has been installed, and the machine has since been rebooted
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchDatabaseAvailabilityGroup'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean]$exchangeInstalled = Get-IsSetupComplete

#endregion HEADER

$adModule = Get-Module -ListAvailable ActiveDirectory -ErrorAction SilentlyContinue

if ($null -ne $adModule)
{
    if ($null -eq $Global:DAGName)
    {
        $Global:DAGName = Read-Host -Prompt 'Enter the name of the DAG to use for testing'
    }

    $compAccount = Get-ADComputer -Identity $Global:DAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount)
    {
        [System.String]$Global:TestDBName = 'TestDAGDB1'

        if ($exchangeInstalled)
        {
            #Get required credentials to use for the test
            if ($null -eq $Global:ShellCredentials)
            {
                [PSCredential]$Global:ShellCredentials = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
            }

            #Get the Server FQDN for using in URL's
            if ($null -eq $Global:ServerFqdn)
            {
                $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
            }

            if ($null -eq $Global:SecondDAGMember)
            {
                $Global:SecondDAGMember = Read-Host -Prompt 'Enter the host name of the second DAG member to use for testing, or press ENTER to skip.'

                #If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $Global:SecondDAGMember)
                {
                    $Global:SecondDAGMember = ''
                }
            }

            #Make sure failover clustering is installed on both nodes. Start with this node.
            $fcNode1 = Get-WindowsFeature -Name Failover-Clustering -ComputerName $Global:ServerFqdn -ErrorAction SilentlyContinue

            if ($null -eq $fcNode1 -or !$fcNode1.Installed)
            {
                Write-Error -Message ('The Failover-Clustering role must be fully installed on' + $($Global:ServerFqdn) + `
                                      'before the server can be added to the cluster. Skipping all DAG tests.')
                return
            }

            if (!([System.String]::IsNullOrEmpty($Global:SecondDAGMember)))
            {
                $fcNode2 = Get-WindowsFeature -Name Failover-Clustering -ComputerName $Global:SecondDAGMember -ErrorAction SilentlyContinue

                if ($null -eq $fcNode2 -or !$fcNode2.Installed)
                {
                    Write-Error -Message ('The Failover-Clustering role must be fully installed on' + $($Global:SecondDAGMember) + `
                                          'before the server can be added to the cluster. Skipping tests that would utilize this DAG member.')
                                        
                    $Global:SecondDAGMember = ''
                }
            }

            while (([System.String]::IsNullOrEmpty($Global:Witness1)))
            {
                $Global:Witness1 = Read-Host -Prompt 'Enter the FQDN of the first File Share Witness for testing'
            }

            #Allow for the second witness to not be specified
            if ($null -eq $Global:Witness2)
            {
                $Global:Witness2 = Read-Host -Prompt 'Enter the FQDN of the second File Share Witness for testing, or press ENTER to skip.'

                #If they didn't enter anything, set to an empty string so we don't prompt again on a re-run of the test
                if ($null -eq $Global:Witness2)
                {
                    $Global:Witness2 = ''
                }
            }

            #Remove the existing DAG
            Initialize-TestForDAG -ServerName @($env:COMPUTERNAME,$Global:SecondDAGMember) `
                                  -DAGName $Global:DAGName `
                                  -DatabaseName $Global:TestDBName

            Describe 'Test Creating and Modifying a DAG, adding DAG members, creating a DAG database, and adding database copies' {
                #Create a new DAG
                $dagTestParams = @{            
                    Name = $Global:DAGName
                    Credential = $Global:ShellCredentials
                    AutoDagAutoReseedEnabled = $true
                    AutoDagDatabaseCopiesPerDatabase = 2
                    AutoDagDatabaseCopiesPerVolume = 2
                    AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
                    AutoDagDiskReclaimerEnabled = $true
                    AutoDagTotalNumberOfServers = 2
                    AutoDagTotalNumberOfDatabases = 2
                    AutoDagVolumesRootFolderPath = 'C:\ExchangeVolumes'
                    DatabaseAvailabilityGroupIpAddresses = '192.168.1.99','192.168.2.99'
                    DatacenterActivationMode = 'DagOnly'
                    ManualDagNetworkConfiguration = $true
                    NetworkCompression = 'Enabled'
                    NetworkEncryption = 'InterSubnetOnly'
                    ReplayLagManagerEnabled = $true
                    SkipDagValidation = $true
                    WitnessDirectory = 'C:\FSW'
                    WitnessServer = $Global:Witness1
                }

                #Skip checking DatacenterActivationMode until we have DAG members
                $dagExpectedGetResults = @{
                    Name = $Global:DAGName
                    AutoDagAutoReseedEnabled = $true
                    AutoDagDatabaseCopiesPerDatabase = 2
                    AutoDagDatabaseCopiesPerVolume = 2
                    AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
                    AutoDagDiskReclaimerEnabled = $true
                    AutoDagTotalNumberOfServers = 2
                    AutoDagTotalNumberOfDatabases = 2
                    AutoDagVolumesRootFolderPath = 'C:\ExchangeVolumes'      
                    ManualDagNetworkConfiguration = $true
                    NetworkCompression = 'Enabled'
                    NetworkEncryption = 'InterSubnetOnly'
                    ReplayLagManagerEnabled = $true
                    WitnessDirectory = 'C:\FSW'
                    WitnessServer = $Global:Witness1
                }

                if (!([System.String]::IsNullOrEmpty($Global:Witness2)))
                {
                    $dagTestParams.Add('AlternateWitnessServer', $Global:Witness2)
                    $dagTestParams.Add('AlternateWitnessDirectory', 'C:\FSW')
                    $dagExpectedGetResults.Add('AlternateWitnessServer', $Global:Witness2)
                    $dagExpectedGetResults.Add('AlternateWitnessDirectory', 'C:\FSW')
                }

                $serverVersion = GetExchangeVersion

                if ($serverVersion -eq '2016')
                {
                    $dagTestParams.Add('FileSystem', 'ReFS')
                    $dagTestParams.Add('AutoDagAutoRedistributeEnabled', $true)
                    $dagTestParams.Add('PreferenceMoveFrequency', "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                    $dagExpectedGetResults.Add('FileSystem', 'ReFS')
                    $dagExpectedGetResults.Add('AutoDagAutoRedistributeEnabled', $true)
                    $dagExpectedGetResults.Add('PreferenceMoveFrequency', "$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())")
                }

                Test-TargetResourceFunctionality -Params $dagTestParams `
                                                 -ContextLabel 'Create the test DAG' `
                                                 -ExpectedGetResults $dagExpectedGetResults
                
                Test-ArrayContentsEqual -TestParams $dagTestParams `
                                        -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses `
                                        -GetResultParameterName 'DatabaseAvailabilityGroupIpAddresses' `
                                        -ContextLabel 'Verify DatabaseAvailabilityGroupIpAddresses' `
                                        -ItLabel 'DatabaseAvailabilityGroupIpAddresses should contain two values'

                #Add this server as a DAG member
                Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchDatabaseAvailabilityGroupMember" -ChildPath "MSFT_xExchDatabaseAvailabilityGroupMember.psm1")))
        
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

                Test-TargetResourceFunctionality -Params $dagMemberTestParams `
                                                 -ContextLabel 'Add first member to the test DAG' `
                                                 -ExpectedGetResults $dagMemberExpectedGetResults

                #Do second DAG member tests if a second member was specified
                if (([System.String]::IsNullOrEmpty($Global:SecondDAGMember)) -eq $false)
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

                    Test-TargetResourceFunctionality -Params $dagMemberTestParams `
                                                     -ContextLabel 'Add second member to the test DAG' `
                                                     -ExpectedGetResults $dagMemberExpectedGetResults

                    #Test the DAG again, with props that only take effect once there are members
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

                    $dagExpectedGetResults.DatacenterActivationMode = 'DagOnly'

                    Test-TargetResourceFunctionality -Params $dagTestParams `
                                                     -ContextLabel 'Set remaining props on the test DAG' `
                                                     -ExpectedGetResults $dagExpectedGetResults
                    
                    Test-ArrayContentsEqual -TestParams $dagTestParams `
                                            -DesiredArrayContents $dagTestParams.DatabaseAvailabilityGroupIpAddresses `
                                            -GetResultParameterName 'DatabaseAvailabilityGroupIpAddresses' `
                                            -ContextLabel 'Verify DatabaseAvailabilityGroupIpAddresses' `
                                            -ItLabel 'DatabaseAvailabilityGroupIpAddresses should contain two values'

                    #Create a new DAG database
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchMailboxDatabase" -ChildPath "MSFT_xExchMailboxDatabase.psm1")))

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

                    Test-TargetResourceFunctionality -Params $dagDBTestParams `
                                                     -ContextLabel 'Create test database' `
                                                     -ExpectedGetResults $dagDBExpectedGetResults

                    #Add DB Copy
                    Get-Module MSFT_xExch* | Remove-Module -ErrorAction SilentlyContinue
                    Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "MSFT_xExchMailboxDatabaseCopy" -ChildPath "MSFT_xExchMailboxDatabaseCopy.psm1")))

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

                    Test-TargetResourceFunctionality -Params $dagDBCopyTestParams `
                                                     -ContextLabel 'Add a database copy' `
                                                     -ExpectedGetResults $dagDBCopyExpectedGetResults
                }
            }
        }
        else
        {
            Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
        }
    }
    else
    {
        Write-Verbose -Message 'Tests in this file require that the computer account for the DAG is precreated'
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that the ActiveDirectory module is installed. Run: Add-WindowsFeature RSAT-ADDS'
}
