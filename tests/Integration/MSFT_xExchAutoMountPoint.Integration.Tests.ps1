<#
    .SYNOPSIS
        Automated unit integration for MSFT_xExchAutoMountPoint DSC Resource.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchAutoMountPoint'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

#endregion HEADER

# Performs tests against all disks listed in DiskToDBMap, as well as
# all Spare Volumes
function Test-MountPointSetup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath,

        [Parameter()]
        [System.String[]]
        $DiskToDBMap,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $SpareVolumeCount,

        [Parameter()]
        [System.Boolean]
        $EnsureExchangeVolumeMountPointIsLast,

        [Parameter()]
        [System.Boolean]
        $CreateSubfolders,

        [Parameter()]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.String]
        $PartitioningScheme,

        [Parameter()]
        [System.String]
        $UnitSize,

        [Parameter()]
        [System.String]
        $VolumePrefix
    )

    # Keep track of the disk numbers of database disks that we find
    $exDiskNumbers = @()

    # Test each disk in the disk map
    foreach ($diskMap in $DiskToDBMap)
    {
        # Keep track of whether we found an EXVOL mount point for this disk
        $foundExVolMountPoint = $false

        # Keep track of the number of EXVOL mount points on this disk
        $exVolMPCount = 0

        # Keep track of whether the EXVOL mount point is last in the list of mount points for the disk
        $exVolLastInList = $false

        # Create a generic EXVOL path name until we find the real one
        $exVolMPName = "$AutoDagVolumesRootFolderPath\$VolumePrefix##"

        # Test individual databases for this disk
        foreach ($dbName in $diskMap.Split(','))
        {
            $dbPath = Join-Path $AutoDagDatabasesRootFolderPath $dbName

            $dbPartition = Get-Partition | Where-Object {$_.AccessPaths.Count -gt 0 -and $_.AccessPaths.Contains("$dbPath\")}

            if ($null -ne $dbPartition)
            {
                # If we haven't looked at this disk yet, make sure it is partitioned and formatted correctly
                if (!$exDiskNumbers.Contains($dbPartition.DiskNumber))
                {
                    $exDiskNumbers += $dbPartition.DiskNumber

                    Test-DiskAndPartitionSetup -Partition $dbPartition -FileSystem $FileSystem -PartitioningScheme $PartitioningScheme -UnitSize $UnitSize
                }
            }

            It "Mount Point Exists: $dbPath" {
                $null -ne $dbPartition | Should Be $true
            }

            # If requested, make sure subfolders were created under the mount points
            if ($null -ne $dbPartition -and $CreateSubfolders)
            {
                $dbdbPath = Join-Path $dbPath "$dbName.db"
                $dblogPath = Join-Path $dbPath "$dbName.log"

                It "$dbdbPath Exists" {
                    Test-Path -Path $dbdbPath | Should Be $true
                }

                It "$dblogPath Exists" {
                    Test-Path -Path $dblogPath | Should Be $true
                }
            }

            # If we haven't found it yet, check if the ExchangeVolumes mount point was added, and store
            # what we know about it
            if (!$foundExVolMountPoint)
            {
                [String[]] $exVolAccessPaths = $dbPartition.AccessPaths | Where-Object {$_ -like "*$AutoDagVolumesRootFolderPath\$VolumePrefix*"}

                if ($exVolAccessPaths.Count -gt 0)
                {
                    $foundExVolMountPoint = $true

                    $exVolMPCount = $exVolAccessPaths.Count
                    $exVolMPName = $exVolAccessPaths[0]
                    $exVolLastInList = $dbPartition.AccessPaths[$dbPartition.AccessPaths.Count - 2] -like "*$VolumePrefix*"
                }
            }
        }

        It "Mount Point Exists: $exVolMPName" {
            $foundExVolMountPoint | Should Be $true
        }

        It "$VolumePrefix Mount Point Count == 1" {
            $exVolMPCount -eq 1 | Should Be $true
        }

        if ($EnsureExchangeVolumeMountPointIsLast)
        {
            It "$VolumePrefix Mount Point Is Last In List" {
                $exVolLastInList | Should Be $true
            }
        }
    }

    # Now try to find and test any requested spare volumes
    [Object[]] $otherExVolPartitions = Get-Partition | Where-Object {$_.AccessPaths -like "*$AutoDagVolumesRootFolderPath\$VolumePrefix*" -and $_.DiskNumber -NotIn $exDiskNumbers}
    [Object[]] $otherExVolDisks = $otherExVolPartitions.DiskNumber

    It "Extra $VolumePrefix Partition Count Same as Disk Count" {
        $otherExVolPartitions.Count -eq $otherExVolDisks.Count | Should Be $true
    }

    It "$SpareVolumeCount Spare Volumes Configured" {
        $SpareVolumeCount -eq $otherExVolDisks.Count | Should Be $true
    }

    foreach ($partition in $otherExVolPartitions)
    {
        Test-DiskAndPartitionSetup -Partition $partition -FileSystem $FileSystem -PartitioningScheme $PartitioningScheme -UnitSize $UnitSize
    }
}

# Performs disk, volume, and partition level tests against
# the specified partition
function Test-DiskAndPartitionSetup
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Object]
        $Partition,

        [Parameter()]
        [System.String]
        $FileSystem,

        [Parameter()]
        [System.String]
        $PartitioningScheme,

        [Parameter()]
        [System.String]
        $UnitSize
    )

    # Get the disk properties and test the partitioning scheme
    $exDisk = Get-Disk -Number $Partition.DiskNumber

    It "PartitioningScheme for Disk $($Partition.DiskNumber) is $PartitioningScheme" {
        $exDisk.PartitionStyle -like $PartitioningScheme | Should Be $true
    }

    # Get the properties exposed via PowerShell and test the file system
    $exDiskVol = Get-Volume -Partition $Partition

    It "File System for Volume is $FileSystem" {
        $exDiskVol.FileSystem -like $FileSystem | Should Be $true
    }

    # Use WMI/CIM to access the BlockSize, and test that the UnitSize was set correctly
    [Object[]] $exDiskVolExtendedProps = Get-CimInstance -Query "SELECT Blocksize FROM Win32_Volume WHERE Label='$($exDiskVol.FileSystemLabel)'"

    It "Only 1 disk exists with label '$($exDiskVol.FileSystemLabel)'" {
        $exDiskVolExtendedProps.Count -eq 1 | Should Be $true
    }

    if ($exDiskVolExtendedProps.Count -eq 1)
    {
        if ($UnitSize.ToLower().EndsWith('k'))
        {
            [UInt64] $UnitSizeBytes = [UInt64]::Parse($UnitSize.Substring(0, $UnitSize.Length - 1)) * 1024
        }
        else
        {
            [UInt64] $UnitSizeBytes = [UInt64]::Parse($UnitSize)
        }

        It "Volume Unit Size == $UnitSize" {
            $UnitSizeBytes -eq $exDiskVolExtendedProps[0].BlockSize | Should Be $true
        }
    }
}

# Removes existing Exchange partitions and related folders
function Remove-MountPointAndFolderSetup
{
    [CmdletBinding(SupportsShouldProcess=$True)]
    param
    (
        [Parameter()]
        [System.String]
        $AutoDagDatabasesRootFolderPath,

        [Parameter()]
        [System.String]
        $AutoDagVolumesRootFolderPath
    )

    # Find the disk numbers of any disk that currently has an Exchange partition on it
    [Object[]] $exDiskNumbers = (Get-Partition | Where-Object {$_.AccessPaths -like "*$AutoDagDatabasesRootFolderPath*" -or $_.AccessPaths -like "*$AutoDagVolumesRootFolderPath*"}).DiskNumber

    # Remove all partitions from any Exchange disk. This ensures the System Reserved
    # partitions are also removed, which is necessary for xExchAutoMountPoint to find
    # the disk as usable.
    foreach ($number in $exDiskNumbers)
    {
        Get-Disk -Number $number | Get-Partition | Remove-Partition -Confirm:$false
    }

    # Remove any folders in the ExchangeDatabases and ExchangeVolumes directories.
    # Do so using Directory.Delete(), as Remove-Item doesn't seem to work against
    # current or former mount points, even with -Force.
    foreach($folder in Get-ChildItem -Path $AutoDagDatabasesRootFolderPath -ErrorAction SilentlyContinue | Where-Object {$_.GetType().Name -like 'DirectoryInfo'})
    {
        [System.IO.Directory]::Delete($folder.FullName,$true)
    }

    foreach($folder in Get-ChildItem -Path $AutoDagVolumesRootFolderPath -ErrorAction SilentlyContinue | Where-Object {$_.GetType().Name -like 'DirectoryInfo'})
    {
        [System.IO.Directory]::Delete($folder.FullName,$true)
    }
}

# Define where Exchange databases and volumes will go
[System.String] $autoDagDatabasesRootFolderPath = Join-Path $env:SystemDrive 'ExchangeDatabases'
[System.String] $autoDagVolumesRootFolderPath = Join-Path $env:SystemDrive 'ExchangeVolumes'

# Clean up any existing mount points or folders
Remove-MountPointAndFolderSetup -AutoDagDatabasesRootFolderPath $autoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $autoDagVolumesRootFolderPath

# Make sure we have enough empty disks to work with to perform required tests
$unpartitionedDisks = Get-Disk | ForEach-Object {if (($_ | Get-Partition).Count -eq 0) {$_}}

if ($unpartitionedDisks.Count -lt 2)
{
    Write-Verbose -Message 'Testing xExchAutoMountPoint requires at least 2 available disks with no partitions configured'
    return
}

$existingExMountPoints = Get-Partition | Where-Object {$_.AccessPaths -like "*$autoDagDatabasesRootFolderPath*" -or $_.AccessPaths -like "*$autoDagVolumesRootFolderPath*"}

if ($existingExMountPoints.Count -gt 0)
{
    Write-Verbose -Message "$($existingExMountPoints.Count) mount points already exist in the Exchange Databases or Exchange Volumes folder. Clean these up before running tests."
    return
}

Invoke-TestSetup

# Begin Testing
Describe 'Test xExchAutoMountPoint Scenarios' {
    # Run through initial testing using 1 DB disk with 4 DB mount points, 1 spare, REFS file system, and GPT partitioning
    $testParams = @{
        Identity = $env:COMPUTERNAME
        AutoDagDatabasesRootFolderPath = $autoDagDatabasesRootFolderPath
        AutoDagVolumesRootFolderPath = $autoDagVolumesRootFolderPath
        DiskToDBMap = @('IntegrationTestDB1,IntegrationTestDB2,IntegrationTestDB3,IntegrationTestDB4')
        SpareVolumeCount = 1
        EnsureExchangeVolumeMountPointIsLast = $true
        CreateSubfolders = $true
        FileSystem = 'REFS'
        PartitioningScheme = 'GPT'
        UnitSize = '64K'
        VolumePrefix = 'EXVOL'
    }

    $expectedGetResults = @{
        Identity = $env:COMPUTERNAME
        AutoDagDatabasesRootFolderPath = $autoDagDatabasesRootFolderPath
        AutoDagVolumesRootFolderPath = $autoDagVolumesRootFolderPath
        SpareVolumeCount = 1
        FileSystem = 'REFS'
        PartitioningScheme = 'GPT'
        UnitSize = '64K'
        VolumePrefix = 'EXVOL'
    }

    Test-TargetResourceFunctionality -Params $testParams `
                                     -ContextLabel 'Configure database disk with 4 DB folder mount points, and a spare disk' `
                                     -ExpectedGetResults $expectedGetResults

    Test-MountPointSetup -AutoDagDatabasesRootFolderPath $testParams.AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $testParams.AutoDagVolumesRootFolderPath -DiskToDBMap $testParams.DiskToDBMap -SpareVolumeCount $testParams.SpareVolumeCount -EnsureExchangeVolumeMountPointIsLast $testParams.EnsureExchangeVolumeMountPointIsLast -CreateSubfolders $testParams.CreateSubfolders -FileSystem $testParams.FileSystem -PartitioningScheme $testParams.PartitioningScheme -UnitSize $testParams.UnitSize -VolumePrefix $testParams.VolumePrefix

    # Cleanup mount points before next round of testing
    Remove-MountPointAndFolderSetup -AutoDagDatabasesRootFolderPath $autoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $autoDagVolumesRootFolderPath

    # Update test parameters and re-test
    # Add an additional disk to the disk map
    $testParams.DiskToDBMap = $expectedGetResults.DiskToDBMap += ('IntegrationTestDB5,IntegrationTestDB6,IntegrationTestDB7,IntegrationTestDB8')

    # Switch to using no spare volumes
    $testParams.SpareVolumeCount = $expectedGetResults.SpareVolumeCount = 0

    # Change file system to NTFS
    $testParams.FileSystem = $expectedGetResults.FileSystem = 'NTFS'

    # Change partitioning scheme to MBR
    $testParams.PartitioningScheme = $expectedGetResults.PartitioningScheme = 'MBR'

    # Specify unit size in bytes instead of kilobytes
    $testParams.UnitSize = $expectedGetResults.UnitSize = '65536'

    # Don't ask for the EXVOL mount point to be added last
    $testParams.EnsureExchangeVolumeMountPointIsLast = $false

    # Don't create subfolders under mount points
    $testParams.CreateSubfolders = $false

    Test-TargetResourceFunctionality -Params $testParams `
                                     -ContextLabel 'Configure 2 database disks with 8 DB folder mount points, and no spare disk' `
                                     -ExpectedGetResults $expectedGetResults

    Test-MountPointSetup -AutoDagDatabasesRootFolderPath $testParams.AutoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $testParams.AutoDagVolumesRootFolderPath -DiskToDBMap $testParams.DiskToDBMap -SpareVolumeCount $testParams.SpareVolumeCount -EnsureExchangeVolumeMountPointIsLast $testParams.EnsureExchangeVolumeMountPointIsLast -CreateSubfolders $testParams.CreateSubfolders -FileSystem $testParams.FileSystem -PartitioningScheme $testParams.PartitioningScheme -UnitSize $testParams.UnitSize -VolumePrefix $testParams.VolumePrefix
}

# Clean up mount points and folders one last time
Remove-MountPointAndFolderSetup -AutoDagDatabasesRootFolderPath $autoDagDatabasesRootFolderPath -AutoDagVolumesRootFolderPath $autoDagVolumesRootFolderPath
