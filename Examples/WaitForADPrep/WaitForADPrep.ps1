<#
.EXAMPLE
    This example shows how to ensure that the ADPrep already exists.
#>

Configuration Example
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $Creds    
    )

    Import-DscResource -Module xExchange

    node localhost
    {
        xExchWaitForADPrep WaitForADPrep
        {
            Identity            = "Doesn'tMatter"
            Credential          = $Creds
            SchemaVersion       = 15303
            OrganizationVersion = 15965
            DomainVersion       = 13236
        }
    }
}
