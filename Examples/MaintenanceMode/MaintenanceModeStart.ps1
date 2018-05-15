<#
.EXAMPLE
    This example shows how to start maintenance mode.
#>

Write-Verbose -Message 'Loading Configuration File - ConfigurationData.psd1.'
$ConfigRoot = "$PSScriptRoot\Config"
$ConfigFile = Get-ChildItem "$ConfigRoot\ConfigurationData.psd1"
$ConfigurationData = New-Object -TypeName hashtable
$ConfigurationData = (Import-PowerShellDataFile -Path $ConfigFile.FullName)

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
