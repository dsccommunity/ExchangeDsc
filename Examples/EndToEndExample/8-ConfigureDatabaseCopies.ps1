Configuration ConfigureDatabaseCopies
{
    param
    (
        [PSCredential]$ShellCreds,
        [string]$NodeFilter = "*"
    )

    #Import required DSC Modules
    Import-DscResource -Module xExchange

    #Import the helper module. It is used for importing the .CSV's created by the Server Role Requirements Calculator and using them to create mount points and databases
    Import-Module "$($PSScriptRoot)\ExchangeConfigHelper.psm1"

    #This section will handle configuring all non-DAG specific settings, including CAS and MBX settings.
    Node $AllNodes.NodeName
    {
        $dagSettings = $ConfigurationData[$Node.DAGId] #Look up and retrieve the DAG settings for this node

        ###Mailbox Server settings###
        $copyDbList = DBListFromMailboxDatabaseCopiesCsv -MailboxDatabaseCopiesCsvPath $Node.MailboxDatabaseCopiesCsvPath -ServerNameInCsv $Node.ServerNameInCsv -DbNameReplacements $dagSettings.DbNameReplacements

        #Create the copies
        foreach ($DB in $copyDbList)
        {
            $waitResourceId = "WaitForDB:$($DB.Name)" #Unique ID for the xWaitForMailboxDatabase resource
            $copyResourceId = "MDBCopy:$($DB.Name)" #Unique ID for the xMailboxDatabaseCopy resource 

            #Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ShellCreds           
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity                        = $DB.Name
                Credential                      = $ShellCreds
                MailboxServer                   = $Node.NodeName
                ActivationPreference            = $DB.ActivationPreference
                ReplayLagTime                   = $DB.ReplayLagTime
                AllowServiceRestart             = $false
                SeedingPostponed                = $true
                
                DependsOn                       = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }
}

if ($null -eq $ShellCreds)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
ConfigureDatabaseCopies -ConfigurationData $PSScriptRoot\ExchangeSettings-Lab.psd1 -ShellCreds $ShellCreds -NodeFilter "*"

###Pushes configuration to specified computer
#Start-DscConfiguration -Path .\ConfigureDatabaseCopies -Verbose -Wait -Credential $ShellCreds -ComputerName XXX
