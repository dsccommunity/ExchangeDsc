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
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    if ($null -ne $db)
    {
        $returnValue = @{
            Name = $Name
            Server = $Server
            EdbFilePath = $EdbFilePath
            LogFolderPath = $LogFolderPath
            DatabaseCopyCount = $DatabaseCopyCount
            AutoDagExcludeFromMonitoring = $db.AutoDagExcludeFromMonitoring
            BackgroundDatabaseMaintenance = $db.BackgroundDatabaseMaintenance
            CalendarLoggingQuota = $db.CalendarLoggingQuota
            CircularLoggingEnabled = $db.CircularLoggingEnabled
            DataMoveReplicationConstraint = $db.DataMoveReplicationConstraint
            DeletedItemRetention = $db.DeletedItemRetention
            EventHistoryRetentionPeriod = $db.EventHistoryRetentionPeriod
            IndexEnabled = $db.IndexEnabled
            IsExcludedFromProvisioning = $db.IsExcludedFromProvisioning
            IssueWarningQuota = $db.IssueWarningQuota
            IsSuspendedFromProvisioning = $db.IsSuspendedFromProvisioning
            JournalRecipient = $db.JournalRecipient
            MailboxRetention = $db.MailboxRetention
            MountAtStartup = $db.MountAtStartup
            OfflineAddressBook = $db.OfflineAddressBook
            ProhibitSendQuota = $db.ProhibitSendQuota
            ProhibitSendReceiveQuota = $db.ProhibitSendReceiveQuota
            RecoverableItemsQuota = $db.RecoverableItemsQuota
            RecoverableItemsWarningQuota = $db.RecoverableItemsWarningQuota
            RetainDeletedItemsUntilBackup = $db.RetainDeletedItemsUntilBackup
        }

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $returnValue.Add("IsExcludedFromProvisioningReason", $db.IsExcludedFromProvisioningReason)
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
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*MailboxDatabase","Move-DatabasePath","Mount-Database","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "IsExcludedFromProvisioningReason" -ResourceName "xExchMailboxDatabase" -ParamExistsInVersion "2016"

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    if ($null -eq $db) #Need to create a new DB
    {
        #Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Name","Server","EdbFilePath","LogFolderPath","DomainController"

        #Create the database
        $db = New-MailboxDatabase @PSBoundParameters

        if ($null -ne $db)
        {
            #Add original props back
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

            if ($AllowServiceRestart -eq $true)
            {
                Write-Verbose "Restarting Information Store"

                Restart-Service MSExchangeIS
            }
            else
            {
                Write-Warning "The configuration will not take effect until MSExchangeIS is manually restarted."
            }
            
            #If MountAtStartup is not explicitly set to $false, mount the new database
            if ($PSBoundParameters.ContainsKey("SkipInitialDatabaseMount") -eq $true -and $SkipInitialDatabaseMount -eq $true)
            {
                #Don't mount the DB, regardless of what else is set.
            }
            elseif ($PSBoundParameters.ContainsKey("MountAtStartup") -eq $false -or $MountAtStartup -eq $true)
            {                            
                Write-Verbose "Attempting to mount database."

                MountDatabase @PSBoundParameters
            }
        }
        else
        {
            throw "Failed to create new Mailbox Database"
        }
    }

    if ($null -ne $db) #Set props on existing DB
    {
        #First check if a DB or log move is required
        if (($PSBoundParameters.ContainsKey("EdbFilePath") -and (CompareStrings -String1 $db.EdbFilePath.PathName -String2 $EdbFilePath -IgnoreCase) -eq $false) -or
            ($PSBoundParameters.ContainsKey("LogFolderPath") -and (CompareStrings -String1 $db.LogFolderPath.PathName -String2 $LogFolderPath -IgnoreCase) -eq $false))
        {
            if ($db.DatabaseCopies.Count -le 1)
            {
                Write-Verbose "Moving database and/or log path"

                MoveDatabaseOrLogPath @PSBoundParameters
            }
            else
            {
                throw "Database must have only a single copy for the DB path or log path to be moved"
            }
        }
        
        #setup params
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $Name}
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Name","Server","DatabaseCopyCount","AllowServiceRestart","EdbFilePath","LogFolderPath","Credential","AdServerSettingsPreferredServer","SkipInitialDatabaseMount"

        #Remove parameters that depend on all copies being added
        if ($db.DatabaseCopies.Count -lt $DatabaseCopyCount)
        {
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "CircularLoggingEnabled","DataMoveReplicationConstraint"
        }

        Set-MailboxDatabase @PSBoundParameters
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
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","Get-Mailbox","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    #Check for non-existent parameters in Exchange 2013
    RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "IsExcludedFromProvisioningReason" -ResourceName "xExchMailboxDatabase" -ParamExistsInVersion "2016"

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    if ($null -eq $db)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "AutoDagExcludeFromMonitoring" -Type "Boolean" -ExpectedValue $AutoDagExcludeFromMonitoring -ActualValue $db.AutoDagExcludeFromMonitoring -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "BackgroundDatabaseMaintenance" -Type "Boolean" -ExpectedValue $BackgroundDatabaseMaintenance -ActualValue $db.BackgroundDatabaseMaintenance -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarLoggingQuota" -Type "Unlimited" -ExpectedValue $CalendarLoggingQuota -ActualValue $db.CalendarLoggingQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        #Only check these if all copies have been added
        if ($db.DatabaseCopies.Count -ge $DatabaseCopyCount)
        {
            if (!(VerifySetting -Name "CircularLoggingEnabled" -Type "Boolean" -ExpectedValue $CircularLoggingEnabled -ActualValue $db.CircularLoggingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "DataMoveReplicationConstraint" -Type "Boolean" -ExpectedValue $DataMoveReplicationConstraint -ActualValue $db.DataMoveReplicationConstraint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }
        }

        if (!(VerifySetting -Name "DeletedItemRetention" -Type "Timespan" -ExpectedValue $DeletedItemRetention -ActualValue $db.DeletedItemRetention -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "EdbFilePath" -Type "String" -ExpectedValue $EdbFilePath -ActualValue $db.EdbFilePath.PathName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "EventHistoryRetentionPeriod" -Type "Timespan" -ExpectedValue $EventHistoryRetentionPeriod -ActualValue $db.EventHistoryRetentionPeriod -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IndexEnabled" -Type "Boolean" -ExpectedValue $IndexEnabled -ActualValue $db.IndexEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IsExcludedFromProvisioning" -Type "Boolean" -ExpectedValue $IsExcludedFromProvisioning -ActualValue $db.IsExcludedFromProvisioning -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IssueWarningQuota" -Type "Unlimited" -ExpectedValue $IssueWarningQuota -ActualValue $db.IssueWarningQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IsSuspendedFromProvisioning" -Type "Boolean" -ExpectedValue $IsSuspendedFromProvisioning -ActualValue $db.IsSuspendedFromProvisioning -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "JournalRecipient" -Type "ADObjectID" -ExpectedValue $JournalRecipient -ActualValue $db.JournalRecipient -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogFolderPath" -Type "String" -ExpectedValue $LogFolderPath -ActualValue $db.LogFolderPath.PathName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MailboxRetention" -Type "Timespan" -ExpectedValue $MailboxRetention -ActualValue $db.MailboxRetention -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MountAtStartup" -Type "Boolean" -ExpectedValue $MountAtStartup -ActualValue $db.MountAtStartup -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        #Strip leading slash off the OAB now so it's easier to check
        if ($PSBoundParameters.ContainsKey("OfflineAddressBook"))
        {
            if ($OfflineAddressBook.StartsWith('\'))
            {
                $OfflineAddressBook = $OfflineAddressBook.Substring(1)
            }

            if ($db.OfflineAddressBook.Name.StartsWith('\'))
            {
                $dbOab = $db.OfflineAddressBook.Name.Substring(1)
            }
            else
            {
                $dbOab = $db.OfflineAddressBook.Name
            }
        }

        if (!(VerifySetting -Name "OfflineAddressBook" -Type "String" -ExpectedValue $OfflineAddressBook -ActualValue $dbOab -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ProhibitSendQuota" -Type "Unlimited" -ExpectedValue $ProhibitSendQuota -ActualValue $db.ProhibitSendQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ProhibitSendReceiveQuota" -Type "Unlimited" -ExpectedValue $ProhibitSendReceiveQuota -ActualValue $db.ProhibitSendReceiveQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RecoverableItemsQuota" -Type "Unlimited" -ExpectedValue $RecoverableItemsQuota -ActualValue $db.RecoverableItemsQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RecoverableItemsWarningQuota" -Type "Unlimited" -ExpectedValue $RecoverableItemsWarningQuota -ActualValue $db.RecoverableItemsWarningQuota -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RetainDeletedItemsUntilBackup" -Type "Boolean" -ExpectedValue $RetainDeletedItemsUntilBackup -ActualValue $db.RetainDeletedItemsUntilBackup -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }
    
    return $true
}

#Runs Get-MailboxDatabase, only specifying Identity and optionally DomainController
function GetMailboxDatabase
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $Name}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue)
}

#Moves the database or log path. Doesn't validate that the DB is in a good condition to move. Caller should do that.
function MoveDatabaseOrLogPath
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )
    
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $Name}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController","EdbFilePath","LogFolderPath"

    Move-DatabasePath @PSBoundParameters -Confirm:$false -Force
}

#Mounts the specified database
function MountDatabase
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [System.String]
        $CalendarLoggingQuota,

        [System.Boolean]
        $CircularLoggingEnabled,

        [ValidateSet("None","SecondCopy","SecondDatacenter","AllDatacenters","AllCopies")]
        [System.String]
        $DataMoveReplicationConstraint,

        [System.String]
        $DeletedItemRetention,

        [System.String]
        $DomainController,

        [System.String]
        $EventHistoryRetentionPeriod,

        [System.Boolean]
        $IndexEnabled,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.String]
        $IsExcludedFromProvisioningReason,

        [System.String]
        $IssueWarningQuota,

        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [System.String]
        $JournalRecipient,

        [System.String]
        $MailboxRetention,

        [System.Boolean]
        $MountAtStartup,

        [System.String]
        $OfflineAddressBook,

        [System.String]
        $ProhibitSendQuota,

        [System.String]
        $ProhibitSendReceiveQuota,

        [System.String]
        $RecoverableItemsQuota,

        [System.String]
        $RecoverableItemsWarningQuota,

        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [System.String]
        $AdServerSettingsPreferredServer,

        [System.Boolean]
        $SkipInitialDatabaseMount
    )
    
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $Name}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    NotePreviousError

    Mount-Database @PSBoundParameters

    ThrowIfNewErrorsEncountered -CmdletBeingRun "Mount-Database" -VerbosePreference $VerbosePreference
}

Export-ModuleMember -Function *-TargetResource



