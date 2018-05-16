<#
.EXAMPLE
    This example shows how to configure primary databases.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.psm1'
. $ConfigurationDataFile

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]    
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Examples\HelperScripts\ExchangeConfigHelper.psm1"

    #This section will handle configuring all non-DAG specific settings, including CAS and MBX settings.
    Node $AllNodes.NodeName
    {
        $dagSettings        = $ConfigurationData[$Node.DAGId] #Get DAG settings for this node
        $casSettingsPerSite = $ConfigurationData[$Node.CASId] #Get site specific CAS settings for this node

        ###Mailbox Server settings###
        $dbMap = DBMapFromServersCsv -ServersCsvPath $Node.ServersCsvPath `
                                     -ServerNameInCsv $Node.ServerNameInCsv `
                                     -DbNameReplacements $dagSettings.DbNameReplacements
                                     
        $primaryDbList = DBListFromMailboxDatabasesCsv -MailboxDatabasesCsvPath $Node.MailboxDatabasesCsvPath `
                                                       -ServerNameInCsv $Node.ServerNameInCsv `
                                                       -DbNameReplacements $dagSettings.DbNameReplacements

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
            $resourceId = "MDB_$($DB.Name)" #Need to define a unique ID for each database

            xExchMailboxDatabase $resourceId 
            {
                Name                            = $DB.Name
                Credential                      = $ExchangeAdminCredential
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
