function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $AdditionalComponentsToActivate,

        [System.String]
        $DomainController,

        [System.Boolean]
        $MovePreferredDatabasesBack = $false,

        [System.Boolean]
        $SetInactiveComponentsFromAnyRequesterToActive = $false,

        [System.String]
        $UpgradedServerVersion
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Enabled" = $Enabled} -VerbosePreference $VerbosePreference

    #Load TransportMaintenanceMode Helper
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)"))\TransportMaintenance.psm1" -Verbose:0

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-*" -VerbosePreference $VerbosePreference

    $maintenanceModeStatus = GetMaintenanceModeStatus -EnteringMaintenanceMode $Enabled -DomainController $DomainController
    $atDesiredVersion = IsExchangeAtDesiredVersion -DomainController $DomainController -UpgradedServerVersion $UpgradedServerVersion

    if ($null -ne $maintenanceModeStatus)
    {
        #Determine which components are Active
        $activeComponents = $MaintenanceModeStatus.ServerComponentState | where {$_.State -eq "Active"}

        [string[]]$activeComponentsList = @()

        if ($null -ne $activeComponents)
        {
            foreach ($activeComponent in $activeComponents)
            {
                $activeComponentsList += $activeComponent.Component
            }
        }

        $activeComponentCount = $activeComponentsList.Count


        #Figure out what our Enabled state should really be in case UpgradedServerVersion was passed
        $isEnabled = $Enabled

        if ($Enabled -eq $true -and $atDesiredVersion -eq $true)
        {
            $isEnabled = $false
        }

       
        $returnValue = @{
            Enabled = $isEnabled
            ActiveComponentCount = $activeComponentCount
            ActiveComponentsList = $activeComponentsList
            ActiveDBCount = GetActiveDBCount -MaintenanceModeStatus $maintenanceModeStatus -DomainController $DomainController
            ActiveUMCallCount = GetUMCallCount -MaintenanceModeStatus $maintenanceModeStatus -DomainController $DomainController
            ClusterState = $maintenanceModeStatus.ClusterNode.State
            QueuedMessageCount = GetQueueMessageCount -MaintenanceModeStatus $maintenanceModeStatus
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $AdditionalComponentsToActivate,

        [System.String]
        $DomainController,

        [System.Boolean]
        $MovePreferredDatabasesBack = $false,

        [System.Boolean]
        $SetInactiveComponentsFromAnyRequesterToActive = $false,

        [System.String]
        $UpgradedServerVersion
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Enabled" = $Enabled} -VerbosePreference $VerbosePreference

    #Load TransportMaintenanceMode Helper
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)"))\TransportMaintenance.psm1" -Verbose:0

    #Get ready for calling DAG maintenance scripts later
    $scriptsFolder = Join-Path -Path ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup).MsiInstallPath) -ChildPath "Scripts"
    $startDagServerMaintenanceScript = Join-Path -Path "$($scriptsFolder)" -ChildPath "StartDagServerMaintenance.ps1"
    $stopDagServerMaintenanceScript = Join-Path -Path "$($scriptsFolder)" -ChildPath "StopDagServerMaintenance.ps1"

    #Override Write-Host, as it is used by the target scripts, and causes a DSC error since the session is not interactive
    New-Alias Write-Host Write-Verbose

    #Check if setup is running.
    $setupRunning = IsSetupRunning
    
    if ($setupRunning -eq $true)
    {
        Write-Verbose "Exchange Setup is currently running. Skipping maintenance mode checks."
        return
    }

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*" -VerbosePreference $VerbosePreference

    #If the request is to put the server in maintenance mode, make sure we aren't already at the (optional) requested Exchange Server version
    $atDesiredVersion = IsExchangeAtDesiredVersion -DomainController $DomainController -UpgradedServerVersion $UpgradedServerVersion

    if ($Enabled -eq $true -and $atDesiredVersion -eq $true)
    {
        Write-Verbose "Server is already at or above the desired upgrade version of '$($UpgradedServerVersion)'. Skipping putting server into maintenance mode."
        return
    }

    #Continue on with setting the maintenance mode state
    $maintenanceModeStatus = GetMaintenanceModeStatus -EnteringMaintenanceMode $Enabled -DomainController $DomainController

    if ($null -ne $maintenanceModeStatus)
    {
        #Set vars relevant to both 'Enabled' code paths
        $htStatus = $MaintenanceModeStatus.ServerComponentState | where {$_.Component -eq "HubTransport"}
        $haStatus = $MaintenanceModeStatus.ServerComponentState | where {$_.Component -eq "HubTransport"}
        
        #Put the server into maintenance mode
        if ($Enabled -eq $true)
        {
            #Block DB activation on this server
            if ($maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy -ne "Blocked")
            {
                Write-Verbose "Setting DatabaseCopyAutoActivationPolicy to Blocked"
                SetMailboxServer -Identity $env:COMPUTERNAME -DomainController $DomainController -AdditionalParams @{"DatabaseCopyAutoActivationPolicy" = "Blocked"}
            }

            #Set UM to draining before anything else
            $changedUM = ChangeComponentState -Component "UMCallRouter" -Requester "Maintenance" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Draining" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController

            #Start HT maintenance if required
            if ($htStatus.State -ne "Inactive")
            {
                Write-Verbose "Entering Transport Maintenance"
                [string[]]$transportExclusions = GetMessageRedirectionExclusions -DomainController $DomainController
                Start-TransportMaintenance -LoadLocalShell $false -MessageRedirectExclusions $transportExclusions -Verbose
            }            

            #Wait for remaining UM calls to drain
            if ($changedUM)
            {
                WaitForUMToDrain -DomainController $DomainController
            }

            #Run StartDagServerMaintenance script to put cluster offline and failover DB's
            if ($maintenanceModeStatus.ClusterNode.State -eq "Up" -or 
                $maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy -ne "Blocked" -or 
                (GetActiveDBCount -MaintenanceModeStatus $maintenanceModeStatus -DomainController $DomainController) -ne 0)
            {
                Write-Verbose "Running StartDagServerMaintenance.ps1"

                $dagMemberCount = GetDAGMemberCount

                if ($dagMemberCount -ne 0 -and $dagMemberCount -le 2)
                {
                    . $startDagServerMaintenanceScript -serverName $env:COMPUTERNAME -overrideMinimumTwoCopies -Verbose
                }
                else
                {
                    . $startDagServerMaintenanceScript -serverName $env:COMPUTERNAME -Verbose
                }                
            }

            #Set remaining components to offline
            $changedState = ChangeComponentState -Component "ServerWideOffline" -Requester "Maintenance" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Inactive" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController

            #Check whether we are actually in maintenance mode
            $testResults = Test-TargetResource @PSBoundParameters
            
            if ($testResults -eq $false)
            {
                throw "Server is not fully in maintenance mode after running through steps to enable maintenance mode."
            }
        }
        #Take the server out of maintenance mode
        else
        {
            #Bring ServerWideOffline and UMCallRouter back online
            $changedState = ChangeComponentState -Component "ServerWideOffline" -Requester "Maintenance" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Active" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController
            $changedState = ChangeComponentState -Component "UMCallRouter" -Requester "Maintenance" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Active" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController

            #Run StopDagServerMaintenance.ps1 if required
            $updatedActivationPolicy = $false

            if ($maintenanceModeStatus.ClusterNode.State -ne "Up" -or `
                $maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy -ne "Unrestricted" -or`
                $haStatus.State -ne "Active")
            {
                Write-Verbose "Running StopDagServerMaintenance.ps1"

                #Run StopDagServerMaintenance.ps1 in try/catch, so if an exception occurs, we can at least finish
                #doing the rest of the steps to take the server out of maintenance mode
                try
                {
                    . $stopDagServerMaintenanceScript -serverName $env:COMPUTERNAME -Verbose
                }
                catch
                {
                    Write-Error "Caught exception running StopDagServerMaintenance.ps1: $($_.Exception.Message)"
                }
            }

            #End Transport Maintenance
            if ($htStatus.State -ne "Active")
            {
                Write-Verbose "Ending Transport Maintenance"
                Stop-TransportMaintenance -LoadLocalShell $false -Verbose
            }

            #Bring components online that may have been taken offline by a failed setup run
            $changedState = ChangeComponentState -Component "Monitoring" -Requester "Functional" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Active" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController
            $changedState = ChangeComponentState -Component "RecoveryActionsEnabled" -Requester "Functional" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Active" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController       

            #Bring online any specifically requested components
            if ($null -ne $AdditionalComponentsToActivate)
            {
                foreach ($component in $AdditionalComponentsToActivate)
                {
                    if ((IsComponentCheckedByDefault -ComponentName $component) -eq $false)
                    {
                        $status = $null
                        $status = $MaintenanceModeStatus.ServerComponentState | where {$_.Component -like "$($component)"}

                        $changedState = ChangeComponentState -Component $component -Requester "Functional" -ServerComponentState $maintenanceModeStatus.ServerComponentState -State "Active" -SetInactiveComponentsFromAnyRequesterToActive $SetInactiveComponentsFromAnyRequesterToActive -DomainController $DomainController
                    }
                }
            }

            if ($MovePreferredDatabasesBack -eq $true)
            {
                MovePrimaryDatabasesBack -DomainController $DomainController
            }
        }
    }
    else
    {
        throw "Failed to retrieve maintenance mode status of server."
    }

    Remove-Item Alias:Write-Host -ErrorAction SilentlyContinue
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String[]]
        $AdditionalComponentsToActivate,

        [System.String]
        $DomainController,

        [System.Boolean]
        $MovePreferredDatabasesBack = $false,

        [System.Boolean]
        $SetInactiveComponentsFromAnyRequesterToActive = $false,

        [System.String]
        $UpgradedServerVersion
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Enabled" = $Enabled} -VerbosePreference $VerbosePreference

    #Load TransportMaintenanceMode Helper
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)"))\TransportMaintenance.psm1" -Verbose:0

    $setupRunning = IsSetupRunning
    
    if ($setupRunning -eq $true)
    {
        Write-Verbose "Exchange Setup is currently running. Skipping maintenance mode checks."
        return $true
    }

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-*" -VerbosePreference $VerbosePreference

    $maintenanceModeStatus = GetMaintenanceModeStatus -EnteringMaintenanceMode $Enabled -DomainController $DomainController

    if ($null -ne $maintenanceModeStatus)
    {
        #Make sure server is fully in maintenance mode
        if ($Enabled -eq $true)
        {
            $atDesiredVersion = IsExchangeAtDesiredVersion -DomainController $DomainController -UpgradedServerVersion $UpgradedServerVersion

            if ($atDesiredVersion -eq $true)
            {
                Write-Verbose "Server is already at or above the desired upgrade version of '$($UpgradedServerVersion)'. Skipping putting server into maintenance mode."
                return $true 
            }
            else
            {
                if ($maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy -ne "Blocked")
                {
                    Write-Verbose "DatabaseCopyAutoActivationPolicy is not set to Blocked"
                    return $false
                }

                if ($null -ne ($MaintenanceModeStatus.ServerComponentState | where {$_.State -ne "Inactive" -and $_.Component -ne "Monitoring" -and $_.Component -ne "RecoveryActionsEnabled"}))
                {
                    Write-Verbose "One or more components have a status other than Inactive"
                    return $false
                }

                if ($maintenanceModeStatus.ClusterNode.State -eq "Up")
                {
                    Write-Verbose "Cluster node has a status of Up"
                    return $false
                }

                if ((IsServerPAM -DomainController $DomainController) -eq $true)
                {
                    Write-Verbose "Server still has the Primary Active Manager role"
                    return $false
                }


                [int]$messagesQueued = GetQueueMessageCount -MaintenanceModeStatus $maintenanceModeStatus

                if ($messagesQueued -gt 0)
                {
                    Write-Verbose "Found $($messagesQueued) messages still in queue"
                    return $false               
                }


                [int]$activeDBCount = GetActiveDBCount -MaintenanceModeStatus $maintenanceModeStatus -DomainController $DomainController

                if ($activeDBCount -gt 0)
                {
                    Write-Verbose "Found $($activeDBCount) replicated databases still activated on this server"
                    return $false 
                }


                [int]$umCallCount = GetUMCallCount -MaintenanceModeStatus $maintenanceModeStatus -DomainController $DomainController

                if ($umCallCount -gt 0)
                {
                    Write-Verbose "Found $($umCallCount) active UM calls on this server"
                    return $false 
                }
            }
        }
        #Make sure the server is fully out of maintenance mode
        else
        {
            $activeComponents = $MaintenanceModeStatus.ServerComponentState | where {$_.State -eq "Active"}

            if ($null -eq $activeComponents)
            {
                Write-Verbose "No Components found with a status of Active"
                return $false
            }

            if ($null -eq ($activeComponents | where {$_.Component -eq "ServerWideOffline"}))
            {
                Write-Verbose "Component ServerWideOffline is not Active"
                return $false
            }

            if ($null -eq ($activeComponents | where {$_.Component -eq "UMCallRouter"}))
            {
                Write-Verbose "Component UMCallRouter is not Active"
                return $false
            }

            if ($null -eq ($activeComponents | where {$_.Component -eq "HubTransport"}))
            {
                Write-Verbose "Component HubTransport is not Active"
                return $false
            }

            if ($maintenanceModeStatus.ClusterNode.State -ne "Up")
            {
                Write-Verbose "Cluster node has a status of $($maintenanceModeStatus.ClusterNode.State)"
                return $false
            }

            if ($maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy -ne "Unrestricted")
            {
                Write-Verbose "DatabaseCopyAutoActivationPolicy is set to $($maintenanceModeStatus.MailboxServer.DatabaseCopyAutoActivationPolicy)"
                return $false
            }

            if ($null -eq ($activeComponents | where {$_.Component -eq "Monitoring"}))
            {
                Write-Verbose "Component Monitoring is not Active"
                return $false
            }

            if ($null -eq ($activeComponents | where {$_.Component -eq "RecoveryActionsEnabled"}))
            {
                Write-Verbose "Component RecoveryActionsEnabled is not Active"
                return $false
            }

            if ($null -ne $AdditionalComponentsToActivate)
            {
                foreach ($component in $AdditionalComponentsToActivate)
                {
                    if ((IsComponentCheckedByDefault -ComponentName $component) -eq $false)
                    {
                        $status = $null
                        $status = $MaintenanceModeStatus.ServerComponentState | where {$_.Component -like "$($component)"}

                        if ($null -ne $status -and $Status.State -ne "Active")
                        {
                            Write-Verbose "Component $($component) is not set to Active"
                            return $false
                        }
                    }
                }
            }
        }
    }
    else
    {
        throw "Failed to retrieve maintenance mode status for server."
    }

    return $true
}

#Gets a Hashtable containing various objects from Exchange that will be used to determine maintenance mode status
function GetMaintenanceModeStatus
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [System.String]
        $DomainController,

        [System.Boolean]
        $EnteringMaintenanceMode = $true
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'DomainController'

    $serverComponentState = GetServerComponentState -Identity $env:COMPUTERNAME -DomainController $DomainController
    $clusterNode = Get-ClusterNode -Name $env:COMPUTERNAME    
    $dbCopyStatus = GetMailboxDatabaseCopyStatus -Server $env:COMPUTERNAME -DomainController $DomainController
    $umCalls = GetUMActiveCalls -Server $env:COMPUTERNAME -DomainController $DomainController
    $mailboxServer = GetMailboxServer -Identity $env:COMPUTERNAME -DomainController $DomainController
    $queues = Get-Queue -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue

    #If we're checking queues too soon after restarting Transport, Get-Queue may fail. Wait for bootloader to be active and try again.
    if ($null -eq $queues -and $EnteringMaintenanceMode -eq $true)
    {
        $endTime = [DateTime]::Now.AddMinutes(5)

        Write-Verbose "Waiting up to 5 minutes for the Transport Bootloader to be ready before running Get-Queue. Wait started at $([DateTime]::Now)."

        while ($null -eq $queues -and [DateTime]::Now -lt $endTime)
        {            
            Wait-BootLoaderReady -Server $env:COMPUTERNAME -TimeOut (New-TimeSpan -Seconds 15) -PollingFrequency (New-TimeSpan -Seconds 1) | Out-Null
            $queues = Get-Queue -Server $env:COMPUTERNAME -ErrorAction SilentlyContinue
        }
    }

    [System.Collections.Hashtable]$returnValue = @{
        ServerComponentState = $serverComponentState
        ClusterNode = $clusterNode
        Queues = $queues
        DBCopyStatus = $dbCopyStatus
        UMActiveCalls = $umCalls
        MailboxServer = $mailboxServer
    }

    return $returnValue
}

#Gets a count of messages in queues on the local server
function GetQueueMessageCount
{
    [CmdletBinding()]
    [OutputType([System.UInt32])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $MaintenanceModeStatus
    )

    [Uint32]$messageCount = 0

    if ($null -ne $MaintenanceModeStatus.Queues)
    {
        foreach ($queue in $MaintenanceModeStatus.Queues | where {$_.Identity -notlike "*\Shadow\*"})
        {
            Write-Verbose "Found queue '$($queue.Identity)' with a message count of '$($queue.MessageCount)'."
            $messageCount += $queue.MessageCount
        }
    }
    else
    {
        Write-Warning "No Transport Queues were detected on this server. This can occur if the MSExchangeTransport service is not started, or if Get-Queue was run too quickly after restarting the service."
    }

    return $messageCount
}

#Gets a count of database that are replication enabled, and are still activated on the local server (even if they are dismounted)
function GetActiveDBCount
{
    [CmdletBinding()]
    [OutputType([System.UInt32])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $MaintenanceModeStatus,

        [System.String]
        $DomainController
    )

    [Uint32]$activeDBCount = 0

    #Get DB's with a status of Mounted, Mounting, Dismounted, or Dismounting
    $localDBs = $MaintenanceModeStatus.DBCopyStatus | where {$_.Status -like "Mount*" -or $_.Status -like "Dismount*"}    

    #Ensure that any DB's we found actually have copies
    foreach ($db in $localDBs)
    {
        $dbProps = GetMailboxDatabase -Identity "$($db.DatabaseName)" -DomainController $DomainController

        if ($dbProps.ReplicationType -ne "None")
        {
            Write-Verbose "Found database '$($db.DatabaseName)' with a replication type of '$($dbProps.ReplicationType)' and a status of '$($db.Status)'."
            $activeDBCount++
        }
    }

    return $activeDBCount
}

#Gets a count of active UM calls on the local server
function GetUMCallCount
{
    [CmdletBinding()]
    [OutputType([System.UInt32])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Collections.Hashtable]
        $MaintenanceModeStatus,

        [System.String]
        $DomainController
    )

    [Uint32]$umCallCount = 0

    $umCalls = GetUMActiveCalls -Server $env:COMPUTERNAME -DomainController $DomainController

    if ($null -ne $umCalls)
    {
        if ($null -eq $umCalls.Count)
        {
            $umCallCount = 1
        }
        else
        {
            $umCallCount = $umCalls.Count
        }
    }

    return $umCallCount
}

#Gets a list of servers in the DAG with HubTransport not set to Active, or DatabaseCopyAutoActivationPolicy set to Blocked
function GetMessageRedirectionExclusions
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [System.String]
        $DomainController
    )

    [string[]]$exclusions = @()

    $mbxServer = GetMailboxServer -Identity $env:COMPUTERNAME -DomainController $DomainController

    if ($null -ne $mbxServer)
    {
        $dag = GetDatabaseAvailabilityGroup -Identity $($mbxServer.DatabaseAvailabilityGroup) -DomainController $DomainController

        if ($null -ne $dag)
        {
            foreach ($server in $dag.Servers)
            {
                if ($server.Name -notlike $env:COMPUTERNAME)
                {
                    $serverName = $server.Name.ToLower()

                    #Check whether HubTransport is active on the specified server
                    $htState = $null
                    $htState = GetServerComponentState -Identity $server.Name -Component "HubTransport" -DomainController $DomainController

                    if ($null -ne $htState -and $htState.State -notlike "Active")
                    {
                        if (($exclusions.Contains($serverName) -eq $false))
                        {
                            $exclusions += $serverName
                            continue
                        }                        
                    }

                    #Check whether the server is already blocked from database activation
                    $currentMbxServer = $null
                    $currentMbxServer = GetMailboxServer -Identity $server.Name -DomainController $DomainController

                    if ($null -ne $currentMbxServer -and $currentMbxServer.DatabaseCopyAutoActivationPolicy -like "Blocked")
                    {
                        if (($exclusions.Contains($serverName) -eq $false))
                        {
                            $exclusions += $serverName
                            continue
                        }
                    }
                }
            }
        }
    }

    return $exclusions
}

#If UpgradedServerVersion was specified, checks to see whether the server is already at the desired version
function IsExchangeAtDesiredVersion
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [System.String]
        $DomainController,

        [System.String]
        $UpgradedServerVersion
    )

    $atDesiredVersion = $false

    if (!([string]::IsNullOrEmpty($UpgradedServerVersion)))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'DomainController'

        $server = GetExchangeServer -Identity $env:COMPUTERNAME -DomainController $DomainController

        if ($null -ne $server)
        {
            [string[]]$versionParts = $UpgradedServerVersion.Split('.')

            if ($null -ne $versionParts -and $versionParts.Length -eq 4)
            {
                if (([int]::Parse($server.AdminDisplayVersion.Major) -ge [int]::Parse($versionParts[0])) -and
                    ([int]::Parse($server.AdminDisplayVersion.Minor) -ge [int]::Parse($versionParts[1])) -and
                    ([int]::Parse($server.AdminDisplayVersion.Build) -ge [int]::Parse($versionParts[2])) -and
                    ([int]::Parse($server.AdminDisplayVersion.Revision) -ge [int]::Parse($versionParts[3])))
                {
                    $atDesiredVersion = $true
                }
                else
                {
                    Write-Verbose "Desired server version '$($UpgradedServerVersion)' is greater than the actual server version '$($server.AdminDisplayVersion)'"
                }
            }
            else
            {
                throw "Invalid version format for `$UpgradedServerVersion. Should be in the format ##.#.####.#"
            }
        }
    }

    return $atDesiredVersion
}

#Checks to see whether the specified component is one that is already checked by default
function IsComponentCheckedByDefault
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $ComponentName
    )

    [boolean]$checkedByDefault = $false

    if ($ComponentName -like "ServerWideOffline" -or $ComponentName -like "UMCallRouter" -or $ComponentName -like "HubTransport" -or $ComponentName -like "Monitoring" -or $ComponentName -like "RecoveryActionsEnabled")
    {
        $checkedByDefault = $true
    }

    return $checkedByDefault
}

#Gets a count of members in this servers DAG
function GetDAGMemberCount
{
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param(
        [System.String]
        $DomainController
    )

    [System.Int32]$count = 0

    $server = GetMailboxServer -Identity $env:COMPUTERNAME -DomainController $DomainController

    if ($null -ne $server -and ![string]::IsNullOrEmpty($server.DatabaseAvailabilityGroup))
    {
        $dag = GetDatabaseAvailabilityGroup -Identity "$($server.DatabaseAvailabilityGroup)" -DomainController $DomainController

        if ($null -ne $dag)
        {
            $count = $dag.Servers.Count
        }
    }

    return $count
}

function IsServerPAM
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        [System.String]
        $DomainController
    )

    $isPAM = $false

    $server = GetMailboxServer -Identity $env:COMPUTERNAME -DomainController $DomainController

    if ($null -ne $server -and ![string]::IsNullOrEmpty($server.DatabaseAvailabilityGroup))
    {
        $dag = GetDatabaseAvailabilityGroup -Identity "$($server.DatabaseAvailabilityGroup)" -DomainController $DomainController

        if ($null -ne $dag -and $dag.PrimaryActiveManager -like $env:COMPUTERNAME)
        {
            $isPAM = $true
        }
    }

    return $isPAM
}

#Waits up the the specified WaitMinutes for existing UM calls to finish. Returns True if no more UM calls are active.
function WaitForUMToDrain
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [System.String]
        $DomainController,

        [System.UInt32]
        $SleepSeconds = 15,

        [System.UInt32]
        $WaitMinutes = 5
    )

    [boolean]$umDrained = $false
    
    $endTime = [DateTime]::Now.AddMinutes($WaitMinutes)

    Write-Verbose "Waiting up to $($WaitMinutes) minutes for active UM calls to finish"

    while ($fullyInMaintenanceMode -eq $false -and [DateTime]::Now -lt $endTime)
    {
        Write-Verbose "Checking whether all UM calls are finished at $([DateTime]::Now)."
        
        $umCalls = $null

        GetUMActiveCalls -Server $env:COMPUTERNAME -DomainController $DomainController

        if ($null -eq $umCalls -or $umCalls.Count -eq 0)
        {
            $umDrained = $true
        }
        else
        {
            Write-Verbose "There are still active UM calls as of $([DateTime]::Now). Sleeping for $($SleepSeconds) seconds. Will continue checking until $($endTime)."
            Start-Sleep -Seconds $SleepSeconds
        }
    }

    return $umDrained
}

#Checks whether a Component is at the specified State, if not, changes the component to the state.
#Returns whether a change was made to the component state
function ChangeComponentState
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Component,

        [parameter(Mandatory = $true)]
        [System.String]
        $Requester,

        [parameter(Mandatory = $true)]
        $ServerComponentState,

        [parameter(Mandatory = $true)]
        [System.String]
        $State,

        [System.String]
        $DomainController,

        [System.Boolean]
        $SetInactiveComponentsFromAnyRequesterToActive = $false
    )

    [boolean]$madeChange = $false

    $componentState = $MaintenanceModeStatus.ServerComponentState | where {$_.Component -like "$($Component)"}

    if ($null -ne $componentState)
    {
        #If we're already Inactive don't bother setting to Draining.
        if ($State -like "Draining" -and $componentState.State -like "Inactive")
        {
            return $false
        }
        elseif ($componentState.State -notlike "$($State)")
        {
            Write-Verbose "Setting $($componentState.Component) component to $($State) for requester $($Requester)"

            SetServerComponentState -Component $componentState.Component -State $State -Requester $Requester -DomainController $DomainController

            $madeChange = $true

            if ($State -eq "Active" -and $SetInactiveComponentsFromAnyRequesterToActive -eq $true)
            {
                $additionalRequesters = $null
                $additionalRequesters = $componentState.LocalStates | where {$_.Requester -notlike "$($Requester)" -and $_.State -notlike "Active"}

                if ($null -ne $additionalRequesters)
                {
                    foreach ($additionalRequester in $additionalRequesters)
                    {
                        Write-Verbose "Setting $($componentState.Component) component to Active for requester $($additionalRequester.Requester)"

                        SetServerComponentState -Component $componentState.Component -State Active -Requester $additionalRequester.Requester -DomainController $DomainController
                    }
                }
            }
        }
    }

    return $madeChange
}

#Finds any databases which have an Activation Preference of 1 for this server, which are not currently hosted on this server, and moves them back
function MovePrimaryDatabasesBack
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $DomainController
    )
    
    $databases = GetMailboxDatabase -Server $env:COMPUTERNAME -Status -DomainController $DomainController

    [string[]]$databasesWithActivationPrefOneNotOnThisServer = @()

    if ($null -ne $databases)
    {
        foreach ($database in $databases)
        {
            if ($null -ne $database.ActivationPreference)
            {
                foreach ($ap in $database.ActivationPreference)
                {
                    if ($ap.Key.Name -like $env:COMPUTERNAME -and $ap.Value -eq 1)
                    {
                        $copyStatus = $null
                        $copyStatus = GetMailboxDatabaseCopyStatus -Identity "$($database.Name)\$($env:COMPUTERNAME)" -DomainController $DomainController

                        if ($null -ne $copyStatus -and $copyStatus.Status -eq "Healthy")
                        {
                            $databasesWithActivationPrefOneNotOnThisServer += $database.Name
                        }
                    }
                }
            }
        }
    }

    if ($databasesWithActivationPrefOneNotOnThisServer.Count -gt 0)
    {
        Write-Verbose "Found $($databasesWithActivationPrefOneNotOnThisServer.Count) Healthy databases with Activation Preference 1 that should be moved to this server."

        foreach ($database in $databasesWithActivationPrefOneNotOnThisServer)
        {
            Write-Verbose "Attempting to move database '$($database)' back to this server."

            #Do the move in a try/catch block so we can log the error, but not have it prevent other databases from attempting to move
            try
            {
                MoveActiveMailboxDatabase -Identity $database -ActivateOnServer $env:COMPUTERNAME -DomainController $DomainController
            }
            catch
            {
                Write-Error "$($_.Exception.Message)"
            }
        }
    }
    else
    {
        Write-Verbose "Found 0 Healthy databases with Activation Preference 1 for this server that are currently not hosted on this server"
    }
}

#region Exchange Cmdlet Wrappers
function GetExchangeServer
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity = $env:COMPUTERNAME,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    return (Get-ExchangeServer @PSBoundParameters)
}

function GetDatabaseAvailabilityGroup
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    return (Get-DatabaseAvailabilityGroup @PSBoundParameters -Status)
}

function GetServerComponentState
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity = $env:COMPUTERNAME,

        [System.String]
        $Component,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($Component))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Component'
    }

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    return (Get-ServerComponentState @PSBoundParameters)
}

function SetServerComponentState
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Component,

        [parameter(Mandatory = $true)]
        [System.String]
        $Requester,

        [parameter(Mandatory = $true)]
        [System.String]
        $State,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    Set-ServerComponentState -Identity $env:COMPUTERNAME @PSBoundParameters
}

function GetMailboxDatabase
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $Identity,

        [System.String]
        $DomainController,

        [System.String]
        $Server,

        [switch]
        $Status
    )

    if ([string]::IsNullOrEmpty($Identity))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity'
    }

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    if ([string]::IsNullOrEmpty($Server))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Server'
    }

    return (Get-MailboxDatabase @PSBoundParameters)
}

function GetMailboxDatabaseCopyStatus
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $Identity,

        [System.String]
        $DomainController,

        [System.String]
        $Server
    )

    if ([string]::IsNullOrEmpty($Identity))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity'
    }

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    if ([string]::IsNullOrEmpty($Server))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Server'
    }

    return (Get-MailboxDatabaseCopyStatus @PSBoundParameters)
}

function GetMailboxServer
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity = $env:COMPUTERNAME,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    return (Get-MailboxServer @PSBoundParameters)
}

function SetMailboxServer
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity = $env:COMPUTERNAME,

        [System.String]
        $DomainController,

        [System.Collections.Hashtable]
        $AdditionalParams
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $AdditionalParams
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'AdditionalParams'

    Set-MailboxServer @PSBoundParameters
}

function GetUMActiveCalls
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Server = $env:COMPUTERNAME,

        [System.String]
        $DomainController
    )

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    return (Get-UMActiveCalls @PSBoundParameters)
}

function MoveActiveMailboxDatabase
{
    [CmdletBinding()]
    param
    (
        [System.String]
        $ActivateOnServer,

        [System.String]
        $Identity,

        [System.String]
        $DomainController,

        [System.String]
        $MoveComment,

        [System.String]
        $Server = $env:COMPUTERNAME
    )

    if ([string]::IsNullOrEmpty($ActivateOnServer))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'ActivateOnServer'
    }

    if ([string]::IsNullOrEmpty($DomainController))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'DomainController'
    }

    if ([string]::IsNullOrEmpty($Identity))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Identity'
    }

    if ([string]::IsNullOrEmpty($MoveComment))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'MoveComment'
    }

    if ([string]::IsNullOrEmpty($Server))
    {
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Server'
    }

    $moveResult = Move-ActiveMailboxDatabase @PSBoundParameters -Confirm:$false -ErrorAction Stop
}
#endregion

Export-ModuleMember -Function *-TargetResource

