Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Modules\xExchangeDiskPart\xExchangeDiskPart.psd1" -Force

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter()]
        [System.String]
        $ConfigFilePath,

        [Parameter()]
        [System.String[]]
        $DatabasePaths,

        [Parameter()]
        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [Parameter()]
        [System.String[]]
        $LogPaths,

        [Parameter()]
        [System.String]
        $OutputSaveLocation,

        [Parameter()]
        [System.Boolean]
        $RemoveBinaries
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath' = $JetstressPath
    } -Verbose:$VerbosePreference

    $returnValue = @{
        JetstressPath = [System.String] $JetstressPath
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
        $JetstressPath,

        [Parameter()]
        [System.String]
        $ConfigFilePath,

        [Parameter()]
        [System.String[]]
        $DatabasePaths,

        [Parameter()]
        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [Parameter()]
        [System.String[]]
        $LogPaths,

        [Parameter()]
        [System.String]
        $OutputSaveLocation,

        [Parameter()]
        [System.Boolean]
        $RemoveBinaries
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath' = $JetstressPath
    } -Verbose:$VerbosePreference

    Assert-ParametersValidForJetstress @PSBoundParameters

    $jetstressInstalled = Get-IsJetstressInstalled

    if ($jetstressInstalled)
    {
        throw 'Jetstress must be uninstalled before using the xExchJetstressCleanup resource'
    }

    # If a config file was specified, pull the database and log paths out and put them into $DatabasePaths and $LogPaths
    if ($PSBoundParameters.ContainsKey('ConfigFilePath'))
    {
        [xml] $configFile = Get-JetstressConfigXmlContent -ConfigFilePath "$($ConfigFilePath)"

        [System.String[]] $DatabasePaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path
        [System.String[]] $LogPaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath
    }

    [System.String[]] $FoldersToRemove = $DatabasePaths + $LogPaths

    # Now delete the specified directories
    # Variable Only used if $DeleteAssociatedMountPoints is $true
    [Hashtable] $ParentFoldersToRemove = @{ }

    foreach ($path in $FoldersToRemove)
    {
        # Get the parent folder for the specified path
        $parent = Get-ParentFolderFromPathString -Folder "$($path)"

        if (([System.String]::IsNullOrEmpty($parent) -eq $false -and $ParentFoldersToRemove.ContainsKey($parent) -eq $false))
        {
            $ParentFoldersToRemove.Add($parent, $null)
        }

        Remove-FolderAndContent -Path "$($path)"
    }

    # Delete associated mount points if requested
    if ($DeleteAssociatedMountPoints -eq $true -and $ParentFoldersToRemove.Count -gt 0)
    {
        $diskInfo = Get-DiskInfo

        foreach ($parent in $ParentFoldersToRemove.Keys)
        {
            if ($null -eq (Get-ChildItem -LiteralPath "$($parent)" -ErrorAction SilentlyContinue))
            {
                $volNum = Get-MountPointVolumeNumber -Path "$($parent)" -DiskInfo $diskInfo

                if ($volNum -ge 0)
                {
                    Start-DiskPart -Commands "select volume $($volNum)", "remove mount=`"$($parent)`"" -Verbose:$VerbosePreference | Out-Null

                    Remove-FolderAndContent -Path "$($parent)"
                }
                else
                {
                    Write-Warning "Folder '$($parent)' does not have an associated mount point."
                }
            }
            else
            {
                Write-Warning "Folder '$($parent)' still has child items. Skipping removing mount point."
            }
        }
    }

    # Clean up binaries if requested
    if ($RemoveBinaries -eq $true -and (Test-Path -LiteralPath "$($JetstressPath)") -eq $true)
    {
        # Move output files if requested
        if ([System.String]::IsNullOrEmpty($OutputSaveLocation) -eq $false)
        {
            if ((Test-Path -LiteralPath "$($OutputSaveLocation)") -eq $false)
            {
                New-Item -ItemType Directory -Path "$($OutputSaveLocation)"
            }

            $outputFiles = Get-ChildItem -LiteralPath "$($JetstressPath)" | Where-Object -FilterScript {
                $_.Name -like 'Performance*' -or `
                    $_.Name -like 'Stress*' -or `
                    $_.Name -like 'DBChecksum*' -or `
                    $_.Name -like 'XmlConfig*' -or `
                    $_.Name -like '*.evt' -or `
                    $_.Name -like '*.log'
            }

            $outputFiles | Move-Item -Destination "$($OutputSaveLocation)" -Confirm:$false -Force
        }

        # Now remove the Jetstress folder

        # If the config file is in the Jetstress directory, remove everything but the config file, or else running Test-TargetResource after removing the directory will fail
        if ((Get-FolderPathWithNoTrailingSlash -Folder "$($JetstressPath)") -like (Get-ParentFolderFromPathString -Folder "$($ConfigFilePath)"))
        {
            Get-ChildItem -LiteralPath "$($JetstressPath)" | Where-Object { $_.FullName -notlike "$($ConfigFilePath)" } | Remove-Item -Recurse -Confirm:$false -Force
        }
        else # No config file in this directory. Remove the whole thing
        {
            Remove-FolderAndContent -Path "$($JetstressPath)"
        }
    }

    # Test if we successfully cleaned up Jetstress. If so, flag or initiate a reboot
    $cleanedUp = Test-TargetResource @PSBoundParameters

    if ($cleanedUp -eq $true)
    {
        Write-Verbose -Message 'Jetstress was successfully cleaned up. A reboot must occur to finish the cleanup.'

        Set-DSCMachineStatus -NewDSCMachineStatus 1
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
        $JetstressPath,

        [Parameter()]
        [System.String]
        $ConfigFilePath,

        [Parameter()]
        [System.String[]]
        $DatabasePaths,

        [Parameter()]
        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [Parameter()]
        [System.String[]]
        $LogPaths,

        [Parameter()]
        [System.String]
        $OutputSaveLocation,

        [Parameter()]
        [System.Boolean]
        $RemoveBinaries
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath' = $JetstressPath
    } -Verbose:$VerbosePreference

    Assert-ParametersValidForJetstress @PSBoundParameters

    $jetstressInstalled = Get-IsJetstressInstalled

    $testResults = $true

    if ($jetstressInstalled)
    {
        Write-Verbose -Message 'Jetstress is still installed'
        $testResults = $false
    }
    else
    {
        # If a config file was specified, pull the database and log paths out and put them into $DatabasePaths and $LogPaths
        if ($PSBoundParameters.ContainsKey('ConfigFilePath'))
        {
            [xml] $configFile = Get-JetstressConfigXmlContent -ConfigFilePath "$($ConfigFilePath)"

            [System.String[]] $FoldersToRemove = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path + $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath
        }
        else
        {
            [System.String[]] $FoldersToRemove = $DatabasePaths + $LogPaths
        }

        # First make sure DB and log folders were cleaned up
        $diskInfo = Get-DiskInfo

        foreach ($folder in $FoldersToRemove)
        {
            # If DeleteAssociatedMountPoints was requested, make sure the parent folder doesn't have a mount point
            if ($DeleteAssociatedMountPoints -eq $true)
            {
                $parent = Get-ParentFolderFromPathString -Folder "$($folder)"

                if ((Get-MountPointVolumeNumber -Path "$($parent)" -DiskInfo $diskInfo) -ge 0)
                {
                    Write-Verbose -Message "Folder '$($parent)' still has a mount point associated with it."
                    $testResults = $false
                }
            }

            # Now check the folder itself
            if ((Test-Path -LiteralPath "$($folder)") -eq $true)
            {
                Write-Verbose -Message "Folder '$($folder)' still exists."
                $testResults = $false
            }
        }

        # Now check for binaries
        if ($RemoveBinaries -eq $true -and (Test-Path -LiteralPath "$($JetstressPath)") -eq $true)
        {
            if ((Get-FolderPathWithNoTrailingSlash -Folder "$($JetstressPath)") -like (Get-ParentFolderFromPathString -Folder "$($ConfigFilePath)"))
            {
                $items = Get-ChildItem -LiteralPath "$($JetstressPath)" | Where-Object { $_.FullName -notlike "$($ConfigFilePath)" }

                if ($null -ne $items -or $items.Count -gt 0)
                {
                    Write-Verbose -Message "Folder '$($JetstressPath)' still exists and contains items that are not the config file."
                    $testResults = $false
                }
            }
            else
            {
                Write-Verbose -Message "Folder '$($JetstressPath)' still exists."
                $testResults = $false
            }
        }
    }

    if ($testResults)
    {
        Write-Verbose -Message 'Jetstress has been successfully cleaned up.'
    }

    return $testResults
}

# Verifies that parameters for Jetstress were passed in correctly. Throws an exception if not.
function Assert-ParametersValidForJetstress
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter()]
        [System.String]
        $ConfigFilePath,

        [Parameter()]
        [System.String[]]
        $DatabasePaths,

        [Parameter()]
        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [Parameter()]
        [System.String[]]
        $LogPaths,

        [Parameter()]
        [System.String]
        $OutputSaveLocation,

        [Parameter()]
        [System.Boolean]
        $RemoveBinaries
    )

    if ($PSBoundParameters.ContainsKey('ConfigFilePath') -eq $false -and `
        ($PSBoundParameters.ContainsKey('DatabasePaths') -eq $false -or `
                $PSBoundParameters.ContainsKey('LogPaths') -eq $false))
    {
        throw 'Either the ConfigFilePath parameter must be specified, or DatabasePaths and LogPaths must be specified.'
    }

    if ($PSBoundParameters.ContainsKey('ConfigFilePath') -eq $true)
    {
        if ([System.String]::IsNullOrEmpty($ConfigFilePath) -or ((Test-Path -LiteralPath "$($ConfigFilePath)") -eq $false))
        {
            throw "The path specified for ConfigFilePath, '$($ConfigFilePath)', is either invalid or inaccessible"
        }
    }
    else
    {
        if ($null -eq $DatabasePaths -or $DatabasePaths.Count -eq 0)
        {
            throw 'No paths were specified in the DatabasePaths parameter'
        }

        if ($null -eq $LogPaths -or $LogPaths.Count -eq 0)
        {
            throw 'No paths were specified in the LogPaths parameter'
        }
    }
}

# Get a string for a folder without the trailing slash
function Get-FolderPathWithNoTrailingSlash
{
    param
    (
        [Parameter()]
        [System.String]
        $Folder
    )

    if ($Folder.EndsWith('\'))
    {
        $Folder = $Folder.Substring(0, $Folder.Length - 1)
    }

    return $Folder
}

# Simple string parsing method to determine a folder's parent
function Get-ParentFolderFromPathString
{
    param
    (
        [Parameter()]
        [System.String]
        $Folder
    )

    $Folder = Get-FolderPathWithNoTrailingSlash -Folder "$($Folder)"

    $parent = $Folder.Substring(0, $Folder.LastIndexOf('\'))

    return $parent
}

# Removes the specified folder, if it exists, and all subdirectories
function Remove-FolderAndContent
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Path
    )

    if ((Test-Path -LiteralPath "$($Path)") -eq $true)
    {
        Write-Verbose -Message "Attempting to remove folder '$($Path)' and all subfolders"
        Remove-Item -LiteralPath "$($Path)" -Recurse -Confirm:$false -Force
    }
    else
    {
        Write-Verbose -Message "Folder '$($Path)' does not exist. Skipping."
    }
}

# Loads the specified JetstressConfig.xml file and puts it into an [xml] variable
function Get-JetstressConfigXmlContent
{
    [CmdletBinding()]
    [OutputType([Xml])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ConfigFilePath
    )

    [xml] $configFile = Get-Content -LiteralPath "$($ConfigFilePath)"

    if ($null -ne $configFile)
    {
        [System.String[]] $DatabasePaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path
        [System.String[]] $LogPaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath

        if ($null -eq $DatabasePaths -or $DatabasePaths.Count -eq 0)
        {
            throw "Failed to read any database paths out of config file '$($ConfigFilePath)'"
        }
        elseif ($null -eq $LogPaths -or $LogPaths.Count -eq 0)
        {
            throw "Failed to read any log paths out of config file '$($ConfigFilePath)'"
        }
    }
    else
    {
        throw "Failed to read config file at '$($ConfigFilePath)'"
    }

    return $configFile
}

# Checks whether Jetstress is installed by looking for Jetstress 2013's Product GUID
function Get-IsJetstressInstalled
{
    return ($null -ne (Get-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{75189587-0D84-4404-8F02-79C39728FA64}' -ErrorAction SilentlyContinue))
}

Export-ModuleMember -Function *-TargetResource
