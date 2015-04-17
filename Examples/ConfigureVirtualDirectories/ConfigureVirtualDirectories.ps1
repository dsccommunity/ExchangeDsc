Configuration ConfigureVirtualDirectories
{
    param
    (
        [PSCredential]$ShellCreds
    )

    Import-DscResource -Module xExchange

    Node $AllNodes.NodeName
    {
        $casSettings = $ConfigurationData[$Node.CASId] #Look up and retrieve the CAS settings for this node

        #Thumbprint of the certificate used to decrypt credentials on the target node
        LocalConfigurationManager
        {
            CertificateId = $Node.Thumbprint
        }
        
        ###CAS specific settings###
        xExchClientAccessServer CAS
        {
            Identity                       = $Node.NodeName
            Credential                     = $ShellCreds
            AutoDiscoverServiceInternalUri = "https://$($casSettings.InternalNLBFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope          = $casSettings.AutoDiscoverSiteScope
        }

        #Install features that are required for xExchActiveSyncVirtualDirectory to do Auto Certification Based Authentication
        WindowsFeature WebClientAuth
        {
            Name   = 'Web-Client-Auth'
            Ensure = 'Present'
        }

        WindowsFeature WebCertAuth
        {
            Name   = 'Web-Cert-Auth'
            Ensure = 'Present'
        }

        #This example shows how to enable Certificate Based Authentication for ActiveSync
        xExchActiveSyncVirtualDirectory ASVdir
        {
            Identity                    = "$($Node.NodeName)\Microsoft-Server-ActiveSync (Default Web Site)"
            Credential                  = $ShellCreds
            AutoCertBasedAuth           = $true
            AutoCertBasedAuthThumbprint = '49bef4b2e82599233154465323ebf96a12b60673'
            BasicAuthEnabled            = $false
            ClientCertAuth              = 'Required'
            ExternalUrl                 = "https://$($casSettings.ExternalNLBFqdn)/Microsoft-Server-ActiveSync"  
            InternalUrl                 = "https://$($casSettings.InternalNLBFqdn)/Microsoft-Server-ActiveSync"  
            WindowsAuthEnabled          = $false
            AllowServiceRestart         = $true
            
            DependsOn                   = '[WindowsFeature]WebClientAuth','[WindowsFeature]WebCertAuth'
            #NOTE: If CBA is being configured, this should also be dependent on the cert whose thumbprint is being used. See EndToEndExample.
        }

        #Ensures forms based auth and configures URLs
        xExchEcpVirtualDirectory ECPVDir
        {
            Identity                      = "$($Node.NodeName)\ecp (Default Web Site)"
            Credential                    = $ShellCreds
            BasicAuthentication           = $true
            ExternalAuthenticationMethods = 'Fba'
            ExternalUrl                   = "https://$($casSettings.ExternalNLBFqdn)/ecp"
            FormsAuthentication           = $true
            InternalUrl                   = "https://$($casSettings.InternalNLBFqdn)/ecp"           
            WindowsAuthentication         = $false
            AllowServiceRestart           = $true
        }

		#Configure URL's and for NTLM and negotiate auth
        xExchMapiVirtualDirectory MAPIVdir
        {
            Identity                 = "$($Node.NodeName)\mapi (Default Web Site)"
            Credential               = $ShellCreds
            ExternalUrl              = "https://$($casSettings.ExternalNLBFqdn)/mapi"
            IISAuthenticationMethods = 'NTLM','Negotiate'
            InternalUrl              = "https://$($casSettings.InternalNLBFqdn)/mapi" 
            AllowServiceRestart      = $true
        }

		#Configure URL's and add any OABs this vdir should distribute
        xExchOabVirtualDirectory OABVdir
        {
            Identity            = "$($Node.NodeName)\OAB (Default Web Site)"
            Credential          = $ShellCreds
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/oab"
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/oab"     
            OABsToDistribute    = $casSettings.OABsToDistribute
            AllowServiceRestart = $true
        }

		#Configure URL's and auth settings
        xExchOutlookAnywhere OAVdir
        {
            Identity                           = "$($Node.NodeName)\Rpc (Default Web Site)"
            Credential                         = $ShellCreds
            ExternalClientAuthenticationMethod = 'Ntlm'
            ExternalClientsRequireSSL          = $true
            ExternalHostName                   = $casSettings.ExternalNLBFqdn
            IISAuthenticationMethods           = 'Ntlm'
            InternalClientAuthenticationMethod = 'Ntlm'
            InternalClientsRequireSSL          = $true
            InternalHostName                   = $casSettings.InternalNLBFqdn
            AllowServiceRestart                = $true
        }

        #Ensures forms based auth and configures URLs and IM integration
        xExchOwaVirtualDirectory OWAVdir
        {
            Identity                              = "$($Node.NodeName)\owa (Default Web Site)"
            Credential                            = $ShellCreds
            BasicAuthentication                   = $true
            ExternalAuthenticationMethods         = 'Fba'
            ExternalUrl                           = "https://$($casSettings.ExternalNLBFqdn)/owa"
            FormsAuthentication                   = $true
            InternalUrl                           = "https://$($casSettings.InternalNLBFqdn)/owa"    
            WindowsAuthentication                 = $false
            AllowServiceRestart                   = $true
        }

		#Turn on Windows Integrated auth for remote powershell connections
        xExchPowerShellVirtualDirectory PSVdir
        {
            Identity              = "$($Node.NodeName)\PowerShell (Default Web Site)"
            Credential            = $ShellCreds
            WindowsAuthentication = $true
            AllowServiceRestart   = $true
        }

		#Configure URL's
        xExchWebServicesVirtualDirectory EWSVdir
        {
            Identity            = "$($Node.NodeName)\EWS (Default Web Site)"
            Credential          = $ShellCreds
            ExternalUrl         = "https://$($casSettings.ExternalNLBFqdn)/ews/exchange.asmx" 
            InternalUrl         = "https://$($casSettings.InternalNLBFqdn)/ews/exchange.asmx"
            AllowServiceRestart = $true         
        }
    }
}

if ($ShellCreds -eq $null)
{
    $ShellCreds = Get-Credential -Message 'Enter credentials for establishing Remote Powershell sessions to Exchange'
}

###Compiles the example
ConfigureVirtualDirectories -ConfigurationData $PSScriptRoot\ConfigureVirtualDirectories-Config.psd1 -ShellCreds $ShellCreds

###Sets up LCM on target computers to decrypt credentials.
Set-DscLocalConfigurationManager -Path .\ConfigureVirtualDirectories -Verbose

###Pushes configuration and waits for execution
Start-DscConfiguration -Path .\ConfigureVirtualDirectories -Verbose -Wait 