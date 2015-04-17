[bool]$showValidSettings = $true
[bool]$showVerbose = $true

if ($shellCreds -eq $null)
{
    $shellCreds = Get-Credential -Message "Enter credentials to use to connect to remote Exchange shell"
}

if ($certCreds -eq $null)
{
    $certCreds = Get-Credential -Message "Enter credentials for importing certificate"
}

#First define variables that will be common to many tests
$testServerHostname = "e15-1"
$testServerFQDN = "e15-1.mikelab.local"
$testSecondDAGMember = "e15-2"
$testDBName = "TestDB123"
$testExternalFQDN = "mail.mikelab.local"
$testDC = "dc-1.mikelab.local"
$testIMServer = "l15-1.mikelab.local"
$testDAGName = "TestDAG1"
$testDAGNetName = "DAGNet1"
$testDAGDB1 = "DAGDB1"
$testDAGDB2 = "DAGDB2"
$testWitnessServer = "e14-1.mikelab.local"
$testAlternateWitnessServer = "dc-1.mikelab.local"
$testThumbprint = "7D959B3A37E45978445F8EC8F01D200D00C3141F"
$replacementCertThumbprint = "7D959B3A37E45978445F8EC8F01D200D00C3141F" #The thumbprint to use to assign services to before removing the test certificate
$certPath = "C:\certexport1.pfx"
$testProductKey = "12345-12345-12345-12345-12345"
$testServerDN = "CN=E15-1,CN=Servers,CN=Exchange Administrative Group (FYDIBOHF23SPDLT),CN=Administrative Groups,CN=MikeLab,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=mikelab,DC=local"
$testWorkloadPolicy1 = "DefaultWorkloadManagementPolicy_15.0.825.0"
$testWorkloadPolicy2 = "GlobalOverrideWorkloadManagementPolicy"
$testJournalRecipient = "administrator@mikelab.local"
$testOAB = "Default Offline Address Book (Ex2013)"

#Now define the parameters that can be passed into individual tests
$asParams1 = @{
    Identity = "$($testServerHostname)\Microsoft-Server-ActiveSync (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/Microsoft-Server-ActiveSync"
    ExternalUrl = "https://$($testExternalFQDN)/Microsoft-Server-ActiveSync"
    BasicAuthEnabled = $true
    WindowsAuthEnabled = $false
    CompressionEnabled = $true
    ClientCertAuth = "Ignore"
    DomainController = $testDC
    Credential = $shellCreds
    AllowServiceRestart = $true
    ExternalAuthenticationMethods = "NTLM","Negotiate"
}

$asParams2 = @{
    Identity = "$($testServerHostname)\Microsoft-Server-ActiveSync (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/Microsoft-Server-ActiveSync"
    ExternalUrl = $null
    BasicAuthEnabled = $false
    WindowsAuthEnabled = $false 
    CompressionEnabled = $true
    ClientCertAuth = "Required"
    DomainController = $testDC 
    Credential = $shellCreds
    AllowServiceRestart = $true
    AutoCertBasedAuth = $true 
    AutoCertBasedAuthThumbprint = $testThumbprint
}

$autodParams1 = @{
    Identity = "$($testServerHostname)\Autodiscover (Default Web Site)"
    BasicAuthentication = $true
    WindowsAuthentication = $true
    DigestAuthentication = $false
    WSSecurityAuthentication = $true
    DomainController = $testDC
    Credential = $shellCreds
}

$autodParams2 = @{
    Identity = "$($testServerHostname)\Autodiscover (Default Web Site)"
    BasicAuthentication = $false
    WindowsAuthentication = $false
    DigestAuthentication = $true
    WSSecurityAuthentication = $false
    DomainController = $testDC
    Credential = $shellCreds
}

$autoMountPointParams1 = @{
    Identity = $testServerHostname
    DiskToDBMap = @("DB1,DB2","DB3,DB4")
    SpareVolumeCount = 1 
    AutoDagDatabasesRootFolderPath = "C:\ExchangeDatabases" 
    AutoDagVolumesRootFolderPath = "C:\ExchangeVolumes" 
    VolumePrefix = "EXVOL" 
    MinDiskSize = "10MB"
}

$autoMountPointParams2 = @{
    Identity = $testServerHostname
    DiskToDBMap = @("DB1","DB2","DB3","DB4","DB5","DB6","DB7","DB8","DB9","DB10","DB11","DB12","DB13","DB14","DB15","DB16","DB17","DB18","DB19","DB20","DB21","DB22")
    SpareVolumeCount = 0
    AutoDagDatabasesRootFolderPath = "C:\ExchangeDatabases" 
    AutoDagVolumesRootFolderPath = "C:\ExchangeVolumes" 
    VolumePrefix = "EXVOL" 
    MinDiskSize = "10MB"
    CreateSubfolders = $true
}

$casParams1 = @{
    Identity = $testServerHostname
    AutoDiscoverServiceInternalUri = ""
    AutoDiscoverSiteScope = "Site1"
    Credential = $shellCreds
    DomainController = $testDC
}

$casParams2 = @{
    Identity = $testServerHostname
    AutoDiscoverServiceInternalUri = "https://$($testExternalFQDN)/autodiscover/autodiscover.xml"
    AutoDiscoverSiteScope = "Site1"
    Credential = $shellCreds
    DomainController = $testDC
}

$ecpParams1 = @{
    Identity = "$($testServerHostname)\ecp (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/ecp"
    ExternalUrl = "https://$($testExternalFQDN)/ecp"
    BasicAuthentication = $true
    WindowsAuthentication = $false
    DigestAuthentication = $false
    FormsAuthentication = $true
    AdfsAuthentication = $false
    DomainController = $testDC
    Credential = $shellCreds
    ExternalAuthenticationMethods = "Fba"
    AllowServiceRestart = $true
}

$ecpParams2 = @{
    Identity = "$($testServerHostname)\ecp (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/ecp"
    ExternalUrl = $null
    BasicAuthentication = $false
    WindowsAuthentication = $true
    DigestAuthentication = $false
    FormsAuthentication = $false
    AdfsAuthentication = $false
    DomainController = $testDC
    Credential = $shellCreds
    ExternalAuthenticationMethods = "Ntlm","WindowsIntegrated"
    AllowServiceRestart = $true
}

$certParams1 = @{
    Thumbprint = $testThumbprint
    Services = "IMAP"
    Ensure = "Present"
    AllowExtraServices = $true
    CertFilePath = $certPath
    CertCreds = $certCreds
    Credential = $shellCreds
}

$certParams2 = @{
    Thumbprint = $testThumbprint
    Services = "IMAP", "POP", "IIS", "SMTP", "UM", "UMCallRouter"
    Ensure = "Present"
    CertFilePath = $certPath
    CertCreds = $certCreds
    Credential = $shellCreds
}

$certParams3 = @{
    Thumbprint = $testThumbprint
    Services = "NONE"
    AllowExtraServices = $true
    Ensure = "Present"
    CertFilePath = $certPath
    CertCreds = $certCreds
    Credential = $shellCreds
}

$exServerParams1 = @{
    Identity = $testServerHostname
    CustomerFeedbackEnabled = $true
    InternetWebProxy = "https://somewhere"
    MonitoringGroup = "MGroup"
    ProductKey = "$($testProductKey)"
    WorkloadManagementPolicy = "$($testWorkloadPolicy2)"
    Credential = $shellCreds
}

$mailboxDbParams1 = @{
    Name = $testDBName
    Server = $testServerHostname
    EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\TestDB123\TestDB123.edb"
    LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\TestDB123"
    DatabaseCopyCount = 2
    Credential = $shellCreds
    AllowServiceRestart = $true
    AutoDagExcludeFromMonitoring = $true
    BackgroundDatabaseMaintenance = $true
    CircularLoggingEnabled = $true
    DataMoveReplicationConstraint = "SecondDatacenter"
    DeletedItemRetention = "14.00:00:00"
    DomainController = $testDC
    EventHistoryRetentionPeriod = "03:04:05"
    IndexEnabled = $true
    IsExcludedFromProvisioning = $false
    IsSuspendedFromProvisioning = $false
    JournalRecipient = $testJournalRecipient
    MailboxRetention = "30.00:00:00"
    MountAtStartup = $true
    OfflineAddressBook = "$($testOAB)"
    RetainDeletedItemsUntilBackup = $false
    CalendarLoggingQuota = "unlimited"
    IssueWarningQuota = "27 MB"
    ProhibitSendQuota = "1GB"
    ProhibitSendReceiveQuota = "1.5 GB"
    RecoverableItemsQuota = "uNlImItEd"
    RecoverableItemsWarningQuota = "1,000,448"
}

$mailboxDbParams2 = @{
    Name = $testDBName
    Server = $testServerHostname
    EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\TestDB123-2\TestDB123.edb"
    LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\TestDB123-2"
    DatabaseCopyCount = 2
    Credential = $shellCreds
    AllowServiceRestart = $true
    AutoDagExcludeFromMonitoring = $true
    BackgroundDatabaseMaintenance = $true
    CircularLoggingEnabled = $true
    DataMoveReplicationConstraint = "SecondDatacenter"
    DeletedItemRetention = "14.00:00:00"
    DomainController = $testDC
    EventHistoryRetentionPeriod = "03:04:05"
    IndexEnabled = $true
    IsExcludedFromProvisioning = $false
    IsSuspendedFromProvisioning = $false
    JournalRecipient = $testJournalRecipient
    MailboxRetention = "30.00:00:00"
    MountAtStartup = $true
    OfflineAddressBook = "$($testOAB)"
    RetainDeletedItemsUntilBackup = $false
    CalendarLoggingQuota = "unlimited"
    IssueWarningQuota = "27 MB"
    ProhibitSendQuota = "1GB"
    ProhibitSendReceiveQuota = "1.5 GB"
    RecoverableItemsQuota = "uNlImItEd"
    RecoverableItemsWarningQuota = "1,000,448"
}

$mapiParams1 = @{
    Identity = "$($testServerHostname)\mapi (Default Web Site)"
    Credential = $shellCreds
    AllowServiceRestart = $true
    DomainController = $testDC
    InternalUrl = "http://$($testServerFQDN)/mapi"
    ExternalUrl = $null
    IISAuthenticationMethods = "NTLM","NEGOTIATE"
}

$oabParams1 = @{
    Identity = "$($testServerHostname)\OAB (Default Web Site)"
    Credential = $shellCreds
    OABsToDistribute = $testOAB
    AllowServiceRestart = $true
    BasicAuthentication = $false
    DomainController = $testDC
    ExtendedProtectionFlags = "Proxy","ProxyCoHosting"
    ExtendedProtectionSPNList = $null
    ExtendedProtectionTokenChecking = "Allow"
    InternalUrl = "http://$($testServerFQDN)/OAB"
    ExternalUrl = $null
    RequireSSL = $false
    WindowsAuthentication = $true
    PollInterval = 481
}

$oaParams1 = @{
    Identity = "$($testServerHostname)\Rpc (Default Web Site)"
    Credential = $shellCreds
    InternalHostname = "oa-int.mikelab.local"
    ExternalHostname = "oa-ext.mikelab.local"
    ExternalClientAuthenticationMethod = "Ntlm"
    IISAuthenticationMethods = "Ntlm"
    DomainController = $testdc
    ExternalClientsRequireSsl = $true
    InternalClientsRequireSsl = $true
    SslOffloading = $false
    ExtendedProtectionFlags = "Proxy","ProxyCoHosting"
    ExtendedProtectionSPNList = $null
    ExtendedProtectionTokenChecking = "Allow"
}

$oaParams2 = @{
    Identity = "$($testServerHostname)\Rpc (Default Web Site)"
    Credential = $shellCreds
    ExternalClientAuthenticationMethod = 'Ntlm'
    ExternalClientsRequireSSL          = $true
    ExternalHostName                   = $null
    IISAuthenticationMethods           = 'Ntlm'
    InternalClientAuthenticationMethod = 'Ntlm'
    InternalClientsRequireSSL          = $true
    InternalHostName                   = "oa-int.mikelab.local"
    AllowServiceRestart                = $true
}

$owaParams1 = @{
    Identity = "$($testServerHostname)\owa (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/owa"
    ExternalUrl = "https://$($testExternalFQDN)/owa"
    BasicAuthentication = $true
    WindowsAuthentication = $false
    DigestAuthentication = $false
    FormsAuthentication = $true
    AdfsAuthentication = $false
    DomainController = $testDC
    Credential = $shellCreds
    ExternalAuthenticationMethods = "Fba"
    InstantMessagingType = "Ocs"
    InstantMessagingCertificateThumbprint = $testThumbprint
    InstantMessagingServerName = $testIMServer
}

$owaParams2 = @{
    Identity = "$($testServerHostname)\owa (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/owa"
    ExternalUrl = $null
    BasicAuthentication = $false
    WindowsAuthentication = $true
    DigestAuthentication = $false
    FormsAuthentication = $false
    AdfsAuthentication = $false
    DomainController = $testDC
    Credential = $shellCreds
    ExternalAuthenticationMethods = "Ntlm","WindowsIntegrated"
    InstantMessagingType = "Ocs"
    InstantMessagingCertificateThumbprint = $testThumbprint
    InstantMessagingServerName = $testIMServer
}

$psParams1 = @{
    Identity = "$($testServerHostname)\PowerShell (Default Web Site)"
    Credential = $shellCreds
    AllowServiceRestart = $true
    BasicAuthentication = $false
    CertificateAuthentication = $true
    DomainController = $testDC
    InternalUrl = "http://$($testServerFQDN)/powershell"
    ExternalUrl = $null
    RequireSSL = $false
    WindowsAuthentication = $true
}

$connectorParams1 = @{
    Identity = "$($testServerHostname)\TestConn1"
    Credential = $shellCreds
    Bindings = "192.168.1.4:25","192.168.2.5:25"
    RemoteIPRanges = "10.10.10.1-10.10.11.255"
    Usage = "Custom"
    Ensure = "Present"
    AuthMechanism = "TLS","ExchangeServer"
    MaxMessageSize = 40000000
    MaxHeaderSize = 50000000
    MaxInboundConnectionPerSource = "unLiMiTeD"
    PermissionGroups = "ExchangeUsers","ExchangeServers"
    SizeEnabled = "EnabledWithoutValue"
    TransportRole = "FrontendTransport"
    MaxInboundConnection = "206"
    MaxProtocolErrors = 50
    MessageRateLimit = 9999
    AdvertiseClientSettings = $true
    BareLinefeedRejectionEnabled = $true
    BinaryMimeEnabled = $true
    ChunkingEnabled = $true
    DeliveryStatusNotificationEnabled = $true
    DomainSecureEnabled = $true
    EightBitMimeEnabled = $true
    EnableAuthGSSAPI = $true
    Enabled = $true
    EnhancedStatusCodesEnabled = $true
    LongAddressesEnabled = $true
    OrarEnabled = $true
    PipeliningEnabled = $true
    RequireEHLODomain = $true
    RequireTLS = $true
    SuppressXAnonymousTls = $true
    Banner = "220 what's up"
    Comment = "ccc"
    DefaultDomain = "mikelab.local"
    ExtendedProtectionPolicy = "Allow"
    Fqdn = "e15-1.mikelab.local"
    ProtocolLoggingLevel = "Verbose"
    ServiceDiscoveryFqdn = "a.b.com"
    TlsCertificateName = "<I>CN=mikelab-DC-1-CA, DC=mikelab, DC=local<S>CN=owa.mikelab.local"
    ConnectionInactivityTimeout = "05:04:03"
    ConnectionTimeout = "1.00:00:00"
    MaxAcknowledgementDelay = "00:03:02"
    TarpitInterval = "00:03:02"
    MaxHopCount = 5
    MaxInboundConnectionPercentagePerSource = 90
    MaxLocalHopCount = 6
    MaxLogonFailures = 9
    MaxRecipientsPerMessage = 300
    MessageRateSource = "User"
    TlsDomainCapabilities = "domain1.com:AcceptOorgProtocol","domain2.com:AcceptOorgHeader"
}

$connectorParams2 = @{
    Identity = "$($testServerHostname)\TestConn1"
    Credential = $shellCreds
    Bindings = "192.168.1.4:2525"
    RemoteIPRanges = "10.10.10.1-10.10.11.255","192.168.5.0/24"
    Usage = "Custom"
    Ensure = "Present"
    AuthMechanism = "TLS"
    MaxMessageSize = 40010000
    MaxHeaderSize = 50001000
    MaxInboundConnectionPerSource = "20"
    PermissionGroups = "ExchangeServers"
    SizeEnabled = "Enabled"
    TransportRole = "HubTransport"
    MaxInboundConnection = "106"
    MaxProtocolErrors = 51
    MessageRateLimit = 1999
    AdvertiseClientSettings = $false
    BareLinefeedRejectionEnabled = $false
    BinaryMimeEnabled = $false
    ChunkingEnabled = $false
    DeliveryStatusNotificationEnabled = $false
    DomainSecureEnabled = $false
    EightBitMimeEnabled = $false
    EnableAuthGSSAPI = $false
    Enabled = $false
    EnhancedStatusCodesEnabled = $false
    LongAddressesEnabled = $false
    OrarEnabled = $false
    PipeliningEnabled = $false
    RequireEHLODomain = $false
    RequireTLS = $false
    SuppressXAnonymousTls = $false
    Banner = "220 what's down"
    Comment = "ccca"
    DefaultDomain = "sub.mikelab.local"
    ExtendedProtectionPolicy = "None"
    Fqdn = "e15-1-bad.mikelab.local"
    ProtocolLoggingLevel = "None"
    ServiceDiscoveryFqdn = "a.b.c.com"
    TlsCertificateName = "<I>CN=mikelab-DC-1-CA, DC=mikelab, DC=local<S>CN=owa.mikelab.local"
    ConnectionInactivityTimeout = "06:04:03"
    ConnectionTimeout = "12:00:00"
    MaxAcknowledgementDelay = "0:3:12"
    TarpitInterval = "0:4:2"
    MaxHopCount = 6
    MaxInboundConnectionPercentagePerSource = 91
    MaxLocalHopCount = 7
    MaxLogonFailures = 8
    MaxRecipientsPerMessage = 310
    MessageRateSource = "IPAddress"
    TlsDomainCapabilities = "domain2.com:AcceptOorgProtocol","domain1.com:AcceptOorgHeader"
}

$ewsParams1 = @{
    Identity = "E15-1\EWS (Default Web Site)"
    InternalUrl = "https://$($testServerFQDN)/EWS/exchange.asmx"
    ExternalUrl = "https://$($testExternalFQDN)/EWS/exchange.asmx"
    BasicAuthentication = $false
    CertificateAuthentication = $false
    DigestAuthentication = $false
    OauthAuthentication = $true
    WindowsAuthentication = $true
    DomainController = $testDC
    Credential = $shellCreds
    WSSecurityAuthentication = $true
    InternalNLBBypassUrl = "https://$($testServerFQDN)/EWS/exchange.asmx"
    AllowServiceRestart = $true
}

$dagParams1 = @{
    Credential = $shellCreds
    Name = $testDAGName
    WitnessServer = $testWitnessServer
    WitnessDirectory = "C:\FSW"
    AlternateWitnessServer = $testAlternateWitnessServer
    AlternateWitnessDirectory = "C:\FSW"
    AutoDagAutoReseedEnabled = $true
    AutoDagDatabaseCopiesPerDatabase = 2
    AutoDagDatabaseCopiesPerVolume = 2
    AutoDagDatabasesRootFolderPath = "C:\dbroot"
    AutoDagDiskReclaimerEnabled = $true
    AutoDagTotalNumberOfServers = 2
    AutoDagTotalNumberOfDatabases = 2
    AutoDagVolumesRootFolderPath = "c:\volroot"
    DatabaseAvailabilityGroupIpAddresses = "192.168.1.99","192.168.2.99"
    DatacenterActivationMode = "DagOnly"
    ManualDagNetworkConfiguration = $true
    NetworkCompression = "Enabled"
    NetworkEncryption = "InterSubnetOnly"
    ReplayLagManagerEnabled = $true
    ReplicationPort = 12345
    SkipDagValidation = $true
}

$dagAddMemberParams1 = @{
    MailboxServer = $testServerHostname
    DAGName = $testDAGName
    Credential = $shellCreds 
    SkipDagValidation = $true
}

$dagAddMemberParams2 = @{
    MailboxServer = $testSecondDAGMember
    DAGName = $testDAGName
    Credential = $shellCreds 
    SkipDagValidation = $true
}

$dagNetParams1 = @{
    Name = $testDAGNetName
    DatabaseAvailabilityGroup = $testDAGName
    Credential = $shellCreds
    Ensure = "Present"
    IgnoreNetwork = $false
    ReplicationEnabled = $true
    Subnets = "192.168.1.0/24","192.168.2.0/24"
}

$dagNetParams2 = @{
    Name = $testDAGNetName
    DatabaseAvailabilityGroup = $testDAGName
    Credential = $shellCreds
    Ensure = "Present"
    IgnoreNetwork = $false
    ReplicationEnabled = $true
    Subnets = "192.168.1.0/24","192.168.2.0/24","192.168.3.0/24"
}

$dagDB1Params = @{
    Name = $testDAGDB1
    Server = $testServerHostname
    EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB1)\$($testDAGDB1).edb"
    LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB1)"
    DatabaseCopyCount = 2
    Credential = $shellCreds
    AllowServiceRestart = $true
}

$dagDB1CopyParams = @{
    Identity = $testDAGDB1
    MailboxServer = $testSecondDAGMember
    Credential = $shellCreds
    AllowServiceRestart = $true
    ActivationPreference = 2
}

$dagDB2Params = @{
    Name = $testDAGDB2
    Server = $testSecondDAGMember
    EdbFilePath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB2)\$($testDAGDB2).edb"
    LogFolderPath = "C:\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB2)"
    DatabaseCopyCount = 2
    Credential = $shellCreds
    AllowServiceRestart = $true
}

$dagDB2CopyParams = @{
    Identity = $testDAGDB2
    MailboxServer = $testServerHostname
    Credential = $shellCreds
    AllowServiceRestart = $true
    ActivationPreference = 2
    ReplayLagTime = "14.00:00:00"
    TruncationLagTime = "1.00:00:00"
}

$umServiceParams = @{
    Identity = $testServerHostname
    Credential = $shellCreds
    UMStartupMode = "Dual"
}

$umCallRouterSettingsParams = @{
    Server = $testServerHostname
    Credential = $shellCreds
    UMStartupMode = "Dual"
}

$imapPopSettingsParams = @{
    Server = $testServerHostname
    Credential = $shellCreds
    LoginType = "PlainTextLogin"
}

$installParams = @{
    Path = "C:\Binaries\E15CU6\Setup.exe"
    Arguments = "/mode:Install /role:Mailbox,ClientAccess /Iacceptexchangeserverlicenseterms"
    Credential = $shellCreds
}

$jetstressParams1 = @{
    Type = "Performance"
    JetstressPath = "C:\Program Files\Exchange Jetstress"
    JetstressParams = '/c "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"'
}

$jetstressCleanupParams1 = @{
    JetstressPath = "C:\Program Files\Exchange Jetstress"
    ConfigFilePath = "C:\Program Files\Exchange Jetstress\JetstressConfig.xml"
    DeleteAssociatedMountPoints = $true
    OutputSaveLocation = "C:\Save"
    RemoveBinaries = $true
}

$waitForADPrepParams = @{
    Identity = "Doesn'tMatter"
    Credential = $shellCreds
    SchemaVersion = 15303
    OrganizationVersion = 15965
    DomainVersion = 13236
}

#Removes the test DAG if it exists, and any associated databases
function PrepTestDAG
{
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

    #First remove the test database copies
    if ((Get-MailboxDatabase -Identity "$($testDAGDB1)" -ErrorAction SilentlyContinue) -ne $null)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($testDAGDB1)" | where {$_.MailboxServer -ne "$($testServerHostname)"} | Remove-MailboxDatabaseCopy -Confirm:$false
    }

    if ((Get-MailboxDatabase -Identity "$($testDAGDB2)" -ErrorAction SilentlyContinue) -ne $null)
    {
        Get-MailboxDatabaseCopyStatus -Identity "$($testDAGDB2)" | where {$_.MailboxServer -ne "$($testSecondDAGMember)"} | Remove-MailboxDatabaseCopy -Confirm:$false
    }

    #Now remove the actual DB's
    Get-MailboxDatabase | where {$_.Name -like "$($testDAGDB1)" -or $_.Name -like "$($testDAGDB2)"} | Remove-MailboxDatabase -Confirm:$false

    #Remove the files
    Get-ChildItem -LiteralPath "\\$($testServerHostname)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB1)" -ErrorAction SilentlyContinue | Remove-Item -Force -Confirm:$false
    Get-ChildItem -LiteralPath "\\$($testServerHostname)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB2)" -ErrorAction SilentlyContinue | Remove-Item -Force -Confirm:$false
    Get-ChildItem -LiteralPath "\\$($testSecondDAGMember)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB1)" -ErrorAction SilentlyContinue | Remove-Item -Force -Confirm:$false
    Get-ChildItem -LiteralPath "\\$($testSecondDAGMember)\c`$\Program Files\Microsoft\Exchange Server\V15\Mailbox\$($testDAGDB2)" -ErrorAction SilentlyContinue | Remove-Item -Force -Confirm:$false

    #Last remove the test DAG
    $dag = Get-DatabaseAvailabilityGroup -Identity "$($testDAGName)" -ErrorAction SilentlyContinue
    if ($dag -ne $null)
    {
        Set-DatabaseAvailabilityGroup -Identity "$($testDAGName)" -DatacenterActivationMode Off

        foreach ($server in $dag.Servers)
        {
            Remove-DatabaseAvailabilityGroupServer -MailboxServer "$($server.Name)" -Identity "$($testDAGName)" -Confirm:$false
        }

        Remove-DatabaseAvailabilityGroup -Identity "$($testDAGName)" -Confirm:$false
    }

    if ((Get-DatabaseAvailabilityGroup -Identity "$($testDAGName)" -ErrorAction SilentlyContinue) -ne $null)
    {
        throw "Failed to remove test DAG"
    }



    Remove-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
}

#Sets props retrieved by Get-ExchangeServer back to their default values
function PrepTestExchangeServer
{
    Import-Module ActiveDirectory
    ClearServerADProp("msExchProductID")
    ClearServerADProp("msExchCustomerFeedbackEnabled")
    ClearServerADProp("msExchInternetWebProxy")
    ClearServerADProp("msExchShadowDisplayName")   
}

#Deletes the test database
function PrepTestMailboxDatabase
{
    Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010

    if ((Get-MailboxDatabase "$($testDBName)" -ErrorAction SilentlyContinue) -ne $null)
    {
        Remove-MailboxDatabase "$($testDBName)" -Confirm:$false
    }

    Remove-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
}

#Used to null out the specified Active Directory property of an Exchange Server
function ClearServerADProp($prop)
{ 
    Get-ADObject -SearchBase "$($testServerDN)" -Filter {ObjectClass -eq "msExchExchangeServer"} | where {$_.ObjectClass -eq "msExchExchangeServer"} | Set-ADObject -Clear "$($prop)"
}

#Compares two values and reports whether they are the same or not
function CheckSetting($testName, $expectedValue, $actualValue)
{
    if ($expectedValue -ne $actualValue)
    {
        Write-Host -ForegroundColor Red "Test: '$($testName)'. Result: Fail. Expected value: '$($expectedValue)'. Actual value: '$($actualValue)'."
    }
    else
    {
        if ($showValidSettings -eq $true)
        {
            Write-Host -ForegroundColor Green "Test: '$($testName)'. Result: Pass. Value: '$($expectedValue)'."
        }
    }
}

#Actually runs the specified test
function RunTest
{
    param([string]$TestName, [string[]]$ModulesToImport, [Hashtable]$Parameters)

    #Load Required Modules
    foreach ($module in $ModulesToImport)
    {
        $modulePath = "..\DSCResources\$($module)\$($module).psm1"
        Import-Module $modulePath
    }

    if ($showVerbose -eq $true)
    {
        Set-TargetResource @Parameters -Verbose

        $getResult = Get-TargetResource @Parameters -Verbose
        checkSetting -testName "$($TestName): Get" -expectedValue $true -actualValue ($getResult -ne $null)

        $testResult = Test-TargetResource @Parameters -Verbose
        checkSetting -testName "$($TestName): Test" -expectedValue $true -actualValue $testResult
    }
    else
    {
        Set-TargetResource @Parameters

        $getResult = Get-TargetResource @Parameters
        checkSetting -testName "$($TestName): Get" -expectedValue $true -actualValue ($getResult -ne $null)

        $testResult = Test-TargetResource @Parameters
        checkSetting -testName "$($TestName): Test" -expectedValue $true -actualValue $testResult
    }

    #Unload Required Modules
    foreach ($module in $ModulesToImport)
    {
        Remove-Module $module
    }
}

#Runs any tests that match the filter
function RunTests
{
    param([string]$Filter)

    if ("TestActiveSync" -like $Filter)
    {
        RunTest -TestName "TestActiveSync1" -ModulesToImport "MSFT_xExchActiveSyncVirtualDirectory" -Parameters $asParams1
        RunTest -TestName "TestActiveSync2" -ModulesToImport "MSFT_xExchActiveSyncVirtualDirectory" -Parameters $asParams2
    }

    if ("TestAutoDiscover" -like $Filter)
    {
        RunTest -TestName "TestAutoDiscover1" -ModulesToImport "MSFT_xExchAutodiscoverVirtualDirectory" -Parameters $autodParams1
        RunTest -TestName "TestAutoDiscover2" -ModulesToImport "MSFT_xExchAutodiscoverVirtualDirectory" -Parameters $autodParams2
    }

    if ("TestAutoMountPoint" -like $Filter)
    {
        RunTest -TestName "TestAutoMountPoint2" -ModulesToImport "MSFT_xExchAutoMountPoint" -Parameters $autoMountPointParams2
    }

    if ("TestCAS" -like $Filter)
    {
        RunTest -TestName "TestCAS1" -ModulesToImport "MSFT_xExchClientAccessServer" -Parameters $casParams1
        RunTest -TestName "TestCAS2" -ModulesToImport "MSFT_xExchClientAccessServer" -Parameters $casParams2
    }

    if ("TestECP" -like $Filter)
    {
        RunTest -TestName "TestECP1" -ModulesToImport "MSFT_xExchEcpVirtualDirectory" -Parameters $ecpParams1
        RunTest -TestName "TestECP2" -ModulesToImport "MSFT_xExchEcpVirtualDirectory" -Parameters $ecpParams2
    }

    if ("TestCert" -like $Filter)
    {
        #RunTest -TestName "TestCert1" -ModulesToImport "MSFT_xExchExchangeCertificate" -Parameters $certParams1
        RunTest -TestName "TestCert2" -ModulesToImport "MSFT_xExchExchangeCertificate" -Parameters $certParams2
        #RunTest -TestName "TestCert3" -ModulesToImport "MSFT_xExchExchangeCertificate" -Parameters $certParams3
    }

    if ("TestExchangeServer" -like $Filter)
    {
        PrepTestExchangeServer
        RunTest -TestName "TestExchangeServer1" -ModulesToImport "MSFT_xExchExchangeServer" -Parameters $exServerParams1
    }

    if ("TestMailboxDatabase" -like $Filter)
    {
        PrepTestMailboxDatabase
        RunTest -TestName "TestMailboxDatabase1" -ModulesToImport "MSFT_xExchMailboxDatabase" -Parameters $mailboxDbParams1
        RunTest -TestName "TestMailboxDatabase2" -ModulesToImport "MSFT_xExchMailboxDatabase" -Parameters $mailboxDbParams2
    }

    if ("TestMapi" -like $Filter)
    {
        RunTest -TestName "TestMapi1" -ModulesToImport "MSFT_xExchMapiVirtualDirectory" -Parameters $mapiParams1
    }

    if ("TestOAB" -like $Filter)
    {
        RunTest -TestName "TestOAB1" -ModulesToImport "MSFT_xExchOabVirtualDirectory" -Parameters $oabParams1
    }   

    if ("TestOutlookAnywhere" -like $Filter)
    {
       # RunTest -TestName "TestOutlookAnywhere1" -ModulesToImport "MSFT_xExchOutlookAnywhere" -Parameters $oaParams1
        RunTest -TestName "TestOutlookAnywhere2" -ModulesToImport "MSFT_xExchOutlookAnywhere" -Parameters $oaParams2
    }  

    if ("TestOwa" -like $Filter)
    {
        RunTest -TestName "TestOwa1" -ModulesToImport "MSFT_xExchOwaVirtualDirectory" -Parameters $owaParams1
        RunTest -TestName "TestOwa2" -ModulesToImport "MSFT_xExchOwaVirtualDirectory" -Parameters $owaParams2
    }  

    if ("TestPowershell" -like $Filter)
    {
        RunTest -TestName "TestPowershell1" -ModulesToImport "MSFT_xExchPowerShellVirtualDirectory" -Parameters $psParams1
    }     

    if ("TestReceiveConnector" -like $Filter)
    {
        RunTest -TestName "TestReceiveConnector1" -ModulesToImport "MSFT_xExchReceiveConnector" -Parameters $connectorParams1
        RunTest -TestName "TestReceiveConnector2" -ModulesToImport "MSFT_xExchReceiveConnector" -Parameters $connectorParams2
    }  

    if ("TestEWS" -like $Filter)
    {
        RunTest -TestName "TestEWS1" -ModulesToImport "MSFT_xExchWebServicesVirtualDirectory" -Parameters $ewsParams1
    }  

    if ("TestDAG" -like $Filter)
    {
        PrepTestDAG
        RunTest -TestName "TestDAGNoMembers" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroup" -Parameters $dagParams1
        RunTest -TestName "TestDAGAddMember1" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroupMember" -Parameters $dagAddMemberParams1
        RunTest -TestName "TestDAGAddMember2" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroupMember" -Parameters $dagAddMemberParams2
        RunTest -TestName "TestDAGNet1" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroupNetwork" -Parameters $dagNetParams1
        RunTest -TestName "TestDAGNet2" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroupNetwork" -Parameters $dagNetParams2
        RunTest -TestName "TestDAGWithMembers" -ModulesToImport "MSFT_xExchDatabaseAvailabilityGroup" -Parameters $dagParams1
        RunTest -TestName "TestDAGCreateDB1" -ModulesToImport "MSFT_xExchMailboxDatabase" -Parameters $dagDB1Params
        RunTest -TestName "TestDAGCreateDB2" -ModulesToImport "MSFT_xExchMailboxDatabase" -Parameters $dagDB2Params
        RunTest -TestName "TestDAGAddCopyDB1" -ModulesToImport "MSFT_xExchMailboxDatabaseCopy" -Parameters $dagDB1CopyParams
        RunTest -TestName "TestDAGAddCopyDB2" -ModulesToImport "MSFT_xExchMailboxDatabaseCopy" -Parameters $dagDB2CopyParams
    }

    if ("TestUMService" -like $Filter)
    {
        RunTest -TestName "TestUMService1" -ModulesToImport "MSFT_xExchUMService" -Parameters $umServiceParams
    }

    if ("TestUMCallRouterSettings" -like $Filter)
    {
        RunTest -TestName "TestUCallRouterSettings1" -ModulesToImport "MSFT_xExchUMCallRouterSettings" -Parameters $umCallRouterSettingsParams
    }

    if ("TestImapSettings" -like $Filter)
    {
        RunTest -TestName "TestImapSettings1" -ModulesToImport "MSFT_xExchImapSettings" -Parameters $imapPopSettingsParams
    } 

    if ("TestPopSettings" -like $Filter)
    {
        RunTest -TestName "TestPopSettings1" -ModulesToImport "MSFT_xExchPopSettings" -Parameters $imapPopSettingsParams
    }

    if ("TestInstall" -like $Filter)
    {
        RunTest -TestName "TestInstall1" -ModulesToImport "MSFT_xExchInstall" -Parameters $installParams
    }

    if ("TestJetstress" -like $Filter)
    {
        RunTest -TestName "TestJetstress1" -ModulesToImport "MSFT_xExchJetstress" -Parameters $jetstressParams1
    }

    if ("TestJetstressCleanup" -like $Filter)
    {
        RunTest -TestName "TestJetstressCleanup1" -ModulesToImport "MSFT_xExchJetstressCleanup" -Parameters $jetstressCleanupParams1
    }

    if ("TestWaitForADPrep" -like $Filter)
    {
        RunTest -TestName "TestWaitForADPrep1" -ModulesToImport "MSFT_xExchWaitForADPrep" -Parameters $waitForADPrepParams
    }
}

RunTests -Filter "TestAutoMount*"