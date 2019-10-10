<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Name
        The name of the DAG network.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER DatabaseAvailabilityGroup
        The DAG where the network will live.

    .PARAMETER Ensure
        Whether the DAG network should exist or not.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER IgnoreNetwork
        The IgnoreNetwork parameter indicates that the specified network should
        be ignored and not used by the DAG.

    .PARAMETER ReplicationEnabled
        The ReplicationEnabled parameter specifies whether the network can be
        used for replication activity. If this parameter isn't specified, the
        default behavior is to enable the network for replication.

    .PARAMETER Subnets
        The Subnets parameter specifies one or more subnets that are associated
        with the DAG network.
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $IgnoreNetwork,

        [Parameter()]
        [System.Boolean]
        $ReplicationEnabled,

        [Parameter()]
        [System.String[]]
        $Subnets
    )

    Write-FunctionEntry -Parameters @{
        'Name'                      = $Name
        "DatabaseAvailabilityGroup" = $DatabaseAvailabilityGroup
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroupNetwork' -Verbose:$VerbosePreference

    $dagNet = Get-DatabaseAvailabilityGroupNetworkInternal @PSBoundParameters

    if ($null -ne $dagNet)
    {
        $returnValue = @{
            Name                      = [System.String] $Name
            DatabaseAvailabilityGroup = [System.String] $DatabaseAvailabilityGroup
            IgnoreNetwork             = [System.Boolean] $dagNet.IgnoreNetwork
            ReplicationEnabled        = [System.Boolean] $dagNet.ReplicationEnabled
            Subnets                   = [System.String[]] $dagNet.Subnets
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Name
        The name of the DAG network.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER DatabaseAvailabilityGroup
        The DAG where the network will live.

    .PARAMETER Ensure
        Whether the DAG network should exist or not.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER IgnoreNetwork
        The IgnoreNetwork parameter indicates that the specified network should
        be ignored and not used by the DAG.

    .PARAMETER ReplicationEnabled
        The ReplicationEnabled parameter specifies whether the network can be
        used for replication activity. If this parameter isn't specified, the
        default behavior is to enable the network for replication.

    .PARAMETER Subnets
        The Subnets parameter specifies one or more subnets that are associated
        with the DAG network.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $IgnoreNetwork,

        [Parameter()]
        [System.Boolean]
        $ReplicationEnabled,

        [Parameter()]
        [System.String[]]
        $Subnets
    )

    Write-FunctionEntry -Parameters @{
        'Name'                      = $Name
        "DatabaseAvailabilityGroup" = $DatabaseAvailabilityGroup
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*DatabaseAvailabilityGroup*' -Verbose:$VerbosePreference

    $dagId = "$($DatabaseAvailabilityGroup)\$($Name)"

    $dagNet = Get-DatabaseAvailabilityGroupNetworkInternal @PSBoundParameters

    if ($Ensure -eq 'Absent')
    {
        # Only try to remove the network if it has 0 associated subnets
        if ($null -ne $dagNet)
        {
            if ($null -eq $dagNet.Subnets -or $dagNet.Subnets.Count -eq 0)
            {
                Remove-DatabaseAvailabilityGroupNetwork -Identity "$($dagId)" -Confirm:$false
            }
            else
            {
                throw 'Unable to remove network, as it still has associated subnets.'
            }
        }
    }
    else
    {
        # Remove Credential and Ensure so we don't pass it into the next command
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure'

        Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        if ($null -eq $dagNet) # Need to create a new network
        {
            $dagNet = New-DatabaseAvailabilityGroupNetwork @PSBoundParameters
            Set-DatabaseAvailabilityGroup -Identity $DatabaseAvailabilityGroup -DiscoverNetworks
        }
        else # Set props on the existing network
        {
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
                'Identity' = $dagId
            }
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Name', 'DatabaseAvailabilityGroup'

            Set-DatabaseAvailabilityGroupNetwork @PSBoundParameters
        }
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Name
        The name of the DAG network.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER DatabaseAvailabilityGroup
        The DAG where the network will live.

    .PARAMETER Ensure
        Whether the DAG network should exist or not.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER IgnoreNetwork
        The IgnoreNetwork parameter indicates that the specified network should
        be ignored and not used by the DAG.

    .PARAMETER ReplicationEnabled
        The ReplicationEnabled parameter specifies whether the network can be
        used for replication activity. If this parameter isn't specified, the
        default behavior is to enable the network for replication.

    .PARAMETER Subnets
        The Subnets parameter specifies one or more subnets that are associated
        with the DAG network.
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $IgnoreNetwork,

        [Parameter()]
        [System.Boolean]
        $ReplicationEnabled,

        [Parameter()]
        [System.String[]]
        $Subnets
    )

    Write-FunctionEntry -Parameters @{
        'Name'                      = $Name
        'DatabaseAvailabilityGroup' = $DatabaseAvailabilityGroup
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroupNetwork' -Verbose:$VerbosePreference

    $dagNet = Get-DatabaseAvailabilityGroupNetworkInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $dagNet)
    {
        if ($Ensure -eq 'Present')
        {
            Write-InvalidSettingVerbose -SettingName 'Ensure' -ExpectedValue 'Present' -ActualValue 'Absent' -Verbose:$VerbosePreference
            $testResults = $false
        }
    }
    else
    {
        if ($Ensure -eq 'Absent')
        {
            Write-InvalidSettingVerbose -SettingName 'Ensure' -ExpectedValue 'Absent' -ActualValue 'Present' -Verbose:$VerbosePreference
            $testResults = $false
        }
        else
        {
            if (!(Test-ExchangeSetting -Name 'IgnoreNetwork' -Type 'Boolean' -ExpectedValue $IgnoreNetwork -ActualValue $dagNet.IgnoreNetwork -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'ReplicationEnabled' -Type 'Boolean' -ExpectedValue $ReplicationEnabled -ActualValue $dagNet.ReplicationEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'Subnets' -Type 'Array' -ExpectedValue $Subnets -ActualValue (Convert-DAGSubnetsToStringArray -Subnets $dagNet.Subnets) -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-DatabaseAvailabilityGroupNetwork. Runs
        Get-DatabaseAvailabilityGroupNetwork, only specifying Identity, and
        optionally DomainController, and returns the results.

    .PARAMETER Name
        The name of the DAG network.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER DatabaseAvailabilityGroup
        The DAG where the network will live.

    .PARAMETER Ensure
        Whether the DAG network should exist or not.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER IgnoreNetwork
        The IgnoreNetwork parameter indicates that the specified network should
        be ignored and not used by the DAG.

    .PARAMETER ReplicationEnabled
        The ReplicationEnabled parameter specifies whether the network can be
        used for replication activity. If this parameter isn't specified, the
        default behavior is to enable the network for replication.

    .PARAMETER Subnets
        The Subnets parameter specifies one or more subnets that are associated
        with the DAG network.
#>
function Get-DatabaseAvailabilityGroupNetworkInternal
{
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $IgnoreNetwork,

        [Parameter()]
        [System.Boolean]
        $ReplicationEnabled,

        [Parameter()]
        [System.String[]]
        $Subnets
    )

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity'    = "$($DatabaseAvailabilityGroup)\$($Name)"
        'ErrorAction' = 'SilentlyContinue'
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'ErrorAction', 'DomainController'

    return (Get-DatabaseAvailabilityGroupNetwork @PSBoundParameters)
}

<#
    .SYNOPSIS
        Takes an array of
        Microsoft.Exchange.Data.DatabaseAvailabilityGroupNetworkSubnet objects
        and converts the SubnetId properties to a string array.

    .PARAMETER Subnets
        The array of
        Microsoft.Exchange.Data.DatabaseAvailabilityGroupNetworkSubnet objects
        to convert.
#>
function Convert-DAGSubnetsToStringArray
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $Subnets
    )

    if ($null -ne $Subnets -and $Subnets.Count -gt 0)
    {
        [System.String[]] $SubnetsOut = $Subnets[0].SubnetId

        for ($i = 1; $i -lt $Subnets.Count; $i++)
        {
            $SubnetsOut += $Subnets[$i].SubnetId
        }
    }

    return $SubnetsOut
}

Export-ModuleMember -Function *-TargetResource
