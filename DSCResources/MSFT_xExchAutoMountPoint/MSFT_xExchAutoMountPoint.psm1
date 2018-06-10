Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Modules\xExchangeDiskPart.psm1" -Force

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR','GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-Verbose -Message 'Getting Exchange volume mount point'
    $dbMap = Get-ExchDscDatabaseMap -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath

    $returnValue = @{
        DiskToDBMap                     = $dbMap
        SpareVolumeCount                = $SpareVolumeCount
        AutoDagDatabasesRootFolderPath  = $AutoDagDatabasesRootFolderPath
        AutoDagVolumesRootFolderPath    = $AutoDagVolumesRootFolderPath
        VolumePrefix                    = $VolumePrefix
        MinDiskSize                     = $MinDiskSize
        UnitSize                        = $UnitSize
        PartitioningScheme              = $PartitioningScheme
        FileSystem                      = $FileSystem
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR','GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-Verbose -Message 'Setting Exchange volume mount point'

    #First see if we need to assign any disks to ExVol's
    Get-ExchDscDiskInfo
    
    $exVolCount = Get-ExchDscInUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath
    $requiredVolCount = $DiskToDBMap.Count + $SpareVolumeCount
   
    if ($exVolCount -lt $requiredVolCount)
    {
        Add-ExchDscMissingVolumes @PSBoundParameters -CurrentVolCount $exVolCount -RequiredVolCount $requiredVolCount
    }

    #Now see if we need any DB mount points
    Get-ExchDscDiskInfo

    $exDbCount = Get-ExchDscInUseMountPointCount -RootFolder $AutoDagDatabasesRootFolderPath
    $requiredDbCount = Get-ExchDscDatabaseCount -DiskToDBMap $DiskToDBMap
    
    if ($exDbCount -lt $requiredDbCount)
    {
        Add-ExchDscMissingDatabases @PSBoundParameters
    }

    #Now see if any Mount Points are ordered incorrectly. Jetstress wants ExchangeDatabase mount points to be listed before ExchangeVolume mount points
    Get-ExchDscDiskInfo

    if ($EnsureExchangeVolumeMountPointIsLast -eq $true)
    {
        while($true)
        {
            $volNum = Get-ExchDscVolumeMountPoint -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath

            if ($volNum -ne -1)
            {
                Set-ExchDscVolumeMountPoint -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumeNumber $volNum

                #Update DiskInfo for next iteration
                Get-ExchDscDiskInfo
            }
            else
            {
                break
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders = $false,

        [Parameter()]
        [ValidateSet('NTFS','REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR','GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-Verbose -Message 'Testing Exchange volume mount point'

    #Check if the number of assigned EXVOL's is less than the requested number of DB disks plus spares
    $mountPointCount = Get-ExchDscInUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath

    if ($mountPointCount -lt ($DiskToDBMap.Count + $SpareVolumeCount))
    {
        ReportBadSetting -SettingName 'MountPointCount' -ExpectedValue ($DiskToDBMap.Count + $SpareVolumeCount) -ActualValue $mountPointCount -VerbosePreference $VerbosePreference
        return $false
    }
    else #Loop through all requested DB's and see if they have a mount point yet
    {
        foreach ($value in $DiskToDBMap)
        {
            foreach ($db in $value.Split(','))
            {
                if ((Test-ExchDscDatabaseMountPoint -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -Database $db) -eq $false)
                {
                    ReportBadSetting -SettingName "DB '$($db)' Has Mount Point" -ExpectedValue $true -ActualValue $false -VerbosePreference $VerbosePreference
                    return $false
                }
            }
        }
    }

    #Now check if any ExchangeVolume mount points are higher ordered than ExchangeDatabase mount points. ExchangeDatabase MP's must be listed first for logical disk counters to function properly
    if ($EnsureExchangeVolumeMountPointIsLast -eq $true -and (Get-ExchDscVolumeMountPoint -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath) -ne -1)
    {
        Write-Verbose -Message "One or more volumes have an $($AutoDagVolumesRootFolderPath) mount point ordered before a $($AutoDagDatabasesRootFolderPath) mount point"
        return $false
    }

    return $true
}

Export-ModuleMember -Function *-TargetResource
