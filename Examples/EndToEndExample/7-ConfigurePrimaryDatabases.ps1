Configuration ConfigurePrimaryDatabases
{
    param
    (
        [PSCredential]$ShellCreds
    )

    #Import required DSC Modules
    Import-DscResource -Module xExchange

    #Import the helper module. It is used for importing the .CSV's created by the Server Role Requirements Calculator and using them to create mount points and databases
    Import-Module "$($PSScriptRoot)\ExchangeConfigHelper.psm1"

    #This section will handle configuring all non-DAG specific settings, including CAS and MBX settings.
    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Get DAG settings for this node

        $casSettingsPerSite = $ConfigurationData[$Node.CASId] #Get site specific CAS settings for this node


        ###Mailbox Server settings###
        $dbMap = DBMapFromServersCsv -ServersCsvPath $Node.ServersCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements
        $primaryDbList = DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $Node.MailboxDatabasesCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements

        #Create all mount points on the server
        xExchAutoMountPoint AMP
        {
            Identity                       = $Node.NodeName
            AutoDagDatabasesRootFolderPath = 'C:\ExchangeDatabases'
            AutoDagVolumesRootFolderPath   = 'C:\ExchangeVolumes'
            DiskToDBMap                    = $dbMap
            SpareVolumeCount               = 1
            VolumePrefix                   = 'EXVOL'
        }

        #Create primary databases
        foreach ($DB in $primaryDbList)
        {
            $resourceId = "MDB:$($DB.Name)" #Need to define a unique ID for each database

            xExchMailboxDatabase $resourceId 
            {
                Name                            = $DB.Name
                Credential                      = $ShellCreds
                EdbFilePath                     = $DB.DBFilePath
                LogFolderPath                   = $DB.LogFolderPath
                Server                          = $Node.NodeName
                CircularLoggingEnabled          = $true
                DatabaseCopyCount               = $dagSettings.AutoDagDatabaseCopiesPerVolume
                OfflineAddressBook              = $casSettingsPerSite.DefaultOAB
                SkipInitialDatabaseMount        = $true

                DependsOn                       = '[xExchAutoMountPoint]AMP' #Can't create databases until the mount points exist
            }
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
ConfigurePrimaryDatabases -ConfigurationData $PSScriptRoot\ExchangeSettings-Prod.psd1 -ShellCreds $ShellCreds

###Pushes configuration to specified computer
#Start-DscConfiguration -Path .\ConfigurePrimaryDatabases -Verbose -Wait -ComputerName XXX
