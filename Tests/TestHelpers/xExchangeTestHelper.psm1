<#
    Function to be used within pester for end to end testing of Get/Set/Test-TargetResource
    Function first calls Set-TargetResource with provided parameters, then runs Get and Test-TargetResource,
    and ensures they match $ExpectedGetResults and $ExpectedTestResult
#>
function Test-TargetResourceFunctionality
{
    [CmdletBinding()]
    param
    (
        [Parameter()]    
        [System.Collections.Hashtable]
        $Params,
        
        [Parameter()]
        [System.String]
        $ContextLabel, 
        
        [Parameter()]
        [System.Collections.Hashtable]
        $ExpectedGetResults, 
        
        [Parameter()]
        [System.Boolean]
        $ExpectedTestResult = $true
    )

    Context $ContextLabel {
        Set-TargetResource @Params -Verbose

        [System.Collections.Hashtable]$getResult = Get-TargetResource @Params -Verbose
        [System.Boolean]$testResult = Test-TargetResource @Params -Verbose

        #The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($null -eq $ExpectedGetResults)
        {
            It 'Get-TargetResource: Should Be Null' {
                $getResult | Should BeNullOrEmpty
            }
        }
        else
        {
            #Test each individual key in $ExpectedGetResult to see if they exist, and if the expected value matches
            foreach ($key in $ExpectedGetResults.Keys)
            {
                It "Get-TargetResource: Contains Key: $($key)" {
                    $getResult | Should Be ($getResult.ContainsKey($key))
                }

                if ($getResult.ContainsKey($key))
                {
                    It "Get-TargetResource: Value Matches for Key: $($key)" {
                        $getResult | Should Be ($getResult.ContainsKey($key) -and $getResult[$key] -eq $ExpectedGetResults[$key])
                    }
                }
            }
        }

        #Test the Test-TargetResource results
        It 'Test-TargetResource' {
            $testResult | Should Be $ExpectedTestResult
        }
    }
}

function Test-ArrayContentsEqual
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $TestParams, 
        
        [Parameter()]
        [System.String[]]
        $DesiredArrayContents, 
        
        [Parameter()]
        [System.String]
        $GetResultParameterName, 
        
        [Parameter()]
        [System.String]
        $ContextLabel, 
        
        [Parameter()]
        [System.String]
        $ItLabel
    )

    Context $ContextLabel {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @TestParams

        It $ItLabel {
            CompareArrayContents -Array1 $DesiredArrayContents -Array2 $getResult."$($GetResultParameterName)" -IgnoreCase | Should Be $true
        }
    }
}

function Test-Array2ContainsArray1
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $TestParams, 
        
        [Parameter()]
        [System.String[]]
        $DesiredArrayContents, 
        
        [Parameter()]
        [System.String]
        $GetResultParameterName, 
        
        [Parameter()]
        [System.String]
        $ContextLabel, 
        
        [Parameter()]
        [System.String]
        $ItLabel
    )

    Context $ContextLabel {
        [System.Collections.Hashtable]$getResult = Get-TargetResource @TestParams

        It $ItLabel {
            Array2ContainsArray1Contents -Array1 $DesiredArrayContents -Array2 $getResult."$($GetResultParameterName)" -IgnoreCase | Should Be $true
        }
    }
}

#Creates a test OAB for DSC, or sees if it exists. If it is created or exists, return the name of the OAB.
function Get-TestOfflineAddressBook
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $ShellCredentials
    )

    [System.String]$testOabName = 'Offline Address Book (DSC Test)'

    GetRemoteExchangeSession -Credential $ShellCredentials -CommandsToLoad '*-OfflineAddressBook'

    if ($null -eq (Get-OfflineAddressBook -Identity $testOabName -ErrorAction SilentlyContinue))
    {
        Write-Verbose -Message "Test OAB does not exist. Creating OAB with name '$testOabName'."

        $testOab = New-OfflineAddressBook -Name $testOabName -AddressLists '\'

        if ($null -eq $testOab)
        {
            throw 'Failed to create test OAB.'
        }
    }

    return $testOabName
}

#Removes the test DAG if it exists, and any associated databases
function Initialize-TestForDAG
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String[]]
        $ServerName,

        [Parameter()]
        [System.String]
        $DAGName,

        [Parameter()]
        [System.String]
        $DatabaseName
    )
    
    Write-Verbose -Message 'Cleaning up test DAG and related resources'

    GetRemoteExchangeSession -Credential $Global:ShellCredentials -CommandsToLoad '*-MailboxDatabase',`
                                                                                  '*-DatabaseAvailabilityGroup',`
                                                                                  'Remove-DatabaseAvailabilityGroupServer',`
                                                                                  'Get-MailboxDatabaseCopyStatus',`
                                                                                  'Remove-MailboxDatabaseCopy'

    $existingDB = Get-MailboxDatabase -Identity "$($DatabaseName)" -Status -ErrorAction SilentlyContinue

    #First remove the test database copies
    if ($null -ne $existingDB)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($DatabaseName)" | Where-Object -FilterScript {
            $existingDB.MountedOnServer.ToLower().Contains($_.MailboxServer.ToLower()) -eq $false
        } | Remove-MailboxDatabaseCopy -Confirm:$false
    }

    #Now remove the actual DB's
    Get-MailboxDatabase | Where-Object -FilterScript {
        $_.Name -like "$($DatabaseName)"
    } | Remove-MailboxDatabase -Confirm:$false

    #Remove the files
    foreach ($server in $ServerName)
    {
        Get-ChildItem -LiteralPath "\\$($server)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($DatabaseName)" `
                      -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
    }

    #Last remove the test DAG
    $dag = Get-DatabaseAvailabilityGroup -Identity "$($DAGName)" -ErrorAction SilentlyContinue

    if ($null -ne $dag)
    {
        Set-DatabaseAvailabilityGroup -Identity "$($DAGName)" -DatacenterActivationMode Off

        foreach ($server in $dag.Servers)
        {
            Remove-DatabaseAvailabilityGroupServer -MailboxServer "$($server.Name)" -Identity "$($DAGName)" -Confirm:$false
        }

        Remove-DatabaseAvailabilityGroup -Identity "$($DAGName)" -Confirm:$false
    }

    if ($null -ne (Get-DatabaseAvailabilityGroup -Identity "$($DAGName)" -ErrorAction SilentlyContinue))
    {
        throw 'Failed to remove test DAG'
    }

    #Disable the DAG computer account
    $compAccount = Get-ADComputer -Identity $DAGName -ErrorAction SilentlyContinue

    if ($null -ne $compAccount -and $compAccount.Enabled -eq $true)
    {
        $compAccount | Disable-ADAccount
    }

    Write-Verbose -Message 'Finished cleaning up test DAG and related resources'
}

Export-ModuleMember -Function *
