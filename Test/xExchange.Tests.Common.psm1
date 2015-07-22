#Function to be used within pester for end to end testing of Get/Set/Test-TargetResource
#Function first calls Set-TargetResource with provided parameters, then runs Get and Test-TargetResource,
#and ensures they match $ExpectedGetResults and $ExpectedTestResult
function Test-AllTargetResourceFunctions
{
    [CmdletBinding()]
    param([Hashtable]$Params, [string]$ContextLabel, [Hashtable]$ExpectedGetResults, [bool]$ExpectedTestResult = $true)

    Context $ContextLabel {
        Set-TargetResource @Params

        [Hashtable]$getResult = Get-TargetResource @Params
        [bool]$testResult = Test-TargetResource @Params

        #The ExpectedGetResults are $null, so let's check that what we got back is $null
        if ($ExpectedGetResults -eq $null)
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

Export-ModuleMember -Function *
