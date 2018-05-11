<#
.EXAMPLE
    This example shows how to start maintenance mode.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName        = '*'

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

            Site1DC         = 'dc-1'
            Site2DC         = 'dc-2'
        }

        #Individual target nodes are defined next
        @{
            NodeName = 'e15-1'
            NodeFqdn = 'e15-1.mikelab.local'
        }
    )
}

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
