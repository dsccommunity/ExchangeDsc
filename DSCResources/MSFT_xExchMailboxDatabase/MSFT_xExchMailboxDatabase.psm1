<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
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
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Write-FunctionEntry -Parameters @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxDatabase', 'Set-AdServerSettings' -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = Get-MailboxDatabaseInternal @PSBoundParameters

    if ($null -ne $db)
    {
        $returnValue = @{
            Name                          = [System.String] $Name
            Server                        = [System.String] $Server
            EdbFilePath                   = [System.String] $EdbFilePath
            LogFolderPath                 = [System.String] $LogFolderPath
            DatabaseCopyCount             = [System.UInt32] $DatabaseCopyCount
            AllowFileRestore              = [System.Boolean] $db.AllowFileRestore
            AutoDagExcludeFromMonitoring  = [System.Boolean] $db.AutoDagExcludeFromMonitoring
            BackgroundDatabaseMaintenance = [System.Boolean] $db.BackgroundDatabaseMaintenance
            CalendarLoggingQuota          = [System.String] $db.CalendarLoggingQuota
            CircularLoggingEnabled        = [System.Boolean] $db.CircularLoggingEnabled
            DataMoveReplicationConstraint = [System.String] $db.DataMoveReplicationConstraint
            DeletedItemRetention          = [System.String] $db.DeletedItemRetention
            EventHistoryRetentionPeriod   = [System.String] $db.EventHistoryRetentionPeriod
            IsExcludedFromProvisioning    = [System.Boolean] $db.IsExcludedFromProvisioning
            IssueWarningQuota             = [System.String] $db.IssueWarningQuota
            IsSuspendedFromProvisioning   = [System.Boolean] $db.IsSuspendedFromProvisioning
            JournalRecipient              = [System.String] $db.JournalRecipient
            MailboxRetention              = [System.String] $db.MailboxRetention
            MountAtStartup                = [System.Boolean] $db.MountAtStartup
            OfflineAddressBook            = [System.String] $db.OfflineAddressBook
            ProhibitSendQuota             = [System.String] $db.ProhibitSendQuota
            ProhibitSendReceiveQuota      = [System.String] $db.ProhibitSendReceiveQuota
            RecoverableItemsQuota         = [System.String] $db.RecoverableItemsQuota
            RecoverableItemsWarningQuota  = [System.String] $db.RecoverableItemsWarningQuota
            RetainDeletedItemsUntilBackup = [System.Boolean] $db.RetainDeletedItemsUntilBackup
            SkipInitialDatabaseMount      = [System.Boolean] $SkipInitialDatabaseMount
        }

        $serverVersion = Get-ExchangeVersionYear

        if ($serverVersion -in '2013', '2016')
        {
            $returnValue.Add('IndexEnabled', [System.Boolean] $db.IndexEnabled)
        }

        if ($serverVersion -in '2016', '2019')
        {
            $returnValue.Add('IsExcludedFromProvisioningByOperator', [System.Boolean] $db.IsExcludedFromProvisioningByOperator)
            $returnValue.Add('IsExcludedFromProvisioningDueToLogicalCorruption', [System.Boolean] $db.IsExcludedFromProvisioningDueToLogicalCorruption)
            $returnValue.Add('IsExcludedFromProvisioningReason', [System.String] $db.IsExcludedFromProvisioningReason)
        }

        if ($serverVersion -in '2019')
        {
            $returnValue.Add('MetaCacheDatabaseMaxCapacityInBytes', [System.Int64] $db.MetaCacheDatabaseMaxCapacityInBytes)
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Write-FunctionEntry -Parameters  @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential `
        -CommandsToLoad '*MailboxDatabase', 'Move-DatabasePath', 'Mount-Database', 'Set-AdServerSettings'`
        -Verbose:$VerbosePreference

    # Check for non-existent parameters in Exchange 2013
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningByOperator' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningDueToLogicalCorruption' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningReason' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    # Check for non-existent parameters in Exchange 2013 or 2016
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'MetaCacheDatabaseMaxCapacityInBytes' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2019'

    # Check for non-existent parameters in Exchange 2019
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IndexEnabled' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2013', '2016'

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = Get-MailboxDatabaseInternal @PSBoundParameters

    if ($null -eq $db) # Need to create a new DB
    {
        # Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Name', 'Server', 'EdbFilePath', 'LogFolderPath', 'DomainController'

        # Create the database
        $db = New-MailboxDatabase @PSBoundParameters

        if ($null -ne $db)
        {
            # Add original props back
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

            if ($AllowServiceRestart -eq $true)
            {
                Write-Verbose -Message 'Restarting Information Store'

                Restart-Service MSExchangeIS
            }
            else
            {
                Write-Warning -Message 'The configuration will not take effect until MSExchangeIS is manually restarted.'
            }

            # If MountAtStartup is not explicitly set to $false, mount the new database
            if ($PSBoundParameters.ContainsKey('SkipInitialDatabaseMount') -eq $true -and $SkipInitialDatabaseMount -eq $true)
            {
                # Don't mount the DB, regardless of what else is set.
            }
            elseif ($PSBoundParameters.ContainsKey('MountAtStartup') -eq $false -or $MountAtStartup -eq $true)
            {
                Write-Verbose -Message 'Attempting to mount database.'

                Mount-DatabaseInternal @PSBoundParameters
            }
        }
        else
        {
            throw 'Failed to create new Mailbox Database'
        }
    }

    if ($null -ne $db) # Set props on existing DB
    {
        # First check if a DB or log move is required
        if (($PSBoundParameters.ContainsKey('EdbFilePath') -and (Compare-StringToString -String1 $db.EdbFilePath.PathName -String2 $EdbFilePath -IgnoreCase) -eq $false) -or
            ($PSBoundParameters.ContainsKey('LogFolderPath') -and (Compare-StringToString -String1 $db.LogFolderPath.PathName -String2 $LogFolderPath -IgnoreCase) -eq $false))
        {
            if ($db.DatabaseCopies.Count -le 1)
            {
                Write-Verbose -Message 'Moving database and/or log path'

                Move-DatabaseOrLogPath @PSBoundParameters
            }
            else
            {
                throw 'Database must have only a single copy for the DB path or log path to be moved'
            }
        }

        # setup params
        Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
            'Name' = $Name
        }
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
            -ParamsToRemove 'Name', 'Server', 'DatabaseCopyCount', 'AllowServiceRestart', 'EdbFilePath', 'LogFolderPath', 'Credential', 'AdServerSettingsPreferredServer', 'SkipInitialDatabaseMount'

        # Remove parameters that depend on all copies being added
        if ($db.DatabaseCopies.Count -lt $DatabaseCopyCount)
        {
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
                -ParamsToRemove 'CircularLoggingEnabled', 'DataMoveReplicationConstraint'
        }

        Set-MailboxDatabase @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
#>
function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Write-FunctionEntry -Parameters  @{
        'Name' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential `
        -CommandsToLoad 'Get-MailboxDatabase', 'Get-Recipient', 'Set-AdServerSettings'`
        -Verbose:$VerbosePreference

    # Check for non-existent parameters in Exchange 2013
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningByOperator' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningDueToLogicalCorruption' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IsExcludedFromProvisioningReason' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2016', '2019'

    # Check for non-existent parameters in Exchange 2013 or 2016
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'MetaCacheDatabaseMaxCapacityInBytes' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2019'

    # Check for non-existent parameters in Exchange 2019
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'IndexEnabled' `
        -ResourceName 'xExchMailboxDatabase' `
        -ParamExistsInVersion '2013', '2016'

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = Get-MailboxDatabaseInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $db)
    {
        Write-Verbose -Message 'Unable to retrieve Mailbox Database settings or Mailbox Database does not exist'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'AllowFileRestore' -Type 'Boolean' -ExpectedValue $AllowFileRestore -ActualValue $db.AllowFileRestore -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDagExcludeFromMonitoring' -Type 'Boolean' -ExpectedValue $AutoDagExcludeFromMonitoring -ActualValue $db.AutoDagExcludeFromMonitoring -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'BackgroundDatabaseMaintenance' -Type 'Boolean' -ExpectedValue $BackgroundDatabaseMaintenance -ActualValue $db.BackgroundDatabaseMaintenance -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'CalendarLoggingQuota' -Type 'Unlimited' -ExpectedValue $CalendarLoggingQuota -ActualValue $db.CalendarLoggingQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        # Only check these if all copies have been added
        if ($db.DatabaseCopies.Count -ge $DatabaseCopyCount)
        {
            if (!(Test-ExchangeSetting -Name 'CircularLoggingEnabled' -Type 'Boolean' -ExpectedValue $CircularLoggingEnabled -ActualValue $db.CircularLoggingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }

            if (!(Test-ExchangeSetting -Name 'DataMoveReplicationConstraint' -Type 'String' -ExpectedValue $DataMoveReplicationConstraint -ActualValue $db.DataMoveReplicationConstraint -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
            {
                $testResults = $false
            }
        }

        if (!(Test-ExchangeSetting -Name 'DeletedItemRetention' -Type 'Timespan' -ExpectedValue $DeletedItemRetention -ActualValue $db.DeletedItemRetention -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'EdbFilePath' -Type 'String' -ExpectedValue $EdbFilePath -ActualValue $db.EdbFilePath.PathName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'EventHistoryRetentionPeriod' -Type 'Timespan' -ExpectedValue $EventHistoryRetentionPeriod -ActualValue $db.EventHistoryRetentionPeriod -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IndexEnabled' -Type 'Boolean' -ExpectedValue $IndexEnabled -ActualValue $db.IndexEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IsExcludedFromProvisioning' -Type 'Boolean' -ExpectedValue $IsExcludedFromProvisioning -ActualValue $db.IsExcludedFromProvisioning -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IsExcludedFromProvisioningReason' -Type 'String' -ExpectedValue $IsExcludedFromProvisioningReason -ActualValue $db.IsExcludedFromProvisioningReason -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IsExcludedFromProvisioningByOperator' -Type 'Boolean' -ExpectedValue $IsExcludedFromProvisioningByOperator -ActualValue $db.IsExcludedFromProvisioningByOperator -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IsExcludedFromProvisioningDueToLogicalCorruption' -Type 'Boolean' -ExpectedValue $IsExcludedFromProvisioningDueToLogicalCorruption -ActualValue $db.IsExcludedFromProvisioningDueToLogicalCorruption -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IssueWarningQuota' -Type 'Unlimited' -ExpectedValue $IssueWarningQuota -ActualValue $db.IssueWarningQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'IsSuspendedFromProvisioning' -Type 'Boolean' -ExpectedValue $IsSuspendedFromProvisioning -ActualValue $db.IsSuspendedFromProvisioning -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'JournalRecipient' -Type 'ADObjectID' -ExpectedValue $JournalRecipient -ActualValue $db.JournalRecipient -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'LogFolderPath' -Type 'String' -ExpectedValue $LogFolderPath -ActualValue $db.LogFolderPath.PathName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MailboxRetention' -Type 'Timespan' -ExpectedValue $MailboxRetention -ActualValue $db.MailboxRetention -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MetaCacheDatabaseMaxCapacityInBytes' -Type 'Int' -ExpectedValue $MetaCacheDatabaseMaxCapacityInBytes -ActualValue $db.MetaCacheDatabaseMaxCapacityInBytes -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'MountAtStartup' -Type 'Boolean' -ExpectedValue $MountAtStartup -ActualValue $db.MountAtStartup -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        # Strip leading slash off the OAB now so it's easier to check
        if ($PSBoundParameters.ContainsKey('OfflineAddressBook'))
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

        if (!(Test-ExchangeSetting -Name 'OfflineAddressBook' -Type 'String' -ExpectedValue $OfflineAddressBook -ActualValue $dbOab -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ProhibitSendQuota' -Type 'Unlimited' -ExpectedValue $ProhibitSendQuota -ActualValue $db.ProhibitSendQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ProhibitSendReceiveQuota' -Type 'Unlimited' -ExpectedValue $ProhibitSendReceiveQuota -ActualValue $db.ProhibitSendReceiveQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RecoverableItemsQuota' -Type 'Unlimited' -ExpectedValue $RecoverableItemsQuota -ActualValue $db.RecoverableItemsQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RecoverableItemsWarningQuota' -Type 'Unlimited' -ExpectedValue $RecoverableItemsWarningQuota -ActualValue $db.RecoverableItemsWarningQuota -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'RetainDeletedItemsUntilBackup' -Type 'Boolean' -ExpectedValue $RetainDeletedItemsUntilBackup -ActualValue $db.RetainDeletedItemsUntilBackup -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Runs Get-MailboxDatabase, only specifying Identity and optionally
        DomainController.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
#>
function Get-MailboxDatabaseInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd  @{
        'Name' = $Name
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-MailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue)
}

<#
    .SYNOPSIS
        Moves the database or log path. Doesn't validate that the DB is in a
        good condition to move. Caller should do that.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
#>
function Move-DatabaseOrLogPath
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd  @{
        'Name' = $Name
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController', 'EdbFilePath', 'LogFolderPath'

    Move-DatabasePath @PSBoundParameters -Confirm:$false -Force
}

<#
    .SYNOPSIS
        Mounts the specified database.

    .PARAMETER Name
        The Name parameter specifies the unique name of the mailbox database.

    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.

    .PARAMETER DatabaseCopyCount
        The number of copies that the database will have once fully configured.

    .PARAMETER EdbFilePath
        The EdbFilePath parameter specifies the path to the database files.

    .PARAMETER LogFolderPath
        The LogFolderPath parameter specifies the folder location for log
        files.

    .PARAMETER Server
        The Server parameter specifies the server on which you want to create
        the database.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowFileRestore
        The AllowFileRestore parameter specifies whether to allow a database to
        be restored from a backup.

    .PARAMETER AllowServiceRestart
        Whether it is okay to restart the Information Store Service after
        adding a database. Defaults to $false.

    .PARAMETER AutoDagExcludeFromMonitoring
        The AutoDagExcludedFromMonitoringparameter specifies whether to
        exclude the mailbox database from the ServerOneCopyMonitor, which
        alerts an administrator when a replicated database has only one healthy
        copy available.

    .PARAMETER BackgroundDatabaseMaintenance
        The BackgroundDatabaseMaintenance parameter specifies whether the
        Extensible Storage Engine (ESE) performs database maintenance.

    .PARAMETER CalendarLoggingQuota
        The CalendarLoggingQuota parameter specifies the maximum size of the
        log in the Recoverable Items folder of the mailbox that stores
        changes to calendar items.

    .PARAMETER CircularLoggingEnabled
        The CircularLoggingEnabled parameter specifies whether circular
        logging is enabled for the database.

    .PARAMETER DataMoveReplicationConstraint
        The DataMoveReplicationConstraint parameter specifies the throttling
        behavior for high availability mailbox moves.

    .PARAMETER DeletedItemRetention
        The DeletedItemRetention parameter specifies the length of time to keep
        deleted items in the Recoverable Items\Deletions folder in mailboxes.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER EventHistoryRetentionPeriod
        The EventHistoryRetentionPeriod parameter specifies the length of time
        to keep event data.

    .PARAMETER IndexEnabled
        The IndexEnabled parameter specifies whether Exchange Search indexes
        the mailbox database.

    .PARAMETER IsExcludedFromProvisioning
        The IsExcludedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningByOperator
        The IIsExcludedFromProvisioningByOperator parameter specifies whether
        to exclude the database from the mailbox provisioning load balancer
        that distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER IsExcludedFromProvisioningDueToLogicalCorruption
        The IsExcludedFromProvisioningDueToLogicalCorruption parameter
        specifies whether to exclude the database from the mailbox
        provisioning load balancer that distributes new mailboxes randomly and
        evenly across the available databases.

    .PARAMETER IsExcludedFromProvisioningReason
        The IsExcludedFromProvisioningReason parameter specifies the reason
        why you excluded the mailbox database from the mailbox provisioning
        load balancer.

    .PARAMETER IssueWarningQuota
        The IssueWarningQuota parameter specifies the warning threshold for the
        size of the mailbox.

    .PARAMETER IsSuspendedFromProvisioning
        The IsSuspendedFromProvisioning parameter specifies whether to exclude
        the database from the mailbox provisioning load balancer that
        distributes new mailboxes randomly and evenly across the available
        databases.

    .PARAMETER JournalRecipient
        The JournalRecipient parameter specifies the journal recipient to use
        for per-database journaling for all mailboxes on the database.

    .PARAMETER MailboxRetention
        The MailboxRetention parameter specifies the length of time to keep
        deleted mailboxes before they are permanently deleted or purged.

    .PARAMETER MetaCacheDatabaseMaxCapacityInBytes
        The MetaCacheDatabaseMaxCapacityInBytes parameter specifies the size of
        the metacache database in bytes. To convert gigabytes to bytes,
        multiply the value by 1024^3. For terabytes to bytes, multiply by
        1024^4.

    .PARAMETER MountAtStartup
        The MountAtStartup parameter specifies whether to mount the mailbox
        database when the Microsoft Exchange Information Store service starts.

    .PARAMETER OfflineAddressBook
        The OfflineAddressBook parameter specifies the offline address book
        that's associated with the mailbox database.

    .PARAMETER ProhibitSendQuota
        The ProhibitSendQuota parameter specifies a size limit for the mailbox.
        If the mailbox reaches or exceeds this size, the mailbox can't send
        new messages, and the user receives a descriptive warning message.

    .PARAMETER ProhibitSendReceiveQuota
        The ProhibitSendReceiveQuota parameter specifies a size limit for the
        mailbox. If the mailbox reaches or exceeds this size, the mailbox can't
        send or receive new messages. Messages sent to the mailbox are returned
        to the sender with a descriptive error message. This value effectively
        determines the maximum size of the mailbox.

    .PARAMETER RecoverableItemsQuota
        The RecoverableItemsQuota parameter specifies the maximum size for the
        Recoverable Items folder of the mailbox.

    .PARAMETER RecoverableItemsWarningQuota
        The RecoverableItemsWarningQuota parameter specifies the warning
        threshold for the size of the Recoverable Items folder for the mailbox.

    .PARAMETER RetainDeletedItemsUntilBackup
        The RetainDeletedItemsUntilBackup parameter specifies whether to keep
        items in the Recoverable Items\Deletions folder of the mailbox until
        the next database backup occurs.

    .PARAMETER SkipInitialDatabaseMount
        Whether the initial mount of databases should be skipped after database
        creation.
#>
function Mount-DatabaseInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.UInt32]
        $DatabaseCopyCount,

        [Parameter(Mandatory = $true)]
        [System.String]
        $EdbFilePath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LogFolderPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Server,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

        [Parameter()]
        [System.Boolean]
        $AllowFileRestore,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoDagExcludeFromMonitoring,

        [Parameter()]
        [System.Boolean]
        $BackgroundDatabaseMaintenance,

        [Parameter()]
        [System.String]
        $CalendarLoggingQuota,

        [Parameter()]
        [System.Boolean]
        $CircularLoggingEnabled,

        [Parameter()]
        [ValidateSet('None', 'SecondCopy', 'SecondDatacenter', 'AllDatacenters', 'AllCopies')]
        [System.String]
        $DataMoveReplicationConstraint,

        [Parameter()]
        [System.String]
        $DeletedItemRetention,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $EventHistoryRetentionPeriod,

        [Parameter()]
        [System.Boolean]
        $IndexEnabled,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioning,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningByOperator,

        [Parameter()]
        [System.Boolean]
        $IsExcludedFromProvisioningDueToLogicalCorruption,

        [Parameter()]
        [System.String]
        $IsExcludedFromProvisioningReason,

        [Parameter()]
        [System.String]
        $IssueWarningQuota,

        [Parameter()]
        [System.Boolean]
        $IsSuspendedFromProvisioning,

        [Parameter()]
        [System.String]
        $JournalRecipient,

        [Parameter()]
        [System.String]
        $MailboxRetention,

        [Parameter()]
        [System.Int64]
        $MetaCacheDatabaseMaxCapacityInBytes,

        [Parameter()]
        [System.Boolean]
        $MountAtStartup,

        [Parameter()]
        [System.String]
        $OfflineAddressBook,

        [Parameter()]
        [System.String]
        $ProhibitSendQuota,

        [Parameter()]
        [System.String]
        $ProhibitSendReceiveQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsQuota,

        [Parameter()]
        [System.String]
        $RecoverableItemsWarningQuota,

        [Parameter()]
        [System.Boolean]
        $RetainDeletedItemsUntilBackup,

        [Parameter()]
        [System.Boolean]
        $SkipInitialDatabaseMount
    )

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd  @{
        'Name' = $Name
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $previousError = Get-PreviousError

    Mount-Database @PSBoundParameters

    Assert-NoNewError -CmdletBeingRun 'Mount-Database' -PreviousError $previousError -Verbose:$VerbosePreference
}

Export-ModuleMember -Function *-TargetResource
