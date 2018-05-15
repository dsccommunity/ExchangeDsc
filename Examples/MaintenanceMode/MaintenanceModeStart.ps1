<#
.EXAMPLE
    This example shows how to start maintenance mode.
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

    Node $AllNodes.NodeName
    {
        xExchMaintenanceMode EnterMaintenanceMode
        {
            Enabled    = $true
            Credential = $ExchangeAdminCredential
        }
    }
}
