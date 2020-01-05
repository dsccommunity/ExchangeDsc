<#
.EXAMPLE
    This example shows how to configure databases from calculator.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
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

    Import-Module -Name (Join-Path -Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) -ChildPath 'Modules\xExchangeCalculatorHelper\xExchangeCalculatorHelper.psd1')

    Node $AllNodes.NodeName
    {
        # Load the primary and copy lists from the calculator files
        $primaryDbList = Get-DBListFromMailboxDatabasesCsv `
                            -MailboxDatabasesCsvPath "$($PSScriptRoot)\CalculatorAndScripts\MailboxDatabases.csv" `
                            -ServerNameInCsv $Node.ServerNameInCsv `
                            -DbNameReplacements $Node.DbNameReplacements

        $copyDbList = Get-DBListFromMailboxDatabaseCopiesCsv `
                            -MailboxDatabaseCopiesCsvPath "$($PSScriptRoot)\CalculatorAndScripts\MailboxDatabaseCopies.csv" `
                            -ServerNameInCsv $Node.ServerNameInCsv `
                            -DbNameReplacements $Node.DbNameReplacements

        # Create primary databases
        foreach ($DB in $primaryDbList)
        {
            # Need to define a unique ID for each database
            $resourceId = "MDB:$($DB.Name)"

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

        # Create the copies
        foreach ($DB in $copyDbList)
        {
            # Unique ID for the xExchWaitForMailboxDatabase resource
            $waitResourceId = "WaitForDB_$($DB.Name)"

            # Unique ID for the xExchMailboxDatabaseCopy resource
            $copyResourceId = "MDBCopy_$($DB.Name)"

            # Need to wait for a primary copy to be created before we add a copy
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
