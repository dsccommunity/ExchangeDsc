function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [System.String]
        $AlternateWitnessDirectory,

        [System.String]
        $AlternateWitnessServer,

        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [System.String]
        $AutoDagVolumesRootFolderPath,

        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [ValidateSet("Off","DagOnly")]
        [System.String]
        $DatacenterActivationMode,

        [System.String]
        $DomainController,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FileSystem,

        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkCompression,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkEncryption,

        [System.Boolean]
        $ReplayLagManagerEnabled,

        [System.UInt16]
        $ReplicationPort,

        [System.Boolean]
        $SkipDagValidation,

        [System.String]
        $WitnessDirectory,

        [System.String]
        $WitnessServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    if ($null -ne $dag)
    {
        $returnValue = @{
            Name = $Name
            AlternateWitnessDirectory = $dag.AlternateWitnessDirectory
            AlternateWitnessServer = $dag.AlternateWitnessServer
            AutoDagAutoReseedEnabled = $dag.AutoDagAutoReseedEnabled
            AutoDagDatabaseCopiesPerDatabase = $dag.AutoDagDatabaseCopiesPerDatabase
            AutoDagDatabaseCopiesPerVolume = $dag.AutoDagDatabaseCopiesPerVolume
            AutoDagDatabasesRootFolderPath = $dag.AutoDagDatabasesRootFolderPath
            AutoDagDiskReclaimerEnabled = $dag.AutoDagDiskReclaimerEnabled
            AutoDagTotalNumberOfDatabases = $dag.AutoDagTotalNumberOfDatabases
            AutoDagTotalNumberOfServers = $dag.AutoDagTotalNumberOfServers
            AutoDagVolumesRootFolderPath = $dag.AutoDagVolumesRootFolderPath
            DatabaseAvailabilityGroupIpAddresses = $dag.DatabaseAvailabilityGroupIpAddresses
            DatacenterActivationMode = $dag.DatacenterActivationMode
            ManualDagNetworkConfiguration = $dag.ManualDagNetworkConfiguration
            NetworkCompression = $dag.NetworkCompression
            NetworkEncryption = $dag.NetworkEncryption
            ReplayLagManagerEnabled = $dag.ReplayLagManagerEnabled
            ReplicationPort = $dag.ReplicationPort
            WitnessDirectory = $dag.WitnessDirectory
            WitnessServer = $dag.WitnessServer
        }

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $returnValue.Add("FileSystem", $dag.FileSystem)
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [System.String]
        $AlternateWitnessDirectory,

        [System.String]
        $AlternateWitnessServer,

        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [System.String]
        $AutoDagVolumesRootFolderPath,

        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [ValidateSet("Off","DagOnly")]
        [System.String]
        $DatacenterActivationMode,

        [System.String]
        $DomainController,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FileSystem,

        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkCompression,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkEncryption,

        [System.Boolean]
        $ReplayLagManagerEnabled,

        [System.UInt16]
        $ReplicationPort,

        [System.Boolean]
        $SkipDagValidation,

        [System.String]
        $WitnessDirectory,

        [System.String]
        $WitnessServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup","Set-DatabaseAvailabilityGroup","New-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference
  
    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "FileSystem" -ResourceName "xExchDatabaseAvailabilityGroup" -ParamExistsInVersion "2016"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    #We need to create the DAG
    if ($null -eq $dag)
    {
        #Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        #Remove parameters that don't exist in New-DatabaseAvailabilityGroup
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Name","DatabaseAvailabilityGroupIpAddresses","WitnessDirectory","WitnessServer","DomainController"

        #Create the DAG
        $dag = New-DatabaseAvailabilityGroup @PSBoundParameters

        if ($null -ne $dag)
        {
            #Add original props back
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters
        }
        else
        {
            throw "Failed to create new DAG."
        }
    }

    #Modify existing DAG
    if ($null -ne $dag)
    {
        #convert Name to Identity, and Remove Credential
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $PSBoundParameters["Name"]}
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Name","Credential"

        #If not all members are in DAG yet, remove params that require them to be
        if ($dag.Servers.Count -lt $AutoDagTotalNumberOfServers)
        {
            if ($PSBoundParameters.ContainsKey("DatacenterActivationMode") -and $DatacenterActivationMode -like "DagOnly")
            {
                RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "DatacenterActivationMode"                
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [System.String]
        $AlternateWitnessDirectory,

        [System.String]
        $AlternateWitnessServer,

        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [System.String]
        $AutoDagVolumesRootFolderPath,

        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [ValidateSet("Off","DagOnly")]
        [System.String]
        $DatacenterActivationMode,

        [System.String]
        $DomainController,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FileSystem,

        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkCompression,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkEncryption,

        [System.Boolean]
        $ReplayLagManagerEnabled,

        [System.UInt16]
        $ReplicationPort,

        [System.Boolean]
        $SkipDagValidation,

        [System.String]
        $WitnessDirectory,

        [System.String]
        $WitnessServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "FileSystem" -ResourceName "xExchDatabaseAvailabilityGroup" -ParamExistsInVersion "2016"

    $dag = GetDatabaseAvailabilityGroup @PSBoundParameters

    if ($null -eq $dag)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "AlternateWitnessDirectory" -Type "String" -ExpectedValue $AlternateWitnessDirectory -ActualValue $dag.AlternateWitnessDirectory -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AlternateWitnessServer" -Type "String" -ExpectedValue $AlternateWitnessServer -ActualValue $dag.AlternateWitnessServer -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagAutoReseedEnabled" -Type "Boolean" -ExpectedValue $AutoDagAutoReseedEnabled -ActualValue $dag.AutoDagAutoReseedEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagDatabaseCopiesPerDatabase" -Type "Int" -ExpectedValue $AutoDagDatabaseCopiesPerDatabase -ActualValue $dag.AutoDagDatabaseCopiesPerDatabase -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagDatabaseCopiesPerVolume" -Type "Int" -ExpectedValue $AutoDagDatabaseCopiesPerVolume -ActualValue $dag.AutoDagDatabaseCopiesPerVolume -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagDatabasesRootFolderPath" -Type "String" -ExpectedValue $AutoDagDatabasesRootFolderPath -ActualValue $dag.AutoDagDatabasesRootFolderPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagDiskReclaimerEnabled" -Type "Boolean" -ExpectedValue $AutoDagDiskReclaimerEnabled -ActualValue $dag.AutoDagDiskReclaimerEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagTotalNumberOfDatabases" -Type "Int" -ExpectedValue $AutoDagTotalNumberOfDatabases -ActualValue $dag.AutoDagTotalNumberOfDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagTotalNumberOfServers" -Type "Int" -ExpectedValue $AutoDagTotalNumberOfServers -ActualValue $dag.AutoDagTotalNumberOfServers -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AutoDagVolumesRootFolderPath" -Type "String" -ExpectedValue $AutoDagVolumesRootFolderPath -ActualValue $dag.AutoDagVolumesRootFolderPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DatabaseAvailabilityGroupIpAddresses" -Type "Array" -ExpectedValue $DatabaseAvailabilityGroupIpAddresses -ActualValue $dag.DatabaseAvailabilityGroupIpAddresses -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "FileSystem" -Type "String" -ExpectedValue $FileSystem -ActualValue $dag.FileSystem -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ManualDagNetworkConfiguration" -Type "Boolean" -ExpectedValue $ManualDagNetworkConfiguration -ActualValue $dag.ManualDagNetworkConfiguration -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "NetworkCompression" -Type "String" -ExpectedValue $NetworkCompression -ActualValue $dag.NetworkCompression -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "NetworkEncryption" -Type "String" -ExpectedValue $NetworkEncryption -ActualValue $dag.NetworkEncryption -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReplayLagManagerEnabled" -Type "Boolean" -ExpectedValue $ReplayLagManagerEnabled -ActualValue $dag.ReplayLagManagerEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        #Replication port only comes back correctly from Get-DatabaseAvailabilityGroup if it has been set when there is 1 or more servers in the DAG
        if ($dag.Servers.Count -gt 0)
        {
            if (!(VerifySetting -Name "ReplicationPort" -Type "Int" -ExpectedValue $ReplicationPort -ActualValue $dag.ReplicationPort -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }
        }
        
        if (!(VerifySetting -Name "WitnessDirectory" -Type "String" -ExpectedValue $WitnessDirectory -ActualValue $dag.WitnessDirectory -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WitnessServer" -Type "String" -ExpectedValue $WitnessServer -ActualValue $dag.WitnessServer -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        #Verify these props only if all members are in the DAG
        if ($dag.Servers.Count -ge $AutoDagTotalNumberOfServers)
        {
            if (!(VerifySetting -Name "DatacenterActivationMode" -Type "String" -ExpectedValue $DatacenterActivationMode -ActualValue $dag.DatacenterActivationMode -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }
        }
    }

    return $true
}

#Runs Get-DatabaseAvailabilityGroup, only specifying Identity, ErrorAction, and optionally DomainController
function GetDatabaseAvailabilityGroup
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.Int32]
        $AutoDagTotalNumberOfServers,

        [System.String]
        $AlternateWitnessDirectory,

        [System.String]
        $AlternateWitnessServer,

        [System.Boolean]
        $AutoDagAutoReseedEnabled,

        [System.Int32]
        $AutoDagDatabaseCopiesPerDatabase,

        [System.Int32]
        $AutoDagDatabaseCopiesPerVolume,

        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [System.Boolean]
        $AutoDagDiskReclaimerEnabled,

        [System.Int32]
        $AutoDagTotalNumberOfDatabases,

        [System.String]
        $AutoDagVolumesRootFolderPath,

        [System.String[]]
        $DatabaseAvailabilityGroupIpAddresses,

        [ValidateSet("Off","DagOnly")]
        [System.String]
        $DatacenterActivationMode,

        [System.String]
        $DomainController,

        [ValidateSet("NTFS","ReFS")]
        [System.String]
        $FileSystem,

        [System.Boolean]
        $ManualDagNetworkConfiguration,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkCompression,

        [ValidateSet("Disabled","Enabled","InterSubnetOnly","SeedOnly")]
        [System.String]
        $NetworkEncryption,

        [System.Boolean]
        $ReplayLagManagerEnabled,

        [System.UInt16]
        $ReplicationPort,

        [System.Boolean]
        $SkipDagValidation,

        [System.String]
        $WitnessDirectory,

        [System.String]
        $WitnessServer
    )

    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $PSBoundParameters["Name"]; "ErrorAction" = "SilentlyContinue"}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","ErrorAction","DomainController"

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -Status)
}

Export-ModuleMember -Function *-TargetResource



