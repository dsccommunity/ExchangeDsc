[![Build status](https://ci.appveyor.com/api/projects/status/k9oq77p9xn6bo2j6/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xexchange/branch/master)

# xExchange

The **xExchange** module contains many DSC resources for configuring and managing Exchange 2013 and 2016 servers including individual server properties, databases, mount points, and Database Availability Groups.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **xExchActiveSyncVirtualDirectory**
* **xExchAntiMalwareScanning** is used to enable or disable Exchange Anti-malware scanning
* **xExchAutodiscoverVirtualDirectory**
* **xExchAutoMountPoint**
* **xExchClientAccessServer**
* **xExchDatabaseAvailabilityGroup** configures a Database Availability Group using New/Set-DatabaseAvailibilityGroup. 
* **xExchDatabaseAvailabilityGroupMember** adds a member to a Database Availability Group.
* **xExchDatabaseAvailabilityGroupNetwork** can add, remove, or configure a Database Availability Group Network. 
* **xExchEcpVirtualDirectory**
* **xExchEventLogLevel** is used to configure Exchange diagnostic logging via Set-EventLogLevel.
* **xExchExchangeCertificate** can install, remove, or configure an ExchangeCertificate using *-ExchangeCertificate cmdlets.
* **xExchExchangeServer**
* **xExchImapSettings** configures IMAP settings using Set-ImapSettings.
* **xExchInstall** installs Exchange 2013 or 2016.
* **xExchJetstress** automatically runs Jetstress using the **JetstressCmd.exe** command line executable. 
* **xExchJetstressCleanup** cleans up the database and log directories created by Jetstress.
* **xExchMailboxDatabase**
* **xExchMailboxDatabaseCopy**
* **xExchMailboxTransportService**
* **xExchMailboxServer**
* **xExchMaintenanceMode**
* **xExchMapiVirtualDirectory**
* **xExchOabVirtualDirectory**
* **xExchOutlookAnywhere**
* **xExchOwaVirtualDirectory**
* **xExchPopSettings** configures POP settings using Set-PopSettings.
* **xExchPowerShellVirtualDirectory**
* **xExchReceiveConnector**
* **xExchTransportService**
* **xExchUMCallRouterSettings** configures the UM Call Router service using Set-UMCallRouterSettings.
* **xExchUMService** configures a UM server using Set-UMService.
* **xExchWaitForADPrep** ensures that Active Directory has been prepared for Exchange 2013 or 2016.
* **xExchWaitForDAG**
* **xExchWaitForMailboxDatabase**
* **xExchWebServicesVirtualDirectory**

### xExchActiveSyncVirtualDirectory

Where no description is listed, properties correspond directly to [Set-ActiveSyncVirtualDirectory](http://technet.microsoft.com/en-us/library/bb123679(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the ActiveSync Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is okay to recycle the app pool, or restart IIS after making changes. 
Defaults to $false. 
* **AutoCertBasedAuth**: Automates the IIS configuration portion of certificate based authentication. 
Only works against the Default Web Site. 
Does not configure ClientCertAuth parameter, which must be specified separately. 
Does not install ?Client Certificate Mapping Authentication? or ?IIS Client Certificate Mapping Authentication? roles of IIS, which also must be configured separately.
* **AutoCertBasedAuthThumbprint**: The thumbprint of the in use Exchange certificate for IIS.
* **AutoCertBasedAuthHttpsBindings**: The (IP:PORT)'s of the HTTPS bindings on the Default Web Site. 
Defaults to "0.0.0.0:443","127.0.0.1:443"
* **BasicAuthEnabled**
* **ClientCertAuth**
* **CompressionEnabled**
* **DomainController**
* **ExternalAuthenticationMethods**
* **ExternalUrl**
* **InternalAuthenticationMethods**
* **InternalUrl**
* **WindowsAuthEnabled**: Auto Certificate Based Authentication Requirements: For AutoCertBasedAuth to work, the ?Client Certificate Mapping Authentication? and ?IIS Client Certificate Mapping Authentication? roles of IIS need to be installed.

### xExchAntiMalwareScanning

**xExchAntiMalwareScanning** is used to enable or disable Exchange Anti-malware scanning.

* **Enabled**: Whether Exchange Anti-malware scanning should be Enabled.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether the Transport services should be automatically restarted after a status change.

## xExchAutodiscoverVirtualDirectory

Where no description is listed, properties correspond directly to [Set-AutodiscoverVirtualDirectory](http://technet.microsoft.com/en-us/library/aa998601(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the Autodiscover Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange
* **AllowServiceRestart**: Whether it is okay to recycle the app pool after making changes. 
Defaults to $false.
* **BasicAuthEnabled**
* **DigestAuthentication**
* **DomainController**
* **WindowsAuthEnabled**
* **WSSecurityAuthentication**

### xExchAutoMountPoint

**xExchAutoMountPoint** is used to automatically find unused disks, and prepare them for use within AutoReseed. 
With the disks that are found, it will assign appropriate volume and database mount points. 
Once fully configured, if a disk fails and is replaced with a new disk, xExchAutoMountPoint will automatically detect it and format and assign an Exchange volume mount point so that AutoReseed can detect it as a spare disk. 

* **Identity**: The name of the server. 
This is not actually used for anything.
* **AutoDagDatabasesRootFolderPath**: The parent folder for Exchange database mount point folders.
* **AutoDagVolumesRootFolderPath**: The parent folder for Exchange volume mount point folders.
* **DiskToDBMap**: An array of strings containing the databases for each disk. 
Databases on the same disk should be in the same string, and comma separated. 
Example: "DB1,DB2","DB3,DB4". 
This puts DB1 and DB2 on one disk, and DB3 and DB4 on another.
* **SpareVolumeCount**: How many spare volumes will be available.
* **CreateSubfolders**: Defaults to $false. 
If $true, specifies that DBNAME.db and DBNAME.log subfolders should be automatically created underneath the ExchangeDatabase mount points.
* **FileSystem**: The file system to use when formatting the volume. 
Defaults to NTFS.
* **MinDiskSize**: The minimum size of a disk to consider using. 
Defaults to none. 
Should be in a format like "1024MB" or "1TB".
* **PartitioningScheme**: The partitioning scheme for the volume. 
Defaults to GPT.
* **UnitSize**: The unit size to use when formatting the disk. 
Defaults to 64k. Specified value should end in a number, indicating bytes, or with a k, indicating the value is kilobytes.
* **VolumePrefix**: The prefix to give to Exchange Volume folders. 
Defaults to EXVOL

#### Common Issues
xExchAutoMountPoint will not assign an Exchange database mount point if the target folder for the database already exists. 
If initial setup fails, make sure that the database folders do not already exist. 
Note that this only affects database folders. 
If a volume folder already exists, the resource will just find the next unused number and assign it to a new volume folder.

### xExchClientAccessServer

Where no description is listed, properties correspond directly to [Set-ClientAccessServer](http://technet.microsoft.com/en-us/library/bb125157(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the Autodiscover Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AutoDiscoverServiceInternalUri**
* **AutoDiscoverSiteScope**
* **DomainController**

### xExchDatabaseAvailabilityGroup

**xExchDatabaseAvailabilityGroup** configures a Database Availability Group using New/Set-DatabaseAvailibilityGroup.  
Only a single node in a configuration script should implement this resource.
All DAG nodes, including the node implementing **xExchDatabaseAvailabilityGroup**, should use **xExchDatabaseAvailabilityGroupMember** to join a DAG. 

Where no description is listed, properties correspond directly to [Set-DatabaseAvailabilityGroup](http://technet.microsoft.com/en-us/library/dd297934(v=exchg.150).aspx) parameters.

* **Name**: The name of the Database Availability Group.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AutoDagTotalNumberOfServers**: Required to determine when all DAG members have been added. 
DatacenterActivationMode will not be set until that occurs.
* **AlternateWitnessDirectory**
* **AlternateWitnessServer**
* **AutoDagAutoRedistributeEnabled**
* **AutoDagAutoReseedEnabled**
* **AutoDagDatabaseCopiesPerDatabase**
* **AutoDagDatabaseCopiesPerVolume**
* **AutoDagDatabasesRootFolderPath**
* **AutoDagDiskReclaimerEnabled**
* **AutoDagTotalNumberOfDatabases**
* **AutoDagVolumesRootFolderPath**
* **DatabaseAvailabilityGroupIpAddresses**
* **DatacenterActivationMode**
* **DomainController**
* **FileSystem**
* **ManualDagNetworkConfiguration**
* **NetworkCompression**
* **NetworkEncryption**
* **PreferenceMoveFrequency**
* **ReplayLagManagerEnabled**
* **ReplicationPort**
* **WitnessDirectory**
* **WitnessServer**
* **SkipDagValidation**

#### Common Issues
DAG creation will fail if the computer account of the node managing the DAG does not have permissions to create computers in Active Directory. 
To avoid this issue, you may need to [make sure that the computer account for the DAG is prestaged](http://technet.microsoft.com/en-us/library/ff367878(v=exchg.150).aspx).
To disable PreferenceMoveFrequency you have to use the following value:"$(([System.Threading.Timeout]::InfiniteTimeSpan).ToString())"

### xExchDatabaseAvailabilityGroupMember 

***xExchDatabaseAvailabilityGroupMember** adds a member to a Database Availability Group. 
This must be implemented by all nodes, including the one that creates and maintains the DAG. 

Where no description is listed, properties correspond directly to [Add-DatabaseAvailabilityGroupServer](http://technet.microsoft.com/en-us/library/dd298049(v=exchg.150).aspx) parameters.

* **MailboxServer**: The hostname of the server to add to the DAG.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **DAGName**: The name of the DAG to add the member to.
* **DomainController**
* **SkipDagValidation**

### xExchDatabaseAvailabilityGroupNetwork

**xExchDatabaseAvailabilityGroupNetwork** can add, remove, or configure a Database Availability Group Network. 
This should only be implemented by a single node in the DAG. 

Where no description is listed, properties correspond directly to [Set-DatabaseAvailabilityGroupNetwork](http://technet.microsoft.com/en-us/library/dd298008(v=exchg.150).aspx) parameters.

* **Name**: The name of the DAG network
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **DatabaseAvailabilityGroup**: The name of the DAG where the network exists.
* **Ensure**: Whether the DAG network should exist or not: { Present | Absent }
* **Description**
* **DomainController**
* **IgnoreNetwork**
* **ReplicationEnabled**
* **Subnets**

### xExchEcpVirtualDirectory

Where no description is listed, properties correspond directly to [Set-EcpVirtualDirectory](http://technet.microsoft.com/en-us/library/dd297991(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the ECP Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to recycle the app pool after making changes. Defaults to $false.
* **AdfsAuthentication**
* **BasicAuthentication**
* **DigestAuthentication**
* **DomainController**
* **ExternalAuthenticationMethods**
* **FormsAuthentication**
* **ExternalUrl**
* **InternalUrl**
* **WindowsAuthentication**
* **WSSecurityAuthentication**

### xExchEventLogLevel

**xExchEventLogLevel** is used to configure Exchange diagnostic logging via Set-EventLogLevel.

Properties correspond to [Set-EventLogLevel](https://technet.microsoft.com/en-us/library/aa998905(v=exchg.150).aspx) parameters.

* **Identity**: The Identity parameter specifies the name of the event logging category for which you want to set the event logging level. Do not specify servername within the Identity.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **Level**: The Level parameter specifies the log level for the specific event logging category. Valid values are Lowest, Low, Medium, High, and Expert.

### xExchExchangeCertificate

xExchExchangeCertificate can install, remove, or configure an ExchangeCertificate using *-ExchangeCertificate cmdlets.

* **Thumbprint**: The Thumbprint of the Exchange Certificate to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **Ensure**: Whether the Exchange Certificate should exist or not: { Present | Absent }
* **AllowExtraServices**: Get-ExchangeCertificate sometimes displays more services than are actually enabled. 
Setting this to true allows tests to pass in that situation as long as the requested services are present.
* **CertCreds**: Credentials containing the password to the .pfx file in CertFilePath.
* **CertFilePath**: The file path to the certificate .pfx file that should be imported.
* **DomainController**: Domain Controller to talk to.
* **Services**: Services to enable on the certificate. 
See [Enable-ExchangeCertificate](http://technet.microsoft.com/en-us/library/aa997231(v=exchg.150).aspx) documentation.

### xExchExchangeServer

Where no description is listed, properties correspond directly to [Set-ExchangeServer](http://technet.microsoft.com/en-us/library/bb123716(v=exchg.150).aspx) parameters.

* **Identity**: The hostname of the Exchange Server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart the Information Store service after licensing the server. 
Defaults to $false.
* **CustomerFeedbackEnabled**
* **DomainController**
* **InternetWebProxy**
* **MonitoringGroup**
* **ProductKey**
* **WorkloadManagementPolicy**

### xExchImapSettings

**xExchImapSettings** configures IMAP settings using Set-ImapSettings.

* **Server**: Hostname of the IMAP server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart the IMAP services after making changes. 
Defaults to $false.
* **DomainController**: Optional Domain Controller to connect to.
* **ExternalConnectionSettings**: Specifies the host name, port, and encryption type that Exchange uses when IMAP clients connect to their email from the outside.
* **LoginType**: The LoginType to be used for IMAP.
* **X509CertificateName**: Specifies the host name in the SSL certificate from the Associated Subject field.

### xExchInstall 

**xExchInstall** installs Exchange 2013 or 2016.

* **Path**: Full path to setup.exe in the Exchange 2013 or 2016 setup directory.
* **Arguments**: Command line arguments to pass to setup.exe
* **Credential**: The credentials to use to perform the installation.

### xExchJetstress

**xExchJetstress** automatically runs Jetstress using the **JetstressCmd.exe** command line executable. 
The resource launches Jetstress via a Scheduled Task, then monitors for JetstressCmd.exe to determine whether Jetstress is running. 
Once JetstressCmd.exe has finished, xExchJetstress looks for the existence of **TYPE*.html** files in the Jetstress installation directory to determine whether Jetstress has already been run, or if it needs to be executed. 
**TYPE** corresponds to the Type defined in the **JetstressConfig.xml** file, where valid values are **Performance**, **Stress**, **DatabaseBackup**, or **SoftRecovery**. 
If TYPE*.html files exist, the newest file is inspected to determine whether the Jetstress run resulted in a **Pass** or **Fail**. 
Note that a **TYPE*.html** file is not written until Jetstress has finished its initialization phase, and has also finished the testing phase with either a **Pass** or a **Fail**. 
A crash of the JetstressCmd.exe process will also prevent the file from being written.

* **Type**: Specifies the Type which was defined in the JetstressConfig.xml file: { Performance | Stress | DatabaseBackup | SoftRecovery }
* **JetstressPath**: The path to the folder where Jetstress is installed, and which contains JetstressCmd.exe.
* **JetstressParams**: Command line parameters to pass into JetstressCmd.exe.
* **MaxWaitMinutes**: The maximum amount of time that the Scheduled Task which runs Jetstress can execute for. 
Defaults to 0, which means there is no time limit.
* **MinAchievedIOPS**: The minimum value reported in the 'Achieved Transactional I/O per Second' section of the Jetstress report for the run to be considered successful. 
Defaults to 0. 
    - **WARNING 1:** Jetstress should **NEVER** be run on a server that already has Exchange installed. 
    Jetstress is only meant to be used for pre-installation server validation.
    As such, it is recommended that **xExchJetstress** be used in a one time script which is separate from the script that performs ongoing server configuration validation.
    - **WARNING 2:** **xExchJetstress** should **NOT** be used in the same configuration script as **xExchJetstressCleanup**. 
    Instead, they should be run in separate scripts.
    Because **xExchJetstress** looks for files and folders that may have been cleaned up by **xExchJetstressCleanup**, using them in the same script may result in a configuration loop.

### xExchJetstressCleanup 

xExchJetstressCleanup cleans up the database and log directories created by Jetstress. 
It can optionally remove mount points associated with those directories, and can also remove the Jetstress binaries. 
Note that **xExchJetstressCleanup** does **NOT** uninstall Jetstress. 
That can be accomplished using the **Package** resource which is built into DSC.

* **JetstressPath**: The path to the folder where Jetstress is installed, which contains **JetstressCmd.exe**.
* ***ConfigFilePath**: The full path to **JetstressConfig.xml**, which will be used to determine the database and log folders that need to be removed.
* ***DatabasePaths**: Specifies the paths to database directories that should be cleaned up.
* **DeleteAssociatedMountPoints**: Indicates that the mount points associated with the Jetstress database and log paths should be removed. 
Defaults to $false. 
Does not remove EXVOL mount points.
* ***LogPaths**: Specifies the paths to log directories that should be cleaned up.
* **RemoveBinaries**: Specifies that the files located in **JetstressPath** should be removed. 
If **ConfigFilePath** is also specified and JetstressConfig.xml is in the same directory as JetstressPath, all files will be removed from the directory except JetstressConfig.xml.
* **OutputSaveLocation**: If **RemoveBinaries** is set to $true and Jetstress output was saved to the default location (**JetstressPath**), this specifies the folder path to copy the Jetstress output files to. 

Note: Either **ConfigFilePath**, or **DatabasePaths** AND **LogPaths** MUST be specified. **ConfigFilePath** takes precedence over **DatabasePaths** and **LogPaths**.

**WARNING:** **xExchJetstress** should NOT be used in the same configuration script as **xExchJetstressCleanup**. 
Instead, they should be run in separate scripts. 
Because **xExchJetstress** looks for files and folders that may have been cleaned up by **xExchJetstressCleanup**, using them in the same script may result in a configuration loop.

### xExchMailboxDatabase

Where no description is listed, properties correspond directly to [Set-MailboxDatabase](http://technet.microsoft.com/en-us/library/bb123971%28v=exchg.150%29.aspx) parameters.

* **Name**: The name of the Mailbox Database.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **DatabaseCopyCount**: The number of copies that the database will have once fully configured. 
If circular logging is configured, it will not be enabled until this number of copies is met.
* **EdbFilePath**: Full path to where the database file will be located.
* **LogFolderPath**: Folder where logs for the DB will exist.
* **Server**: The server to create the database on.
* **AllowServiceRestart**: Whether it is okay to restart the Information Store .service after adding a database. 
Defaults to $false.
* **AutoDagExcludeFromMonitoring**
* **BackgroundDatabaseMaintenance**
* **CalendarLoggingQuota**
* **CircularLoggingEnabled**: NOTE: Will not be enabled until the number of copies specified in DatabaseCopyCount have been added.
* **DataMoveReplicationConstraint**
* **DeletedItemRetention**
* **EventHistoryRetentionPeriod**
* **IndexEnabled**
* **IsExcludedFromProvisioning**
* **IsExcludedFromProvisioningReason**
* **IssueWarningQuota**
* **IsSuspendedFromProvisioning**
* **JournalRecipient**
* **MailboxRetention**
* **MountAtStartup**
* **OfflineAddressBook**
* **ProhibitSendQuota**
* **ProhibitSendReceiveQuota**
* **RecoverableItemsQuota**
* **RecoverableItemsWarningQuota**
* **RetainDeletedItemsUntilBackup**

### xExchMailboxDatabaseCopy

Where no description is listed, properties correspond directly to [Add-MailboxDatabaseCopy](http://technet.microsoft.com/en-us/library/dd298105(v=exchg.150).aspx) parameters.

* **Identity**: The name of the Mailbox Database.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **MailboxServer**: The server to create the database copy on.
* **AllowServiceRestart**: Whether it is OK to restart the Information Store service after adding a database copy. 
Defaults to $false.
* **ActivationPreference**
* **DomainController**
* **ReplayLagTime**
* **TruncationLagTime**

### xExchMailboxServer

**xExchMailboxServer** is used to configure Mailbox Server properties via Set-MailboxServer.

Properties correspond to [Set-MailboxServer](https://technet.microsoft.com/en-us/library/aa998651(v=exchg.160).aspx) parameters.

* **Identity**: The Identity parameter specifies the Mailbox server that you want to modify.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AutoDatabaseMountDial**: The AutoDatabaseMountDial parameter specifies the automatic database mount behavior for a continuous replication environment after a database failover.
* **CalendarRepairIntervalEndWindow**: The CalendarRepairIntervalEndWindow parameter specifies the number of days into the future to repair calendars. For example, if this parameter is set to 90, the Calendar Repair Assistant repairs calendars on this Mailbox server 90 days from now.
* **CalendarRepairLogDirectorySizeLimit**: The CalendarRepairLogDirectorySizeLimit parameter specifies the size limit for all log files for the Calendar Repair Assistant. After the limit is reached, the oldest files are deleted.
* **CalendarRepairLogEnabled**: The CalendarRepairLogEnabled parameter specifies whether the Calendar Repair Attendant logs items that it repairs. The repair log doesn't contain failed repair attempts.
* **CalendarRepairLogFileAgeLimit**: The CalendarRepairLogFileAgeLimit parameter specifies how long to retain calendar repair logs. Log files that exceed the maximum retention period are deleted.
* **CalendarRepairLogPath**: The CalendarRepairLogPath parameter specifies the location of the calendar repair log files on the Mailbox server.
* **CalendarRepairLogSubjectLoggingEnabled**: The CalendarRepairLogSubjectLoggingEnabled parameter specifies that the subject of the repaired calendar item is logged in the calendar repair log.
* **CalendarRepairMissingItemFixDisabled**: The CalendarRepairMissingItemFixDisabled parameter specifies that the Calendar Repair Assistant won't fix missing attendee calendar items for mailboxes homed on this Mailbox server.
* **CalendarRepairMode**: The CalendarRepairMode parameter specifies the mode that the Calendar Repair Assistant will run in.
* **CalendarRepairWorkCycle**: The CalendarRepairWorkCycle parameter specifies the time span in which all mailboxes on the specified server will be scanned by the Calendar Repair Assistant. Calendars that have inconsistencies will be flagged and repaired according to the interval specified by the CalendarRepairWorkCycleCheckpoint parameter.
* **CalendarRepairWorkCycleCheckpoint**: The CalendarRepairWorkCycleCheckpoint parameter specifies the time span at which all mailboxes will be identified as needing work completed on them.
* **DomainController**: The DomainController parameter specifies the fully qualified domain name (FQDN) of the domain controller that writes this configuration change to Active Directory.
* **DatabaseCopyActivationDisabledAndMoveNow**: The DatabaseCopyActivationDisabledAndMoveNow parameter specifies whether to prevent databases from being mounted on this Mailbox server if there are other healthy copies of the databases on other Mailbox servers. It will also immediately move any mounted databases on the server to other servers if copies exist and are healthy.
* **DatabaseCopyAutoActivationPolicy**: The DatabaseCopyAutoActivationPolicy parameter specifies the type of automatic activation available for mailbox database copies on the specified Mailbox server. Valid values are Blocked, IntrasiteOnly, and Unrestricted.
* **FolderLogForManagedFoldersEnabled**: The FolderLogForManagedFoldersEnabled parameter specifies whether the folder log for managed folders is enabled for messages that were moved to managed folders.
* **ForceGroupMetricsGeneration**: The ForceGroupMetricsGeneration parameter specifies that group metrics information must be generated on the Mailbox server regardless of whether that server generates an offline address book (OAB). By default, group metrics are generated only on servers that generate OABs. Group metrics information is used by MailTips to inform senders about how many recipients their messages will be sent to. You need to use this parameter if your organization doesn't generate OABs and you want the group metrics data to be available.
* **IsExcludedFromProvisioning**: The IsExcludedFromProvisioning parameter specifies that the Mailbox server isn't considered by the OAB provisioning load balancer. If the IsExcludedFromProvisioning parameter is set to $true, the server won't be used for provisioning a new OAB or for moving existing OABs.
* **JournalingLogForManagedFoldersEnabled**: The JournalingLogForManagedFoldersEnabled parameter specifies whether the log for managed folders is enabled for journaling. The two possible values for this parameter are $true or $false. If you specify $true, information about messages that were journaled is logged. The logs are located at the location you specify with the LogPathForManagedFolders parameter.
* **Locale**: The Locale parameter specifies the locale. A locale is a collection of language-related user preferences such as writing system, calendar, and date format.
* **LogDirectorySizeLimitForManagedFolders**: The LogDirectorySizeLimitForManagedFolders parameter specifies the size limit for all managed folder log files from a single message database. After the limit is reached for a set of managed folder log files from a message database, the oldest files are deleted to make space for new files.
* **LogFileAgeLimitForManagedFolders**: The LogFileAgeLimitForManagedFolders parameter specifies how long to retain managed folder logs. Log files that exceed the maximum retention period are deleted.
* **LogFileSizeLimitForManagedFolders**: The LogFileSizeLimitForManagedFolders parameter specifies the maximum size for each managed folder log file. When the log file size limit is reached, a new log file is created.
* **LogPathForManagedFolders**: The LogPathForManagedFolders parameter specifies the path to the directory that stores the managed folder log files.
* **MailboxProcessorWorkCycle**: The MailboxProcessorWorkCycle parameter specifies how often to scan for locked mailboxes.
* **ManagedFolderAssistantSchedule**: The ManagedFolderAssistantSchedule parameter specifies the intervals each week during which the Managed Folder Assistant applies messaging records management (MRM) settings to managed folders. The format is StartDay.Time-EndDay.
* **ManagedFolderWorkCycle**: The ManagedFolderWorkCycle parameter specifies the time span in which all mailboxes on the specified server will be processed by the Managed Folder Assistant. The Managed Folder Assistant applies retention policies according to the ManagedFolderWorkCycleCheckpoint interval.
* **ManagedFolderWorkCycleCheckpoint**: The ManagedFolderWorkCycleCheckpoint parameter specifies the time span at which to refresh the list of mailboxes so that new mailboxes that have been created or moved will be part of the work queue. Also, as mailboxes are prioritized, existing mailboxes that haven't been successfully processed for a long time will be placed higher in the queue and will have a greater chance of being processed again in the same work cycle.
* **MAPIEncryptionRequired**: The MAPIEncryptionRequired parameter specifies whether Exchange blocks MAPI clients that don't use encrypted remote procedure calls (RPCs).
* **MaximumActiveDatabases**: The MaximumActiveDatabases parameter specifies the number of databases that can be mounted on this Mailbox server. This parameter accepts numeric values.
* **MaximumPreferredActiveDatabases**: The MaximumPreferredActiveDatabases parameter specifies a preferred maximum number of databases that a server should have. This value is different from the actual maximum, which is configured using the MaximumActiveDatabases parameter. The value of MaximumPreferredActiveDatabases is only honored during best copy and server selection, database and server switchovers, and when rebalancing the DAG.
* **OABGeneratorWorkCycle**: The OABGeneratorWorkCycle parameter specifies the time span in which the OAB generation on the specified server will be processed.
* **OABGeneratorWorkCycleCheckpoint**: The OABGeneratorWorkCycleCheckpoint parameter specifies the time span at which to run OAB generation.
* **PublicFolderWorkCycle**: The PublicFolderWorkCycle parameter is used by the public folder assistant to determine how often the mailboxes in a database are processed by the assistant.
* **PublicFolderWorkCycleCheckpoint**: The PublicFolderWorkCycleCheckpoint determines how often the mailbox list for a database is evaluated. The processing speed is also calculated.
* **RetentionLogForManagedFoldersEnabled**: The RetentionLogForManagedFoldersEnabled parameter specifies whether the Managed Folder Assistant logs information about messages that have reached their retention limits.
* **SharingPolicySchedule**: The SharingPolicySchedule parameter specifies the intervals each week during which the sharing policy runs. The Sharing Policy Assistant checks permissions on shared calendar items and contact folders in users' mailboxes against the assigned sharing policy. The assistant lowers or removes permissions according to the policy. The format is StartDay.Time-EndDay.Time.
* **SharingPolicyWorkCycle**: The SharingPolicyWorkCycle parameter specifies the time span in which all mailboxes on the specified server will be scanned by the Sharing Policy Assistant. The Sharing Policy Assistant scans all mailboxes and enables or disables sharing polices according to the interval specified by the SharingPolicyWorkCycle.
* **SharingPolicyWorkCycleCheckpoint**: The SharingPolicyWorkCycleCheckpoint parameter specifies the time span at which to refresh the list of mailboxes so that new mailboxes that have been created or moved will be part of the work queue. Also, as mailboxes are prioritized, existing mailboxes that haven't been successfully processed for a long time will be placed higher in the queue and will have a greater chance of being processed again in the same work cycle.
* **SharingSyncWorkCycle**: The SharingSyncWorkCycle parameter specifies the time span in which all mailboxes on the specified server will be synced to the cloud-based service by the Sharing Sync Assistant. Mailboxes that require syncing will be synced according to the interval specified by the SharingSyncWorkCycleCheckpoint parameter.
* **SharingSyncWorkCycleCheckpoint**: The SharingSyncWorkCycleCheckpoint parameter specifies the time span at which to refresh the list of mailboxes so that new mailboxes that have been created or moved will be part of the work queue. Also, as mailboxes are prioritized, existing mailboxes that haven't been successfully processed for a long time will be placed higher in the queue and will have a greater chance of being processed again in the same work cycle.
* **SiteMailboxWorkCycle**: The SiteMailboxWorkCycle parameter specifies the time span in which the site mailbox information on the specified server will be processed.
* **SiteMailboxWorkCycleCheckpoint**: The SiteMailboxWorkCycleCheckpoint parameter specifies the time span at which to refresh the site mailbox workcycle.
* **SubjectLogForManagedFoldersEnabled**: The SubjectLogForManagedFoldersEnabled parameter specifies whether the subject of messages is displayed in managed folder logs.
* **TopNWorkCycle**: The TopNWorkCycle parameter specifies the time span in which all mailboxes that have Unified Messaging on the specified server will be scanned by the TopN Words Assistant. The TopN Words Assistant scans voice mail for the most frequently used words to aid in transcription.
* **TopNWorkCycleCheckpoint**: The TopNWorkCycleCheckpoint parameter specifies the time span at which to refresh the list of mailboxes so that new mailboxes that have been created or moved will be part of the work queue. Also, as mailboxes are prioritized, existing mailboxes that haven't been successfully processed for a long time will be placed higher in the queue and will have a greater chance of being processed again in the same work cycle.
* **UMReportingWorkCycle**: The UMReportingWorkCycle parameter specifies the time span in which the arbitration mailbox named SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9} on the specified server will be scanned by the Unified Messaging Reporting Assistant. The Unified Messaging Reporting Assistant updates the Call Statistics reports by reading Unified Messaging call data records for an organization on a regular basis.
* **UMReportingWorkCycleCheckpoint**: The UMReportingWorkCycleCheckpoint parameter specifies the time span at which the arbitration mailbox named SystemMailbox{e0dc1c29-89c3-4034-b678-e6c29d823ed9} will be marked by processing.
* **WacDiscoveryEndpoint**: The WacDiscoveryEndpoint parameter specifies the Office Online Server endpoint to use. Exchange 2016 only.

#### Common Issues
The parameter Locale doesn't work.

### xExchMailboxTransportService

xExchMailboxTransportService configures the Mailbox Transport service settings on Mailbox servers using Set-MailboxTransportService.

Where no description is listed, properties correspond directly to [Set-MailboxTransportService](https://technet.microsoft.com/en-us/library/jj215711(v=exchg.160).aspx) parameters.

* **Identity**: Hostname of the server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart service to make changes active
* **ConnectivityLogEnabled**
* **ConnectivityLogMaxAge**
* **ConnectivityLogMaxDirectorySize**
* **ConnectivityLogMaxFileSize**
* **ConnectivityLogPath**
* **ContentConversionTracingEnabled**
* **MaxConcurrentMailboxDeliveries**
* **MaxConcurrentMailboxSubmissions**
* **PipelineTracingEnabled**
* **PipelineTracingPath**
* **PipelineTracingSenderAddress**
* **ReceiveProtocolLogMaxAge**
* **ReceiveProtocolLogMaxDirectorySize**
* **ReceiveProtocolLogMaxFileSize**
* **ReceiveProtocolLogPath**
* **SendProtocolLogMaxAge**
* **SendProtocolLogMaxDirectorySize**
* **SendProtocolLogMaxFileSize**
* **SendProtocolLogPath**

#### Common Issues
To set some settings to NULL you need to set the value to '' instead of using $null. The following settings are affected:
PipelineTracingSenderAddress

### xExchMaintenanceMode

**xExchMaintenanceMode** is used for putting a Database Availability Group member in and out of maintenance mode. Only works with servers that have both the Client Access and Mailbox Server roles.

* **Enabled**: Whether the server should be put into Maintenance Mode. When Enabled is set to True, the server will be put in Maintenance Mode. If False, the server will be taken out of Maintenance Mode.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AdditionalComponentsToActivate**: When taking a server out of Maintenance Mode, the following components will be set to Active by default: ServerWideOffline, UMCallRouter, HighAvailability, Monitoring, RecoveryActionsEnabled. This parameter specifies an additional list of components to set to Active.
* **DomainController**: The DomainController parameter specifies the fully qualified domain name (FQDN) of the domain controller that writes this configuration change to Active Directory.
* **MovePreferredDatabasesBack**: Whether to move back databases with an Activation Preference of one for this server after taking the server out of Maintenance Mode. Defaults to False.
* **SetInactiveComponentsFromAnyRequesterToActive**: Whether components that were set to Inactive by outside Requesters should also be set to Active when exiting Maintenance Mode. Defaults to False.
* **UpgradedServerVersion**: Optional string to specify what the server version will be after applying a Cumulative Update. If the server is already at this version, requests to put the server in Maintenance Mode will be ignored. Version should be in the format ##.#.####.#, as in 15.0.1104.5.

#### Maintenance Mode Procedures
**xExchMaintenanceMode** performs the following steps when entering or exiting Maintenance Mode

#### Entering Maintenance Mode
* Set DatabaseCopyAutoActivationPolicy to Blocked
* Set UMCallrouter to Draining
* Execute TransportMaintenance.psm1 -> Start-TransportMaintenance
    * Pause MSExchangeTransport service
    * Wait for queues to drain
    * Redirect remaining messages
    * Set HubTransport component to Inactive
    * Resume MSExchangeTransport
* Wait up to 5 minutes for active UM calls to finish
* Run StartDagServerMaintenance.psm1
    * Set HighAvailability component to Inactive
    * Suspend Cluster Node
    * Move active databases: Move-ActiveMailboxDatabase -Server SERVER
    * Move the Primary Active Manager role
* Set ServerWideOffline component to Inactive

#### Exiting Maintenance Mode
* Set ServerWideOffline component to Active
* Set UMCallrouter to Active
* Run StopDagServerMaintenance.ps1
    * Resume Cluster Node
    * Set HubTransport component to Active
    * Set DatabaseCopyAutoActivationPolicy to Unrestricted
* Execute TransportMaintenance.psm1 -> Stop-TransportMaintenance
    * Set HubTransport component to Active
    * Restart MSExchangeTransport service
* Set Monitoring component to Active
* Set RecoveryActionsEnabled component to Active
* (OPTIONAL) Set each in an admin provided list of components to Active
* (OPTIONAL) For each of the above components, set to Active for ANY requester (this addresses the case where multiple requesters have set a component to Inactive, like HealthApi and Maintenance)
* (OPTIONAL) Move back all databases with an Activation Preference of 1

### xExchMapiVirtualDirectory

Where no description is listed, properties correspond directly to [Set-MapiVirtualDirectory](http://technet.microsoft.com/en-US/library/dn595082%28v=exchg.150%29.aspx) parameters.

* **Identity**: The Identity of the MAPI Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to recycle the app pool after making changes.
Defaults to $false.
* **DomainController**
* **ExternalUrl**
* **IISAuthenticationMethods**
* **InternalUrl**

### xExchOabVirtualDirectory

Where no description is listed, properties correspond directly to [Set-OabVirtualDirectory](http://technet.microsoft.com/en-us/library/bb124707(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the OAB Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **OABsToDistribute**: An array of names of Offline Address Books that this virtual directory should be added as a distribution point for. 
Should not be used for any OAB where 'Set-OfflineAddressBook -GlobalWebDistributionEnabled' is being used.
* **AllowServiceRestart**: Whether it is okay to recycle the app pool after making changes. 
Defaults to $false.
* **BasicAuthentication**
* **DomainController**
* **ExtendedProtectionFlags**
* **ExtendedProtectionSPNList**
* **ExtendedProtectionTokenChecking**
* **ExternalUrl**
* **InternalUrl**
* **PollInterval**
* **RequireSSL**
* **WindowsAuthentication**


### xExchOutlookAnywhere

Where no description is listed, properties correspond directly to [Set-OutlookAnywhere](http://technet.microsoft.com/en-us/library/bb123545(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the Outlook Anywhere Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is okay to recycle the app pool after making changes. 
Defaults to $false.
* **DomainController**
* **ExternalClientsRequireSsl**
* **ExtendedProtectionFlags**
* **ExtendedProtectionSPNList**
* **ExtendedProtectionTokenChecking**
* **ExternalClientAuthenticationMethod**
* **ExternalHostname**
* **IISAuthenticationMethods**
* **InternalClientsRequireSsl**
* **InternalHostname**
* **SSLOffloading**

### xExchOwaVirtualDirectory

Where no description is listed, properties correspond directly to [Set-OwaVirtualDirectory](http://technet.microsoft.com/en-us/library/bb123515(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the OWA Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to recycle the app pool after making changes. 
Defaults to $false.
* **AdfsAuthentication**
* **BasicAuthentication**
* **ChangePasswordEnabled**
* **DigestAuthentication**
* **DomainController**
* **ExternalAuthenticationMethods**
* **ExternalUrl**
* **FormsAuthentication**
* **InternalUrl**
* **InstantMessagingEnabled**
* **InstantMessagingCertificateThumbprint**
* **InstantMessagingServerName**
* **InstantMessagingType**
* **LogonPagePublicPrivateSelectionEnabled**
* **LogonPageLightSelectionEnabled**
* **WindowsAuthentication**
* **WSSecurityAuthentication**
* **LogonFormat**
* **DefaultDomain**

### xExchPopSettings

xExchPopSettings configures POP settings using Set-PopSettings.

* **Server**: Hostname of the POP server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart the POP services after making changes. 
Defaults to $false.
* **DomainController**: Optional Domain Controller to connect to.
* **ExternalConnectionSettings**: Specifies the host name, port, and encryption type that Exchange uses when POP clients connect to their email from the outside.
* **LoginType**: The LoginType to be used for POP
* **X509CertificateName**: Specifies the host name in the SSL certificate from the Associated Subject field.

### xExchPowerShellVirtualDirectory

Where no description is listed, properties correspond directly to [Set-PowerShellVirtualDirectory](http://technet.microsoft.com/en-us/library/dd298108(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the PowerShell Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to recycle the app pool after making changes. 
Defaults to $false.
* **BasicAuthentication**
* **CertificateAuthentication**
* **DomainController**
* **ExternalUrl**
* **InternalUrl**
* **WindowsAuthentication**

### xExchReceiveConnector

Where no description is listed, properties correspond directly to [Set-ReceiveConnector](http://technet.microsoft.com/en-us/library/bb125140(v=exchg.150).aspx) parameters.

* **Identity**: Identity of the Receive Connector. 
Needs to be in the format 'SERVERNAME\CONNECTORNAME' (no quotes).
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **Ensure**: Whether the Receive Connector should exist or not: { Present | Absent }
* **ExtendedRightAllowEntries**: additional AD permissions, which should be add to the connector. Can have multiple entries. Example:
@{"NT AUTHORITY\ANONYMOUS LOGON"="Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-SMTP-Accept-XShadow";"Domain Users"="Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-Bypass-Anti-Spam"}
* **ExtendedRightDenyEntries**: Similar as ExtendedRightAllowEntries, but to make sure the defined permission is not set
* **AdvertiseClientSettings**
* **AuthMechanism**
* **Banner**
* **BareLinefeedRejectionEnabled**
* **BinaryMimeEnabled**
* **Bindings**
* **ChunkingEnabled**
* **Comment**
* **ConnectionInactivityTimeout**
* **ConnectionTimeout**
* **DefaultDomain**
* **DeliveryStatusNotificationEnabled**
* **DomainController**
* **DomainSecureEnabled**
* **EightBitMimeEnabled**
* **EnableAuthGSSAPI**
* **Enabled**
* **EnhancedStatusCodesEnabled**
* **ExtendedProtectionPolicy**
* **Fqdn**
* **LongAddressesEnabled**
* **MaxAcknowledgementDelay**
* **MaxHeaderSize**
* **MaxHopCount**
* **MaxInboundConnection**
* **MaxInboundConnectionPercentagePerSource**
* **MaxInboundConnectionPerSource**
* **MaxLocalHopCount**
* **MaxLogonFailures**
* **MaxMessageSize**
* **MaxProtocolErrors**
* **MaxRecipientsPerMessage**
* **MessageRateLimit**
* **MessageRateSource**
* **OrarEnabled**
* **PermissionGroups**
* **PipeliningEnabled**
* **ProtocolLoggingLevel**
* **RemoteIPRanges**
* **RequireEHLODomain**
* **RequireTLS**
* **ServiceDiscoveryFqdn**
* **SizeEnabled**
* **SuppressXAnonymousTls**
* **TarpitInterval**
* **TlsCertificateName**
* **TlsDomainCapabilities**
* **TransportRole**
* **Usage**

### xExchTransportService

xExchTransportService configures the Transport service settings on Mailbox servers or Edge Transport servers using Set-TransportService.

Where no description is listed, properties correspond directly to [Set-TransportService](https://technet.microsoft.com/library/jj215682(v=exchg.150).aspx) parameters.

* **Identity**: Hostname of the server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart service to make changes active
* **ActiveUserStatisticsLogMaxAge**
* **ActiveUserStatisticsLogMaxDirectorySize**
* **ActiveUserStatisticsLogMaxFileSize**
* **ActiveUserStatisticsLogPath**
* **AgentLogEnabled**
* **AgentLogMaxAge**
* **AgentLogMaxDirectorySize**
* **AgentLogMaxFileSize**
* **AgentLogPath**
* **ConnectivityLogEnabled**
* **ConnectivityLogMaxAge**
* **ConnectivityLogMaxDirectorySize**
* **ConnectivityLogMaxFileSize**
* **ConnectivityLogPath**
* **ContentConversionTracingEnabled**
* **DelayNotificationTimeout**
* **DnsLogEnabled**
* **DnsLogMaxAge**
* **DnsLogMaxDirectorySize**
* **DnsLogMaxFileSize**
* **DnsLogPath**
* **ExternalDNSAdapterEnabled**
* **ExternalDNSAdapterGuid**
* **ExternalDNSProtocolOption**
* **ExternalDNSServers**
* **ExternalIPAddress**
* **InternalDNSAdapterEnabled**
* **InternalDNSAdapterGuid**
* **InternalDNSProtocolOption**
* **InternalDNSServers**
* **IntraOrgConnectorProtocolLoggingLevel**
* **IntraOrgConnectorSmtpMaxMessagesPerConnection**
* **IrmLogEnabled**
* **IrmLogMaxAge**
* **IrmLogMaxDirectorySize**
* **IrmLogMaxFileSize**
* **IrmLogPath**
* **MaxConcurrentMailboxDeliveries**
* **MaxConcurrentMailboxSubmissions**
* **MaxConnectionRatePerMinute**
* **MaxOutboundConnections**
* **MaxPerDomainOutboundConnections**
* **MessageExpirationTimeout**
* **MessageRetryInterval**
* **MessageTrackingLogEnabled**
* **MessageTrackingLogMaxAge**
* **MessageTrackingLogMaxDirectorySize**
* **MessageTrackingLogMaxFileSize**
* **MessageTrackingLogPath**
* **MessageTrackingLogSubjectLoggingEnabled**
* **OutboundConnectionFailureRetryInterval**
* **PickupDirectoryMaxHeaderSize**
* **PickupDirectoryMaxMessagesPerMinute**
* **PickupDirectoryMaxRecipientsPerMessage**
* **PickupDirectoryPath**
* **PipelineTracingEnabled**
* **PipelineTracingPath**
* **PipelineTracingSenderAddress**
* **PoisonMessageDetectionEnabled**
* **PoisonThreshold**
* **QueueLogMaxAge**
* **QueueLogMaxDirectorySize**
* **QueueLogMaxFileSize**
* **QueueLogPath**
* **QueueMaxIdleTime**
* **ReceiveProtocolLogMaxAge**
* **ReceiveProtocolLogMaxDirectorySize**
* **ReceiveProtocolLogMaxFileSize**
* **ReceiveProtocolLogPath**
* **RecipientValidationCacheEnabled**
* **ReplayDirectoryPath**
* **RootDropDirectoryPath**
* **RoutingTableLogMaxAge**
* **RoutingTableLogMaxDirectorySize**
* **RoutingTableLogPath**
* **SendProtocolLogMaxAge**
* **SendProtocolLogMaxDirectorySize**
* **SendProtocolLogMaxFileSize**
* **SendProtocolLogPath**
* **ServerStatisticsLogMaxAge**
* **ServerStatisticsLogMaxDirectorySize**
* **ServerStatisticsLogMaxFileSize**
* **ServerStatisticsLogPath**
* **TransientFailureRetryCount**
* **TransientFailureRetryInterval**
* **UseDowngradedExchangeServerAuth**

#### Common Issues
To set some settings to NULL you need to set the value to '' instead of using $null. The following settings are affected:
ExternalDNSServers
ExternalIPAddress
InternalDNSServers
PipelineTracingSenderAddress

### xExchUMCallRouterSettings

xExchUMCallRouterSettings configures the UM Call Router service using Set-UMCallRouterSettings.

* **Server**: Hostname of the UM server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **UMStartupMode**: UMStartupMode for the UM call router.
* **DomainController**: Optional Domain Controller to connect to.

### xExchUMService

xExchUMService configures a UM server using Set-UMService.

* **Identity**: Hostname of the UM server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **UMStartupMode**: UMStartupMode for the UM server.
* **DomainController**: Optional Domain Controller to connect to.
* **DialPlans**: Specifies all dial plans that the Unified Messaging service handles incoming calls for.

### xExchWaitForADPrep

xExchWaitForADPrep ensures that Active Directory has been prepared for Exchange 2013 or 2016 using setup /PrepareSchema, /PrepareAD, and /PrepareDomain. 
To find appropriate version values for the SchemaVersion, OrganizationVersion, and DomainVersion parameters, consult the 'Exchange 2013 Active Directory versions' section of the article [Prepare Active Directory and domains](http://technet.microsoft.com/en-us/library/bb125224(v=exchg.150).aspx).

* **Identity**: Not actually used. Enter anything, as long as it's not null.
* **Credential**: Credentials used to perform Active Directory lookups against the Schema, Configuration, and Domain naming contexts.
* **SchemaVersion**: Specifies that the Active Directory schema should have been prepared using Exchange 2013 or 2016 'setup /PrepareSchema', and should be at the specified version.
* **OrganizationVersion**: Specifies that the Exchange Organization should have been prepared using Exchange 2013 or 2016 'setup /PrepareAD', and should be at the specified version.
* **DomainVersion**: Specifies that the domain containing the target Exchange 2013 or 2016 server was prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains, and should be at the specified version.
* **ExchangeDomains**: The FQDN's of domains that should be checked for DomainVersion in addition to the domain that this Exchange server belongs to.
* **RetryIntervalSec**: How many seconds to wait between retries when checking whether AD has been prepped. 
Defaults to 60.
* **RetryCount**: How many retry attempts should be made to see if AD has been prepped before an exception is thrown. 
Defaults to 30.

### xExchWaitForDAG

xExchWaitForDAG is used by DAG members who are NOT maintaining the DAG configuration. 
Intended to be used as a DependsOn property by **xExchDatabaseAvailabilityGroupMember**. 
Throws an exception if the DAG still does not exist after the specified retry count and interval. 
If this happens, DSC configurations run in push mode will need to be re-executed.

* **Identity**: The name of the DAG.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **DomainController**: Domain controller to talk to when running Get-DatabaseAvailabilityGroup.
* **RetryIntervalSec**: How many seconds to wait between retries when checking whether the DAG exists. 
Defaults to 60.
* **RetryCount**: Mount many retry attempts should be made to find the DAG before an exception is thrown. 
Defaults to 5.

### xExchWaitForMailboxDatabase

xExchWaitForMailboxDatabase is used as a DependsOn property by **xExchMailboxDatabaseCopy** to ensure that a Mailbox Database exists prior to trying to add a copy. 
Throws an exception if the database still does not exist after the specified retry count and interval. 
If this happens, DSC configurations run in push mode will need to be re-executed.

* **Identity**: The name of the Mailbox Database.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **DomainController**: Domain controller to talk to when running Get-MailboxDatabase.
* **RetryIntervalSec**: How many seconds to wait between retries when checking whether the database exists. 
Defaults to 60.
* **RetryCount**: Mount many retry attempts should be made to find the database before an exception is thrown. 
Defaults to 5.

### xExchWebServicesVirtualDirectory

Where no description is listed, properties correspond directly to [Set-WebServicesVirtualDirectory](http://technet.microsoft.com/en-us/library/aa997233(v=exchg.150).aspx) parameters.

* **Identity**: The Identity of the EWS Virtual Directory.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to recycle the app pool after making changes.
Defaults to $false.
* **BasicAuthentication**
* **CertificateAuthentication**
* **DigestAuthentication**
* **DomainController**
* **ExternalUrl**
* **InternalNLBBypassUrl**
* **InternalUrl**
* **OAuthAuthentication**
* **WindowsAuthentication**
* **WSSecurityAuthentication**

## Versions

### Unreleased

### 1.14.0.0

* xExchDatabaseAvailabilityGroup: Added parameter AutoDagAutoRedistributeEnabled,PreferenceMoveFrequency

### 1.13.0.0

* Fix function RemoveVersionSpecificParameters
* xExchMailboxServer: Added missing parameters except these, which are marked as 'This parameter is reserved for internal Microsoft use.'

### 1.12.0.0
* xExchangeCommon : In StartScheduledTask corrected throw error check to throw last error when errorRegister has more than 0 errors instead of throwing error if errorRegister was not null, which would otherwise always be true.
* Fix PSAvoidUsingWMICmdlet issues from PSScriptAnalyzer
* Fix PSUseSingularNouns issues from PSScriptAnalyzer
* Fix PSAvoidUsingCmdletAliases issues from PSScriptAnalyzer
* Fix PSUseApprovedVerbs issues from PSScriptAnalyzer
* Fix PSAvoidUsingEmptyCatchBlock issues from PSScriptAnalyzer
* Fix PSUsePSCredentialType issues from PSScriptAnalyzer
* Fix erroneous PSDSCDscTestsPresent issues from PSScriptAnalyzer for modules that do actually have tests in the root Tests folder
* Fix array comparison issues by removing check for if array is null
* Suppress PSDSCDscExamplesPresent PSScriptAnalyzer issues for resources that do have examples
* Fix PSUseDeclaredVarsMoreThanAssignments issues from PSScriptAnalyzer
* Remove requirements for second DAG member, or second Witness server, from MSFT_xExchDatabaseAvailabilityGroup.Integration.Tests

### 1.11.0.0
* xExchActiveSyncVirtualDirectory: Fix issue where ClientCertAuth parameter set to "Allowed" instead of "Accepted"

### 1.10.0.0
* xExchAutoMountPoint: Fix malformed dash/hyphen characters
* Fix PSPossibleIncorrectComparisonWithNull issues from PowerShell Script Analyzer
* Suppress PSDSCUseVerboseMessageInDSCResource Warnings from PowerShell Script Analyzer

### 1.9.0.0
* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.
* Added xExchMailboxTransportService resource
* xExchMailboxServer: Added WacDiscoveryEndpoint parameter

### 1.8.0.0

* Fixed PSSA issues in:
    * MSFT_xExchClientAccessServer
    * MSFT_xExchAntiMalwareScanning
    * MSFT_xExchWaitForMailboxDatabase
    * MSFT_xExchWebServicesVirtualDirectory
    * MSFT_xExchExchangeCertificate
    * MSFT_xExchWaitForDAG
    * MSFT_xExchUMService
    * MSFT_xExchUMCallRouterSettings
    * MSFT_xExchReceiveConnector
    * MSFT_xExchPowershellVirtualDirectory
    * MSFT_xExchPopSettings
    * MSFT_xExchOwaVirtualDirectory
    * MSFT_xExchOutlookAnywhere
    * MSFT_xExchOabVirtualDirectory
    * MSFT_xExchMapiVirtualDirectory
    * MSFT_xExchMailboxServer
    * MSFT_xExchImapSettings
    * MSFT_xExchExchangeServer
    * MSFT_xExchEventLogLevel
    * MSFT_xExchEcpVirtualDirectory
    * MSFT_xExchDatabaseAvailabilityGroupNetwork
    * MSFT_xExchDatabaseAvailabilityGroupMember
    * MSFT_xExchDatabaseAvailabilityGroup

### 1.7.0.0

* xExchOwaVirtualDirectory
    - Added `LogonFormat` parameter.
    - Added `DefaultDomain` parameter.
* Added FileSystem parameter to xExchDatabaseAvailabilityGroup
* Fixed PSSA issues in MSFT_xExchAutodiscoverVirtualDirectory and MSFT_xExchActiveSyncVirtualDirectory
* Updated xExchAutoMountPoint to disable Integrity Checking when formatting volumes as ReFS. This aligns with the latest version of DiskPart.ps1 from the Exchange Server Role Requirements Calculator.

### 1.6.0.0  

* Added DialPlans parameter to xExchUMService

### 1.5.0.0

* Added support for Exchange 2016!
* Added Pester tests for the following resources: xExchActiveSyncVirtualDirectory, xExchAutodiscoverVirtualDirectory, xExchClientAccessServer, xExchDatabaseAvailabilityGroup, xExchDatabaseAvailabilityGroupMember, xExchEcpVirtualDirectory, xExchExchangeServer, xExchImapSettings, xExchMailboxDatabase, xExchMailboxDatabaseCopy, xExchMapiVirtualDirectory, xExchOabVirtualDirectory, xExchOutlookAnywhere, xExchOwaVirtualDirectory, xExchPopSettings, xExchPowershellVirtualDirectory, xExchUMCallRouterSettings, xExchUMService, xExchWebServicesVirtualDirectory  
* Fixed minor Get-TargetResource issues in xExchAutodiscoverVirtualDirectory, xExchImapSettings, xExchPopSettings, xExchUMCallRouterSettings, and xExchWebServicesVirtualDirectory  
* Added support for extended rights to resource xExchReceiveConnector (ExtendedRightAllowEntries/ExtendedRightDenyEntries)
* Fixed issue where Set-Targetresource is triggered each time consistency check runs in xExchReceiveConnector due to extended permissions on Receive Connector
* Added parameter MaximumActiveDatabases and MaximumPreferredActiveDatabases to resource xExchMailBoxServer

### 1.4.0.0

* Added following resources:
  * xExchMaintenanceMode
  * xExchMailboxServer
  * xExchTransportService
  * xExchEventLogLevel
* For all -ExchangeCertificate functions in xExchExchangeCertificate, added '-Server $env:COMPUTERNAME' switch. This will prevent the resource from configuring a certificate on an incorrect server.
* Fixed issue with reading MailboxDatabases.csv in xExchangeConfigHelper.psm1 caused by a column name changed introduced in v7.7 of the Exchange Server Role Requirements Calculator.
* Changed function GetRemoteExchangeSession so that it will throw an exception if Exchange setup is in progress. This will prevent resources from trying to execute while setup is running.
* Fixed issue where VirtualDirectory resources would incorrectly try to restart a Back End Application Pool on a CAS role only server.
* Added support for the /AddUMLanguagePack parameter in xExchInstall

### 1.3.0.0

* MSFT_xExchWaitForADPrep: Removed obsolete VerbosePreference parameter from Test-TargetResource
* Fixed encoding

### 1.2.0.0

* xExchWaitForADPrep
    - Removed `VerbosePreference` parameter of Test-TargetResource function to resolve schema mismatch error.

* Added xExchAntiMalwareScanning resource

* xExchJetstress:
    - Added fix for an issue where JetstressCmd.exe would not relaunch successfully after ESE initialization. If Jetstress doesn't restart, the resource will now require a reboot before proceeding.

* xExchOwaVirtualDirectory:
    - Added `ChangePasswordEnabled` parameter
    - Added `LogonPagePublicPrivateSelectionEnabled` parameter
    - Added `LogonPageLightSelectionEnabled` parameter

* xExchImapSettings:
    - Added `ExternalConnectionSettings` parameter
    - Added `X509CertificateName` parameter

* xExchPopSettings:
    - Added `ExternalConnectionSettings` parameter
    - Added `X509CertificateName` parameter

* Added EndToEndExample

* Fixed bug where StartScheduledTask would throw an error message and fail to set ExecutionTimeLimit and Priority when using domain credentials

### 1.1.0.0

* xExchAutoMountPoint:
    - Added parameter `EnsureExchangeVolumeMountPointIsLast`

* xExchExchangeCertificate: Added error logging for the `Enable-ExchangeCertificate` cmdlet

* xExchExchangeServer: Added pre-check for deprecated Set-ExchangeServer parameter, WorkloadManagementPolicy

* xExchJetstressCleanup: When OutputSaveLocation is specified, Stress* files will also now be saved

* xExchMailboxDatabase:     
    - Added `AdServerSettingsPreferredServer` parameter
    - Added `SkipInitialDatabaseMount` parameter, which can help in an enviroments where databases need time to be able to mount successfully after creation
    - Added better error logging for `Mount-Database`
    - Databases will only be mounted at initial database creation if `MountAtStartup` is `$true` or not specified

* xExchMailboxDatabaseCopy:     
    - Added `SeedingPostponed` parameter 
    - Added `AdServerSettingsPreferredServer` parameter
    - Changed so that `ActivationPreference` will only be set if the number of existing copies for the database is greater than or equal to the specified ActivationPreference
    - Changed so that a seed of a new copy is only performed if `SeedingPostponed` is not specified or set to `$false`
    - Added better error logging for `Add-MailboxDatabaseCopy`
    - Added missing tests for `EdbFilePath` and `LogFolderPath`

* xExchOwaVirtualDirectory: Added missing test for `InstantMessagingServerName`

* xExchWaitForMailboxDatabase: Added `AdServerSettingsPreferredServer` parameter

* ExchangeConfigHelper.psm1: Updated `DBListFromMailboxDatabaseCopiesCsv` so that the DB copies that are returned are sorted by Activation Preference in ascending order.

### 1.0.3.11

* xExchJetstress Changes: 
    - Changed default for MaxWaitMinutes from 4320 to 0
    - Added property MinAchievedIOPS
    - Changed priority of the JetstressCmd.exe Scheduled Task from the default of 7 to 4
* xExchJetstressCleanup Changes: 
    - Fixed issue which caused the cleanup to not work properly when only a single database is used in JetstressConfig.xml
* xExchAutoMountPoint Changes: 
    - Updated resource to choose the next available EXVOL mount point to use for databases numerically by volume number instead of alphabetically by volume number (ie. EXVOL2 would be selected after EXVOL1 instead of EXVOL11, which is alphabetically closer).

### 1.0.3.6

* Added the following resources: 
    - xExchInstall
    - xExchJetstress
    - xExchJetstressCleanup
    - xExchUMCallRouterSettings
    - xExchWaitForADPrep
* xExchActiveSyncVirtualDirectory Changes: 
    - Fixed an issue where if AutoCertBasedAuth was being configured, it would result in an IISReset and an app pool recycle. Now only an IISReset will occur in this scenario.
* xExchAutoMountPoint Changes: 
    - Added CreateSubfolders parameter
    - Moved many DiskPart functions into helper file Misc\xExchangeDiskPart.ps1
    - Updated so that ExchangeVolume mount points will be listed AFTER ExchangeDatabase mount points on the same disk
* xExchExchangeCertificate Changes: 
    - Changed behavior so that if UM or UMCallRouter services are being enabled, the UM or UMCallRouter services will be stopped before the enablement, then restarted after the enablement.
* xExchMailboxDatabase Changes: 
    - Fixed an issue where the OfflineAddressBook property would not be tested properly depending on if a slash was specified or not at the beginning of the OAB name. Now the slash doesn't matter.
* xExchOutlookAnywhere Changes: 
    - Changed the test for ExternalClientsRequireSsl to only fire if ExternalHostname is also specified.
* xExchUMService Changes: 
    - Fixed issue that was preventing tests from evaluating properly.
* Example Updates: 
    - Added example folder InstallExchange
    - Added example folder JetstressAutomation
    - Added example folder WaitForADPrep
    - Renamed EndToEndExample to PostInstallationConfiguration
    - Updated Start-DscConfiguration commands in ConfigureDatabasesFromCalculator, ConfigureDatabasesManual, ConfigureVirtualDirectories, CreateAndConfigureDAG, and EndToEndExample, as they were missing a required space between parameters

### 1.0.1.0

* Updated all Examples with minor comment changes, and re-wrote the examples ConfigureAutoMountPoint-FromCalculator and ConfigureAutoMountPoints-Manual.
* Updated Exchange Server Role Requirement Calculator examples from version 6.3 to 6.6

### 1.0.0.0

* Initial release with the following resources:
    - xExchActiveSyncVirtualDirectory
    - xExchAutodiscoverVirtualDirectory
    - xExchAutoMountPoint
    - xExchClientAccessServer
    - xExchDatabaseAvailabilityGroup
    - xExchDatabaseAvailabilityGroupMember
    - xExchDatabaseAvailabilityGroupNetwork
    - xExchEcpVirtualDirectory
    - xExchExchangeCertificate
    - xExchExchangeServer
    - xExchImapSettings
    - xExchMailboxDatabase
    - xExchMailboxDatabaseCopy
    - xExchMapiVirtualDirectory
    - xExchOabVirtualDirectory
    - xExchOutlookAnywhere
    - xExchOwaVirtualDirectory
    - xExchPopSettings
    - xExchPowerShellVirtualDirectory
    - xExchReceiveConnector
    - xExchUMService
    - xExchWaitForDAG
    - xExchWaitForMailboxDatabase
    - xExchWebServicesVirtualDirectory


## Examples

### ConfigureAutoMountPoint-FromCalculator

Configures ExchangeDatabase and ExchangeVolume mount points automatically using the **xExchAutoMountPoint** resource. 
Shows how to feed the .CSV files from the Server Role Requirements Calculator into the resource. 
The example code for ConfigureAutoMountPoint-FromCalculator is located in "ConfigureAutoMountPoints-FromCalculator.ps1" in the module folder under ...\xExchange\Examples\ConfigureAutoMountPoint-FromCalculator. 

### ConfigureAutoMountPoint-Manual

Configures ExchangeDatabase and ExchangeVolume mount points automatically using the **xExchAutoMountPoint** resource. 
Configures disk map manually. 
The example code for ConfigureAutoMountPoint-Manual is located in "ConfigureAutoMountPoints-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureAutoMountPoints-Manual.  

### ConfigureDatabases-FromCalculator

Configures primary databases and database copies using the **xExchMailboxDatabase, xExchMailboxDatabaseCopy, and xExchWaitForMailboxDatabase** resources. 
Shows how to feed the .CSV files from the Server Role Requirements Calculator into the resource. 
The example code for ConfigureDatabases-FromCalculator is located in "ConfigureDatabases-FromCalculator.ps1" in the module folder under ...\xExchange\Examples\ConfigureDatabases-FromCalculator.   

### ConfigureDatabases-Manual

Configures primary databases and database copies using the **xExchMailboxDatabase, xExchMailboxDatabaseCopy, and xExchWaitForMailboxDatabase** resources. 
Configures database list manually. 
The example code for ConfigureDatabases-Manual is located in "ConfigureDatabases-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureDatabases-Manual.  

### ConfigureNamespaces

Contains three different examples, **SingleNamespace**, **RegionalNamespaces**, and **InternetFacingSite**, which show different ways to configure Client Access Namespaces. 
The three examples are in separate folders the module folder under ...\xExchange\Examples\PostInstallationConfiguration.  

### ConfigureVirtualDirectories

Configures various properties on Exchange Virtual Directories, like URL's and Authentication settings. 
The example code for ConfigureVirtualDirectories is located in "ConfigureVirtualDirectories-Manual.ps1" in the module folder under ...\xExchange\Examples\ConfigureVirtualDirectories.  

### CreateAndConfigureDAG

Creates a Database Availability Group, creates two new DAG networks and removes the default DAG network, and adds members to the DAG. 
The example code for CreateAndConfigureDAG is located in "CreateAndConfigureDAG.ps1" in the module folder under ...\xExchange\Examples\CreateAndConfigureDAG.

### EndToEndExample

An end to end example of how to deploy and configure an Exchange Server. The example scripts run Jetstress, install Exchange, create the DAG and databases, and configure other Exchange settings.
The example code for EndToEndExample is located in in the module folder under ...\xExchange\Examples\EndToEndExample.

### InstallExchange

Shows how to install Exchange using the **xExchInstall** resource. 
The example code for InstallExchange is located in "InstallExchange.ps1" in the module folder under ...\xExchange\Examples\InstallExchange.  

### JetstressAutomation

Contains two separate example scripts which show how to use the **xExchJetstress** resource to automate running Jetstress, and the **xExchJetstressCleanup** resource to cleanup a Jetstress installation. 
The example code for JetstressAutomation is located in "1-InstallAndRunJetstress.ps1" and "2-CleanupJetstress.ps1" in the module folder under ...\xExchange\Examples\JetstressAutomation.  

### MaintenanceMode

Shows examples of how to prepare for maintenance mode, enter maintenance mode, and exit maintenance mode. MaintenanceModePrep.ps1 prepares a server for maintenance mode by setting DatabaseCopyAutoActivationPolicy to Blocked using a Domain Controller in both the primary and secondary site. If multiple servers are going to be entering maintenance mode at the same time, this step can help prevent these servers from failing over databases to eachother. MaintenanceModeStart.ps1 puts a server into maintenance mode. MaintenanceModeStop.ps1 takes a server out of maintenance mode.

### PostInstallationConfiguration

Shows how to use the majority of the post-installation resources in the **xExchange** module. 
The example code for PostInstallationConfiguration is located in "PostInstallationConfiguration.ps1" in the module folder under ...\xExchange\Examples\PostInstallationConfiguration.  

### WaitForADPrep

Shows how to use the **xExchWaitForADPrep** resource to ensure that Setup /PrepareSchema and /PrepareAD were run successfully. 
The example code for WaitForADPrep is located in "WaitForADPrep.ps1" in the module folder under ...\xExchange\Examples\WaitForADPrep. 
