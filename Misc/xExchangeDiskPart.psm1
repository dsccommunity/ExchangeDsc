#Adds the array of commands to a single temp file, and has disk part execute the temp file
function StartDiskpart
{
	[CmdletBinding()]
	[OutputType([System.String])]
    Param ([Array]$Commands, [Boolean]$ShowOutput = $true, $VerbosePreference)

    $Tempfile = [System.IO.Path]::GetTempFileName()

    foreach ($Com in $Commands)
    {
		$CMDLine = $CMDLine + $Com + ", "
        Add-Content $Tempfile $Com
    }

    $Output = DiskPart /s $Tempfile

    if ($ShowOutput)
    {
        Write-Verbose "Executed Diskpart commands: $(StringArrayToCommaSeparatedString -Array $Commands). Result:"
        Write-Verbose "$($Output)"
    }

    Remove-Item $Tempfile

    return $Output
}

#Uses diskpart to obtain information on the disks and volumes that already exist on the system
function GetDiskInfo
{
    [Hashtable]$global:DiskToVolumeMap = @{}
    [Hashtable]$global:VolumeToMountPointMap = @{}
    [Hashtable]$global:DiskSizeMap = @{}
    [int[]]$diskNums = @()

    $diskList = StartDiskpart -Commands "List Disk" -ShowOutput $false

    $foundDisks = $false

    #First parse out the list of disks
    foreach ($line in $diskList)
    {
        if ($foundDisks -eq $true)
        {
            if ($line.Contains("Disk "))
            {
                #First find the disk number
                $startIndex = "  Disk ".Length
                $endIndex = "  --------  ".Length
                $diskNumStr = $line.Substring($startIndex, $endIndex - $startIndex).Trim()

                if ($diskNumStr.Length -gt 0)
                {
                    $diskNum = [int]::Parse($diskNumStr)
                    $diskNums += $diskNum
                }

                #Now find the disk size
                $startIndex = "  --------  -------------  ".Length
                $endIndex = "  --------  -------------  -------  ".Length
                $diskSize = $line.Substring($startIndex, $endIndex - $startIndex).Trim()

                if ($diskSize.Length -gt 0 -and $diskNum -ne $null)
                {
                    $DiskSizeMap.Add($diskNum, $diskSize)
                }
            }
        }
        elseif ($line.Contains("--------  -------------  -------  -------  ---  ---")) #Scroll forward until we find the where the list of disks starts
        {
            $foundDisks = $true
        }
    }

    #Now get info on the disks
    foreach ($diskNum in $diskNums)
    {
        $diskDetails = StartDiskpart -Commands "Select Disk $($diskNum)","Detail Disk" -ShowOutput $false

        $foundVolumes = $false

        for ($i = 0; $i -lt $diskDetails.Count; $i++)
        {
            $line = $diskDetails[$i]

            if ($foundVolumes -eq $true)
            {
                if ($line.StartsWith("  Volume "))
                {
                    #First find the volume number
                    $volStart = "  Volume ".Length
                    $volEnd = "  ----------  ".Length
                    $volStr = $line.Substring($volStart, $volEnd - $volStart).Trim()

                    if ($volStr.Length -gt 0)
                    {
                        $volNum = [int]::Parse($volStr)

                        AddObjectToMapOfObjectArrays -Map $DiskToVolumeMap -Key $diskNum -Value $volNum

                        #Now parse out the drive letter if it's set
                        $letterStart = "  ----------  ".Length
                        $letterEnd = $line.IndexOf("  ----------  ---  ") + "  ----------  ---  ".Length
                        $letter = $line.Substring($letterStart, $letterEnd - $letterStart).Trim()

                        if ($letter.Length -eq 1)
                        {
                            AddObjectToMapOfObjectArrays -Map $VolumeToMountPointMap -Key $volNum -Value $letter
                        }

                        #Now find all the mount points
                        do
                        {
                            $line = $diskDetails[++$i]

                            if ($line -eq $null -or $line.StartsWith("  Volume ") -or $line.Trim().Length -eq 0) #We've hit the next volume, or the end of all info
                            {
                                $i-- #Move $i back one as we may have overrun the start of the next volume info
                                break
                            }
                            else
                            {
                                $mountPoint = $line.Trim()

                                AddObjectToMapOfObjectArrays -Map $VolumeToMountPointMap -Key $volNum -Value $mountPoint
                            }

                        } while ($i -lt $diskDetails.Count)

                    }
                }
            }
            elseif ($line.Contains("There are no volumes."))
            {
                [string[]]$emptyArray = @()
                $DiskToVolumeMap[$diskNum] = $emptyArray

                break
            }
            elseif ($line.Contains("----------  ---  -----------  -----  ----------  -------  ---------  --------"))
            {
                $foundVolumes = $true
            }
        }
    }
}

function StringArrayToCommaSeparatedString
{
    param([string[]]$Array)

    $string = ""

    if ($Array -ne $null -and $Array.Count -gt 0)
    {
        $string = $Array[0]

        for ($i = 1; $i -lt $Array.Count; $i++)
        {
            $string += ",$($Array[$i])"
        }
    }

    return $string
}

#Takes a hashtable, and adds the given key and value.
function AddObjectToMapOfObjectArrays
{
    Param([Hashtable]$Map, $Key, $Value)

    if ($Map.ContainsKey($Key))
    {
        $Map[$Key] += $Value
    }
    else
    {
        [object[]]$Array = $Value
        $Map[$Key] = $Array
    }
}

#Checks whether the mount point specified in the given path already exists as a mount point
#Returns the volume number if it does exist, else -1
function MountPointExists
{
    param([string]$Path)

    foreach ($key in $global:VolumeToMountPointMap.Keys)
    {
        foreach ($value in $global:VolumeToMountPointMap[$key])
        {
            #Make sure both paths end with the same character
            if (($value.EndsWith("\")) -eq $false)
            {
                $value += "\"
            }

            if (($Path.EndsWith("\")) -eq $false)
            {
                $Path += "\"
            }

            #Do the comparison
            if ($value -like $Path)
            {
                return $key
            }
        }
    }

    return -1
}


Export-ModuleMember -Function *