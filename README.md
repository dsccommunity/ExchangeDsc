[![Build status](https://ci.appveyor.com/api/projects/status/k9oq77p9xn6bo2j6/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xexchange/branch/master)

# xExchange

The **xExchange** module contains many DSC resources for configuring and managing Exchange 2013 servers including individual server properties, databases, mount points, and Database Availability Groups.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **xExchActiveSyncVirtualDirectory**
* **xExchAutodiscoverVirtualDirectory**
* **xExchAutoMountPoint**
* **xExchClientAccessServer**
* **xExchDatabaseAvailabilityGroup** configures a Database Availability Group using New/Set-DatabaseAvailibilityGroup. 
* **xExchDatabaseAvailabilityGroupMember** adds a member to a Database Availability Group.
* **xExchDatabaseAvailabilityGroupNetwork** can add, remove, or configure a Database Availability Group Network. 
* **xExchEcpVirtualDirectory**
* **xExchExchangeCertificate** can install, remove, or configure an ExchangeCertificate using *-ExchangeCertificate cmdlets.
* **xExchExchangeServer**
* **xExchImapSettings** configures IMAP settings using Set-ImapSettings.
* **xExchInstall** installs Exchange 2013.
* **xExchJetstress** automatically runs Jetstress using the **JetstressCmd.exe** command line executable. 
* **xExchJetstressCleanup** cleans up the database and log directories created by Jetstress.
* **xExchMailboxDatabase**
* **xExchMailboxDatabaseCopy**
* **xExchMapiVirtualDirectory**
* **xExchOabVirtualDirectory**
* **xExchOutlookAnywhere**
* **xExchOwaVirtualDirectory**
* **xExchPopSettings** configures POP settings using Set-PopSettings.
* **xExchPowerShellVirtualDirectory**
* **xExchReceiveConnector**
* **xExchUMCallRouterSettings** configures the UM Call Router service using Set-UMCallRouterSettings.
* **xExchUMService** configures a UM server using Set-UMService.
* **xExchWaitForADPrep** ensures that Active Directory has been prepared for Exchange 2013.
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
Does not install ‘Client Certificate Mapping Authentication’ or ‘IIS Client Certificate Mapping Authentication’ roles of IIS, which also must be configured separately.
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
* **WindowsAuthEnabled**: Auto Certificate Based Authentication Requirements: For AutoCertBasedAuth to work, the ‘Client Certificate Mapping Authentication’ and ‘IIS Client Certificate Mapping Authentication’ roles of IIS need to be installed.

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
Defaults to 64k.
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
* **ManualDagNetworkConfiguration**
* **NetworkCompression**
* **NetworkEncryption**
* **ReplayLagManagerEnabled**
* **ReplicationPort**
* **WitnessDirectory**
* **WitnessServer**
* **SkipDagValidation**

#### Common Issues
DAG creation will fail if the computer account of the node managing the DAG does not have permissions to create computers in Active Directory. 
To avoid this issue, you may need to [make sure that the computer account for the DAG is prestaged](http://technet.microsoft.com/en-us/library/ff367878(v=exchg.150).aspx).

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
* **LoginType**: The LoginType to be used for IMAP.

### xExchInstall 

**xExchInstall** installs Exchange 2013.

* **Path**: Full path to setup.exe in the Exchange 2013 setup directory.
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
* **WindowsAuthentication**
* **WSSecurityAuthentication**

### xExchPopSettings

xExchPopSettings configures POP settings using Set-PopSettings.

* **Server**: Hostname of the POP server to configure.
* **Credential**: Credentials used to establish a remote PowerShell session to Exchange.
* **AllowServiceRestart**: Whether it is OK to restart the POP services after making changes. 
Defaults to $false.
* **DomainController**: Optional Domain Controller to connect to.
* **LoginType**: The LoginType to be used for POP.

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

### xExchWaitForADPrep

xExchWaitForADPrep ensures that Active Directory has been prepared for Exchange 2013 using setup /PrepareSchema, /PrepareAD, and /PrepareDomain. 
To find appropriate version values for the SchemaVersion, OrganizationVersion, and DomainVersion parameters, consult the 'Exchange 2013 Active Directory versions' section of the article [Prepare Active Directory and domains](http://technet.microsoft.com/en-us/library/bb125224(v=exchg.150).aspx).

* **Identity**: Not actually used. Enter anything, as long as it's not null.
* **Credential**: Credentials used to perform Active Directory lookups against the Schema, Configuration, and Domain naming contexts.
* **SchemaVersion**: Specifies that the Active Directory schema should have been prepared using Exchange 2013 'setup /PrepareSchema', and should be at the specified version.
* **OrganizationVersion**: Specifies that the Exchange Organization should have been prepared using Exchange 2013 'setup /PrepareAD', and should be at the specified version.
* **DomainVersion**: Specifies that the domain containing the target Exchange 2013 server was prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains, and should be at the specified version.
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

## 1.1.0.0

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

### InstallExchange

Shows how to install Exchange using the **xExchInstall** resource. 
The example code for InstallExchange is located in "InstallExchange.ps1" in the module folder under ...\xExchange\Examples\InstallExchange.  

### JetstressAutomation

Contains two separate example scripts which show how to use the **xExchJetstress** resource to automate running Jetstress, and the **xExchJetstressCleanup** resource to cleanup a Jetstress installation. 
The example code for JetstressAutomation is located in "1-InstallAndRunJetstress.ps1" and "2-CleanupJetstress.ps1" in the module folder under ...\xExchange\Examples\JetstressAutomation.  

### PostInstallationConfiguration

Shows how to use the majority of the post-installation resources in the **xExchange** module. 
The example code for PostInstallationConfiguration is located in "PostInstallationConfiguration.ps1" in the module folder under ...\xExchange\Examples\PostInstallationConfiguration.  

### WaitForADPrep

Shows how to use the **xExchWaitForADPrep** resource to ensure that Setup /PrepareSchema and /PrepareAD were run successfully. 
The example code for WaitForADPrep is located in "WaitForADPrep.ps1" in the module folder under ...\xExchange\Examples\WaitForADPrep. 
