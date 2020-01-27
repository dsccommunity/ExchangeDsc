Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Modules\xExchangeDiskPart\xExchangeDiskPart.psd1" -Force

<#
    .SYNOPSIS
        Gets DSC resource configuration.

    .PARAMETER Identity
        The name of the server. Not actually used for anything.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.

    .PARAMETER SpareVolumeCount
        How many spare volumes will be available.

    .PARAMETER EnsureExchangeVolumeMountPointIsLast
        Whether the EXVOL mount point should be moved to be the last mount
        point listed on each disk. Defaults to $false.

    .PARAMETER CreateSubfolders
        If $true, specifies that DBNAME.db and DBNAME.log subfolders should be
        automatically created underneath the ExchangeDatabase mount points.
        Defaults to $false.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER MinDiskSize
        The minimum size of a disk to consider using. Defaults to none. Should
        be in a format like '1024MB' or '1TB'.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.
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
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    $diskInfo = Get-DiskInfo

    $dbMap = Get-DiskToDBMap -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -DiskInfo $diskInfo

    $returnValue = @{
        Identity                       = [System.String] $Identity
        DiskToDBMap                    = [System.String[]] $dbMap
        SpareVolumeCount               = [System.UInt32] $SpareVolumeCount
        AutoDagDatabasesRootFolderPath = [System.String] $AutoDagDatabasesRootFolderPath
        AutoDagVolumesRootFolderPath   = [System.String] $AutoDagVolumesRootFolderPath
        VolumePrefix                   = [System.String] $VolumePrefix
        MinDiskSize                    = [System.String] $MinDiskSize
        UnitSize                       = [System.String] $UnitSize
        PartitioningScheme             = [System.String] $PartitioningScheme
        FileSystem                     = [System.String] $FileSystem
    }

    $returnValue
}

<#
    .SYNOPSIS
        Configures settings defined DSC resource configuration.

    .PARAMETER Identity
        The name of the server. Not actually used for anything.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.

    .PARAMETER SpareVolumeCount
        How many spare volumes will be available.

    .PARAMETER EnsureExchangeVolumeMountPointIsLast
        Whether the EXVOL mount point should be moved to be the last mount
        point listed on each disk. Defaults to $false.

    .PARAMETER CreateSubfolders
        If $true, specifies that DBNAME.db and DBNAME.log subfolders should be
        automatically created underneath the ExchangeDatabase mount points.
        Defaults to $false.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER MinDiskSize
        The minimum size of a disk to consider using. Defaults to none. Should
        be in a format like '1024MB' or '1TB'.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.
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
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    # First see if we need to assign any disks to ExVol's
    $diskInfo = Get-DiskInfo

    $exVolCount = Get-InUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath -DiskInfo $diskInfo
    $requiredVolCount = $DiskToDBMap.Count + $SpareVolumeCount

    if ($exVolCount -lt $requiredVolCount)
    {
        New-ExVolumesWhereMissing @PSBoundParameters -CurrentVolCount $exVolCount -RequiredVolCount $requiredVolCount
    }

    # Now see if we need any DB mount points
    $diskInfo = Get-DiskInfo

    $exDbCount = Get-InUseMountPointCount -RootFolder $AutoDagDatabasesRootFolderPath -DiskInfo $diskInfo
    $requiredDbCount = Get-DesiredDatabaseCount -DiskToDBMap $DiskToDBMap

    if ($exDbCount -lt $requiredDbCount)
    {
        New-ExDatabaseMountPointsWhereMissing @PSBoundParameters
    }

    # Now see if any Mount Points are ordered incorrectly. Jetstress wants ExchangeDatabase mount points to be listed before ExchangeVolume mount points
    $diskInfo = Get-DiskInfo

    if ($EnsureExchangeVolumeMountPointIsLast -eq $true)
    {
        while ($true)
        {
            $volNum = Get-VolumeNumberWhereMountPointNotLastInList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -DiskInfo $diskInfo

            if ($volNum -ne -1)
            {
                Move-VolumeMountPointToEndOfList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumeNumber $volNum -DiskInfo $diskInfo

                # Update DiskInfo for next iteration
                $diskInfo = Get-DiskInfo
            }
            else
            {
                break
            }
        }
    }
}

<#
    .SYNOPSIS
        Tests whether settings defined DSC resource configuration are in the
        expected state.

    .PARAMETER Identity
        The name of the server. Not actually used for anything.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.

    .PARAMETER SpareVolumeCount
        How many spare volumes will be available.

    .PARAMETER EnsureExchangeVolumeMountPointIsLast
        Whether the EXVOL mount point should be moved to be the last mount
        point listed on each disk. Defaults to $false.

    .PARAMETER CreateSubfolders
        If $true, specifies that DBNAME.db and DBNAME.log subfolders should be
        automatically created underneath the ExchangeDatabase mount points.
        Defaults to $false.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER MinDiskSize
        The minimum size of a disk to consider using. Defaults to none. Should
        be in a format like '1024MB' or '1TB'.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.
#>
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
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    $diskInfo = Get-DiskInfo

    # Check if the number of assigned EXVOL's is less than the requested number of DB disks plus spares
    $mountPointCount = Get-InUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath -DiskInfo $diskInfo

    $testResults = $true

    if ($mountPointCount -lt ($DiskToDBMap.Count + $SpareVolumeCount))
    {
        Write-InvalidSettingVerbose -SettingName 'MountPointCount' -ExpectedValue ($DiskToDBMap.Count + $SpareVolumeCount) -ActualValue $mountPointCount -Verbose:$VerbosePreference
        $testResults = $false
    }
    else # Loop through all requested DB's and see if they have a mount point yet
    {
        foreach ($value in $DiskToDBMap)
        {
            foreach ($db in $value.Split(','))
            {
                if ((Test-DBHasMountPoint -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -Database $db -DiskInfo $diskInfo) -eq $false)
                {
                    Write-InvalidSettingVerbose -SettingName "DB '$db' Has Mount Point" -ExpectedValue $true -ActualValue $false -Verbose:$VerbosePreference
                    $testResults = $false
                }
            }
        }
    }

    # Now check if any ExchangeVolume mount points are higher ordered than ExchangeDatabase mount points. ExchangeDatabase MP's must be listed first for logical disk counters to function properly
    if ($EnsureExchangeVolumeMountPointIsLast -eq $true -and (Get-VolumeNumberWhereMountPointNotLastInList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -DiskInfo $diskInfo) -ne -1)
    {
        Write-Verbose -Message "One or more volumes have an $($AutoDagVolumesRootFolderPath) mount point ordered before a $($AutoDagDatabasesRootFolderPath) mount point"
        $testResults = $false
    }

    return $testResults
}

<#
    .SYNOPSIS
        Creates Exchange Volume mount points for any disks which should have
        them, but do not.

    .PARAMETER Identity
        The name of the server. Not actually used for anything.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.

    .PARAMETER SpareVolumeCount
        How many spare volumes will be available.

    .PARAMETER EnsureExchangeVolumeMountPointIsLast
        Whether the EXVOL mount point should be moved to be the last mount
        point listed on each disk. Defaults to $false.

    .PARAMETER CreateSubfolders
        If $true, specifies that DBNAME.db and DBNAME.log subfolders should be
        automatically created underneath the ExchangeDatabase mount points.
        Defaults to $false.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER MinDiskSize
        The minimum size of a disk to consider using. Defaults to none. Should
        be in a format like '1024MB' or '1TB'.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.

    .PARAMETER CurrentVolCount
        The current number of Exchange Volumes that have been created.

    .PARAMETER RequiredVolCount
        The expected final number of Exchange Volumes.
#>
function New-ExVolumesWhereMissing
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
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL',

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $CurrentVolCount,

        [Parameter(Mandatory = $true)]
        [System.Int32]
        $RequiredVolCount
    )

    for ($i = $CurrentVolCount; $i -lt $RequiredVolCount; $i++)
    {
        if ($i -ne $CurrentVolCount) # Need to update disk info if we've gone through the loop already
        {
            $diskInfo = Get-DiskInfo
        }

        $firstDisk = Get-FirstAvailableDiskNumber -MinDiskSize $MinDiskSize -DiskInfo $diskInfo

        if ($firstDisk -ne -1)
        {
            $firstVolume = Get-FirstAvailableVolumeNumber -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix

            if ($firstVolume -ne -1)
            {
                $volPath = Join-Path -Path "$($AutoDagVolumesRootFolderPath)" -ChildPath "$($VolumePrefix)$($firstVolume)"

                Initialize-ExchangeVolume -DiskNumber $firstDisk -Folder $volPath -FileSystem $FileSystem -UnitSize $UnitSize -PartitioningScheme $PartitioningScheme -Label "$($VolumePrefix)$($firstVolume)"
            }
            else
            {
                throw 'Unable to find a free volume number to use when naming the volume folder'
            }
        }
        else
        {
            throw 'No available disks to assign an Exchange Volume mount point to'
        }
    }
}

<#
    .SYNOPSIS
        Looks for databases that have never had a mount point created, and adds
        a mount point for them on an appropriate Exchange Volume.

    .PARAMETER Identity
        The name of the server. Not actually used for anything.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.

    .PARAMETER SpareVolumeCount
        How many spare volumes will be available.

    .PARAMETER EnsureExchangeVolumeMountPointIsLast
        Whether the EXVOL mount point should be moved to be the last mount
        point listed on each disk. Defaults to $false.

    .PARAMETER CreateSubfolders
        If $true, specifies that DBNAME.db and DBNAME.log subfolders should be
        automatically created underneath the ExchangeDatabase mount points.
        Defaults to $false.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER MinDiskSize
        The minimum size of a disk to consider using. Defaults to none. Should
        be in a format like '1024MB' or '1TB'.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.
#>
function New-ExDatabaseMountPointsWhereMissing
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
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter()]
        [ValidateSet('MBR', 'GPT')]
        [System.String]
        $PartitioningScheme = 'GPT',

        [Parameter()]
        [System.String]
        $UnitSize = '64K',

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL'
    )

    for ($i = 0; $i -lt $DiskToDBMap.Count; $i++)
    {
        if ($i -gt 0) # Need to refresh current disk info
        {
            $diskInfo = Get-DiskInfo
        }

        $dbsNeedingMountPoints = @()

        $allDBsRequestedForDisk = $DiskToDBMap[$i].Split(',')

        for ($j = 0; $j -lt $allDBsRequestedForDisk.Count; $j++)
        {
            $current = $allDBsRequestedForDisk[$j]

            $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($current)"

            # We only want to touch datases who have never had a mount point created. After that, AutoReseed will handle it.
            if ((Test-Path -Path "$($path)") -eq $false)
            {
                $dbsNeedingMountPoints += $current
            }
            else # Since the folder already exists, need to check and error if the mount point doesn't
            {
                if ((Get-MountPointVolumeNumber -Path $path) -eq -1)
                {
                    throw "Database '$($current)' already has a folder on disk at '$($path)', but does not have a mount point. This must be manually corrected for xAutoMountPoint to proceed."
                }
            }
        }

        if ($dbsNeedingMountPoints.Count -eq $allDBsRequestedForDisk.Count) # No DB mount points for this disk have been created yet
        {
            $targetVolume = Get-ExchangeVolumeNumberForMountPoint -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -DBsPerDisk $allDBsRequestedForDisk.Count -VolumePrefix $VolumePrefix -DiskInfo $diskInfo
        }
        elseif ($dbsNeedingMountPoints.Count -gt 0) # We just need to create some mount points
        {
            $existingDB = ''

            # Find a DB that's already had its mount point created
            foreach ($db in $allDBsRequestedForDisk)
            {
                if (($dbsNeedingMountPoints.Contains($db) -eq $false))
                {
                    $existingDB = $db
                    break
                }
            }

            if ($existingDB -ne '')
            {
                $targetVolume = Get-ExchangeVolumeNumberForMountPoint -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -ExistingDB $existingDB -DBsPerDisk $allDBsRequestedForDisk.Count -DBsToCreate $dbsNeedingMountPoints.Count -VolumePrefix $VolumePrefix -DiskInfo $diskInfo
            }
        }
        else # All DB's requested for this disk are good. Just continue on in the loop
        {
            continue
        }

        if ($null -ne $targetVolume)
        {
            if ($targetVolume -ne -1)
            {
                foreach ($db in $dbsNeedingMountPoints)
                {
                    $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($db)"

                    Add-ExchangeMountPoint -VolumeNumber $targetVolume -Folder $path

                    if ($CreateSubfolders -eq $true)
                    {
                        $dbFolder = Join-Path -Path "$($path)" -ChildPath "$($db).db"
                        $logFolder = Join-Path -Path "$($path)" -ChildPath "$($db).log"

                        if ((Test-Path -LiteralPath "$($dbFolder)") -eq $false)
                        {
                            New-Item -ItemType Directory -Path "$($dbFolder)"
                        }

                        if ((Test-Path -LiteralPath "$($logFolder)") -eq $false)
                        {
                            New-Item -ItemType Directory -Path "$($logFolder)"
                        }
                    }
                }
            }
            else
            {
                throw "Unable to find a volume to place mount points for the following databases: '$($dbsNeedingMountPoints)'"
            }
        }
    }
}

<#
    .SYNOPSIS
        Builds a map of the DBs that already exist on disk.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-DiskToDBMap
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    # Get the DB path to a point where we know there will be a trailing \
    $dbpath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath ""

    # Will be the return value for DiskToDBMap
    [System.String[]] $dbMap = @()

    # Loop through all existing mount points and figure out which ones are for DB's
    foreach ($key in $DiskInfo.VolumeToMountPointMap.Keys)
    {
        [System.String] $mountPoints = ''

        foreach ($mountPoint in $DiskInfo.VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbpath))
            {
                $startIndex = $dbpath.Length
                $endIndex = $mountPoint.IndexOf('\', $startIndex)
                $dbName = $mountPoint.Substring($startIndex, $endIndex - $startIndex)

                if ($mountPoints -eq '')
                {
                    $mountPoints = $dbName
                }
                else
                {
                    $mountPoints += ",$($dbName)"
                }
            }
        }

        if ($mountPoints.Length -gt 0)
        {
            $dbMap += $mountPoints
        }
    }

    return $dbMap
}

<#
    .SYNOPSIS
        Looks for a volume where an Exchange Volume or Database mount point can
        be added.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER ExistingDB
        If ExistingDB is not specified, looks for a spare volume that
        has no mount points yet. If ExistingDB is specified, finds the volume
        number where that DB exists, only if there is room to Create the
        requested database mount points.

    .PARAMETER DBsPerDisk
        The number of databases that are allowed per disk.

    .PARAMETER DBsToCreate
        The number of databases to create on the discovered disk.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-ExchangeVolumeNumberForMountPoint
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String]
        $ExistingDB = '',

        [Parameter()]
        [Uint32]
        $DBsPerDisk,

        [Parameter()]
        [Uint32]
        $DBsToCreate,

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL',

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    $targetVol = -1 # Our return variable

    [object[]] $keysSorted = Get-ExchangeVolumeKeysSorted -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix -DiskInfo $DiskInfo

    # Loop through every volume
    foreach ($key in $keysSorted)
    {
        [int] $intKey = $key

        # Get mount points for this volume
        [System.String[]] $mountPoints = $DiskInfo.VolumeToMountPointMap[$intKey]

        $hasExVol = $false # Whether any ExVol mount points exist on this disk
        $hasExDb = $false # Whether any ExDB mount points exist on this disk
        $hasExistingDB = $false # Whether $ExistingDB exists as a mount point on this disk

        # Inspect each individual mount point
        foreach ($mountPoint in $mountPoints)
        {
            if ($mountPoint.StartsWith($AutoDagVolumesRootFolderPath))
            {
                $hasExVol = $true
            }
            elseif ($mountPoint.StartsWith($AutoDagDatabasesRootFolderPath))
            {
                $hasExDb = $true

                $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($ExistingDB)"

                if ($mountPoint.StartsWith($path))
                {
                    $hasExistingDB = $true
                }
            }
        }

        if ($ExistingDB -eq '')
        {
            if ($hasExVol -eq $true -and $hasExDb -eq $false)
            {
                $targetVol = $intKey
                break
            }
        }
        else
        {
            if ($hasExVol -eq $true -and $hasExistingDB -eq $true)
            {
                if (($mountPoints.Count + $DBsToCreate) -le ($DBsPerDisk + 1))
                {
                    $targetVol = $intKey
                }

                break
            }
        }
    }

    return $targetVol
}

<#
    .SYNOPSIS
        Finds the names of all existing EXVOL mount points, and returns a
        sorted array of all the EXVOL volume numbers.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-ExchangeVolumeKeysSorted
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String]
        $VolumePrefix = 'EXVOL',

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    [System.String[]] $sortedKeys = @() # The return value

    [System.String] $pathBeforeVolumeNumber = Join-Path -Path $AutoDagVolumesRootFolderPath -ChildPath $VolumePrefix

    # First extract the actual volume number as an Int from the volume path, then add it to a new hashtable with the same key value
    [System.Collections.Hashtable] $tempVolumeToMountPointMap = @{}

    foreach ($key in $DiskInfo.VolumeToMountPointMap.Keys)
    {
        $volPath = ''

        # Loop through each mount point on this volume and find the EXVOL mount point
        foreach ($value in $DiskInfo.VolumeToMountPointMap[$key])
        {
            if ($value.StartsWith($pathBeforeVolumeNumber))
            {
                $volPath = $value
                break
            }
        }

        if ($volPath.StartsWith($pathBeforeVolumeNumber))
        {
            if ($volPath.EndsWith('\') -or $volPath.EndsWith('/'))
            {
                [System.String] $exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length - 1))
            }
            else
            {
                [System.String] $exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length))
            }

            [int] $exVolNumber = [int]::Parse($exVolNumberStr)
            $tempVolumeToMountPointMap.Add($key, $exVolNumber)
        }
    }

    # Now go through the volume numbers, and add the keys to the return array in sorted value order
    while ($tempVolumeToMountPointMap.Count -gt 0)
    {
        [object[]] $keys = $tempVolumeToMountPointMap.Keys
        [int] $lowestKey = $keys[0]
        [int] $lowestValue = $tempVolumeToMountPointMap[$keys[0]]

        for ($i = 1; $i -lt $tempVolumeToMountPointMap.Count; $i++)
        {
            [int] $currentValue = $tempVolumeToMountPointMap[$keys[$i]]

            if ($currentValue -lt $lowestValue)
            {
                $lowestKey = $keys[$i]
                $lowestValue = $currentValue
            }
        }

        $sortedKeys += $lowestKey
        $tempVolumeToMountPointMap.Remove($lowestKey)
    }

    return $sortedKeys
}

<#
    .SYNOPSIS
        Finds the lowest disk number that doesn't have any volumes associated,
        and is larger than the requested size.

    .PARAMETER MinDiskSize
        The minimum disk size to consider when looking for available disks.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-FirstAvailableDiskNumber
{
    [CmdletBinding()]
    [OutputType([System.UInt32])]
    param
    (
        [Parameter()]
        [System.String]
        $MinDiskSize = '',

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    $diskNum = -1

    foreach ($key in $DiskInfo.DiskToVolumeMap.Keys)
    {
        if ($DiskInfo.DiskToVolumeMap[$key].Count -eq 0 -and ($key -lt $diskNum -or $diskNum -eq -1))
        {
            if ($MinDiskSize -ne '')
            {
                [Uint64] $minSize = 0 + $MinDiskSize.Replace(' ', '')
                [Uint64] $actualSize = 0 + $DiskInfo.DiskSizeMap[$key].Replace(' ', '')

                if ($actualSize -gt $minSize)
                {
                    $diskNum = $key
                }
            }
            else
            {
                $diskNum = $key
            }
        }
    }

    return $diskNum
}

<#
    .SYNOPSIS
        Looks in the volumes root folder and finds the first number we can give
        to a volume folder based off of what folders have already been created.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER VolumePrefix
        The prefix to give to Exchange Volume folders. Defaults to EXVOL.
#>
function Get-FirstAvailableVolumeNumber
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String]
        $VolumePrefix
    )

    if ((Test-Path -LiteralPath "$($AutoDagVolumesRootFolderPath)") -eq $false) # If the ExVol folder doesn't already exist, then we can start with 1
    {
        return 1
    }

    $currentFolders = Get-ChildItem -LiteralPath "$($AutoDagVolumesRootFolderPath)" | Where-Object {$_.GetType().Name -eq 'DirectoryInfo'} | Sort-Object

    for ($i = 1; $i -lt 999; $i++)
    {
        $existing = $null
        $existing = $currentFolders | Where-Object {$_.Name -eq "$($VolumePrefix)$($i)"}

        if ($null -eq $existing)
        {
            return $i
        }
    }

    return -1
}

<#
    .SYNOPSIS
        Counts and returns the number of DB's in the input DiskToDBMap.

    .PARAMETER DiskToDBMap
        An array of strings containing the databases for each disk. Databases
        on the same disk should be in the same string, and comma separated.
        Example: 'DB1,DB2','DB3,DB4'. This puts DB1 and DB2 on one disk, and
        DB3 and DB4 on another.
#>
function Get-DesiredDatabaseCount
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [System.String[]]
        $DiskToDBMap
    )

    $count = 0

    foreach ($value in $DiskToDBMap)
    {
        $count += $value.Split(',').Count
    }

    return $count
}

<#
    .SYNOPSIS
        Checks if a database already has a mountpoint created.

    .PARAMETER AutoDagDatabasesRootFolderPath
        The parent folder for Exchange database mount point folders.

    .PARAMETER Database
        The name of the Database to check for.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Test-DBHasMountPoint
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.String]
        $Database,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    $dbPath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($Database)"

    foreach ($key in $DiskInfo.VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $DiskInfo.VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbPath))
            {
                return $true
            }
        }
    }

    return $false
}

<#
    .SYNOPSIS
        Gets the count of in use mount points matching the given critera.

    .PARAMETER RootFolder
        The folder to count Mount Points within.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-InUseMountPointCount
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [System.String]
        $RootFolder,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    $count = 0

    foreach ($key in $DiskInfo.VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $DiskInfo.VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($RootFolder))
            {
                $count++
            }
        }
    }

    return $count
}

<#
    .SYNOPSIS
        Checks all volumes, and sees if any of them have ExchangeVolume mount
        points that show up before other (like ExchangeDatabase) mount points.
        If so, it returns the volume number. If not, it returns -1.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Get-VolumeNumberWhereMountPointNotLastInList
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    foreach ($key in $DiskInfo.VolumeToMountPointMap.Keys)
    {
        $values = $DiskInfo.VolumeToMountPointMap[$key]

        if ($null -ne $values)
        {
            for ($i = 0; $i -lt $values.Count; $i++)
            {
                if ($values[$i].StartsWith($AutoDagVolumesRootFolderPath) -eq $true -and $i -lt ($values.Count - 1))
                {
                    return $key
                }
            }
        }
    }

    return -1
}

<#
    .SYNOPSIS
        For volumes that have multiple mount points including an ExchangeVolum
         mount point, sends removes and re-adds the ExchangeVolume mount point
         so that it is at the end of the list of mount points.

    .PARAMETER AutoDagVolumesRootFolderPath
        The parent folder for Exchange volume mount point folders.

    .PARAMETER VolumeNumber
        The number of the volume to modify.

    .PARAMETER DiskInfo
        Information on the disks and volumes that already exist on the system.
#>
function Move-VolumeMountPointToEndOfList
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.Int32]
        $VolumeNumber,

        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $DiskInfo
    )

    $values = $DiskInfo.VolumeToMountPointMap[$VolumeNumber]

    foreach ($folderName in $values)
    {
        if ($folderName.StartsWith($AutoDagVolumesRootFolderPath))
        {
            if ($folderName.EndsWith('\'))
            {
                $folderName = $folderName.Substring(0, $folderName.Length - 1)
            }

            Start-DiskPart -Commands "select volume $($VolumeNumber)", "remove mount=`"$($folderName)`"", "assign mount=`"$($folderName)`"" -Verbose:$VerbosePreference | Out-Null
            break
        }
    }
}

<#
    .SYNOPSIS
        Takes an empty disk, initalizes and formats it, and gives it an
        ExchangeVolume mount point.

    .PARAMETER Folder
        The folder to assign the Exchange Volume mount point to.

    .PARAMETER FileSystem
        The file system to use when formatting the volume. Defaults to NTFS.

    .PARAMETER Label
        The label to assign to the formatted volume.

    .PARAMETER PartitioningScheme
        The partitioning scheme for the volume. Defaults to GPT.

    .PARAMETER UnitSize
        The unit size to use when formatting the disk. Defaults to 64k.
#>
function Initialize-ExchangeVolume
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [int]
        $DiskNumber,

        [Parameter()]
        [System.String]
        $Folder,

        [Parameter()]
        [ValidateSet('NTFS', 'REFS')]
        [System.String]
        $FileSystem = 'NTFS',

        [Parameter()]
        [System.String]
        $Label,

        [Parameter()]
        [System.String]
        $PartitioningScheme,

        [Parameter()]
        [System.String]
        $UnitSize
    )

    # Initialize the disk and put in MBR format
    Start-DiskPart -Commands "select disk $($DiskNumber)", 'clean' -Verbose:$VerbosePreference | Out-Null
    Start-DiskPart -Commands "select disk $($DiskNumber)", 'online disk' -Verbose:$VerbosePreference | Out-Null
    Start-DiskPart -Commands "select disk $($DiskNumber)", 'attributes disk clear readonly', 'convert MBR' -Verbose:$VerbosePreference | Out-Null
    Start-DiskPart -Commands "select disk $($DiskNumber)", 'offline disk' -Verbose:$VerbosePreference | Out-Null

    # Online the disk
    Start-DiskPart -Commands "select disk $($DiskNumber)", 'attributes disk clear readonly', 'online disk' -Verbose:$VerbosePreference | Out-Null

    # Convert to GPT if requested
    if ($PartitioningScheme -eq 'GPT')
    {
        Start-DiskPart -Commands "select disk $($DiskNumber)", 'convert GPT noerr' -Verbose:$VerbosePreference | Out-Null
    }

    # Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        New-Item -ItemType Directory -Path "$($Folder)" | Out-Null
    }

    # Create the partition and format the drive
    if ($FileSystem -eq 'NTFS')
    {
        $formatString = "Format FS=$($FileSystem) UNIT=$($UnitSize) Label=$($Label) QUICK"

        Start-DiskPart -Commands "select disk $($DiskNumber)", "create partition primary", "$($formatString)", "assign mount=`"$($Folder)`"" -Verbose:$VerbosePreference | Out-Null
    }
    else # If ($FileSystem -eq "REFS")
    {
        Start-DiskPart -Commands "select disk $($DiskNumber)", "create partition primary" -Verbose:$VerbosePreference | Out-Null

        if ($UnitSize.ToLower().EndsWith('k'))
        {
            $UnitSizeBytes = [UInt64]::Parse($UnitSize.Substring(0, $UnitSize.Length - 1)) * 1024
        }
        else
        {
            $UnitSizeBytes = $UnitSize
        }

        Write-Verbose -Message 'Sleeping for 15 seconds after partition creation.'

        Start-Sleep -Seconds 15

        Get-Partition -DiskNumber $DiskNumber -PartitionNumber 2| Format-Volume -AllocationUnitSize $UnitSizeBytes -FileSystem REFS -NewFileSystemLabel $Label -SetIntegrityStreams:$false -Confirm:$false
        Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 2 -AccessPath $Folder -PassThru | Set-Partition -NoDefaultDriveLetter $true
    }
}

<#
    .SYNOPSIS
        Adds a mount point to an existing volume.

    .PARAMETER VolumeNumber
        The number of the volume to assign a mount point to.

    .PARAMETER Folder
        The folder to assign the Exchange Volume mount point to.
#>
function Add-ExchangeMountPoint
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [int]
        $VolumeNumber,

        [Parameter()]
        [System.String]
        $Folder
    )

    # Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        New-Item -ItemType Directory -Path "$($Folder)" | Out-Null
    }

    Start-DiskPart -Commands "select volume $($VolumeNumber)", "assign mount=`"$($Folder)`"" -Verbose:$VerbosePreference | Out-Null
}

Export-ModuleMember -Function *-TargetResource
