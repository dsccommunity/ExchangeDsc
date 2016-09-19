function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [System.String]
        $ConfigFilePath,

        [System.String[]]
        $DatabasePaths,

        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [System.String[]]
        $LogPaths,

        [System.String]
        $OutputSaveLocation,

        [System.Boolean]
        $RemoveBinaries
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath} -VerbosePreference $VerbosePreference

    $returnValue = @{
        JetstressPath = $JetstressPath
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [System.String]
        $ConfigFilePath,

        [System.String[]]
        $DatabasePaths,

        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [System.String[]]
        $LogPaths,

        [System.String]
        $OutputSaveLocation,

        [System.Boolean]
        $RemoveBinaries
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeDiskPart.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath} -VerbosePreference $VerbosePreference

    VerifyParameters @PSBoundParameters

    $jetstressInstalled = IsJetstressInstalled

    if ($jetstressInstalled)
    {
        throw "Jetstress must be uninstalled before using the xExchJetstressCleanup resource"
    }

    #If a config file was specified, pull the database and log paths out and put them into $DatabasePaths and $LogPaths
    if ($PSBoundParameters.ContainsKey("ConfigFilePath"))
    {
        [xml]$configFile = LoadConfigXml -ConfigFilePath "$($ConfigFilePath)"

        [string[]]$DatabasePaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path
        [string[]]$LogPaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath
    }

    [string[]]$FoldersToRemove = $DatabasePaths + $LogPaths

    #Now delete the specified directories
    [Hashtable]$ParentFoldersToRemove = @{} #Only used if $DeleteAssociatedMountPoints is $true

    foreach ($path in $FoldersToRemove)
    {
        #Get the parent folder for the specified path
        $parent = GetParentFolderFromString -Folder "$($path)"

        if (([string]::IsNullOrEmpty($parent) -eq $false -and $ParentFoldersToRemove.ContainsKey($parent) -eq $false))
        {
            $ParentFoldersToRemove.Add($parent, $null)
        }

        RemoveFolder -Path "$($path)"
    }

    #Delete associated mount points if requested
    if ($DeleteAssociatedMountPoints -eq $true -and $ParentFoldersToRemove.Count -gt 0)
    {
        GetDiskInfo

        foreach ($parent in $ParentFoldersToRemove.Keys)
        {
            if ($null -eq (Get-ChildItem -LiteralPath "$($parent)" -ErrorAction SilentlyContinue))
            {
                $volNum = MountPointExists -Path "$($parent)"

                if ($volNum -ge 0)
                {
                    StartDiskpart -Commands "select volume $($volNum)","remove mount=`"$($parent)`"" -VerbosePreference $VerbosePreference | Out-Null

                    RemoveFolder -Path "$($parent)"
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

    #Clean up binaries if requested
    if ($RemoveBinaries -eq $true -and (Test-Path -LiteralPath "$($JetstressPath)") -eq $true)
    {
        #Move output files if requested
        if ([string]::IsNullOrEmpty($OutputSaveLocation) -eq $false)
        {
            if ((Test-Path -LiteralPath "$($OutputSaveLocation)") -eq $false)
            {
                mkdir -Path "$($OutputSaveLocation)"
            }

            $outputFiles = Get-ChildItem -LiteralPath "$($JetstressPath)" | `
                where {$_.Name -like "Performance*" -or $_.Name -like "Stress*" -or $_.Name -like "DBChecksum*" -or $_.Name -like "XmlConfig*" -or $_.Name -like "*.evt" -or $_.Name -like "*.log"}

            $outputFiles | Move-Item -Destination "$($OutputSaveLocation)" -Confirm:$false -Force
        }

        #Now remove the Jetstress folder

        #If the config file is in the Jetstress directory, remove everything but the config file, or else running Test-TargetResource after removing the directory will fail
        if ((GetFolderNoTrailingSlash -Folder "$($JetstressPath)") -like (GetParentFolderFromString -Folder "$($ConfigFilePath)"))
        {
            Get-ChildItem -LiteralPath "$($JetstressPath)" | where {$_.FullName -notlike "$($ConfigFilePath)"} | Remove-Item -Recurse -Confirm:$false -Force
        }
        else #No config file in this directory. Remove the whole thing
        {
            RemoveFolder -Path "$($JetstressPath)"
        }  
    }

    #Test if we successfully cleaned up Jetstress. If so, flag or initiate a reboot
    $cleanedUp = Test-TargetResource @PSBoundParameters

    if ($cleanedUp -eq $true)
    {
        Write-Verbose "Jetstress was successfully cleaned up. A reboot must occur to finish the cleanup."

        $global:DSCMachineStatus = 1
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
        $JetstressPath,

        [System.String]
        $ConfigFilePath,

        [System.String[]]
        $DatabasePaths,

        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [System.String[]]
        $LogPaths,

        [System.String]
        $OutputSaveLocation,

        [System.Boolean]
        $RemoveBinaries
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeDiskPart.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath} -VerbosePreference $VerbosePreference

    VerifyParameters @PSBoundParameters
    
    $jetstressInstalled = IsJetstressInstalled

    if ($jetstressInstalled)
    {
        Write-Verbose "Jetstress is still installed"
        return $false
    }
    else
    {
        #If a config file was specified, pull the database and log paths out and put them into $DatabasePaths and $LogPaths
        if ($PSBoundParameters.ContainsKey("ConfigFilePath"))
        {
            [xml]$configFile = LoadConfigXml -ConfigFilePath "$($ConfigFilePath)"

            [string[]]$FoldersToRemove = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path + $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath
        }
        else
        {
            [string[]]$FoldersToRemove = $DatabasePaths + $LogPaths
        }

        #First make sure DB and log folders were cleaned up
        GetDiskInfo

        foreach ($folder in $FoldersToRemove)
        {
            #If DeleteAssociatedMountPoints was requested, make sure the parent folder doesn't have a mount point
            if ($DeleteAssociatedMountPoints -eq $true)
            {
                $parent = GetParentFolderFromString -Folder "$($folder)"

                if ((MountPointExists -Path "$($parent)") -ge 0)
                {
                    Write-Verbose "Folder '$($parent)' still has a mount point associated with it."
                    return $false
                }
            }

            #Now check the folder itself
            if ((Test-Path -LiteralPath "$($folder)") -eq $true)
            {
                Write-Verbose "Folder '$($folder)' still exists."
                return $false
            }
        }

        #Now check for binaries
        if ($RemoveBinaries -eq $true -and (Test-Path -LiteralPath "$($JetstressPath)") -eq $true)
        {
            if ((GetFolderNoTrailingSlash -Folder "$($JetstressPath)") -like (GetParentFolderFromString -Folder "$($ConfigFilePath)"))
            {
                $items = Get-ChildItem -LiteralPath "$($JetstressPath)" | where {$_.FullName -notlike "$($ConfigFilePath)"}

                if ($null -ne $items -or $items.Count -gt 0)
                {
                    Write-Verbose "Folder '$($JetstressPath)' still exists and contains items that are not the config file."
                    return $false
                }
            }
            else
            {
                Write-Verbose "Folder '$($JetstressPath)' still exists."
                return $false
            }  
        }
    }

    Write-Verbose "Jetstress has been successfully cleaned up."

    return $true
}

#Verifies that parameters for Jetstress were passed in correctly. Throws an exception if not.
function VerifyParameters
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [System.String]
        $ConfigFilePath,

        [System.String[]]
        $DatabasePaths,

        [System.Boolean]
        $DeleteAssociatedMountPoints,

        [System.String[]]
        $LogPaths,

        [System.String]
        $OutputSaveLocation,

        [System.Boolean]
        $RemoveBinaries
    )

    if ($PSBoundParameters.ContainsKey("ConfigFilePath") -eq $false -and ($PSBoundParameters.ContainsKey("DatabasePaths") -eq $false -or $PSBoundParameters.ContainsKey("LogPaths") -eq $false))
    {
        throw "Either the ConfigFilePath parameter must be specified, or DatabasePaths and LogPaths must be specified."
    }

    if ($PSBoundParameters.ContainsKey("ConfigFilePath") -eq $true)
    {
        if ([string]::IsNullOrEmpty($ConfigFilePath) -or ((Test-Path -LiteralPath "$($ConfigFilePath)") -eq $false))
        {
            throw "The path specified for ConfigFilePath, '$($ConfigFilePath)', is either invalid or inaccessible"
        }
    }
    else
    {
        if ($null -eq $DatabasePaths -or $DatabasePaths.Count -eq 0)
        {
            throw "No paths were specified in the DatabasePaths parameter"
        }

        if ($null -eq $LogPaths -or $LogPaths.Count -eq 0)
        {
            throw "No paths were specified in the LogPaths parameter"
        }
    }
}

#Get a string for a folder without the trailing slash
function GetFolderNoTrailingSlash
{
    param([string]$Folder)

    if ($Folder.EndsWith('\'))
    {
        $Folder = $Folder.Substring(0, $Folder.Length - 1)
    }

    return $Folder
}

#Simple string parsing method to determine what the parent folder of a folder is given the child folder's path
function GetParentFolderFromString
{
    param([string]$Folder)

    $Folder = GetFolderNoTrailingSlash -Folder "$($Folder)"

    $parent = $Folder.Substring(0, $Folder.LastIndexOf('\'))

    return $parent
}

#Removes the specified folder, if it exists, and all subdirectories
function RemoveFolder
{
    [CmdletBinding()]
    param([string]$Path)

    if ((Test-Path -LiteralPath "$($Path)") -eq $true)
    {
        Write-Verbose "Attempting to remove folder '$($Path)' and all subfolders"
        Remove-Item -LiteralPath "$($Path)" -Recurse -Confirm:$false -Force
    }
    else
    {
        Write-Verbose "Folder '$($Path)' does not exist. Skipping."
    }
}

#Loads the specified JetstressConfig.xml file and puts it into an [xml] variable
function LoadConfigXml
{
    [CmdletBinding()]
    [OutputType([Xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $ConfigFilePath
    )

    [xml]$configFile = Get-Content -LiteralPath "$($ConfigFilePath)"

    if ($null -ne $configFile)
    {
        [string[]]$DatabasePaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.DatabasePaths.Path
        [string[]]$LogPaths = $configFile.configuration.ExchangeProfile.EseInstances.EseInstance.LogPath

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

#Checks whether Jetstress is installed by looking for Jetstress 2013's Product GUID
function IsJetstressInstalled
{
    return ($null -ne (Get-WmiObject -Class Win32_Product -Filter "IdentifyingNumber = '{75189587-0D84-4404-8F02-79C39728FA64}'"))
}


Export-ModuleMember -Function *-TargetResource



