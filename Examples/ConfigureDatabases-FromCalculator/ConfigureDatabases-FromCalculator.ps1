Configuration ConfigureDatabasesFromCalculator
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.FullName)\HelperScripts\ExchangeConfigHelper.psm1"

    Node $AllNodes.NodeName
    {
        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
        
        #Load the primary and copy lists from the calculator files
        $primaryDbList = DBListFromMailboxDatabasesCsv `
                            -MailboxDatabasesCsvPath "$($PSScriptRoot)\CalculatorAndScripts\MailboxDatabases.csv" `
                            -ServerNameInCsv $Node.ServerNameInCsv `
                            -DbNameReplacements $Node.DbNameReplacements

        $copyDbList = DBListFromMailboxDatabaseCopiesCsv `
                            -MailboxDatabaseCopiesCsvPath "$($PSScriptRoot)\CalculatorAndScripts\MailboxDatabaseCopies.csv" `
                            -ServerNameInCsv $Node.ServerNameInCsv `
                            -DbNameReplacements $Node.DbNameReplacements

        #Create primary databases
        foreach ($DB in $primaryDbList)
        {
            $resourceId = "MDB:$($DB.Name)" #Need to define a unique ID for each database

            xExchMailboxDatabase $resourceId 
            {
                Name                     = $DB.Name
                Credential               = $ShellCreds
                EdbFilePath              = $DB.DBFilePath
                LogFolderPath            = $DB.LogFolderPath
                Server                   = $Node.NodeName
                CircularLoggingEnabled   = $true
                DatabaseCopyCount        = 4
                IssueWarningQuota        = "50176MB"
                ProhibitSendQuota        = "51200MB"
                ProhibitSendReceiveQuota = "52224MB"
                AllowServiceRestart      = $true
            }
        }

        #Create the copies
        foreach ($DB in $copyDbList)
        {
            $waitResourceId = "WaitForDB:$($DB.Name)" #Unique ID for the xExchWaitForMailboxDatabase resource
            $copyResourceId = "MDBCopy:$($DB.Name)" #Unique ID for the xExchMailboxDatabaseCopy resource 

            #Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ShellCreds                
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity             = $DB.Name
                Credential           = $ShellCreds
                MailboxServer        = $Node.NodeName
                ActivationPreference = $DB.ActivationPreference
                ReplayLagTime        = $DB.ReplayLagTime
                AllowServiceRestart  = $true
                
                DependsOn            = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
ConfigureDatabasesFromCalculator -ConfigurationData $PSScriptRoot\ConfigureDatabases-FromCalculator-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
Set-DscLocalConfigurationManager -Path .\ConfigureDatabasesFromCalculator -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\ConfigureDatabasesFromCalculator -Verbose -Wait 