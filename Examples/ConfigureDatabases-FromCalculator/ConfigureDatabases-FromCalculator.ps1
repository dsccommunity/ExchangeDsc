<#
.EXAMPLE
    This example shows how to configure databases from calculator.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'

            <#
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                This is added so that AppVeyor automatic tests can pass, otherwise
                the tests will fail on passwords being in plain text and not being
                encrypted. Because it is not possible to have a certificate in
                AppVeyor to encrypt the passwords we need to add the parameter
                'PSDscAllowPlainTextPassword'.
                NOTE! THIS IS NOT RECOMMENDED IN PRODUCTION.
                See:
                http://blogs.msdn.com/b/powershell/archive/2014/01/31/want-to-secure-credentials-in-windows-powershell-desired-state-configuration.aspx
            #>
            PSDscAllowPlainTextPassword = $true
        },

        @{
            NodeName           = 'e15-1'
            ServerNameInCsv    = 'SRV-nn-01'
            DbNameReplacements = @{"-nn-" = "-01-"}
        }

        @{
            NodeName           = 'e15-2'
            ServerNameInCsv    = 'SRV-nn-02'
            DbNameReplacements = @{"-nn-" = "-01-"}
        }
    )
}

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $ExchangeAdminCredential
    )

    Import-DscResource -Module xExchange

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.FullName)\HelperScripts\ExchangeConfigHelper.psm1"

    Node $AllNodes.NodeName
    {       
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
                Credential               = $ExchangeAdminCredential
                EdbFilePath              = $DB.DBFilePath
                LogFolderPath            = $DB.LogFolderPath
                Server                   = $Node.NodeName
                CircularLoggingEnabled   = $true
                DatabaseCopyCount        = 4
                IssueWarningQuota        = '50176MB'
                ProhibitSendQuota        = '51200MB'
                ProhibitSendReceiveQuota = '52224MB'
                AllowServiceRestart      = $true
            }
        }

        #Create the copies
        foreach ($DB in $copyDbList)
        {
            $waitResourceId = "WaitForDB_$($DB.Name)" #Unique ID for the xExchWaitForMailboxDatabase resource
            $copyResourceId = "MDBCopy_$($DB.Name)" #Unique ID for the xExchMailboxDatabaseCopy resource 

            #Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ExchangeAdminCredential                
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity             = $DB.Name
                Credential           = $ExchangeAdminCredential
                MailboxServer        = $Node.NodeName
                ActivationPreference = $DB.ActivationPreference
                ReplayLagTime        = $DB.ReplayLagTime
                AllowServiceRestart  = $true                
                DependsOn            = "[xExchWaitForMailboxDatabase]$($waitResourceId)"
            }
        }
    }
}
