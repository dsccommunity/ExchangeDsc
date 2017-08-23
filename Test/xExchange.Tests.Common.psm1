#Function to be used within pester for end to end testing of Get/Set/Test-TargetResource
#Function first calls Set-TargetResource with provided parameters, then runs Get and Test-TargetResource,
#and ensures they match $ExpectedGetResults and $ExpectedTestResult
function Test-TargetResourceFunctionality
{
    [CmdletBinding()]
    param([Hashtable]$Params, [string]$ContextLabel, [Hashtable]$ExpectedGetResults, [bool]$ExpectedTestResult = $true)

    Context $ContextLabel {
        Set-TargetResource @Params -Verbose

        [Hashtable]$getResult = Get-TargetResource @Params -Verbose
        [bool]$testResult = Test-TargetResource @Params -Verbose

        #The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($null -eq $ExpectedGetResults)
        {
            It "Get-TargetResource: Should Be Null" {
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
        It "Test-TargetResource" {
            $testResult | Should Be $ExpectedTestResult
        }
    }
}

function Test-ArrayContentsEqual
{
    [CmdletBinding()]
    param([Hashtable]$TestParams, [string[]]$DesiredArrayContents, [string]$GetResultParameterName, [string]$ContextLabel, [string]$ItLabel)

    Context $ContextLabel {
        [Hashtable]$getResult = Get-TargetResource @TestParams

        It $ItLabel {
            CompareArrayContents -Array1 $DesiredArrayContents -Array2 $getResult."$($GetResultParameterName)" -IgnoreCase | Should Be $true
        }
    }
}

function Test-Array2ContainsArray1
{
    [CmdletBinding()]
    param([Hashtable]$TestParams, [string[]]$DesiredArrayContents, [string]$GetResultParameterName, [string]$ContextLabel, [string]$ItLabel)

    Context $ContextLabel {
        [Hashtable]$getResult = Get-TargetResource @TestParams

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
    param([PSCredential]$ShellCredentials)

    $testOabName = "Offline Address Book (DSC Test)"

    GetRemoteExchangeSession -Credential $ShellCredentials -CommandsToLoad "*-OfflineAddressBook"

    if ($null -eq (Get-OfflineAddressBook -Identity $testOabName -ErrorAction SilentlyContinue))
    {
        Write-Verbose "Test OAB does not exist. Creating OAB with name '$testOabName'."

        $testOab = New-OfflineAddressBook -Name $testOabName -AddressLists \

        if ($null -eq $testOab)
        {
            throw "Failed to create test OAB."
        }
    }

    return $testOabName
}

Export-ModuleMember -Function *
