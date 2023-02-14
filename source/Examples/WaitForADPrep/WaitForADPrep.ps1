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
        $ExchangeAdminCredential
    )

    Import-DscResource -Module ExchangeDsc

    node localhost
    {
        ExchWaitForADPrep WaitForADPrep
        {
            Identity            = "Doesn'tMatter"
            Credential          = $ExchangeAdminCredential
            SchemaVersion       = 15303
            OrganizationVersion = 15965
            DomainVersion       = 13236
        }
    }
}
