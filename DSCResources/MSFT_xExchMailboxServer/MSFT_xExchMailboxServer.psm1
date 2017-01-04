[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateSet("BestAvailability","GoodAvailability","Lossless")]
        [System.String]
        $AutoDatabaseMountDial,

        [System.Int32]
        $CalendarRepairIntervalEndWindow,

        [System.String]
        $CalendarRepairLogDirectorySizeLimit,

        [System.Boolean]
        $CalendarRepairLogEnabled,

        [System.String]
        $CalendarRepairLogFileAgeLimit,

        [System.String]
        $CalendarRepairLogPath,

        [System.Boolean]
        $CalendarRepairLogSubjectLoggingEnabled,

        [System.Boolean]
        $CalendarRepairMissingItemFixDisabled,

        [ValidateSet("ValidateOnly","RepairAndValidate")]
        [System.String]
        $CalendarRepairMode,

        [System.String]
        $CalendarRepairWorkCycle,

        [System.String]
        $CalendarRepairWorkCycleCheckpoint,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $DomainController,

        [System.Boolean]
        $FolderLogForManagedFoldersEnabled,

        [System.Boolean]
        $ForceGroupMetricsGeneration,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.Boolean]
        $JournalingLogForManagedFoldersEnabled,

        [System.String[]]
        $Locale,

        [System.String]
        $LogDirectorySizeLimitForManagedFolders,

        [System.String]
        $LogFileAgeLimitForManagedFolders,

        [System.String]
        $LogFileSizeLimitForManagedFolders,

        [System.String]
        $LogPathForManagedFolders,

        [System.String]
        $MailboxProcessorWorkCycle,

        [System.String[]]
        $ManagedFolderAssistantSchedule,

        [System.String]
        $ManagedFolderWorkCycle,

        [System.String]
        $ManagedFolderWorkCycleCheckpoint,

        [System.Boolean]
        $MAPIEncryptionRequired,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $OABGeneratorWorkCycle,

        [System.String]
        $OABGeneratorWorkCycleCheckpoint,

        [System.String]
        $PublicFolderWorkCycle,

        [System.String]
        $PublicFolderWorkCycleCheckpoint,

        [System.Boolean]
        $RetentionLogForManagedFoldersEnabled,

        [System.String[]]
        $SharingPolicySchedule,

        [System.String]
        $SharingPolicyWorkCycle,

        [System.String]
        $SharingPolicyWorkCycleCheckpoint,

        [System.String]
        $SharingSyncWorkCycle,

        [System.String]
        $SharingSyncWorkCycleCheckpoint,

        [System.String]
        $SiteMailboxWorkCycle,

        [System.String]
        $SiteMailboxWorkCycleCheckpoint,

        [System.Boolean]
        $SubjectLogForManagedFoldersEnabled,

        [System.String]
        $TopNWorkCycle,

        [System.String]
        $TopNWorkCycleCheckpoint,

        [System.String]
        $UMReportingWorkCycle,

        [System.String]
        $UMReportingWorkCycleCheckpoint,

        [System.String]
        $WacDiscoveryEndpoint
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer" -VerbosePreference $VerbosePreference

    $server = GetMailboxServer @PSBoundParameters

    if ($null -ne $server)
    {
        $returnValue = @{
            Identity = $Identity
            AutoDatabaseMountDial = $server.AutoDatabaseMountDial
            CalendarRepairIntervalEndWindow = $server.CalendarRepairIntervalEndWindow
            CalendarRepairLogDirectorySizeLimit = $server.CalendarRepairLogDirectorySizeLimit
            CalendarRepairLogEnabled = $server.CalendarRepairLogEnabled
            CalendarRepairLogFileAgeLimit = $server.CalendarRepairLogFileAgeLimit
            CalendarRepairLogPath = $server.CalendarRepairLogPath
            CalendarRepairLogSubjectLoggingEnabled = $server.CalendarRepairLogSubjectLoggingEnabled
            CalendarRepairMissingItemFixDisabled = $server.CalendarRepairMissingItemFixDisabled
            CalendarRepairMode = $server.CalendarRepairMode
            FolderLogForManagedFoldersEnabled = $server.FolderLogForManagedFoldersEnabled
            ForceGroupMetricsGeneration = $server.ForceGroupMetricsGeneration
            IsExcludedFromProvisioning = $server.IsExcludedFromProvisioning
            JournalingLogForManagedFoldersEnabled = $server.JournalingLogForManagedFoldersEnabled
            Locale = $Server.Locale
            LogDirectorySizeLimitForManagedFolders = $server.LogDirectorySizeLimitForManagedFolders
            LogFileAgeLimitForManagedFolders = $server.LogFileAgeLimitForManagedFolders
            LogFileSizeLimitForManagedFolders = $server.LogFileSizeLimitForManagedFolders
            LogPathForManagedFolders = $server.LogPathForManagedFolders
            DatabaseCopyActivationDisabledAndMoveNow = $server.DatabaseCopyActivationDisabledAndMoveNow
            DatabaseCopyAutoActivationPolicy = $server.DatabaseCopyAutoActivationPolicy
            MAPIEncryptionRequired = $server.MAPIEncryptionRequired
            MaximumActiveDatabases = $server.MaximumActiveDatabases
            MaximumPreferredActiveDatabases = $server.MaximumPreferredActiveDatabases
            RetentionLogForManagedFoldersEnabled = $server.RetentionLogForManagedFoldersEnabled
            SharingPolicySchedule = $server.SharingPolicySchedule
            SubjectLogForManagedFoldersEnabled = $server.SubjectLogForManagedFoldersEnabled
        }

        $serverVersion = GetExchangeVersion

        if ($serverVersion -eq "2016")
        {
            $returnValue.Add("WacDiscoveryEndpoint", $server.WacDiscoveryEndpoint)
        }
        elseif ($serverVersion -eq "2013")
        {
            $returnValue.Add("CalendarRepairWorkCycle", $server.CalendarRepairWorkCycle)
            $returnValue.Add("CalendarRepairWorkCycleCheckpoint", $server.CalendarRepairWorkCycleCheckpoint)
            $returnValue.Add("MailboxProcessorWorkCycle", $server.MailboxProcessorWorkCycle)
            $returnValue.Add("ManagedFolderAssistantSchedule", $server.ManagedFolderAssistantSchedule)
            $returnValue.Add("ManagedFolderWorkCycle", $server.ManagedFolderWorkCycle)
            $returnValue.Add("ManagedFolderWorkCycleCheckpoint", $server.ManagedFolderWorkCycleCheckpoint)
            $returnValue.Add("OABGeneratorWorkCycle", $server.OABGeneratorWorkCycle)
            $returnValue.Add("OABGeneratorWorkCycleCheckpoint", $server.OABGeneratorWorkCycleCheckpoint)
            $returnValue.Add("PublicFolderWorkCycle", $server.PublicFolderWorkCycle)
            $returnValue.Add("PublicFolderWorkCycleCheckpoint", $server.PublicFolderWorkCycleCheckpoint)
            $returnValue.Add("SharingPolicyWorkCycle", $server.SharingPolicyWorkCycle)
            $returnValue.Add("SharingPolicyWorkCycleCheckpoint", $server.SharingPolicyWorkCycleCheckpoint)
            $returnValue.Add("SharingSyncWorkCycle", $server.SharingSyncWorkCycle)
            $returnValue.Add("SharingSyncWorkCycleCheckpoint", $server.SharingSyncWorkCycleCheckpoint)
            $returnValue.Add("SiteMailboxWorkCycle", $server.SiteMailboxWorkCycle)
            $returnValue.Add("SiteMailboxWorkCycleCheckpoint", $server.SiteMailboxWorkCycleCheckpoint)
            $returnValue.Add("TopNWorkCycle", $server.TopNWorkCycle)
            $returnValue.Add("TopNWorkCycleCheckpoint", $server.TopNWorkCycleCheckpoint)
            $returnValue.Add("UMReportingWorkCycle", $server.UMReportingWorkCycle)
            $returnValue.Add("UMReportingWorkCycleCheckpoint", $server.UMReportingWorkCycleCheckpoint)
        }
        else
        {
          Write-Verbose -Message "Could not detect Exchange version"
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateSet("BestAvailability","GoodAvailability","Lossless")]
        [System.String]
        $AutoDatabaseMountDial,

        [System.Int32]
        $CalendarRepairIntervalEndWindow,

        [System.String]
        $CalendarRepairLogDirectorySizeLimit,

        [System.Boolean]
        $CalendarRepairLogEnabled,

        [System.String]
        $CalendarRepairLogFileAgeLimit,

        [System.String]
        $CalendarRepairLogPath,

        [System.Boolean]
        $CalendarRepairLogSubjectLoggingEnabled,

        [System.Boolean]
        $CalendarRepairMissingItemFixDisabled,

        [ValidateSet("ValidateOnly","RepairAndValidate")]
        [System.String]
        $CalendarRepairMode,

        [System.String]
        $CalendarRepairWorkCycle,

        [System.String]
        $CalendarRepairWorkCycleCheckpoint,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $DomainController,

        [System.Boolean]
        $FolderLogForManagedFoldersEnabled,

        [System.Boolean]
        $ForceGroupMetricsGeneration,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.Boolean]
        $JournalingLogForManagedFoldersEnabled,

        [System.String[]]
        $Locale,

        [System.String]
        $LogDirectorySizeLimitForManagedFolders,

        [System.String]
        $LogFileAgeLimitForManagedFolders,

        [System.String]
        $LogFileSizeLimitForManagedFolders,

        [System.String]
        $LogPathForManagedFolders,

        [System.String]
        $MailboxProcessorWorkCycle,

        [System.String[]]
        $ManagedFolderAssistantSchedule,

        [System.String]
        $ManagedFolderWorkCycle,

        [System.String]
        $ManagedFolderWorkCycleCheckpoint,

        [System.Boolean]
        $MAPIEncryptionRequired,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $OABGeneratorWorkCycle,

        [System.String]
        $OABGeneratorWorkCycleCheckpoint,

        [System.String]
        $PublicFolderWorkCycle,

        [System.String]
        $PublicFolderWorkCycleCheckpoint,

        [System.Boolean]
        $RetentionLogForManagedFoldersEnabled,

        [System.String[]]
        $SharingPolicySchedule,

        [System.String]
        $SharingPolicyWorkCycle,

        [System.String]
        $SharingPolicyWorkCycleCheckpoint,

        [System.String]
        $SharingSyncWorkCycle,

        [System.String]
        $SharingSyncWorkCycleCheckpoint,

        [System.String]
        $SiteMailboxWorkCycle,

        [System.String]
        $SiteMailboxWorkCycleCheckpoint,

        [System.Boolean]
        $SubjectLogForManagedFoldersEnabled,

        [System.String]
        $TopNWorkCycle,

        [System.String]
        $TopNWorkCycleCheckpoint,

        [System.String]
        $UMReportingWorkCycle,

        [System.String]
        $UMReportingWorkCycleCheckpoint,

        [System.String]
        $WacDiscoveryEndpoint
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MailboxServer" -VerbosePreference $VerbosePreference

    #Setup params for next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    #create array of Exchange 2013 only parameters
    [array]$Exchange2013Only = 'CalendarRepairWorkCycle','CalendarRepairWorkCycleCheckpoint','MailboxProcessorWorkCycle','ManagedFolderAssistantSchedule','ManagedFolderWorkCycle',
    'ManagedFolderWorkCycleCheckpoint','OABGeneratorWorkCycle','OABGeneratorWorkCycleCheckpoint','PublicFolderWorkCycle','PublicFolderWorkCycleCheckpoint','SharingPolicyWorkCycle',
    'SharingPolicyWorkCycleCheckpoint','SharingSyncWorkCycle','SharingSyncWorkCycleCheckpoint','SiteMailboxWorkCycle','SiteMailboxWorkCycleCheckpoint','TopNWorkCycle','TopNWorkCycleCheckpoint',
    'UMReportingWorkCycle','UMReportingWorkCycleCheckpoint'

    $serverVersion = GetExchangeVersion
    if ($serverVersion -eq '2013')
    {
      #Check for non-existent parameters in Exchange 2013
      RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "WacDiscoveryEndpoint" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2016"
    }
    elseif ($serverVersion -eq '2016')
    {
      foreach ($Exchange2013Parameter in $Exchange2013Only)
      {
        #Check for non-existent parameters in Exchange 2016
        RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "$($Exchange2013Parameter)" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2013"
      }
    }
    else
    {
      Write-Verbose -Message "Could not detect Exchange version"
    }

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MailboxServer @PSBoundParameters

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
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateSet("BestAvailability","GoodAvailability","Lossless")]
        [System.String]
        $AutoDatabaseMountDial,

        [System.Int32]
        $CalendarRepairIntervalEndWindow,

        [System.String]
        $CalendarRepairLogDirectorySizeLimit,

        [System.Boolean]
        $CalendarRepairLogEnabled,

        [System.String]
        $CalendarRepairLogFileAgeLimit,

        [System.String]
        $CalendarRepairLogPath,

        [System.Boolean]
        $CalendarRepairLogSubjectLoggingEnabled,

        [System.Boolean]
        $CalendarRepairMissingItemFixDisabled,

        [ValidateSet("ValidateOnly","RepairAndValidate")]
        [System.String]
        $CalendarRepairMode,

        [System.String]
        $CalendarRepairWorkCycle,

        [System.String]
        $CalendarRepairWorkCycleCheckpoint,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $DomainController,

        [System.Boolean]
        $FolderLogForManagedFoldersEnabled,

        [System.Boolean]
        $ForceGroupMetricsGeneration,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.Boolean]
        $JournalingLogForManagedFoldersEnabled,

        [System.String[]]
        $Locale,

        [System.String]
        $LogDirectorySizeLimitForManagedFolders,

        [System.String]
        $LogFileAgeLimitForManagedFolders,

        [System.String]
        $LogFileSizeLimitForManagedFolders,

        [System.String]
        $LogPathForManagedFolders,

        [System.String]
        $MailboxProcessorWorkCycle,

        [System.String[]]
        $ManagedFolderAssistantSchedule,

        [System.String]
        $ManagedFolderWorkCycle,

        [System.String]
        $ManagedFolderWorkCycleCheckpoint,

        [System.Boolean]
        $MAPIEncryptionRequired,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $OABGeneratorWorkCycle,

        [System.String]
        $OABGeneratorWorkCycleCheckpoint,

        [System.String]
        $PublicFolderWorkCycle,

        [System.String]
        $PublicFolderWorkCycleCheckpoint,

        [System.Boolean]
        $RetentionLogForManagedFoldersEnabled,

        [System.String[]]
        $SharingPolicySchedule,

        [System.String]
        $SharingPolicyWorkCycle,

        [System.String]
        $SharingPolicyWorkCycleCheckpoint,

        [System.String]
        $SharingSyncWorkCycle,

        [System.String]
        $SharingSyncWorkCycleCheckpoint,

        [System.String]
        $SiteMailboxWorkCycle,

        [System.String]
        $SiteMailboxWorkCycleCheckpoint,

        [System.Boolean]
        $SubjectLogForManagedFoldersEnabled,

        [System.String]
        $TopNWorkCycle,

        [System.String]
        $TopNWorkCycleCheckpoint,

        [System.String]
        $UMReportingWorkCycle,

        [System.String]
        $UMReportingWorkCycleCheckpoint,

        [System.String]
        $WacDiscoveryEndpoint
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxServer","Set-MailboxServer" -VerbosePreference $VerbosePreference

    #create array of Exchange 2013 only parameters
    [array]$Exchange2013Only = 'CalendarRepairWorkCycle','CalendarRepairWorkCycleCheckpoint','MailboxProcessorWorkCycle','ManagedFolderAssistantSchedule','ManagedFolderWorkCycle',
    'ManagedFolderWorkCycleCheckpoint','OABGeneratorWorkCycle','OABGeneratorWorkCycleCheckpoint','PublicFolderWorkCycle','PublicFolderWorkCycleCheckpoint','SharingPolicyWorkCycle',
    'SharingPolicyWorkCycleCheckpoint','SharingSyncWorkCycle','SharingSyncWorkCycleCheckpoint','SiteMailboxWorkCycle','SiteMailboxWorkCycleCheckpoint','TopNWorkCycle','TopNWorkCycleCheckpoint',
    'UMReportingWorkCycle','UMReportingWorkCycleCheckpoint'

    $serverVersion = GetExchangeVersion
    if ($serverVersion -eq '2013')
    {
      #Check for non-existent parameters in Exchange 2013
      RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "WacDiscoveryEndpoint" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2016"
    }
    elseif ($serverVersion -eq '2016')
    {
      foreach ($Exchange2013Parameter in $Exchange2013Only)
      {
        #Check for non-existent parameters in Exchange 2016
        RemoveVersionSpecificParameters -PSBoundParametersIn $PSBoundParameters -ParamName "$($Exchange2013Parameter)" -ResourceName "xExchMailboxServer" -ParamExistsInVersion "2013"
      }
    }
    else
    {
      Write-Verbose -Message "Could not detect Exchange version"
    }

    $server = GetMailboxServer @PSBoundParameters

    if ($null -eq $server) #Couldn't find the server, which is bad
    {
        return $false
    }
    else #Validate server params
    {
        if (!(VerifySetting -Name "AutoDatabaseMountDial" -Type "String" -ExpectedValue $AutoDatabaseMountDial -ActualValue $server.AutoDatabaseMountDial -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairIntervalEndWindow" -Type "Int" -ExpectedValue $CalendarRepairIntervalEndWindow -ActualValue $server.CalendarRepairIntervalEndWindow -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairLogDirectorySizeLimit" -Type "Unlimited" -ExpectedValue $CalendarRepairLogDirectorySizeLimit -ActualValue $server.CalendarRepairLogDirectorySizeLimit -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }


        if (!(VerifySetting -Name "CalendarRepairLogEnabled" -Type "Boolean" -ExpectedValue $CalendarRepairLogEnabled -ActualValue $server.CalendarRepairLogEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }


        if (!(VerifySetting -Name "CalendarRepairLogFileAgeLimit" -Type "TimeSpan" -ExpectedValue $CalendarRepairLogFileAgeLimit -ActualValue $server.CalendarRepairLogFileAgeLimit -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairLogPath" -Type "String" -ExpectedValue $CalendarRepairLogPath -ActualValue $server.CalendarRepairLogPath -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairLogSubjectLoggingEnabled" -Type "Boolean" -ExpectedValue $CalendarRepairLogSubjectLoggingEnabled -ActualValue $server.CalendarRepairLogSubjectLoggingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairMissingItemFixDisabled" -Type "Boolean" -ExpectedValue $CalendarRepairMissingItemFixDisabled -ActualValue $server.CalendarRepairMissingItemFixDisabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairMode" -Type "String" -ExpectedValue $CalendarRepairMode -ActualValue $server.CalendarRepairMode -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairWorkCycle" -Type "TimeSpan" -ExpectedValue $CalendarRepairWorkCycle -ActualValue $server.CalendarRepairWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CalendarRepairWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $CalendarRepairWorkCycleCheckpoint -ActualValue $server.CalendarRepairWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DatabaseCopyActivationDisabledAndMoveNow" -Type "Boolean" -ExpectedValue $DatabaseCopyActivationDisabledAndMoveNow -ActualValue $server.DatabaseCopyActivationDisabledAndMoveNow -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DatabaseCopyAutoActivationPolicy" -Type "String" -ExpectedValue $DatabaseCopyAutoActivationPolicy -ActualValue $server.DatabaseCopyAutoActivationPolicy -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "FolderLogForManagedFoldersEnabled" -Type "Boolean" -ExpectedValue $FolderLogForManagedFoldersEnabled -ActualValue $server.FolderLogForManagedFoldersEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ForceGroupMetricsGeneration" -Type "Boolean" -ExpectedValue $ForceGroupMetricsGeneration -ActualValue $server.ForceGroupMetricsGeneration -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IsExcludedFromProvisioning" -Type "Boolean" -ExpectedValue $IsExcludedFromProvisioning -ActualValue $server.IsExcludedFromProvisioning -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "JournalingLogForManagedFoldersEnabled" -Type "Boolean" -ExpectedValue $JournalingLogForManagedFoldersEnabled -ActualValue $server.JournalingLogForManagedFoldersEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "Locale" -Type "Array" -ExpectedValue $Locale -ActualValue $server.Locale -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogDirectorySizeLimitForManagedFolders" -Type "Unlimited" -ExpectedValue $LogDirectorySizeLimitForManagedFolders -ActualValue $server.LogDirectorySizeLimitForManagedFolders -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogFileAgeLimitForManagedFolders" -Type "TimeSpan" -ExpectedValue $LogFileAgeLimitForManagedFolders -ActualValue $server.LogFileAgeLimitForManagedFolders -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogFileSizeLimitForManagedFolders" -Type "Unlimited" -ExpectedValue $LogFileSizeLimitForManagedFolders -ActualValue $server.LogFileSizeLimitForManagedFolders -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogPathForManagedFolders" -Type "String" -ExpectedValue $LogPathForManagedFolders -ActualValue $server.LogPathForManagedFolders -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MailboxProcessorWorkCycle" -Type "TimeSpan" -ExpectedValue $MailboxProcessorWorkCycle -ActualValue $server.MailboxProcessorWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ManagedFolderAssistantSchedule" -Type "Array" -ExpectedValue $ManagedFolderAssistantSchedule -ActualValue $server.ManagedFolderAssistantSchedule -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ManagedFolderWorkCycle" -Type "TimeSpan" -ExpectedValue $ManagedFolderWorkCycle -ActualValue $server.ManagedFolderWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ManagedFolderWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $ManagedFolderWorkCycleCheckpoint -ActualValue $server.ManagedFolderWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MAPIEncryptionRequired" -Type "Boolean" -ExpectedValue $MAPIEncryptionRequired -ActualValue $server.MAPIEncryptionRequired -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumActiveDatabases" -Type "String" -ExpectedValue $MaximumActiveDatabases -ActualValue $server.MaximumActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "MaximumPreferredActiveDatabases" -Type "String" -ExpectedValue $MaximumPreferredActiveDatabases -ActualValue $server.MaximumPreferredActiveDatabases -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "OABGeneratorWorkCycle" -Type "TimeSpan" -ExpectedValue $OABGeneratorWorkCycle -ActualValue $server.OABGeneratorWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "OABGeneratorWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $OABGeneratorWorkCycleCheckpoint -ActualValue $server.OABGeneratorWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PublicFolderWorkCycle" -Type "TimeSpan" -ExpectedValue $PublicFolderWorkCycle -ActualValue $server.PublicFolderWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "PublicFolderWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $PublicFolderWorkCycleCheckpoint -ActualValue $server.PublicFolderWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RetentionLogForManagedFoldersEnabled" -Type "Boolean" -ExpectedValue $RetentionLogForManagedFoldersEnabled -ActualValue $server.RetentionLogForManagedFoldersEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SharingPolicySchedule" -Type "Array" -ExpectedValue $SharingPolicySchedule -ActualValue $server.SharingPolicySchedule -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SharingPolicyWorkCycle" -Type "TimeSpan" -ExpectedValue $SharingPolicyWorkCycle -ActualValue $server.SharingPolicyWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SharingPolicyWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $SharingPolicyWorkCycleCheckpoint -ActualValue $server.SharingPolicyWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SharingSyncWorkCycle" -Type "TimeSpan" -ExpectedValue $SharingSyncWorkCycle -ActualValue $server.SharingSyncWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SharingSyncWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $SharingSyncWorkCycleCheckpoint -ActualValue $server.SharingSyncWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SiteMailboxWorkCycle" -Type "TimeSpan" -ExpectedValue $SiteMailboxWorkCycle -ActualValue $server.SiteMailboxWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SiteMailboxWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $SiteMailboxWorkCycleCheckpoint -ActualValue $server.SiteMailboxWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SubjectLogForManagedFoldersEnabled" -Type "Boolean" -ExpectedValue $SubjectLogForManagedFoldersEnabled -ActualValue $server.SubjectLogForManagedFoldersEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "TopNWorkCycle" -Type "TimeSpan" -ExpectedValue $TopNWorkCycle -ActualValue $server.TopNWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "TopNWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $TopNWorkCycleCheckpoint -ActualValue $server.TopNWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "UMReportingWorkCycle" -Type "TimeSpan" -ExpectedValue $UMReportingWorkCycle -ActualValue $server.UMReportingWorkCycle -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "UMReportingWorkCycleCheckpoint" -Type "TimeSpan" -ExpectedValue $UMReportingWorkCycleCheckpoint -ActualValue $server.UMReportingWorkCycleCheckpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WacDiscoveryEndpoint" -Type "String" -ExpectedValue $WacDiscoveryEndpoint -ActualValue $server.WacDiscoveryEndpoint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

#Runs Get-MailboxServer, only specifying Identity, and optionally DomainController
function GetMailboxServer
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [ValidateSet("BestAvailability","GoodAvailability","Lossless")]
        [System.String]
        $AutoDatabaseMountDial,

        [System.Int32]
        $CalendarRepairIntervalEndWindow,

        [System.String]
        $CalendarRepairLogDirectorySizeLimit,

        [System.Boolean]
        $CalendarRepairLogEnabled,

        [System.String]
        $CalendarRepairLogFileAgeLimit,

        [System.String]
        $CalendarRepairLogPath,

        [System.Boolean]
        $CalendarRepairLogSubjectLoggingEnabled,

        [System.Boolean]
        $CalendarRepairMissingItemFixDisabled,

        [ValidateSet("ValidateOnly","RepairAndValidate")]
        [System.String]
        $CalendarRepairMode,

        [System.String]
        $CalendarRepairWorkCycle,

        [System.String]
        $CalendarRepairWorkCycleCheckpoint,

        [System.Boolean]
        $DatabaseCopyActivationDisabledAndMoveNow,

        [ValidateSet("Blocked","IntrasiteOnly","Unrestricted")]
        [System.String]
        $DatabaseCopyAutoActivationPolicy,

        [System.String]
        $DomainController,

        [System.Boolean]
        $FolderLogForManagedFoldersEnabled,

        [System.Boolean]
        $ForceGroupMetricsGeneration,

        [System.Boolean]
        $IsExcludedFromProvisioning,

        [System.Boolean]
        $JournalingLogForManagedFoldersEnabled,

        [System.String[]]
        $Locale,

        [System.String]
        $LogDirectorySizeLimitForManagedFolders,

        [System.String]
        $LogFileAgeLimitForManagedFolders,

        [System.String]
        $LogFileSizeLimitForManagedFolders,

        [System.String]
        $LogPathForManagedFolders,

        [System.String]
        $MailboxProcessorWorkCycle,

        [System.String[]]
        $ManagedFolderAssistantSchedule,

        [System.String]
        $ManagedFolderWorkCycle,

        [System.String]
        $ManagedFolderWorkCycleCheckpoint,

        [System.Boolean]
        $MAPIEncryptionRequired,

        [System.String]
        $MaximumActiveDatabases,

        [System.String]
        $MaximumPreferredActiveDatabases,

        [System.String]
        $OABGeneratorWorkCycle,

        [System.String]
        $OABGeneratorWorkCycleCheckpoint,

        [System.String]
        $PublicFolderWorkCycle,

        [System.String]
        $PublicFolderWorkCycleCheckpoint,

        [System.Boolean]
        $RetentionLogForManagedFoldersEnabled,

        [System.String[]]
        $SharingPolicySchedule,

        [System.String]
        $SharingPolicyWorkCycle,

        [System.String]
        $SharingPolicyWorkCycleCheckpoint,

        [System.String]
        $SharingSyncWorkCycle,

        [System.String]
        $SharingSyncWorkCycleCheckpoint,

        [System.String]
        $SiteMailboxWorkCycle,

        [System.String]
        $SiteMailboxWorkCycleCheckpoint,

        [System.Boolean]
        $SubjectLogForManagedFoldersEnabled,

        [System.String]
        $TopNWorkCycle,

        [System.String]
        $TopNWorkCycleCheckpoint,

        [System.String]
        $UMReportingWorkCycle,

        [System.String]
        $UMReportingWorkCycleCheckpoint,

        [System.String]
        $WacDiscoveryEndpoint
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxServer @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource

