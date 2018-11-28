<#
.EXAMPLE
    This example shows how to configure databases manually.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName                    = '*'
        },

        # Individual target nodes are defined next
        @{
            NodeName        = 'e15-1'

            # Configure the databases whose primary copies will reside on this server
            PrimaryDBList = @{
                DB1 = @{Name = 'DB1'; EdbFilePath = 'C:\ExchangeDatabases\DB1\DB1.db\DB1.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB1\DB1.log'};
                DB3 = @{Name = 'DB3'; EdbFilePath = 'C:\ExchangeDatabases\DB3\DB3.db\DB3.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB3\DB3.log'}
            }

            # Configure the copies next.
            CopyDBList    = @{
                DB2 = @{Name = 'DB2'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB4 = @{Name = 'DB4'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
        }

        @{
            NodeName        = 'e15-2'

            PrimaryDBList = @{
                DB1 = @{Name = 'DB1'; EdbFilePath = 'C:\ExchangeDatabases\DB1\DB1.db\DB1.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB1\DB1.log'};
                DB3 = @{Name = 'DB3'; EdbFilePath = 'C:\ExchangeDatabases\DB3\DB3.db\DB3.edb'; LogFolderPath = 'C:\ExchangeDatabases\DB3\DB3.log'}
            }

            CopyDBList    = @{
                DB2 = @{Name = 'DB2'; ActivationPreference = 2; ReplayLagTime = '00:00:00'};
                DB4 = @{Name = 'DB4'; ActivationPreference = 2; ReplayLagTime = '00:00:00'}
            }
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

    Node $AllNodes.NodeName
    {
        # Create primary databases
        foreach ($DB in $Node.PrimaryDBList.Values)
        {
            # Need to define a unique ID for each database
            $resourceId = "MDB_$($DB.Name)"

            xExchMailboxDatabase $resourceId
            {
                Name                     = $DB.Name
                Credential               = $ExchangeAdminCredential
                EdbFilePath              = $DB.EdbFilePath
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
        foreach ($DB in $Node.CopyDBList.Values)
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
