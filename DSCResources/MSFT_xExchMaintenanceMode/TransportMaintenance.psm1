#region Globals from all three scripts
# Service Names
$TransportServiceName    = "MsExchangeTransport"
$MessageTracing          = "MSMessageTracingClient"
$EdgeSync                = "MsExchangeEdgeSync"
$Script:OriginalPref     = $ErrorActionPreference

$Script:ExchangeServer   = $null
$Script:TransportService = $null
$Script:HubTransport     = $null
$Script:Entered          = $false

$Component = "HubTransport"
$Requester = "Maintenance"

$Target = $env:COMPUTERNAME

$Script:LogFileName = $null
$Script:TransportMaintenanceLogPrefix = 'TransportMaintenance'
$Script:TransportMaintenanceLogNameFormat = "{0}\TransportMaintenance-{1}-{2}.log"
$Script:ServerInMM = "ServerInMM"
$Script:AllotedTimeExceeded = "AllotedTimeExceeded"
$Script:NoProgressTimeout = "NoProgressTimeout"
$Script:UnredirectedMessageEventId = 100
$Script:UndrainedDiscardEventEventId = 101
$Script:MaxWaitForOtherWorkflow = New-TimeSpan -Minutes 30
$Script:TransportMaintenanceSync = $null
$Script:ExchangeVersion = ""

$ServiceState = $null
#endregion

#region New Code or Wrappers
<#
.DESCRIPTION
Begin maintenance script for HUB components.

.PARAMETER Target
The name of the machine being put into maintenance.

#>
function Start-TransportMaintenance
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Target = $env:COMPUTERNAME,

        [switch]$ExcludeLocalSiteFromMessageRedirect,

        [boolean]$LoadLocalShell = $false,
        
        [string[]]$MessageRedirectExclusions
    )

    if ($LoadLocalShell -eq $true)
    {
        AddExchangeSnapinIfRequired
    }

    $Script:LogInfo = @{
        Target = $Target
    }

    try
    {
        Write-Verbose "Starting non-fatal Transport maintenance tasks for '$Target' on $($env:ComputerName)" 
        if(-not (Init-TransportMaintenance -Target $Target))
        {
            return
        }

        # Log the BeginTM/start event
        $beginTMLog = Create-LogEntry -Source $Target -Stage BeginTM
        Log-EventOfEntry -Event Start -Entry $beginTMLog -Reason $Script:LogInfo

        Perform-RemoteMaintenance -Target $Target -MessageRedirectExclusions $MessageRedirectExclusions -ExcludeLocalSiteFromMessageRedirect:$ExcludeLocalSiteFromMessageRedirect

    }
    catch
    {
        Write-Warning "At least one non-fatal tasked failed. Ignoring and continuing deployment. Error was $_"
    }
    finally
    {
        if($beginTMLog)
        {
            Log-EventOfEntry -Event Completed -Entry $beginTMLog -Reason $Script:LogInfo
        }
    }
}

<#
.DESCRIPTION
Performs End Maintenance of HubTransport

#>
function Stop-TransportMaintenance
{
    [CmdletBinding()]
    param(
        [boolean]$LoadLocalShell = $false
    )

    if ($LoadLocalShell -eq $true)
    {
        AddExchangeSnapinIfRequired
    }

    $ServiceState = "Online"

    Main-HUBEndMaintenance
}

function AddExchangeSnapinIfRequired
{
    if ($null -eq (Get-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue
    }
}
#endregion

#region From TransportBeginMaintenance.ps1
# .DESCRIPTION
#   Initializes logging, validates if the current server
#
# .PARAMETER Target
#   Target server for the operation.
#
# .RETURN
#   True if the initialization is successful and caller should continue the MM process. 
#   Else, returns false and caller should NOT continue with the MM.
function Init-TransportMaintenance
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
        )
        
    $ErrorActionPreference = "Stop"
    $Error.Clear()
        
    Initialize-TransportMaintenanceLog -Server $Target
    
    $Script:ExchangeServer = Get-ExchangeServer $Target
    if(-not $Script:ExchangeServer)
    {
        Write-Verbose "$Target is not an exchange server"
    
        $Script:LogInfo.Add('ExchangeServer', 'False')
        Log-SkippedEvent -Source $Target -Stage BeginTM -Reason $Script:LogInfo
        
        return $false
    }
    
    $Script:TransportService = Get-Service `
        -ComputerName $Script:ExchangeServer.Fqdn `
        -Name $TransportServiceName `
        -ErrorAction SilentlyContinue
    
    if(-not $Script:TransportService)
    {
        Write-Verbose "MSExchangeTransport service is not found on $Target"
        
        $Script:LogInfo.Add($TransportServiceName, 'NotFound')
        Log-SkippedEvent -Source $Target -Stage BeginTM -Reason $Script:LogInfo
        
        return $false
    }
    
    $Script:HubTransport = Get-ComponentState -Server $Target
    if(-not $Script:HubTransport)
    {
        Write-Verbose "Unable to find HubTransport's ServerComponentState from $($env:ComputerName) for $Target."
        
        $Script:LogInfo.Add('HubTransport', 'NotFound')
        Log-SkippedEvent -Source $Target -Stage BeginTM -Reason $Script:LogInfo
        
        return $false
    }
    
    $Script:Entered = $true
    return $true
}

# .DESCRIPTION
#   Fully drains the Transport and put HubTransport component state to Inactive
#
# .PARAMETER Target
#   Target server for the operation.
#
# .RETURN
#   None
function Perform-FullyDrainTransport
{
    param(
        [Parameter(Mandatory = $false)]
        [string]$Target = $env:COMPUTERNAME,

        [switch]$ExcludeLocalSiteFromMessageRedirect,
        
        [string[]]$MessageRedirectExclusions)

    #drain active messages
    Drain-ActiveMessages -Server $Target -TransportService $script:TransportService
    
    # redirect the remaining messages
    $activeServers = Redirect-Messages -Server $Target -MessageRedirectExclusions $MessageRedirectExclusions -ExcludeLocalSite:$ExcludeLocalSiteFromMessageRedirect

    # Drain the discard events
    if($activeServers)
    {
        Drain-DiscardEvents -Primary $Target -ShadowServers $activeServers | out-null
    }
    else
    {
        Write-Verbose "Unable to find other active servers in this DAG. Skip draining of discard event."
    }
    
    Write-Verbose "Setting HubTransport component state to Inactive"
    Set-ComponentState -Server $Target -State Inactive
    Log-InfoEvent -Source $Target -Stage RestartTransport -Reason  @{ComponentState = 'Inactive'}
}

# .DESCRIPTION
#   Perform the Remote Maintenance stage
#
# .PARAMETER Target
#   Target server for the operation.
#
function Perform-RemoteMaintenance
{
    param(
        [Parameter(Mandatory = $false)]
        [string]$Target = $env:COMPUTERNAME,

        [switch]$ExcludeLocalSiteFromMessageRedirect,
        
        [string[]]$MessageRedirectExclusions
    )

    if(($Script:TransportService.Status -ne "Running") -or `
        ($Script:HubTransport.State -ne "Active"))
    {
        $Script:LogInfo.Add('MsExchangeTransport', $Script:TransportService.Status)
        $Script:LogInfo.Add('HubTransport', $Script:HubTransport.State)
        $Script:LogInfo.Add('Reason', 'Skipped')
    }
    else
    {
        Perform-FullyDrainTransport -Target $Target -MessageRedirectExclusions $MessageRedirectExclusions -ExcludeLocalSiteFromMessageRedirect:$ExcludeLocalSiteFromMessageRedirect
    }
}


#endregion

#region From TransportEndMaintenance.ps1
# Main entry point for the script.
function Main-HUBEndMaintenance
{
    $reasons = @{
        ServiceState = $ServiceState
        }
    try
    {
        Initialize-TransportMaintenanceLog -Server $Target
        
        $TransportService = get-service $TransportServiceName -errorAction silentlyContinue
        if(-not $TransportService)
        {
            Write-Verbose 'MSExchangeTransport service is not found'
            
            $reasons.Add('MsExchangeTransport', 'NotFound')
            Log-SkippedEvent -Source $Target -Stage EndTM -Reason $reasons
            return;
        }   

        $endMMLog = Create-LogEntry -Source $Target -Stage EndTM

        Log-EventOfEntry -Event Start -Entry $endMMLog -Reason $reasons
            
        if($ServiceState -eq "Online")
        {        
            Set-TransportActive
            return
        }
        
        # All other parameter combinations indicate 'Inactive' state.
        Set-TransportInactive
    }
    finally
    {
        if($endMMLog)
        {
            Log-EventOfEntry -Event Completed -Entry $endMMLog -Reason $reasons
        }
    }
}

# checks and enable the submission queue if needed.  This should be successful in
# the first iteration. However, we allow the service to have up to 5 minutes to return
# the submission queue.
function Enable-SubmissionQueue
{
    param(
        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),
        
        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5)
    )
    
    $endTime = (Get-Date) + $Timeout
    $submissionQName = $env:COMPUTERNAME + "\Submission"
    
    while ($true)
    {
        $submissionQ = Get-Queue $submissionQName -ErrorAction 'SilentlyContinue'
        if ($submissionQ)
        {
            if($submissionQ.Status -eq 'Suspended')
            {
                try
                {
                    Resume-Queue $submissionQName -confirm:$false
                    Log-InfoEvent -source $env:COMPUTERNAME -stage SubmissionQueueCheck -Reason @{EnableSubmissionQueue = 'Succeeded'}
                    return $true
                }
                catch
                {
                    Log-InfoEvent -source $env:COMPUTERNAME -stage SubmissionQueueCheck -Reason @{EnableSubmissionQueue = 'Failed'}
                    return $false
                }
            }
            
            Log-SkippedEvent -source $env:COMPUTERNAME -stage SubmissionQueueCheck -Reason @{EnableSubmissionQueue = $submissionQ.Status}
            return $true
        }
        
        if ((Get-Date) -gt $endTime)
        {
            Log-InfoEvent -source $env:COMPUTERNAME -stage SubmissionQueueCheck -Reason @{EnableSubmissionQueue = 'QueueNotFound'}
            return $false
        }
        else
        {
            Sleep -Seconds $PollingFrequency.Seconds
        }
    }
}

# Sets the Transport Component State to 'Active' and starts the appropriate services.
function Set-TransportActive
{
    Write-Output "Enter [Set-TransportActive]"
    
    $currentServerComponentState = Get-ServerComponentState -Identity $env:COMPUTERNAME -Component $Component
    $transportService = Get-WmiObject win32_service -filter "name = 'MSExchangeTransport'"

    if($currentServerComponentState.State -eq "Active" `
         -and $null -ne $transportService `
         -and $transportService.StartMode -eq "Auto" `
         -and $transportService.State -eq "Running")
    {
        Log-SkippedEvent -Source $env:COMPUTERNAME -Stage StartTransport -Reason @{ComponentState = 'Active'}
    }
    else
    {
        # Set component state to 'Active'
        Set-ComponentState -Component $Component -State "Active" -Requester $Requester | out-null 
        
        # Restart transport
        Set-ServiceState -ServiceName $TransportServiceName -State "Stopped" -LoggingStage StopTransport -StartMode "Auto" -ThrowOnFailure
        Set-ServiceState -ServiceName $TransportServiceName -State "Running" -LoggingStage StartTransport -ThrowOnFailure
    }

    # Enable the submission queue if needed. In case of failure, we will have to put
    # the service back to inactive
    if (-not (Enable-SubmissionQueue))
    {
        Set-TransportInactive
        return
    }
    
    # Set MSExchangeEdgeSync service start mode to Auto and restart.
    Set-ServiceState -ServiceName $EdgeSync -State "Stopped" -LoggingStage StopEdgeSync -StartMode "Auto"
    Set-ServiceState -ServiceName $EdgeSync -State "Running" -LoggingStage StartEdgeSync
    
    # Do not change the start mode for MSMessageTracingClient
    # MSMessageTracingClient service is disabled in some test topologies
    # so only start the service, if it is NOT Disabled.
    Set-ServiceState -ServiceName $MessageTracing -State "Running" -LoggingStage StartMessageTrace

    Write-Output "Exit [Set-TransportActive]"
}

# Sets the Transport Component State to 'Inactive' and starts the appropriate services.
function Set-TransportInactive
{
    Write-Output "Enter [Set-TransportInactive]"

    $currentServerComponentState = Get-ServerComponentState -Identity $env:COMPUTERNAME -Component $Component
    $transportService = Get-WmiObject win32_service -filter "name = 'MSExchangeTransport'"

    if($currentServerComponentState.State -eq "Inactive" `
        -and $null -ne $transportService `
        -and $transportService.StartMode -eq "Auto" `
        -and $transportService.State -eq "Running")
    {
        Log-SkippedEvent -Source $env:COMPUTERNAME -Stage StartTransport -Reason @{ComponentState = 'Inactive'}
    }
    else
    {  
       # Set component state to 'Inactive'
       Set-ComponentState -Component $Component -State "Inactive" -Requester $Requester | out-null
       Set-ServiceState -ServiceName $TransportServiceName -State "Running" -LoggingStage StopTransport -StartMode "Auto" -ThrowOnFailure
    }
    
    Write-Output "Exit [Set-TransportInactive]"
}
#endregion

#region From DatacenterDeploymentTransportLibrary.ps1

# .DESCRIPTION
#  Get servers in the dag that contains the specified server
#
# .PARAMETER server
#  Server whose dag's members is retrieving.
#
# .PARAMETER ExcludeLocalSite
#  Whether to exclude the servers on the same site
#
# .RETURN
# array of servers in the dag.
#
function Get-ServersInDag
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$server,

        [Parameter(Mandatory = $true)]
        [Switch]$ExcludeLocalSite,
        
        [string[]]$AdditionalExclusions
        )

    Write-Verbose "$server - Retrieving the DAG for the target server"
    $exchangeServer = (Get-ExchangeServer $server)
    if ($null -eq $exchangeServer)
    {
        Write-Warning "Could not get the exchange server. Skipping redirect."
        return $null
    }

    if ($exchangeServer.IsMailboxServer -eq $false)
    {
        Write-Warning "Could not find the mailbox server. Skipping redirect."
        return $null
    }

    $dag = (Get-MailboxServer $server).DatabaseAvailabilityGroup
    if ($null -eq $dag)
    {
        Write-Warning "Could not find the DAG for the target server. Skipping redirect."
        return $null
    }
    
    Write-Verbose "$server - Retrieving other hub transport servers in the DAG - $dag"

    $dagServers = @((Get-DatabaseAvailabilityGroup $dag).Servers | %{if($_.Name){$_.Name}else{$_}} | ?{$_ -ne $server})

    if($null -ne $dagServers)
    {
        #Filter out servers who are in the local site, if $ExcludeLocalSite
        if ($ExcludeLocalSite)
        {
            for ($i = $dagServers.Count - 1; $i -ge 0; $i--)
            {
                $dagServerProps = $null
                $dagServerProps = Get-ExchangeServer $dagServers[$i]

                if ($null -ne $dagServerProps -and $dagServerProps.Site -eq $exchangeServer.Site)
                {
                    $dagServers = $dagServers | where {$_ -ne $dagServers[$i]}
                }
            }
        }

        #Filter out additional exclusions
        if ($null -ne $AdditionalExclusions)
        {
            foreach ($exclusion in $AdditionalExclusions)
            {
                $dagServers = $dagServers | where {$_ -notlike $exclusion}
            }
        }
    }

    if (-not $dagServers)
    {
        Write-Warning "Could not find servers in the DAG that do not meeting exclusion criteria."
    }

    return $dagServers
}

# .DESCRIPTION
#   Selects the active servers from the specified array of servers.
#   Active servers are those that have EdgeTransport running.
#
# .PARAMETER $Servers
#   Array of servers
#
# .RETURN
#   Array of active servers
function Get-ActiveServers
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Servers
        )

    $activeServers = $Servers | `
        ?{(Get-ServerComponentState -Identity $_ -Component HubTransport).State -eq 'Active' } | `
        %{ `
            $xml = [xml](Get-ExchangeDiagnosticInfo -Process "EdgeTransport" -server $_ -erroraction SilentlyContinue)
            if($xml -and $xml.Diagnostics.ProcessInfo)
            {
                Write-Output $_
            }
        }

    return $activeServers
}

# .DESCRIPTION
#  Get version for exchange installed on the server
#
# .PARAMETER server
#  Server whose version is being retrieved.
#
# .RETURN
# version string.
#
function Get-ExchangeVersion
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$server
        )

    Write-Verbose "$server - Retrieving version for the target server"

    $serverVersion = (Get-ExchangeServer $server).AdminDisplayVersion

    if ($null -eq $serverVersion)
    {
        Write-Warning "Could not find exchange version."
        return $null
    }

    $versionString = [string]::Format("{0}.{1}.{2}.{3}", `
                                     $serverVersion.Major.ToString("D2"), `
                                     $serverVersion.Minor.ToString("D2"), `
                                     $serverVersion.Build.ToString("D4"), `
                                     $serverVersion.Revision.ToString("D3"))
    return $versionString
}

# .DESCRIPTION
#   Get the list of files that are in the Maintenance Log folder
#
# .PARAMETER $TransportService
#   Transport Service object retrieved from Get-TransportService of the current server
#   This object holds configuration and size limits of the Maintenance Log folder
#
# .PARAMETER $LogPath
#   The path to the log folder adjusted for remote logging.
#
# .RETURN
#  Array of file objects of files that are in the Maintenance Log folder
function Get-TransportMaintenanceLogFiles()
{
    param(
        [Parameter(Mandatory = $true)]
        [Object] $TransportService,

        [Parameter(Mandatory = $true)]
        [string] $LogPath
    )

    $logFilesMatch = "{0}\{1}*.log" -f $LogPath, $Script:TransportMaintenanceLogPrefix
    return @(Get-Item $logFilesMatch -ErrorAction SilentlyContinue)
}

# .DESCRIPTION
#   Ensures the current Maintenance log file stay within the limit specified in the TransportService object.
#   Creates and initializes the log file to be ready for accepting logs.
#
# .PARAMETER $LogPath
#   The path to the log folder adjusted for remote logging.
#
# .PARAMETER $TransportService
#   Transport Service object retrieved from Get-TransportService of the current server
#   This object holds configuration and size limits of the Maintenance Log folder
function Configure-TransportMaintenanceLog
{
    param(
        [Parameter(Mandatory = $true)]
        [Object] $TransportService,

        [Parameter(Mandatory = $true)]
        [string] $LogPath
    )

    $maxFileSize = $TransportService.TransportMaintenanceLogMaxFileSize.Value.ToBytes()

    if($Script:LogFileName -and $Script:LogStream)
    {
        if((Get-Item $Script:LogFileName).Length -lt $maxFileSize)
        {
            return
        }
        else
        {
            $Script:LogFileName = $null
            $newestLog = $null
        }
    }
    else
    {
        $newestLog = Get-TransportMaintenanceLogFiles -TransportService $TransportService -LogPath $LogPath | `
                        sort LastWriteTime -Descending | `
                        Select -First 1
    }

    if(-not $newestLog -or $newestLog.Length -ge $maxFileSize)
    {
        $instance = 0
        while($true)
        {
            $newLogFileName = $Script:TransportMaintenanceLogNameFormat -f `
                                $LogPath, `
                                [System.DateTime]::Now.ToString("yyyyMMdd"), $instance

            $existedLogFile = Get-Item -Path $newLogFileName -ErrorAction SilentlyContinue
            if(-not $existedLogFile)
            {
                break;
            }
            $instance++
        }
    }
    else
    {
        $newLogFileName = $newestLog.FullName
    }

    $Script:LogFileName = $newLogFileName
}

# .DESCRIPTION
#   Removes old log files from the Maintenance Log directory to stay within the age limit specified
#   in the TransportService object
#
# .PARAMETER $LogPath
#   The path to the log folder adjusted for remote logging.
#
# .PARAMETER $TransportService
#   Transport Service object retrieved from Get-TransportService of the current server
#   This object holds configuration and size limits of the Maintenance Log folder
function Enforce-TransportMaintenanceLogMaxAge
{
    param(
        [Parameter(Mandatory = $true)]
        [Object] $TransportService,

        [Parameter(Mandatory = $true)]
        [string] $LogPath
    )

    $maxLogAge = [TimeSpan]$TransportService.TransportMaintenanceLogMaxAge
    [DateTime]$rolloutTime = (Get-Date) - $maxLogAge

    Get-TransportMaintenanceLogFiles -TransportService $TransportService -LogPath $LogPath | `
        ? {$_.LastWriteTime -lt $rolloutTime} | `
        % {Remove-Item -Path $_.FullName}
}

# .DESCRIPTION
#   Removes old log files from the Maintenance Log directory to stay within total size limit specified
#   in the TransportService object
#
# .PARAMETER $LogPath
#   The path to the log folder adjusted for remote logging.
#
# .PARAMETER $TransportService
#   Transport Service object retrieved from Get-TransportService of the current server
#   This object holds configuration and size limits of the Maintenance Log folder
function Enforce-TransportMaintenanceLogMaxDirectorySize
{
    param(
        [Parameter(Mandatory = $true)]
        [Object] $TransportService,

        [Parameter(Mandatory = $true)]
        [string] $LogPath
    )

    $maxDirectorySize = $TransportService.TransportMaintenanceLogMaxDirectorySize.Value.ToBytes()
    $maxFileSize = $TransportService.TransportMaintenanceLogMaxFileSize.Value.ToBytes()

    $files = Get-TransportMaintenanceLogFiles -TransportService $TransportService -LogPath $LogPath | Sort LastWriteTime
    $directorySize = $files | Measure-Object Length -Sum | %{ $_.Sum }

    $i = 0
    $desiredSize = $maxDirectorySize - $maxFileSize
    while ($directorySize -ge $desiredSize)
    {
        try
        {
            if($files[$i].FullName -ne $Script:LogFileName)
            {
                $directorySize -= $files[$i].Length
                Remove-Item -Path $files[$i].FullName
                $i++
            }
        }
        catch
        {
            continue
        }
    }
}

# .DESCRIPTION
#   Get the adjusted logging path for remote or local logging.
#
# .PARAMETER $TransportService
#   Transport Service object retrieved from Get-TransportService of the current server
#   This object holds configuration and size limits of the Maintenance Log folder
#
# .PARAMETER $Server
#   Server name of the log folder
#
# .RETURN
#   The path to the log folder adjusted for remote or local logging depending on the specified $Server.
function Get-MaintenanceLogPath
{
    param(
        [Parameter(Mandatory = $true)]
        [Object] $TransportService,

        [Parameter(Mandatory = $false)]
        [String] $Server = $env:ComputerName
    )
    
    if(-not $TransportService.TransportMaintenanceLogPath)
    {
        $logPath = Join-Path (Split-Path ($TransportService.QueueLogPath) -Parent) "TransportMaintenance"
    }
    else
    {
        $logPath = $TransportService.TransportMaintenanceLogPath.PathName
    }
    
    if($server -eq $env:ComputerName)
    {
        return $logPath
    }

    $drive = [IO.Path]::GetPathRoot($logPath)
    $share = Get-WmiObject -Class Win32_Share -ComputerName $server -Filter "Path = '$drive\'" -ErrorAction SilentlyContinue
    if($share)
    {
        $remotePath = "\\{0}\{1}\{2}" -f `
            $server, `
            $share.Name, `
            $logPath.SubString($drive.Length)
        return $remotePath
    }
    else
    {
        return $logPath
    }
}

# .DESCRIPTION
#   Initializes the Maintenance Log and ensures the log directory conforms with limits
#   set in Transport Service.  This function must be called by Begin/End MM script before
#   performing any MM tasks to ensure log file is created properly.
#
# .PARAMETER Server
#   Name of Server to write the maintenance log to
function Initialize-TransportMaintenanceLog()
{
    param(
        [Parameter(Mandatory = $false)]
        [String] $Server = $env:ComputerName
    )

    #read MM log limits
    $transportService = Get-TransportService -Identity $Server

    # only configure the logging if we have the setting from Transport Service
    $hasMaintenanceSettings = $transportService.PsObject.Properties.Match('TransportMaintenance*')
    if($hasMaintenanceSettings.Count -gt 0)
    {
        if(-not $transportService.TransportMaintenanceLogEnabled)
        {
            $Script:LogFileName = $null
            return
        }

        $logPath = Get-MaintenanceLogPath -Server $Server -TransportService $transportService

        if(Test-Path $logPath)
        {
            Enforce-TransportMaintenanceLogMaxAge -TransportService $transportService -LogPath $logPath
            Enforce-TransportMaintenanceLogMaxDirectorySize -TransportService $transportService -LogPath $logPath
        }
        else
        {
            try
            {
                New-Item $logPath -Item Directory -ErrorAction Stop | Out-Null
            }
            catch
            {
                Write-Verbose $_.Exception.Message
                $Script:LogFileName = $null
                return
            }
        }

        $Script:ExchangeVersion = Get-ExchangeVersion $Server
        Configure-TransportMaintenanceLog -TransportService $transportService -LogPath $logPath
    }
}

# .DESCRIPTION
#  Change the running state of a service
#
# .PARAMETER $ServiceName
#  Name of the service to change the state of
#
# .PARAMETER $Server
#  Server where the service is running on
#
# .PARAMETER $State
#  New state of the service, can be Stopped, Running, Paused, or NoChange
#
# .PARAMETER $StartMode
#  Change the startMode if necessary before changing its running state
#
# .PARAMETER $WaitTime
#  Maximum wait time for the service to change its state
#
# .PARAMETER $LoggingStage
#  If provide, a log entry is added to MM log on start and complete of the state change
#
# .PARAMETER $ThrowOnFailure
#  Whether to throw on failures
#
# .RETURN 
#  True if successful, false otherwise.
function Set-ServiceState
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [ValidateSet("NoChange", "Stopped", "Running", "Paused")]
        [string]$State = "NoChange",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("NoChange", "Auto", "Automatic", "Manual", "Disabled")]
        [string]$StartMode = "NoChange",
        
        [Parameter(Mandatory = $false)]
        [TimeSpan] $WaitTime = (New-TimeSpan -Minutes 5),
        
        [Parameter(Mandatory = $false)]
        [string] $LoggingStage,
        
        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnFailure
    )
    
    $service = Get-WmiObject win32_service -filter "name = '$ServiceName'" -ComputerName $Server
    
    if(-not $service)
    {
        if($LoggingStage)
        {
            Log-SkippedEvent -Source $Server -Stage $LoggingStage -Reason @{$ServiceName = 'NotFound'}
        }
        
        if($ThrowOnFailure)
        {
            throw "Service $ServiceName not found on $Server."
        }
        return
    }
    
    # Check and change the StartMode if necessary
    if($StartMode -eq "Auto")
    {
        $StartMode = "Automatic"
    }
    
    if(($StartMode -ne "NoChange") -and ($service.StartMode -ne $StartMode))
    {
        $service.ChangeStartMode($StartMode) | Out-Null
        
        if($StartMode -eq "Disabled")
        {
            $State = "Stopped"
        }
    }
    
    # Determine if the start/stop/restart action is needed
    if($State -eq "NoChange" -or $service.State -eq $State)
    {
        return
    }
    
    if($LoggingStage)
    {
        $logEntry = Create-LogEntry -Source $Server -Stage $LoggingStage
        Log-EventOfEntry -Event Start -Entry $logEntry
    }
    
    switch($State)
    {
        "Stopped" 
        {   
            $service.StopService() | Out-Null
        }
        
        "Running" 
        {
            if($service.State -eq "Paused")
            {
                $service.ResumeService() | Out-Null
            }
            else
            {
                $service.StartService()| Out-Null
            }
        }
        
        "Paused"
        {
            if($service.State -eq "Running")
            {
                $service.PauseService() | Out-Null
            }
            else
            {
                # service is stopped, start it up first
                $service.StartService() | Out-Null
                
                if($WaitTime -eq [TimeSpan]::Zero)
                {
                    $startupWaitTime = New-TimeSpan -Minutes 5
                }
                else
                {
                    $startupWaitTime = $WaitTime
                }
                
                Wait-ServiceState `
                    -ServiceName $ServiceName `
                    -Server $Server `
                    -State "Running" `
                    -WaitTime $startupWaitTime `
                    -ThrowOnFailure:$ThrowOnFailure
                
                # pause now
                $service.PauseService() | Out-Null
            }
        }
    }
    
    if($WaitTime -gt [TimeSpan]::Zero)
    {
        Wait-ServiceState `
            -ServiceName $ServiceName `
            -Server $Server `
            -State $State `
            -WaitTime $WaitTime `
            -ThrowOnFailure:$ThrowOnFailure
    }
    
    if($LoggingStage)
    {
        Log-EventOfEntry -Event Completed -Entry $logEntry -reason @{'MaxWaitMinutes' = $WaitTime.TotalMinutes}
    }
}

# .DESCRIPTION
#   Create a log entry object to be used in logging with various events and reasons
#
# .PARAMETER Source
#   Name of the computer that originates this logging
#
# .PARAMETER Stage
#   Logging stage
#
# .PARAMETER Id
#   Id of this log entry
#
# .PARAMETER Count
#   Value for the count column, meaning of this count varies with id and stage
#
# .RETURN
#   Log Entry object which can be use Log-EventOfEntry & Log-SkippedEvent
function Create-LogEntry
{
    param(
        [Parameter(Mandatory = $true)]
        [String] $Source,

        [Parameter(Mandatory = $true)]
        [string] $Stage,

        [Parameter(Mandatory = $false)]
        [string] $Id,

        [Parameter(Mandatory = $false)]
        [int] $Count = -1
    )

    $logProps = @{
        Source = $Source
        Stage = $Stage
        Id = $Id
        Count = $Count
        Created = Get-Date
    }

    return New-Object PsObject -Property $logProps
}

# .DESCRIPTION
#   Add a log entry of certain event to the current log file
#
# .PARAMETER Event
#   Event to be logged. For Completed event, the duration is automatically
#   computed from the time LogEntry was created
#
# .PARAMETER Entry
#   Log Entry, created by Create-LogEntry
#
# .PARAMETER Reason
#   Reason of this event
function Log-EventOfEntry
{
    param(
        [Parameter(Mandatory = $true)]
        [string] $Event,

        [Parameter(Mandatory = $true)]
        [Object] $Entry,

        [Parameter(Mandatory = $false)]
        [hashtable] $Reason
    )

    if($Event -eq "Completed")
    {
        $duration = (Get-Date) - $Entry.Created
    }

    if($Reason)
    {
        $Reason.GetEnumerator() |  `
            sort Key | % {
                if($ReasonStr)
                {
                    $ReasonStr += '; '
                }

                $ReasonStr += "{0}={1}" -f $_.Name,$_.Value
            }
    }

    $msg = [string]::Format("{0},{1},{2},{3},{4},{5:g},{6},{7},{8}", `
                        (Get-Date), `
                        $Entry.Source, `
                        $Entry.Stage, `
                        $Event, `
                        $Entry.Id, `
                        $duration, `
                        $(if($Entry.Count -ne -1){$Entry.Count} else {""}), `
                        $ReasonStr, `
                        $Script:ExchangeVersion)

    Write-Verbose $msg
    
    if(-not $Script:LogFileName)
    {
        return
    }

    $maxTries = 3
    while($maxTries -gt 0)
    {
        try
        {
            Add-Content -Path $Script:LogFileName -Value $msg -ErrorAction Stop
            return
        }
        catch [IO.DriveNotFoundException]
        {
            # we stop logging if log causes exception
            $Script:LogFileName = $null
            Write-Verbose $_.Exception.Message
            return
        }
        catch
        {
            # we may have other MM workflow accessing the log file
            # delay 1 sec and try again
            sleep 1
            $maxTries--
        }
    }
}

# .DESCRIPTION
#   Log a Skipped event to the current log file
#
# .PARAMETER Source
#   Name of the computer that originates this logging
#
# .PARAMETER Stage
#   Logging stage
#
# .PARAMETER Id
#   Id of this log entry
#
# .PARAMETER Count
#   Value for the count column, meaning of this count varies with id and stage
#
# .PARAMETER Reason
#   Reason of this event

function Log-SkippedEvent
{
    param(
        [Parameter(Mandatory = $true)]
        [String] $Source,

        [Parameter(Mandatory = $true)]
        [string] $Stage,

        [Parameter(Mandatory = $false)]
        [string] $Id,

        [Parameter(Mandatory = $false)]
        [int] $Count,

        [Parameter(Mandatory = $false)]
        [hashtable] $Reason
    )

    $entry = Create-LogEntry -Source $Source -Stage $Stage -Id $Id -Count $Count
    Log-EventOfEntry -Event Skipped -Entry $entry -Reason $Reason
}

# .DESCRIPTION
#   Log an Info event to the current log file
#
# .PARAMETER Source
#   Name of the computer that originates this logging
#
# .PARAMETER Stage
#   Logging stage
#
# .PARAMETER Id
#   Id of this log entry
#
# .PARAMETER Count
#   Value for the count column, meaning of this count varies with id and stage
#
# .PARAMETER Reason
#   Reason of this event

function Log-InfoEvent
{
    param(
        [Parameter(Mandatory = $true)]
        [String] $Source,

        [Parameter(Mandatory = $true)]
        [string] $Stage,

        [Parameter(Mandatory = $false)]
        [string] $Id,

        [Parameter(Mandatory = $false)]
        [int] $Count,

        [Parameter(Mandatory = $false)]
        [hashtable] $Reason
    )

    $entry = Create-LogEntry -Source $Source -Stage $Stage -Id $Id -Count $Count
    Log-EventOfEntry -Event Info -Entry $entry -Reason $Reason
}

# .DESCRIPTION
#   Used by Wait-EmptyEntries.
#   Takes a hash table by the entry's id. Remove any entry that's not found in ActiveEntries.
#
# .PARAMETER ActiveEntries
#   Array of active entries
#
# .PARAMETER DetailLogging
#   Whether to log progress of each entry.
#
# .PARAMETER Tracker
#   Tracking hash table to be updated
#
# .RETURN
#  returns True if at least an entry removed. Otherwise returns False.
function Remove-CompletedEntries
{
    param (
        [Parameter(Mandatory = $true)]
        [HashTable] $Tracker,

        [Parameter(Mandatory = $false)]
        [Object[]] $ActiveEntries = @(),

        [Parameter(Mandatory = $false)]
        [Switch] $DetailLogging = $true
    )

    $progressMade = $false

    $activeIds = $ActiveEntries | %{$_.Id}
    $completedKeys = $tracker.Keys | ? {$activeIds -notcontains $_}
    $completedKeys | %{
        # update entry
        $entry = $Tracker[$_]
        $entry.LogEntry.Count = 0

        if($DetailLogging)
        {
            Log-EventOfEntry -Event Completed -Entry $entry.LogEntry
        }

        # remove completed entry from tracking
        $Tracker.Remove($_)
        $progressMade = $true
    }

    return $progressMade
}

# .DESCRIPTION
#   Used by Wait-EmptyEntries.
#   Takes a hash table by the entry's id. Adds/Updates any entry that's found in ActiveEntries.
#
# .PARAMETER Tracker
#   Tracking hash table to be updated
#
# .PARAMETER Source
#   Name of server, for logging purpose, which GetEntries Scriptblock is retrieving data from
#
# .PARAMETER Stage
#   Name of the Stage of the overall BeginMM process, for logging purpose
#
# .PARAMETER DetailLogging
#   Whether to log progress of each entry.
#
# .PARAMETER ActiveEntries
#   Array of active entries
#
# .RETURN
#  Returns True if at least an entry is updated or created. Otherwise returns False.
function Update-EntriesTracker
{
    param (
        [Parameter(Mandatory = $true)]
        [HashTable] $Tracker,

        [Parameter(Mandatory = $true)]
        [string] $Source,

        [Parameter(Mandatory = $true)]
        [string] $Stage,

        [Parameter(Mandatory = $false)]
        [Switch] $DetailLogging = $true,

        [Parameter(Mandatory = $false)]
        [Object[]] $ActiveEntries = @()
    )

    $progressMade = $false

    # Update the tracker hash table; Create new entries as needed
    $ActiveEntries | %{
        if(-not $tracker.ContainsKey($_.Id))
        {
            $logEntry = Create-LogEntry -Source $Source -Stage $Stage -Id $_.Id -Count $_.Count

            $trackEnty = New-Object PsObject -Property @{
                LogEntry = $logEntry
                LastUpdated = Get-Date
            }

            $tracker.Add($_.Id, $trackEnty)

            if($DetailLogging)
            {
                Log-EventOfEntry -Event Start -Entry $logEntry
            }

            $progressMade = $true
        }
        else
        {
            $trackingEntry = $tracker[$_.Id]
            $drainRateProp = $_.PsObject.Properties.Match('DrainRate')
            if((($drainRateProp.count -gt 0) -and ($_.DrainRate -gt 0)) -or `
               (($drainRateProp.count -eq 0) -and ($trackingEntry.LogEntry.Count -ne $_.Count)))
            {
                $trackingEntry.LogEntry.Count = $_.Count
                $trackingEntry.LastUpdated = Get-Date
                $progressMade = $true
            }
        }
    }

    return $progressMade
}

# .DESCRIPTION
#   Implements a generic wait function for entries returned by a scriptblock to go
#   to zero or abort when time allow exceed or no progress was made.
#   Each entry is tracked individually.
#
# .PARAMETER GetEntries
#   ScriptBlock to be called every PollingFrequency interval with GetScriptArgs arguments
#   to retrieve an array of entries with count
#
# .PARAMETER Stage
#   Name of the Stage of the overall BeginMM process, for logging purpose
#
# .PARAMETER DetailLogging
#   Whether to log progress of each entry.
#
# .PARAMETER GetEntriesAgrs
#   Parameters for the GetEntries script block
#
# .PARAMETER Source
#   Name of server, for logging purpose, which GetEntries Scriptblock is retrieving data from
#
# .PARAMETER PollingFrequency
#   Frequency of polling queues for status
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   Returns the remaining count of messages in the queues.  When the wait ends with overall timeout
#   or no progress timeout, this function returns a non-zero value.
function Wait-EmptyEntries
{
    Param (
        [Parameter(Mandatory = $true)]
        [ScriptBlock] $GetEntries,

        [Parameter(Mandatory = $true)]
        [string] $Stage,

        [Parameter(Mandatory = $false)]
        [Switch] $DetailLogging = $true,

        [Parameter(Mandatory = $false)]
        [object[]] $GetEntriesArgs = @(),

        [Parameter(Mandatory = $false)]
        [string] $Source = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    $tracker = @{}
    $endTime = (Get-Date) + $Timeout
    $summaryLog = $null
    $firstTime = $true

    while($true)
    {
        $progressMade = $false
        $activeEntries = Invoke-Command -ScriptBlock $GetEntries -ArgumentList $GetEntriesArgs | ? {$_.Count -gt 0}

        if($firstTime)
        {
            if($DetailLogging -and -not $ActiveEntries)
            {
                Log-SkippedEvent -Source $Source -Stage $Stage -Reason @{Reason = 'Not needed'}
            }
            else
            {
                $startCount = 0
                $startCount += $activeEntries | Measure-Object -Sum -Property Count | % {$_.Sum}

                $summaryLog = Create-LogEntry -Source $Source -Stage $Stage -Count $startCount
                Log-EventOfEntry -Event Start -Entry $summaryLog
            }

            $firstTime = $false
        }

        $foundCompleted = Remove-CompletedEntries `
            -Tracker $tracker `
            -ActiveEntries $activeEntries `
            -DetailLogging:$DetailLogging

        if(-not $activeEntries)
        {
            break;
        }

        $foundUpdate = Update-EntriesTracker `
            -Tracker $tracker `
            -ActiveEntries $activeEntries `
            -Source $Source `
            -Stage $Stage `
            -DetailLogging:$DetailLogging

        if((Get-Date) -gt $endTime)
        {
            Write-Verbose "$Source - $Stage Time-out occurred. Wait aborted!"
            $Reason = $Script:AllotedTimeExceeded
            break;
        }
        elseif($foundCompleted -or $foundUpdate)
        {
            $remaningCount = $activeEntries | Measure-Object -Sum -Property Count | % {$_.Sum}
            Write-Verbose "$Source - $Stage Progress made. $remaningCount items remain."
        }
        else
        {
            # checking if it's been too long since progress was made
            $recentEntries = $tracker.Values | ? {((Get-Date) - $_.LastUpdated) -lt $NoProgressTimeout}
            if(-not $recentEntries)
            {
                Write-Verbose "$Source - $Stage NoProgressTimeout occurred. Wait aborted!"
                $Reason = $Script:NoProgressTimeout
                break;
            }
        }

        Sleep -Seconds $PollingFrequency.Seconds
    }

    $remainingCount = 0
    $remainingCount += $activeEntries | Measure-Object -Sum -Property Count | % {$_.Sum}

    if($DetailLogging)
    {
        $tracker.Values | %{ Log-EventOfEntry -Event Completed -Entry $_.LogEntry -Reason @{Reason = $reason} }
    }
    else
    {
        $summaryLog.Count = $remainingCount

        if($reason)
        {
            Log-EventOfEntry -Event Completed -Entry $summaryLog -Reason @{Reason = $reason}
        }
        else
        {
            Log-EventOfEntry -Event Completed -Entry $summaryLog
        }
    }

    if($ThrowOnTimeout)
    {
        throw New-Object System.TimeoutException "Time-out reached."
    }

    return $remainingCount
}

# .SYNOPSIS
#   Waits for the draining of Remote SMTP Relay queues, MapiDelivery queues and Submission queue.
#
# .DESCRIPTION
#   Monitors and waits for all messages to be drained before returning. Will throw
#   TimeoutException if time-out is reached or if no progress is made in NoProgressTimeout.
#
# .PARAMETER Server
#   Target server for the operation.
#
# .PARAMETER QueueTypes
#   Array of DeliveryTypes defined in:
#   http://technet.microsoft.com/en-us/library/bb125022(v=exchg.150).aspx#NextHopSolutionKey.
#   If null specified, all queue types are included in the wait.  This function implicitly
#   includes Submission queue and excludes Poison queue.
#
# .PARAMETER ActiveMsgOnly
#   Whether to wait for active messages or all messages.
#
# .PARAMETER Stage
#   Whether the wait is for the natural draining or the redirection
#
# .PARAMETER PollingFrequency
#   Frequency of polling queues for status
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   Returns the remaining count of messages in the queues.  When the wait ends with overall timeout or no progress timeout,
#   this function returns a non-zero value.
function Wait-EmptyQueues
{
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Server = $null,

        [Parameter(Mandatory = $false)]
        [String[]] $QueueTypes = $null,

        [Parameter(Mandatory = $false)]
        [bool] $ActiveMsgOnly = $false,

        [Parameter(Mandatory = $false)]
        [string]$Stage = "QueueDrain",

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    $getQueueEntries = `
    {
        param(
        [Parameter(Mandatory = $true)]
        [string]$Server = $null,

        [Parameter(Mandatory = $true)]
        [string[]]$QueueTypes,

        [Parameter(Mandatory = $true)]
        [bool]$ActiveMsgOnly
        )

        $filter = "{MessageCount -gt 0 -and DeliveryType -ne 'ShadowRedundancy' -and NextHopDomain -ne 'Poison Message'}"
        $queues = get-queue -server $Server -ErrorAction SilentlyContinue -filter $filter | `
            ?{ $null -eq $QueueTypes -or $QueueTypes -contains $_.DeliveryType }

        $entries = $queues | %{
            if($ActiveMsgOnly)
            {
                $count = $_.MessageCountsPerPriority | Measure-Object -Sum | %{$_.Sum}
            }
            else
            {
                $count = $_.MessageCount
            }

            $queueInfo = `
            @{
                Id = $_.Identity
                Count = $count
                DrainRate = $_.OutgoingRate
            }
            New-Object PsObject -Property $queueInfo
        }

        return $entries
    }

    Write-Verbose "$Server - Start waiting for $Stage..."

    $remaining = Wait-EmptyEntries `
                -GetEntries $getQueueEntries `
                -GetEntriesArgs $Server,$queueTypes,$ActiveMsgOnly `
                -Source $Server `
                -Stage $Stage `
                -DetailLogging:$false `
                -PollingFrequency $PollingFrequency `
                -TimeOut $TimeOut `
                -NoProgressTimeout $NoProgressTimeout `
                -ThrowOnTimeout:$ThrowOnTimeout

    Write-Verbose "$Server - Wait for $Stage ended with $remaining items remain."

    return $remaining
}

# .DESCRIPTION
#   returns the pending discard events from a specified server
#
# .PARAMETER Server
#   Target server for the operation.
#
# .PARAMETER Detail
#   If detail is specified, Discard Ids are included in the discard information returned.
#
# .RETURN
#   Returns array of discard events count of each shadow server.  When -Detail present,
#   DiscardIDs of each shadow server are also returned.
function Get-DiscardInfo
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$Server,
        [Parameter(Mandatory = $false)]
        [switch]$Detail
        )

    if($Detail)
    {
        $argument = 'verbose'
    }
    else
    {
        $argument = 'basic'
    }

    $shadowInfo = [xml](Get-ExchangeDiagnosticInfo -Server $Server -Process edgetransport -Component ShadowRedundancy -argument $argument)

    $discardInfo = $shadowInfo.Diagnostics.Components.ShadowRedundancy.ShadowServerCollection.ShadowServer | `
        ? {$_.ShadowServerInfo.discardEventsCount -gt 0 } |
        % {
            $infoProps = `
            @{
                Id = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($_.Context))
                Count  = $_.ShadowServerInfo.discardEventsCount
                DiscardIds = @()
            }
            if($Detail)
            {
                $infoProps.DiscardIds = $_.ShadowServerInfo.discardEventMessageId
            }

            new-object psobject -Property $infoProps
        }

    return $discardInfo
}

# .SYNOPSIS
#   Waits for discard events to be consumed by shadow servers
#
# .DESCRIPTION
#   Monitors and waits for all discard events to be consumed by shadow servers before returned.
#   Will throw TimeoutException if timeout is reached or if no progress is made in NoProgressTimeout.
#
# .PARAMETER Server
#   Target server for the operation.
#
# .PARAMETER ActiveServers
#   Array of active servers whose discard events are waiting to be drained
#
# .PARAMETER PollingFrequency
#   Frequency of polling queues for status
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   Returns the remaining count of discard events.  When the wait ends with timeout exceeded or no progress
#   this functions returns a non-zero value.
function Wait-EmptyDiscards
{
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Server = $null,

        [Parameter(Mandatory = $true)]
        [string[]]$ActiveServers = $null,

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    Write-Verbose "$Server - Start waiting for ShadowDiscardDrain..."

    # log the undrainable entries
    $discardInfo = Get-DiscardInfo -server $Server
    $notDrainable = $discardInfo | ? {$ActiveServers -notcontains $_.Id.Split('.')[0]} | %{
        Log-SkippedEvent -Source $Server -Stage ShadowDiscardDrain -Id $_.Id `
            -Count $_.Count -Reason @{Reason = $Script:ServerInMM}
    }

    # wait for discard events to be drained
    $getDiscardInfo = `
    {
        param (
            [Parameter(Mandatory = $true)]
            [string]$Server = $null,

            [Parameter(Mandatory = $true)]
            [string[]]$ActiveServers = $null
        )

        $discardInfo = Get-DiscardInfo -server $Server
        $discardInfo | ? {$ActiveServers -contains $_.Id.Split('.')[0]}
    }

    $remaining = Wait-EmptyEntries `
                    -GetEntries $getDiscardInfo `
                    -GetEntriesArgs $Server,$ActiveServers `
                    -Source $Server `
                    -Stage ShadowDiscardDrain `
                    -PollingFrequency $PollingFrequency `
                    -TimeOut $TimeOut `
                    -NoProgressTimeout $NoProgressTimeout `
                    -ThrowOnTimeout:$ThrowOnTimeout

    Write-Verbose "$Server - ShadowDiscardDrain ended with $remaining items remain."

    return $remaining
}

# .DESCRIPTION
#   Waits for the event log StartScanForMessages (id = 17008) to be logged to Windows Event Log
#   This tells that the bootscanner had completed counting for the outstanding items and
#   start boot-scanning messages
#
# .PARAMETER ServerFqdn
#   Fqdn of the server
#
# .PARAMETER PollingFrequency
#   Frequency of polling for event
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   none
function Wait-BootLoaderCountCheck
{
    Param (
        [Parameter(Mandatory = $true)]
        [string]$ServerFqdn,

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    $waitBootScanningEvent =
    {
        param(
            [Parameter(Mandatory = $true)]
            [string]$fqdn = $null,

            [Parameter(Mandatory = $true)]
            [DateTime]$StartTime = $null
        )

        $bootScanningEvent = @{
            LogName = 'Application'
            ProviderName = 'MsExchangeTransport'
            Id = 17008
            StartTime = $StartTime
        }

        $event = Get-WinEvent -ComputerName $ServerFqdn -FilterHashtable $bootScanningEvent -ErrorAction SilentlyContinue

        if($event)
        {
            # return null to complete the wait
            return $null
        }
        else
        {
            $bootScanningEvent = `
            @{
                Id = "TransportQueueDatabase"
                Count = 1
            }
            New-Object PsObject -Property $bootScanningEvent
        }
    }

    $server = $ServerFqdn.split('.')[0]
    $xml = [xml](Get-ExchangeDiagnosticInfo -Process "EdgeTransport" -server $server -erroraction SilentlyContinue)
    if($xml)
    {
        $processStartTime = [DateTime]($xml.Diagnostics.ProcessInfo.StartTime)
        $remaining = Wait-EmptyEntries `
                        -GetEntries $waitBootScanningEvent `
                        -GetEntriesArgs $ServerFqdn,$processStartTime `
                        -Source $server `
                        -Stage BootLoaderCountCheck `
                        -PollingFrequency $PollingFrequency `
                        -TimeOut $Timeout `
                        -NoProgressTimeout $NoProgressTimeout `
                        -ThrowOnTimeout:$ThrowOnTimeout
    }
}

# .DESCRIPTION
#   Waits for the 'BootLoader Outstanding Items' perfcounter to go down to 0
#
# .PARAMETER ServerFqdn
#   Fqdn of the server
#
# .PARAMETER PollingFrequency
#   Frequency of polling for event
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   none
function Wait-BootLoaderSubmitCheck
{
    Param (
        [Parameter(Mandatory = $true)]
        [string] $ServerFqdn,

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    $getOutstandingItems =
    {
        param(
            [Parameter(Mandatory = $true)]
            [string]$fqdn = $null
        )

        $counter = Get-Counter `
            -Counter "\MSExchangeTransport Database(other*)\BootLoader Outstanding Items" `
            -ComputerName $fqdn `
            -ErrorAction SilentlyContinue
        try
        {
            $counterInfo = `
            @{
                Id = "BootLoaderOutstandingItems"
                Count = $counter.CounterSamples[0].RawValue
            }
        }
        catch
        {
            $counterInfo = `
            @{
                Id = "BootLoaderOutstandingItems"
                Count = 1
            }
        }

        return New-Object PsObject -Property $counterInfo
    }

    $server = $ServerFqdn.split('.')[0]
    $remaining = Wait-EmptyEntries `
                    -GetEntries $getOutstandingItems `
                    -GetEntriesArgs $ServerFqdn `
                    -Source $server `
                    -Stage BootLoaderSubmitCheck `
                    -PollingFrequency $PollingFrequency `
                    -TimeOut $Timeout `
                    -NoProgressTimeout $NoProgressTimeout `
                    -ThrowOnTimeout:$ThrowOnTimeout

    return $remaining
}

# .DESCRIPTION
#   If the process has been running for more than 30 mins, then this function returns immediately.
#   Otherwise, wait for the bootscanner to complete up to 30 minutes or the specified timeout, whichever
#   less.
#
# .PARAMETER Server
#   Target server for the operation.
#
# .PARAMETER MaxBootLoaderProcessTimeout
#   Max time for the BootLoader to completely bootscanning all the unprocessed messages.
#
# .PARAMETER PollingFrequency
#   Frequency of polling queues for status
#
# .PARAMETER Timeout
#   Timeout not to exceed
#
# .PARAMETER NoProgressTimeout
#   Timeout for when no progress is made
#
# .PARAMETER ThrowOnTimeout
#   Whether to throw error on timeout
#
# .RETURN
#   Returns the remaining count of the outstanding items in the BootLoader.  When the wait ends with
#   timeout exceeded or no progress, this function returns a non-zero value.
function Wait-BootLoaderReady
{
    Param (
        [Parameter(Mandatory = $true)]
        [string]$Server = $null,

        [Parameter(Mandatory = $false)]
        [TimeSpan]$MaxBootLoaderProcessTimeout = (New-TimeSpan -Minutes 30),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $PollingFrequency = (New-TimeSpan -Seconds 10),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $Timeout = (New-TimeSpan -Minutes 5),

        [Parameter(Mandatory = $false)]
        [TimeSpan] $NoProgressTimeout = (New-TimeSpan -Minutes 1),

        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnTimeout
    )

    Write-Verbose "$Server - Waiting for BootLoader to be ready..."

    $exchangeServer = Get-ExchangeServer $Server
    if(-not $exchangeServer)
    {
        Write-Warning "Could not get the exchange server. Skip waiting for BootLoader."
        return 0
    }

    $retry = 5
    while ($true)
    {
        try
        {
            $xml = [xml](Get-ExchangeDiagnosticInfo -Process "EdgeTransport" -server $Server -erroraction SilentlyContinue)
            $processLifeTime = [TimeSpan]($xml.Diagnostics.ProcessInfo.LifeTime)
            $processStartTime = [DateTime]($xml.Diagnostics.ProcessInfo.StartTime)
            break
        }
        catch
        {
            if($retry -gt 0)
            {
                Write-Verbose "$Server - Can not read the process lifetime. Sleep 20 to retry..."
                Sleep 20
                $retry--
            }
            else
            {
                break
            }
        }
    }


    if(-not $processLifeTime -or -not $processStartTime)
    {
        # EdgeTransport isn't running or Server isn't a HubTransport, nothing to wait here
        Log-SkippedEvent -Source $Server -Stage BootLoaderCountCheck -Reason @{Reason = 'EdgeTransportUnreachable'}
        Log-SkippedEvent -Source $Server -Stage BootLoaderSubmitCheck -Reason @{Reason = 'EdgeTransportUnreachable'}

        Write-Warning "$Server - EdgeTransport is not running or server $server is unreachable. Skipping waiting for BootLoader."
        return 0
    }

    if($processLifeTime -gt $MaxBootLoaderProcessTimeout)
    {
        Log-SkippedEvent -Source $Server -Stage BootLoaderCountCheck -Reason @{ProcessLifeTime = $processLifeTime}
        Log-SkippedEvent -Source $Server -Stage BootLoaderSubmitCheck -Reason @{ProcessLifeTime = $processLifeTime}

        Write-Verbose "$Server - EdgeTransport has been running for $processLifeTime. BootLoader is ready"
        return 0
    }
    elseif ($MaxBootLoaderProcessTimeout - $processLifeTime -gt $Timeout)
    {
        $waitTime = $Timeout
    }
    else
    {
        $waitTime = $MaxBootLoaderProcessTimeout - $processLifeTime
    }

    $msg = "$Server EdgeTransport has been running for $processLifeTime! Let's give BootLoader $waitTime  to complete."
    Write-Verbose $msg

    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew()

    Wait-BootLoaderCountCheck `
        -ServerFqdn ($exchangeServer.fqdn) `
        -PollingFrequency $PollingFrequency `
        -TimeOut $waitTime `
        -NoProgressTimeout $waitTime `
        -ThrowOnTimeout:$ThrowOnTimeout

    $stopWatch.Stop()
    $elapsed = $stopWatch.Elapsed
    $waitTime = $waitTime - $elapsed

    Wait-BootLoaderSubmitCheck `
        -ServerFqdn ($exchangeServer.fqdn) `
        -PollingFrequency $PollingFrequency `
        -TimeOut $waitTime `
        -NoProgressTimeout $NoProgressTimeout `
        -ThrowOnTimeout:$ThrowOnTimeout

    Write-Verbose "$Server - BootLoader ended with $remaining items remain"
    return $remaining
}

# .DESCRIPTION
#   Put the MsExchangeTransport/EdgeTransport on the specified server to Draining
#   mode WITHOUT changing the server component state. This is done by pausing the service.
#
# .PARAMETER Server
#   Server to drain the active messages from
#
# .PARAMETER TransportService
#   Optional MsExchangeTransport service object.
function Drain-ActiveMessages
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Server = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [object] $TransportService
    )

    Wait-BootLoaderReady -Server $Server

    if(-not $TransportService)
    {
        $exServer = Get-ExchangeServer $Server
        Write-Verbose "$Server - Pausing the MsExchangeTransport service to stop accepting new traffic"
        $TransportService = get-service -ComputerName $exServer.Fqdn -Name MSExchangeTransport -errorAction silentlyContinue
    }

    if($TransportService)
    {
        $TransportService.Pause() | Out-Null
    }

    $queueTypes = @("SmtpDeliveryToMailbox", "SmtpRelayToRemoteAdSite", "SmtpRelayToDag", "SmtpRelayToServers", "Undefined")
    Wait-EmptyQueues -Server $server -QueueTypes $queueTypes -ActiveMsgOnly $true -Stage QueueDrain -Timeout 00:01:30
}

# .DESCRIPTION
#  Redirecting messages from the specified server to all other servers in its dag
#
# .PARAMETER server
#  Server whose messages are being redirecting
#
# .PARAMETER ExcludeLocalSite
#  Whether to redirect messages to servers at the same site
#
# .PARAMETER LogIfRemain
#  Whether to write to window event log if there remaining message that can not be redirected
#
# .RETURN
#  Returns active servers in the dag
#
function Redirect-Messages
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Server,

        [Parameter(Mandatory = $false)]
        [switch] $ExcludeLocalSite,

        [Parameter(Mandatory = $false)]
        [switch] $LogIfRemain = $true,
        
        [string[]]$MessageRedirectExclusions
    )

    # get domain name of the server
    $fqdn = Get-ExchangeServer $Server | %{$_.Fqdn}
    $domainIndex = $fqdn.Indexof(".")
    $domain = $fqdn.SubString($domainIndex)

    $serversInDag = Get-ServersInDag -server $Server -ExcludeLocalSite:$ExcludeLocalSite -AdditionalExclusions $MessageRedirectExclusions
    if (-not $serversInDag -or $serversInDag.count -eq 0)
    {
        Write-Warning "$Server - Could not find servers in the DAG to redirect messages to that do not meeting exclusion criteria. Skipping redirect."
        return $null
    }

    $serversInDag = Get-ActiveServers $serversInDag
    $hubFqdns = $serversInDag | ? { $_ -ne $Server } | % { $_ + $domain }

    $verboseMessage = "$Server - Redirecting messages to " + [string]::Join(", ", $hubFqdns)
    Write-Verbose $verboseMessage

    Redirect-Message -Target $hubFqdns -Server $Server -Confirm:$false -ErrorAction SilentlyContinue

    $timeOut = (New-TimeSpan -Minutes 8)
    $remaining = Wait-EmptyQueues -Server $Server -Stage Redirect -Timeout $timeOut
    
    if($remaining -and $LogIfRemain)
    {
        $message = "Transport service is going to Maintenance with $messageCount messages in its queues."
        Log-WindowsEvent -EventId $Script:UnredirectedMessageEventId -Message $message
    }

    return $serversInDag
}

# .DESCRIPTION
#  Forcing heartbeats from other shadow servers in the dag to the primary
#  Wait for all discard events to be drained by its shadow servers
#
# .PARAMETER primary
#  Primary server
#
# .PARAMETER shadowServers
#  Array of shadow servers
#
# .PARAMETER LogIfRemain
#  Whether to log a windows event log if there is remains discard event that can't be drained.
#
# .RETURN
#  none
#
function Drain-DiscardEvents
{
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String] $Primary,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]] $ShadowServers,

        [Parameter(Mandatory = $false)]
        [switch] $LogIfRemain = $true
    )

    $filter = "{DeliveryType -eq 'ShadowRedundancy' -and NextHopDomain -like '$Primary*'}"
    $ShadowServers | % {
        Write-Verbose "$Primary - Forcing heart-beat on server $_"
        Retry-Queue -server $_ -Filter $filter -ErrorAction SilentlyContinue
    }

    Write-Verbose "$Primary - Waiting for the heartbeats to complete processing"
    $remaining = Wait-EmptyDiscards -Server $Primary -ActiveServers $ShadowServers -NoProgressTimeout (New-TimeSpan -Minutes 2)

    if($remaining -and $LogIfRemain)
    {
        $message = "Transport service is going to Maintenance with $remaining unacknowledged discard events."
        Log-WindowsEvent -EventId $Script:UndrainedDiscardEventEventId -Message $message
    }
}

function Unblock-SubmissionQueue
{
    Write-Verbose "Getting handles for Transport worker process and service"
    $TransportWorkerProcess=(get-process EdgeTransport)
    $TransportServiceProcess=(get-process MSExchangeTransport)
    $TransportService=(get-service MSExchangeTransport)

    ## Create the dump
    Write-Output "Sending trouble signal (204) to Transport Service"
    try { $TransportService.ExecuteCommand(204) } ## This could fail and its ok.
    catch { Write-Verbose ("Sending trouble signal (204) to Transport Service issued an error:"+$Error[0].ToString()) }

    Write-Verbose "Waiting 90s for the worker process to exit(Watson dump being created)"
    if ($TransportWorkerProcess.WaitForExit(90000))
    {
        Write-Output "Worker process exited"
    }
    else
    {
        Write-Warning "Worker process hasn't exited."
    }

    ##Stop transport, one way or another
    Write-Output "Stopping Transport."
    try { $TransportService.Stop() } ## This could timeout and it's ok.
    catch { Write-Verbose ("Stopping Transport issued an error:"+$Error[0].ToString()) }

    Write-Verbose "Waiting for Transport to stop completely"
    while (-not $TransportServiceProcess.WaitForExit(30000))
    {
        if(-not $TransportWorkerProcess.HasExited)
        {
            Write-Warning "Transport worker process didn't stop yet. Killing the process"
            $TransportWorkerProcess.Kill()
        }
        else
        {
            Write-Warning "Transport service didnt stop yet. Killing the process"
            $TransportServiceProcess.Kill()
        }
    }
    $TransportService.WaitForStatus("Stopped") ## If it never stops the workflow will timeout and we should wake some people up.
    Write-Output "Transport is stopped."

    ## Starting transport will cause the dependencies to start.
    Write-Output "Starting Transport"
    try { $TransportService.Start() } ## This could timeout and its ok.
    catch { Write-Verbose ("Starting Transport issued an error:"+$Error[0].ToString()) }

    $TransportService.WaitForStatus("Running") ## If it never starts the workflow will timeout and we should wake some people up.

    Write-Output "Transport restarted."
}

# .DESCRIPTION
#   Sets specified component to state requested.
#
# .PARAMETER $State
#   Requested state for the component.
#
# .PARAMETER $Component
#   Component to set.
#
# .PARAMETER $Requester
#   Requester who set the state.
#
# .PARAMETER Server
#  The server to change the component state
#
function Set-ComponentState
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet("Active", "Inactive")]
        [string]$State,

        [Parameter(Mandatory = $false)]
        [string]$Component = "HubTransport",

        [Parameter(Mandatory = $false)]
        [string]$Requester = "Maintenance",

        [Parameter(Mandatory = $false)]
        [string]$Server = $env:COMPUTERNAME
    )

    Write-Verbose "Setting $Component state to $State"
    Set-ServerComponentState `
        -Identity $Server `
        -Component $Component `
        -Requester $Requester `
        -State $State `
        -ErrorAction SilentlyContinue
}

# .DESCRIPTION
#   Gets state of the specified component of an exchange server
#
# .PARAMETER $Server
#   Server to retrieve component state of
#
# .PARAMETER $Component
#   Component to get.
#
function Get-ComponentState
{
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [string]$Component = "HubTransport"
    )

    Write-Verbose "Getting $Component state of $Server"
    $serverComponentState = Get-ServerComponentState `
        -Identity $Server `
        -Component $Component `
        -ErrorAction SilentlyContinue
    Write-Verbose "ServerComponentState of $Component is '$($serverComponentState.State)'"

    return $serverComponentState
}

# .DESCRIPTION
#  Change the running state of a service
#
# .PARAMETER $ServiceName
#  Name of the service to change the state of
#
# .PARAMETER $Server
#  Server where the service is running on
#
# .PARAMETER $State
#  New state of the service, can be Stopped, Running, Paused, or NoChange
#
# .PARAMETER $StartMode
#  Change the startMode if necessary before changing its running state
#
# .PARAMETER $WaitTime
#  Maximum wait time for the service to change its state
#
# .PARAMETER $LoggingStage
#  If provide, a log entry is added to MM log on start and complete of the state change
#
# .PARAMETER $ThrowOnFailure
#  Whether to throw on failures
#
# .RETURN 
#  True if successful, false otherwise.
function Set-ServiceState
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:COMPUTERNAME,

        [Parameter(Mandatory = $false)]
        [ValidateSet("NoChange", "Stopped", "Running", "Paused")]
        [string]$State = "NoChange",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("NoChange", "Auto", "Automatic", "Manual", "Disabled")]
        [string]$StartMode = "NoChange",
        
        [Parameter(Mandatory = $false)]
        [TimeSpan] $WaitTime = (New-TimeSpan -Minutes 5),
        
        [Parameter(Mandatory = $false)]
        [string] $LoggingStage,
        
        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnFailure
    )
    
    $service = Get-WmiObject win32_service -filter "name = '$ServiceName'" -ComputerName $Server
    
    if(-not $service)
    {
        if($LoggingStage)
        {
            Log-SkippedEvent -Source $Server -Stage $LoggingStage -Reason @{$ServiceName = 'NotFound'}
        }
        
        if($ThrowOnFailure)
        {
            throw "Service $ServiceName not found on $Server."
        }
        return
    }
    
    # Check and change the StartMode if necessary
    if($StartMode -eq "Auto")
    {
        $StartMode = "Automatic"
    }
    
    if(($StartMode -ne "NoChange") -and ($service.StartMode -ne $StartMode))
    {
        $service.ChangeStartMode($StartMode) | Out-Null
        
        if($StartMode -eq "Disabled")
        {
            $State = "Stopped"
        }
    }
    
    # Determine if the start/stop/restart action is needed
    if($State -eq "NoChange" -or $service.State -eq $State)
    {
        return
    }
    
    if($LoggingStage)
    {
        $logEntry = Create-LogEntry -Source $Server -Stage $LoggingStage
        Log-EventOfEntry -Event Start -Entry $logEntry
    }
    
    switch($State)
    {
        "Stopped" 
        {   
            $service.StopService() | Out-Null
        }
        
        "Running" 
        {
            if($service.State -eq "Paused")
            {
                $service.ResumeService() | Out-Null
            }
            else
            {
                $service.StartService()| Out-Null
            }
        }
        
        "Paused"
        {
            if($service.State -eq "Running")
            {
                $service.PauseService() | Out-Null
            }
            else
            {
                # service is stopped, start it up first
                $service.StartService() | Out-Null
                
                if($WaitTime -eq [TimeSpan]::Zero)
                {
                    $startupWaitTime = New-TimeSpan -Minutes 5
                }
                else
                {
                    $startupWaitTime = $WaitTime
                }
                
                Wait-ServiceState `
                    -ServiceName $ServiceName `
                    -Server $Server `
                    -State "Running" `
                    -WaitTime $startupWaitTime `
                    -ThrowOnFailure:$ThrowOnFailure
                
                # pause now
                $service.PauseService() | Out-Null
            }
        }
    }
    
    if($WaitTime -gt [TimeSpan]::Zero)
    {
        Wait-ServiceState `
            -ServiceName $ServiceName `
            -Server $Server `
            -State $State `
            -WaitTime $WaitTime `
            -ThrowOnFailure:$ThrowOnFailure
    }
    
    if($LoggingStage)
    {
        Log-EventOfEntry -Event Completed -Entry $logEntry -reason @{'MaxWaitMinutes' = $WaitTime.TotalMinutes}
    }
}

# .DESCRIPTION
#  Wait for the state of a service to change to the specified state
#
# .PARAMETER $ServiceName
#  Name of the service to wait for
#
# .PARAMETER $Server
#  Server where the service is running on
#
# .PARAMETER $State
#  State to wait for
#
# .PARAMETER $WaitTime
#  Maximum wait time for the service to change its state
#
# .PARAMETER $ThrowOnFailure
#  Whether to throw on failures
#
# .RETURN 
#  None
function Wait-ServiceState 
{
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $false)]
        [string]$Server = $env:COMPUTERNAME,
        
        [Parameter(Mandatory = $True)]
        [ValidateSet("Stopped", "Running", "Paused")]
        [string]$State,
        
        [Parameter(Mandatory = $false)]
        [TimeSpan] $WaitTime = (New-TimeSpan -Minutes 5),
        
        [Parameter(Mandatory = $false)]
        [Switch] $ThrowOnFailure
    )
    
    $service = Get-Service -ComputerName $Server -ServiceName $ServiceName
    
    if(-not $service)
    {
        if($ThrowOnFailure)
        {
            throw "Service $ServiceName not found on $Server."
        }
        return
    }
    
    try
    {
        $service.WaitForStatus($State, $WaitTime) | Out-Null
    }
    catch
    {
        if($ThrowOnFailure)
        {
            throw $_
        }
    }
}

# .DESCRIPTION
#   Function to stop a service by killing the underlying process
#
# .PARAMETER $ServiceName
#   Name of the service to stop
#
# .PARAMETER $StartMode
#   Service startup mode to set after killing the service, default to 'Auto'
function Stop-ServiceForcefully
{
    param
    (
        [ValidateNotNullOrEmpty()]
        [string]$ServiceName = $(throw "ServiceName required."),

        [ValidateSet("Auto", "Manual", "Disabled")]
        [string]$StartMode = "Auto"
    )

    Write-Verbose "Stopping $ServiceName Service"
    Set-ServiceState -ServiceName $ServiceName -StartMode Disabled -WaitTime ([TimeSpan]::Zero)
    # Wait in case it needs time to take effect
    Wait-Event -Timeout 5

    $processFullPath = (Get-WmiObject -query "SELECT PathName FROM Win32_Service WHERE Name = '$ServiceName'").PathName.Replace('"','')
    $processName = (Split-Path $processFullPath -Leaf).Replace('.exe','')

    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    if ($null -ne $process)
    {
        Stop-Process $process -Force
        # we wait so that the next statement that sets the startup type back to automatic does not
        # take effect while the process is still being killed and cause SCM to start the service back up
        Wait-Event -Timeout 5
    }
    else
    {
        Write-Verbose 'The service process was not running'
    }
    
    Set-ServiceState -ServiceName $ServiceName -StartMode $StartMode -WaitTime ([TimeSpan]::Zero)
}
#endregion

Export-ModuleMember -Function Start-TransportMaintenance
Export-ModuleMember -Function Stop-TransportMaintenance
Export-ModuleMember -Function Wait-BootLoaderReady
