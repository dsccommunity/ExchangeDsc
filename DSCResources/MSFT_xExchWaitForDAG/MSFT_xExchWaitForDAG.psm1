<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters
    $dagComp = Get-DAGComputerObject @PSBoundParameters

    $returnValue = @{
        Identity          = [System.String] $Identity
        DAGExists         = [System.Boolean] ($null -ne $dag)
        DAGComputerExists = [System.Boolean] ($null -ne $dagComp)
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $foundDAG = Wait-ForDatabaseAvailabilityGroup @PSBoundParameters

    if (!$foundDAG)
    {
        throw 'Database Availability Group does not exist after waiting the specified amount of time.'
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters
    $dagComp = Get-DAGComputerObject @PSBoundParameters

    $testResults = $true

    if ($null -eq $dag -or ($WaitForComputerObject -and $null -eq $dagComp))
    {
        Write-Warning -Message 'Database Availability Group does not yet exist'
        $testResults = $false
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-DatabaseAvailabilityGroup.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
function Get-DatabaseAvailabilityGroupInternal
{
    [CmdletBinding()]
    [OutputType([System.Object])]
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -ErrorAction SilentlyContinue)
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-DatabaseAvailabilityGroup.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
function Get-DAGComputerObject
{
    [CmdletBinding()]
    [OutputType([System.Object])]
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    $getParams = @{
        Identity = $Identity
    }

    if (![String]::IsNullOrEmpty($DomainController))
    {
        $getParams.Add('Server', $DomainController)
    }

    # ErrorAction SilentlyContinue doesn't always work with Get-ADComputer. Doing in Try/Catch instead.
    try
    {
        $adComputer = Get-ADComputer @getParams -ErrorAction SilentlyContinue
    }
    catch
    {
        if ($WaitForComputerObject)
        {
            Write-Warning "Failed to find computer with name '$Identity' using Get-ADComputer."
        }
    }

    return $adComputer
}

<#
    .SYNOPSIS
        Waits a specified amount of time to detect that the Database
        Availability Group exists. Returns the true if it is detected within
        the time limit.

    .PARAMETER Identity
        The name of the DAG to wait for.

    .PARAMETER Credential
        Credentials used to establish a remote Powershell session to Exchange.

    .PARAMETER DomainController
        Optional Domain controller to use when running
        Get-DatabaseAvailabilityGroup.

    .PARAMETER WaitForComputerObject
        Whether DSC should also wait for the DAG Computer account object to
        be discovered. Defaults to False.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether the DAG
        exists. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to find the DAG before an
        exception is thrown. Defaults to 5.
#>
function Wait-ForDatabaseAvailabilityGroup
{
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
        [System.Boolean]
        $WaitForComputerObject,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5
    )

    $foundDAG = $false

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters
        $dagComp = Get-DAGComputerObject @PSBoundParameters

        if ($null -eq $dag -or ($WaitForComputerObject -and $null -eq $dagComp))
        {
            Write-Warning "DAG '$($Identity)' object, or associated computer object (if requested) does not yet exist. Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec
        }
        else
        {
            $foundDAG = $true
            break
        }
    }

    return $foundDAG
}

Export-ModuleMember -Function *-TargetResource
