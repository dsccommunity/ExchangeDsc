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
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [Parameter()]
        [System.String]
        $AlternateWitnessDirectory,

        [Parameter()]
        [System.String]
        $AlternateWitnessServer,

        [Parameter()]
        [System.Boolean]
        $AutoDagBitlockerEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoRedistributeEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [Parameter()]
        [ValidateSet('Off', 'DagOnly')]
        [System.String]
        $DatacenterActivationMode,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('NTFS', 'ReFS')]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkCompression,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkEncryption,

        [Parameter()]
        [System.String]
        $PreferenceMoveFrequency,

        [Parameter()]
        [System.Boolean]
        $ReplayLagManagerEnabled,

        [Parameter()]
        [System.UInt16]
        $ReplicationPort,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation,

        [Parameter()]
        [System.String]
        $WitnessDirectory,

        [Parameter()]
        [System.String]
        $WitnessServer
    )

    Write-FunctionEntry -Parameters @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters

    if ($null -ne $dag)
    {
        $returnValue = @{
            Name                                 = [System.String] $Name
            AlternateWitnessDirectory            = [System.String] $dag.AlternateWitnessDirectory
            AlternateWitnessServer               = [System.String] $dag.AlternateWitnessServer
            AutoDagBitlockerEnabled              = [System.Boolean] $dag.AutoDagBitlockerEnabled
            AutoDagAutoReseedEnabled             = [System.Boolean] $dag.AutoDagAutoReseedEnabled
            AutoDagDatabaseCopiesPerDatabase     = [System.Int32] $dag.AutoDagDatabaseCopiesPerDatabase
            AutoDagDatabaseCopiesPerVolume       = [System.Int32] $dag.AutoDagDatabaseCopiesPerVolume
            AutoDagDatabasesRootFolderPath       = [System.String] $dag.AutoDagDatabasesRootFolderPath
            AutoDagDiskReclaimerEnabled          = [System.Boolean] $dag.AutoDagDiskReclaimerEnabled
            AutoDagTotalNumberOfDatabases        = [System.Int32] $dag.AutoDagTotalNumberOfDatabases
            AutoDagTotalNumberOfServers          = [System.Int32] $dag.AutoDagTotalNumberOfServers
            AutoDagVolumesRootFolderPath         = [System.String] $dag.AutoDagVolumesRootFolderPath
            DatabaseAvailabilityGroupIpAddresses = [System.String[]] $dag.DatabaseAvailabilityGroupIpAddresses
            DatacenterActivationMode             = [System.String] $dag.DatacenterActivationMode
            ManualDagNetworkConfiguration        = [System.Boolean] $dag.ManualDagNetworkConfiguration
            NetworkCompression                   = [System.String] $dag.NetworkCompression
            NetworkEncryption                    = [System.String] $dag.NetworkEncryption
            ReplayLagManagerEnabled              = [System.Boolean] $dag.ReplayLagManagerEnabled
            ReplicationPort                      = [System.UInt16] $dag.ReplicationPort
            WitnessDirectory                     = [System.String] $dag.WitnessDirectory
            WitnessServer                        = [System.String] $dag.WitnessServer
        }

        $serverVersion = Get-ExchangeVersionYear

        if ($serverVersion -in '2016', '2019')
        {
            $returnValue.Add("AutoDagAutoRedistributeEnabled", [System.Boolean] $dag.AutoDagAutoRedistributeEnabled)
            $returnValue.Add("FileSystem", [System.String] $dag.FileSystem)
            $returnValue.Add("PreferenceMoveFrequency", [System.String] $dag.PreferenceMoveFrequency)
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [Parameter()]
        [System.String]
        $AlternateWitnessDirectory,

        [Parameter()]
        [System.String]
        $AlternateWitnessServer,

        [Parameter()]
        [System.Boolean]
        $AutoDagBitlockerEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoRedistributeEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [Parameter()]
        [ValidateSet('Off', 'DagOnly')]
        [System.String]
        $DatacenterActivationMode,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('NTFS', 'ReFS')]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkCompression,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkEncryption,

        [Parameter()]
        [System.String]
        $PreferenceMoveFrequency,

        [Parameter()]
        [System.Boolean]
        $ReplayLagManagerEnabled,

        [Parameter()]
        [System.UInt16]
        $ReplicationPort,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation,

        [Parameter()]
        [System.String]
        $WitnessDirectory,

        [Parameter()]
        [System.String]
        $WitnessServer
    )

    Write-FunctionEntry -Parameters @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup', 'Set-DatabaseAvailabilityGroup', 'New-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    #create array of Exchange 2016 only parameters
    [System.Array] $Exchange2016Only = 'AutoDagAutoRedistributeEnabled', 'FileSystem', 'PreferenceMoveFrequency'

    $serverVersion = Get-ExchangeVersionYear

    if ($serverVersion -eq '2013')
    {
        foreach ($Exchange2016Parameter in $Exchange2016Only)
        {
            # Check for non-existent parameters in Exchange 2013
            Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters -ParamName "$Exchange2016Parameter"  -ResourceName 'xExchDatabaseAvailabilityGroup' -ParamExistsInVersion '2016'
        }
    }
    elseif ($serverVersion -in '2016', '2019')
    {
        Write-Verbose -Message "No need to remove parameters"
    }
    else
    {
        Write-Verbose -Message "Could not detect Exchange version"
    }

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters

    # We need to create the DAG
    if ($null -eq $dag)
    {
        # Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        # Remove parameters that don't exist in New-DatabaseAvailabilityGroup
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Name", "DatabaseAvailabilityGroupIpAddresses", "WitnessDirectory", "WitnessServer", "DomainController"

        # Create the DAG
        $dag = New-DatabaseAvailabilityGroup @PSBoundParameters

        if ($null -ne $dag)
        {
            # Add original props back
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters
        }
        else
        {
            throw "Failed to create new DAG."
        }
    }

    # Modify existing DAG
    if ($null -ne $dag)
    {
        # convert Name to Identity, and Remove Credential
        Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
            'Identity' = $PSBoundParameters['Name']
        }
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Name", "Credential"

        # If not all members are in DAG yet, remove params that require them to be
        if ($dag.Servers.Count -lt $AutoDagTotalNumberOfServers)
        {
            if ($PSBoundParameters.ContainsKey("DatacenterActivationMode") -and $DatacenterActivationMode -like "DagOnly")
            {
                Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "DatacenterActivationMode"
            }
        }

        Set-DatabaseAvailabilityGroup @PSBoundParameters
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [Parameter()]
        [System.String]
        $AlternateWitnessDirectory,

        [Parameter()]
        [System.String]
        $AlternateWitnessServer,

        [Parameter()]
        [System.Boolean]
        $AutoDagBitlockerEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoRedistributeEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [Parameter()]
        [ValidateSet('Off', 'DagOnly')]
        [System.String]
        $DatacenterActivationMode,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('NTFS', 'ReFS')]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkCompression,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkEncryption,

        [Parameter()]
        [System.String]
        $PreferenceMoveFrequency,

        [Parameter()]
        [System.Boolean]
        $ReplayLagManagerEnabled,

        [Parameter()]
        [System.UInt16]
        $ReplicationPort,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation,

        [Parameter()]
        [System.String]
        $WitnessDirectory,

        [Parameter()]
        [System.String]
        $WitnessServer
    )

    Write-FunctionEntry -Parameters @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-DatabaseAvailabilityGroup' -Verbose:$VerbosePreference

    # Create array of Exchange 2016 only parameters
    [System.Array] $Exchange2016Only = 'AutoDagAutoRedistributeEnabled', 'FileSystem', 'PreferenceMoveFrequency'

    $serverVersion = Get-ExchangeVersionYear

    if ($serverVersion -eq '2013')
    {
        foreach ($Exchange2016Parameter in $Exchange2016Only)
        {
            # Check for non-existent parameters in Exchange 2013
            Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters -ParamName "$Exchange2016Parameter"  -ResourceName 'xExchDatabaseAvailabilityGroup' -ParamExistsInVersion '2016'
        }
    }
    elseif ($serverVersion -in '2016', '2019')
    {
        Write-Verbose -Message "No need to remove parameters"
    }
    else
    {
        Write-Verbose -Message "Could not detect Exchange version"
    }

    $dag = Get-DatabaseAvailabilityGroupInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $dag)
    {
        Write-Verbose -Message 'Unable to retrieve Database Availability Group settings'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'AlternateWitnessDirectory' -Type 'String' -ExpectedValue $AlternateWitnessDirectory -ActualValue $dag.AlternateWitnessDirectory -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AlternateWitnessServer' -Type 'String' -ExpectedValue $AlternateWitnessServer -ActualValue $dag.AlternateWitnessServer -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagBitlockerEnabled' -Type 'Boolean' -ExpectedValue $AutoDagBitlockerEnabled -ActualValue $dag.AutoDagBitlockerEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagAutoRedistributeEnabled' -Type 'Boolean' -ExpectedValue $AutoDagAutoRedistributeEnabled -ActualValue $dag.AutoDagAutoRedistributeEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagAutoReseedEnabled' -Type 'Boolean' -ExpectedValue $AutoDagAutoReseedEnabled -ActualValue $dag.AutoDagAutoReseedEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagDatabaseCopiesPerDatabase' -Type 'Int' -ExpectedValue $AutoDagDatabaseCopiesPerDatabase -ActualValue $dag.AutoDagDatabaseCopiesPerDatabase -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagDatabaseCopiesPerVolume' -Type 'Int' -ExpectedValue $AutoDagDatabaseCopiesPerVolume -ActualValue $dag.AutoDagDatabaseCopiesPerVolume -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagDatabasesRootFolderPath' -Type 'String' -ExpectedValue $AutoDagDatabasesRootFolderPath -ActualValue $dag.AutoDagDatabasesRootFolderPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagDiskReclaimerEnabled' -Type 'Boolean' -ExpectedValue $AutoDagDiskReclaimerEnabled -ActualValue $dag.AutoDagDiskReclaimerEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagTotalNumberOfDatabases' -Type 'Int' -ExpectedValue $AutoDagTotalNumberOfDatabases -ActualValue $dag.AutoDagTotalNumberOfDatabases -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagTotalNumberOfServers' -Type 'Int' -ExpectedValue $AutoDagTotalNumberOfServers -ActualValue $dag.AutoDagTotalNumberOfServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagVolumesRootFolderPath' -Type 'String' -ExpectedValue $AutoDagVolumesRootFolderPath -ActualValue $dag.AutoDagVolumesRootFolderPath -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DatabaseAvailabilityGroupIpAddresses' -Type 'Array' -ExpectedValue $DatabaseAvailabilityGroupIpAddresses -ActualValue $dag.DatabaseAvailabilityGroupIpAddresses -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'FileSystem' -Type 'String' -ExpectedValue $FileSystem -ActualValue $dag.FileSystem -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ManualDagNetworkConfiguration' -Type 'Boolean' -ExpectedValue $ManualDagNetworkConfiguration -ActualValue $dag.ManualDagNetworkConfiguration -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'NetworkCompression' -Type 'String' -ExpectedValue $NetworkCompression -ActualValue $dag.NetworkCompression -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'NetworkEncryption' -Type 'String' -ExpectedValue $NetworkEncryption -ActualValue $dag.NetworkEncryption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'NetworkEncryption' -Type 'String' -ExpectedValue $NetworkEncryption -ActualValue $dag.NetworkEncryption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'PreferenceMoveFrequency' -Type 'Timespan' -ExpectedValue $PreferenceMoveFrequency -ActualValue $dag.PreferenceMoveFrequency -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        # Replication port only comes back correctly from Get-DatabaseAvailabilityGroup if it has been set when there is 1 or more servers in the DAG
        if ($dag.Servers.Count -gt 0)
        {
            if (!(Test-ExchangeSetting -Name 'ReplicationPort' -Type 'Int' -ExpectedValue $ReplicationPort -ActualValue $dag.ReplicationPort -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }

        if (!(Test-ExchangeSetting -Name 'WitnessDirectory' -Type 'String' -ExpectedValue $WitnessDirectory -ActualValue $dag.WitnessDirectory -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WitnessServer' -Type 'String' -ExpectedValue $WitnessServer -ActualValue $dag.WitnessServer -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        # Verify these props only if all members are in the DAG
        if ($dag.Servers.Count -ge $AutoDagTotalNumberOfServers)
        {
            if (!(Test-ExchangeSetting -Name 'DatacenterActivationMode' -Type 'String' -ExpectedValue $DatacenterActivationMode -ActualValue $dag.DatacenterActivationMode -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }
    }

    return $testResults
}

# Runs Get-DatabaseAvailabilityGroup, only specifying Identity, ErrorAction, and optionally DomainController
function Get-DatabaseAvailabilityGroupInternal
{
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
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [Parameter()]
        [System.String]
        $AlternateWitnessDirectory,

        [Parameter()]
        [System.String]
        $AlternateWitnessServer,

        [Parameter()]
        [System.Boolean]
        $AutoDagBitlockerEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoRedistributeEnabled,

        [Parameter()]
        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [Parameter()]
        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [Parameter()]
        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [Parameter()]
        [ValidateSet('Off', 'DagOnly')]
        [System.String]
        $DatacenterActivationMode,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('NTFS', 'ReFS')]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkCompression,

        [Parameter()]
        [ValidateSet('Disabled', 'Enabled', 'InterSubnetOnly', 'SeedOnly')]
        [System.String]
        $NetworkEncryption,

        [Parameter()]
        [System.String]
        $PreferenceMoveFrequency,

        [Parameter()]
        [System.Boolean]
        $ReplayLagManagerEnabled,

        [Parameter()]
        [System.UInt16]
        $ReplicationPort,

        [Parameter()]
        [System.Boolean]
        $SkipDagValidation,

        [Parameter()]
        [System.String]
        $WitnessDirectory,

        [Parameter()]
        [System.String]
        $WitnessServer
    )

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity'    = $PSBoundParameters['Name']
        'ErrorAction' = 'SilentlyContinue'
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'ErrorAction', 'DomainController'

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -Status)
}

Export-ModuleMember -Function *-TargetResource
