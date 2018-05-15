<#
.EXAMPLE
    This example shows how to configure databases copies.
#>

$ConfigurationDataFile = Join-Path -Path $PSScriptRoot -ChildPath 'ConfigurationData.ps1'
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
        $dagSettings = $ConfigurationData[$Node.DAGId] #Look up and retrieve the DAG settings for this node

        ###Mailbox Server settings###
        $copyDbList = DBListFromMailboxDatabaseCopiesCsv -MailboxDatabaseCopiesCsvPath $Node.MailboxDatabaseCopiesCsvPath `
                                                         -ServerNameInCsv $Node.ServerNameInCsv `
                                                         -DbNameReplacements $dagSettings.DbNameReplacements

        #Create the copies
        foreach ($DB in $copyDbList)
        {
            $waitResourceId = "WaitForDB_$($DB.Name)" #Unique ID for the xWaitForMailboxDatabase resource
            $copyResourceId = "MDBCopy_$($DB.Name)" #Unique ID for the xMailboxDatabaseCopy resource 

            #Need to wait for a primary copy to be created before we add a copy
            xExchWaitForMailboxDatabase $waitResourceId
            {
                Identity   = $DB.Name
                Credential = $ExchangeAdminCredential           
            }

            xExchMailboxDatabaseCopy $copyResourceId
            {
                Identity                        = $DB.Name
                Credential                      = $ExchangeAdminCredential
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
