function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    if ($null -ne $dag)
    {
        $returnValue = @{
            Identity = [System.String] $Identity
        }    

    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        if ($null -eq $dag)
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
    
    if ($null -eq $dag)
    {
        throw "DAG '$($Identity)' does not yet exist. This will prevent resources that are dependant on this resource from executing. If you are running the DSC configuration in push mode, you will need to re-run the configuration once the database has been created."
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    $testResults = $true

    if ($null -eq $dag)
    {
        Write-Verbose -Message "Database Availability Group does not yet exist"
        $testResults = $false
    }

    return $testResults
}

function GetDatabaseAvailabilityGroup
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String]
        $DomainController
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity','DomainController'

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function *-TargetResource
