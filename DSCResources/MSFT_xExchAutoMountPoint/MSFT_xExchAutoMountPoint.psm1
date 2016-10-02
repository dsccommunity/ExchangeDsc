function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [System.Boolean]
        $CreateSubfolders = $false,

        [ValidateSet("NTFS","REFS")]
        [System.String]
        $FileSystem = "NTFS",

        [System.String]
        $MinDiskSize = "",

        [ValidateSet("MBR","GPT")]
        [System.String]
        $PartitioningScheme = "GPT",

        [System.String]
        $UnitSize = "64K",

        [System.String]
        $VolumePrefix = "EXVOL"
    )

    #Load helper modules
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeDiskPart.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    GetDiskInfo

    $dbMap = GetDiskToDBMap -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath

    $returnValue = @{
        Identity = $Identity
        DiskToDBMap = $dbMap
        SpareVolumeCount = $SpareVolumeCount
        AutoDagDatabasesRootFolderPath = $AutoDagDatabasesRootFolderPath
        AutoDagVolumesRootFolderPath = $AutoDagVolumesRootFolderPath
        VolumePrefix = $VolumePrefix
        MinDiskSize = $MinDiskSize
        UnitSize = $UnitSize
        PartitioningScheme = $PartitioningScheme
        FileSystem = $FileSystem
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
        $Identity,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [System.Boolean]
        $CreateSubfolders = $false,

        [ValidateSet("NTFS","REFS")]
        [System.String]
        $FileSystem = "NTFS",

        [System.String]
        $MinDiskSize = "",

        [ValidateSet("MBR","GPT")]
        [System.String]
        $PartitioningScheme = "GPT",

        [System.String]
        $UnitSize = "64K",

        [System.String]
        $VolumePrefix = "EXVOL"
    )

    #Load helper modules
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeDiskPart.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    #First see if we need to assign any disks to ExVol's
    GetDiskInfo
    
    $exVolCount = GetInUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath
    $requiredVolCount = $DiskToDBMap.Count + $SpareVolumeCount
   
    if ($exVolCount -lt $requiredVolCount)
    {
        CreateMissingExVolumes @PSBoundParameters -CurrentVolCount $exVolCount -RequiredVolCount $requiredVolCount
    }

    #Now see if we need any DB mount points
    GetDiskInfo

    $exDbCount = GetInUseMountPointCount -RootFolder $AutoDagDatabasesRootFolderPath
    $requiredDbCount = GetDesiredDatabaseCount -DiskToDBMap $DiskToDBMap
    
    if ($exDbCount -lt $requiredDbCount)
    {
        CreateMissingExDatabases @PSBoundParameters
    }

    #Now see if any Mount Points are ordered incorrectly. Jetstress wants ExchangeDatabase mount points to be listed before ExchangeVolume mount points
    GetDiskInfo

    if ($EnsureExchangeVolumeMountPointIsLast -eq $true)
    {
        while($true)
        {
            $volNum = VolumeMountPointNotLastInList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath

            if ($volNum -ne -1)
            {
                SendVolumeMountPointToEndOfList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumeNumber $volNum

                #Update DiskInfo for next iteration
                GetDiskInfo
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
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast = $false,

        [System.Boolean]
        $CreateSubfolders = $false,

        [ValidateSet("NTFS","REFS")]
        [System.String]
        $FileSystem = "NTFS",

        [System.String]
        $MinDiskSize = "",

        [ValidateSet("MBR","GPT")]
        [System.String]
        $PartitioningScheme = "GPT",

        [System.String]
        $UnitSize = "64K",

        [System.String]
        $VolumePrefix = "EXVOL"
    )

    #Load helper modules
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeDiskPart.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    GetDiskInfo

    #Check if the number of assigned EXVOL's is less than the requested number of DB disks plus spares
    $mountPointCount = GetInUseMountPointCount -RootFolder $AutoDagVolumesRootFolderPath

    if ($mountPointCount -lt ($DiskToDBMap.Count + $SpareVolumeCount))
    {
        ReportBadSetting -SettingName "MountPointCount" -ExpectedValue ($DiskToDBMap.Count + $SpareVolumeCount) -ActualValue $mountPointCount -VerbosePreference $VerbosePreference
        return $false
    }
    else #Loop through all requested DB's and see if they have a mount point yet
    {
        foreach ($value in $DiskToDBMap)
        {
            foreach ($db in $value.Split(','))
            {
                if ((DBHasMountPoint -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -DB $db) -eq $false)
                {
                    ReportBadSetting -SettingName "DB '$($db)' Has Mount Point" -ExpectedValue $true -ActualValue $false -VerbosePreference $VerbosePreference
                    return $false
                }
            }
        }
    }

    #Now check if any ExchangeVolume mount points are higher ordered than ExchangeDatabase mount points. ExchangeDatabase MP's must be listed first for logical disk counters to function properly
    if ($EnsureExchangeVolumeMountPointIsLast -eq $true -and (VolumeMountPointNotLastInList -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath) -ne -1)
    {
        Write-Verbose "One or more volumes have an $($AutoDagVolumesRootFolderPath) mount point ordered before a $($AutoDagDatabasesRootFolderPath) mount point"
        return $false
    }

    return $true
}

#Creates mount points for any Exchange Volumes we are missing
function CreateMissingExVolumes
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [System.Boolean]
        $CreateSubfolders = $false,

        [ValidateSet("NTFS","REFS")]
        [System.String]
        $FileSystem = "NTFS",

        [System.String]
        $MinDiskSize = "",

        [ValidateSet("MBR","GPT")]
        [System.String]
        $PartitioningScheme = "GPT",

        [System.String]
        $UnitSize = "64K",

        [System.String]
        $VolumePrefix = "EXVOL",

        [System.Int32]
        $CurrentVolCount,

        [System.Int32]
        $RequiredVolCount
    )

    for ($i = $CurrentVolCount; $i -lt $RequiredVolCount; $i++)
    {
        if ($i -ne $CurrentVolCount) #Need to update disk info if we've gone through the loop already
        {
            GetDiskInfo
        }

        $firstDisk = FindFirstAvailableDisk -MinDiskSize $MinDiskSize

        if ($firstDisk -ne -1)
        {
            $firstVolume = FindFirstAvailableVolumeNumber -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix

            if ($firstVolume -ne -1)
            {
                $volPath = Join-Path -Path "$($AutoDagVolumesRootFolderPath)" -ChildPath "$($VolumePrefix)$($firstVolume)"

                PrepareVolume -DiskNumber $firstDisk -Folder $volPath -FileSystem $FileSystem -UnitSize $UnitSize -PartitioningScheme $PartitioningScheme -Label "$($VolumePrefix)$($firstVolume)"
            }
            else
            {
                throw "Unable to find a free volume number to use when naming the volume folder"
            }
        }
        else
        {
            throw "No available disks to assign an Exchange Volume mount point to"
        }
    }
}

#Looks for databases that have never had a mount point created, and gives them a mount point
function CreateMissingExDatabases
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [parameter(Mandatory = $true)]
        [System.String[]]
        $DiskToDBMap,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [System.Boolean]
        $CreateSubfolders = $false,

        [ValidateSet("NTFS","REFS")]
        [System.String]
        $FileSystem = "NTFS",

        [System.String]
        $MinDiskSize = "",

        [ValidateSet("MBR","GPT")]
        [System.String]
        $PartitioningScheme = "GPT",

        [System.String]
        $UnitSize = "64K",

        [System.String]
        $VolumePrefix = "EXVOL"
    )

    for ($i = 0; $i -lt $DiskToDBMap.Count; $i++)
    {
        if ($i -gt 0) #Need to refresh current disk info
        {
            GetDiskInfo
        }

        [string[]]$dbsNeedingMountPoints = @()

        [string[]]$allDBsRequestedForDisk = $DiskToDBMap[$i].Split(',')

        for ($j = 0; $j -lt $allDBsRequestedForDisk.Count; $j++)
        {
            $current = $allDBsRequestedForDisk[$j]

            $path = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($current)"

            #We only want to touch datases who have never had a mount point created. After that, AutoReseed will handle it.
            if ((Test-Path -Path "$($path)") -eq $false)
            {
                $dbsNeedingMountPoints += $current
            }
            else #Since the folder already exists, need to check and error if the mount point doesn't
            {
                if ((MountPointExists -Path $path) -eq -1)
                {
                    throw "Database '$($current)' already has a folder on disk at '$($path)', but does not have a mount point. This must be manually corrected for xAutoMountPoint to proceed."
                }
            }
        }

        if ($dbsNeedingMountPoints.Count -eq $allDBsRequestedForDisk.Count) #No DB mount points for this disk have been created yet
        {
            $targetVolume = GetExchangeVolume -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -DBsPerDisk $allDBsRequestedForDisk.Count -VolumePrefix $VolumePrefix
        }
        elseif ($dbsNeedingMountPoints.Count -gt 0) #We just need to create some mount points
        {
            $existingDB = ""

            #Find a DB that's already had its mount point created
            foreach ($db in $allDBsRequestedForDisk)
            {
                if (($dbsNeedingMountPoints.Contains($db) -eq $false))
                {
                    $existingDB = $db
                    break
                }
            }

            if ($existingDB -ne "")
            {
                $targetVolume = GetExchangeVolume -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -ExistingDB $existingDB -DBsPerDisk $allDBsRequestedForDisk.Count -DBsToCreate $dbsNeedingMountPoints.Count -VolumePrefix $VolumePrefix
            }
        }
        else #All DB's requested for this disk are good. Just continue on in the loop
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

                    AddMountPoint -VolumeNumber $targetVolume -Folder $path

                    if ($CreateSubfolders -eq $true)
                    {
                        $dbFolder = Join-Path -Path "$($path)" -ChildPath "$($db).db"
                        $logFolder = Join-Path -Path "$($path)" -ChildPath "$($db).log"

                        if ((Test-Path -LiteralPath "$($dbFolder)") -eq $false)
                        {
                            mkdir -Path "$($dbFolder)"
                        }

                        if ((Test-Path -LiteralPath "$($logFolder)") -eq $false)
                        {
                            mkdir -Path "$($logFolder)"
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

#Builds a map of the DBs that already exist on disk
function GetDiskToDBMap
{
    param([string]$AutoDagDatabasesRootFolderPath)

    #Get the DB path to a point where we know there will be a trailing \
    $dbpath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath ""

    #Keep track of a disk number for putting in the map
    $i = 0

    #Will be the return value for DiskToDBMap
    [string[]]$dbMap = @()

    #Loop through all existing mount points and figure out which ones are for DB's
    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        [string]$mountPoints = ""

        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbpath))
            {
                $startIndex = $dbpath.Length
                $endIndex = $mountPoint.IndexOf("\", $startIndex)
                $dbName = $mountPoint.Substring($startIndex, $endIndex - $startIndex)

                if ($mountPoints -eq "")
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

#Looks for a volume where an Exchange Volume or Database mount point can be added.
#If ExistingDB is not specified, looks for a spare volume that has no mount points yet.
#If ExistingDB is specified, finds the volume number where that DB exists, only if there is room to
#create the requested database mount points.
function GetExchangeVolume
{
    param([string]$AutoDagDatabasesRootFolderPath, [string]$AutoDagVolumesRootFolderPath, [string]$ExistingDB = "", [Uint32]$DBsPerDisk, [Uint32]$DBsToCreate, [string]$VolumePrefix = "EXVOL")

    $targetVol = -1 #Our return variable

    [object[]]$keysSorted = GetSortedExchangeVolumeKeys -AutoDagDatabasesRootFolderPath $AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $AutoDagVolumesRootFolderPath -VolumePrefix $VolumePrefix
    
    #Loop through every volume
    foreach ($key in $keysSorted)
    {
        [int]$intKey = $key

        #Get mount points for this volume
        [string[]]$mountPoints = $global:VolumeToMountPointMap[$intKey]

        $hasExVol = $false #Whether any ExVol mount points exist on this disk
        $hasExDb = $false #Whether any ExDB mount points exist on this disk
        $hasExistingDB = $false #Whether $ExistingDB exists as a mount point on this disk

        #Inspect each individual mount point
        foreach($mountPoint in $mountPoints)
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

        if ($ExistingDB -eq "")
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

function GetSortedExchangeVolumeKeys
{
    param([string]$AutoDagDatabasesRootFolderPath, [string]$AutoDagVolumesRootFolderPath, [string]$VolumePrefix = "EXVOL")

    [string[]]$sortedKeys = @() #The return value

    [string]$pathBeforeVolumeNumber = Join-Path -Path $AutoDagVolumesRootFolderPath -ChildPath $VolumePrefix

    #First extract the actual volume number as an Int from the volume path, then add it to a new hashtable with the same key value
    [Hashtable]$tempVolumeToMountPointMap = @{}

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        $volPath = ""

        #Loop through each mount point on this volume and find the EXVOL mount point
        foreach ($value in $VolumeToMountPointMap[$key])
        {
            if ($value.StartsWith($pathBeforeVolumeNumber))
            {
                $volPath = $value
                break
            }
        }

        if ($volPath.StartsWith($pathBeforeVolumeNumber))
        {
            if ($volPath.EndsWith("\") -or $volPath.EndsWith("/"))
            {
                [string]$exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length - 1))
            }
            else
            {
                [string]$exVolNumberStr = $volPath.Substring($pathBeforeVolumeNumber.Length, ($volPath.Length - $pathBeforeVolumeNumber.Length))
            }
            
            [int]$exVolNumber = [int]::Parse($exVolNumberStr)
            $tempVolumeToMountPointMap.Add($key, $exVolNumber)
        }
    }

    #Now go through the volume numbers, and add the keys to the return array in sorted value order
    while ($tempVolumeToMountPointMap.Count -gt 0)
    {
        [object[]]$keys = $tempVolumeToMountPointMap.Keys
        [int]$lowestKey = $keys[0]
        [int]$lowestValue = $tempVolumeToMountPointMap[$keys[0]]

        for ($i = 1; $i -lt $tempVolumeToMountPointMap.Count; $i++)
        {
            [int]$currentValue = $tempVolumeToMountPointMap[$keys[$i]]

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

#Finds the lowest disk number that doesn't have any volumes associated, and is larger than the requested size
function FindFirstAvailableDisk
{
    param([string]$MinDiskSize = "")

    $diskNum = -1

    foreach ($key in $global:DiskToVolumeMap.Keys)
    {
        if ($global:DiskToVolumeMap[$key].Count -eq 0 -and ($key -lt $diskNum -or $diskNum -eq -1))
        {
            if ($MinDiskSize -ne "")
            {
                [Uint64]$minSize = 0 + $MinDiskSize.Replace(" ", "")
                [Uint64]$actualSize = 0 + $global:DiskSizeMap[$key].Replace(" ", "")

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

#Looks in the volumes root folder and finds the first number we can give to a volume folder
#based off of what folders have already been created
function FindFirstAvailableVolumeNumber
{
    param([string]$AutoDagVolumesRootFolderPath, [string]$VolumePrefix)

    if((Test-Path -LiteralPath "$($AutoDagVolumesRootFolderPath)") -eq $false) #If the ExVol folder doesn't already exist, then we can start with 1
    {
        return 1
    }

    $currentFolders = Get-ChildItem -LiteralPath "$($AutoDagVolumesRootFolderPath)" | where {$_.GetType().Name -eq "DirectoryInfo"} | Sort-Object

    for ($i = 1; $i -lt 999; $i++)
    {
        $existing = $null
        $existing = $currentFolders | where {$_.Name -eq "$($VolumePrefix)$($i)"}

        if ($null -eq $existing)
        {
            return $i
        }
    }

    return -1
}

#Counts and returns the number of DB's in the disk to db map
function GetDesiredDatabaseCount
{
    param([string[]]$DiskToDBMap)

    $count = 0

    foreach ($value in $DiskToDBMap)
    {
        $count += $value.Split(',').Count
    }

    return $count
}

#Checks if a database already has a mountpoint created
function DBHasMountPoint
{
    param([string]$AutoDagDatabasesRootFolderPath, [string]$DB)

    $dbPath = Join-Path -Path "$($AutoDagDatabasesRootFolderPath)" -ChildPath "$($DB)"

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($dbPath))
            {
                return $true
            }
        }
    }

    return $false
}

#Gets the count of in use mount points matching the given critera
function GetInUseMountPointCount
{
    param([string]$RootFolder)

    $count = 0

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($mountPoint in $global:VolumeToMountPointMap[$key])
        {
            if ($mountPoint.StartsWith($RootFolder))
            {
                $count++
            }
        }
    }

    return $count
}

#Checks all volumes, and sees if any of them have ExchangeVolume mount points that show up before other (like ExchangeDatabase) mount points.
#If so, it returns the volume number. If not, it returns -1
function VolumeMountPointNotLastInList
{
    param([string]$AutoDagVolumesRootFolderPath)

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        $values = $global:VolumeToMountPointMap[$key]

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

#For volumes that have multiple mount points including an ExchangeVolume mount point, sends removes and re-adds the ExchangeVolume
#mount point so that it is at the end of the list of mount points
function SendVolumeMountPointToEndOfList
{
    [CmdletBinding()]
    param([string]$AutoDagVolumesRootFolderPath, [Int32]$VolumeNumber)

    $values = $global:VolumeToMountPointMap[$VolumeNumber]

    foreach ($folderName in $values)
    {
        if ($folderName.StartsWith($AutoDagVolumesRootFolderPath))
        {
            if ($folderName.EndsWith("\"))
            {
                $folderName = $folderName.Substring(0, $folderName.Length - 1)
            }

            StartDiskpart -Commands "select volume $($VolumeNumber)","remove mount=`"$($folderName)`"","assign mount=`"$($folderName)`"" -VerbosePreference $VerbosePreference | Out-Null
            break
        }
    }
}

#Takes an empty disk, initalizes and formats it, and gives it an ExchangeVolume mount point
function PrepareVolume
{
    [CmdletBinding()]
    param([int]$DiskNumber, [string]$Folder, [ValidateSet("NTFS","REFS")][string]$FileSystem = "NTFS", [string]$UnitSize, [string]$PartitioningScheme, [string]$Label)
    
    #Initialize the disk and put in MBR format
    StartDiskpart -Commands "select disk $($DiskNumber)","clean" -VerbosePreference $VerbosePreference | Out-Null
    StartDiskpart -Commands "select disk $($DiskNumber)","online disk" -VerbosePreference $VerbosePreference | Out-Null
    StartDiskpart -Commands "select disk $($DiskNumber)","attributes disk clear readonly","convert MBR" -VerbosePreference $VerbosePreference | Out-Null
    StartDiskpart -Commands "select disk $($DiskNumber)","offline disk" -VerbosePreference $VerbosePreference | Out-Null
 
    #Online the disk
    StartDiskpart -Commands "select disk $($DiskNumber)","attributes disk clear readonly","online disk" -VerbosePreference $VerbosePreference | Out-Null

    #Convert to GPT if requested
    if ($PartitioningScheme -eq "GPT")
    {
        StartDiskpart -Commands "select disk $($DiskNumber)","convert GPT noerr" -VerbosePreference $VerbosePreference | Out-Null
    }

    #Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        mkdir -Path "$($Folder)" | Out-Null
    }    

    #Create the partition and format the drive
    if ($FileSystem -eq "NTFS")
    {
        $formatString = "Format FS=$($FileSystem) UNIT=$($UnitSize) Label=$($Label) QUICK"

        StartDiskpart -Commands "select disk $($DiskNumber)","create partition primary","$($formatString)","assign mount=`"$($Folder)`"" -VerbosePreference $VerbosePreference | Out-Null
    }
    else #if ($FileSystem -eq "REFS")
    {
        StartDiskpart -Commands "select disk $($DiskNumber)","create partition primary" -VerbosePreference $VerbosePreference | Out-Null
        
        if ($UnitSize.ToLower().EndsWith("k"))
        {
            $UnitSizeBytes = [UInt64]::Parse($UnitSize.Substring(0, $UnitSize.Length - 1)) * 1024
        }
        else
        {
            $UnitSizeBytes = $UnitSize
        }

        Write-Verbose "Sleeping for 15 seconds after partition creation."

        Start-Sleep -Seconds 15

        Get-Partition -DiskNumber $DiskNumber -PartitionNumber 2| Format-Volume -AllocationUnitSize $UnitSizeBytes -FileSystem REFS -NewFileSystemLabel $Label -SetIntegrityStreams:$false -Confirm:$false
        Add-PartitionAccessPath -DiskNumber $DiskNumber -PartitionNumber 2 -AccessPath $Folder -PassThru | Set-Partition -NoDefaultDriveLetter $true
    }
}

#Adds a mount point to an existing volume
function AddMountPoint
{
    [CmdletBinding()]
    param([int]$VolumeNumber, [string]$Folder)

    #Create the directory if it doesn't exist
    if ((Test-Path $Folder) -eq $False)
    {
        mkdir -Path "$($Folder)" | Out-Null
    }

    StartDiskpart -Commands "select volume $($VolumeNumber)","assign mount=`"$($Folder)`"" -VerbosePreference $VerbosePreference | Out-Null
}


Export-ModuleMember -Function *-TargetResource



