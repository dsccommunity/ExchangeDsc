#Function to be used within pester for end to end testing of Get/Set/Test-TargetResource
#Function first calls Set-TargetResource with provided parameters, then runs Get and Test-TargetResource,
#and ensures they return $true
function Test-AllTargetResourceFunctions
{
    [CmdletBinding()]
    param([Hashtable]$Params, [string]$ContextLabel, [string]$ItLabel)

    Context $ContextLabel {
        Set-TargetResource @Params

        $getResult = Get-TargetResource @Params
        $testResult = Test-TargetResource @Params

        It $ItLabel {
            $getResult | Should Be $true
            $testResult | Should Be $true
        }
    }
}

Export-ModuleMember -Function *
