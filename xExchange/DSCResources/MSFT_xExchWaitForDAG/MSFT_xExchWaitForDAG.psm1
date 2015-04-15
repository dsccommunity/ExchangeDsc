function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    if ($dag -ne $null)
    {
        $returnValue = @{
            Identity = $Identity
        }    

    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        if ($dag -eq $null)
        {
            Write-Warning "DAG '$($Identity)' does not yet exist. Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec

            $dag = GetDatabaseAvailabilityGroup @PSBoundParameters
        }
        else
        {
            break
        }
    }
    
    if ($dag -eq $null)
    {
        throw "DAG '$($Identity)' does not yet exist. This will prevent resources that are dependant on this resource from executing. If you are running the DSC configuration in push mode, you will need to re-run the configuration once the database has been created."
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 5
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    return ($dag -ne $null)
}

function GetDatabaseAvailabilityGroup
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $DomainController
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -ErrorAction SilentlyContinue)
}


Export-ModuleMember -Function *-TargetResource



