<#
.EXAMPLE
    This example shows how to ensure that the ADPrep already exists.
#>

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'

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
        }
    )
}

Configuration Example
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Creds    
    )

    Import-DscResource -Module xExchange

    node localhost {
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
