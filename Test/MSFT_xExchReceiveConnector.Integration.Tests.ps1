###NOTE: This test module requires use of credentials. The first run through of the tests will prompt for credentials from the logged on user.

Import-Module $PSScriptRoot\..\DSCResources\MSFT_xExchReceiveConnector\MSFT_xExchReceiveConnector.psm1
Import-Module $PSScriptRoot\..\Misc\xExchangeCommon.psm1 -Verbose:0
Import-Module $PSScriptRoot\xExchange.Tests.Common.psm1 -Verbose:0

#Check if Exchange is installed on this machine. If not, we can't run tests
[bool]$exchangeInstalled = IsSetupComplete

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message "Enter credentials for connecting a Remote PowerShell session to Exchange"
    }

    Describe "Set and modify a Receive Connector" {
    #Set configuration with default values
    $testParams = @{
         Identity                                = "$($env:computername)\AnonymousRelay $($env:computername)"
         Credential                              = $Global:ShellCredentials
         Ensure                                  = 'Present'
         ExtendedRightAllowEntries               = $(New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration -Property @{Key = 'NT AUTHORITY\ANONYMOUS LOGON'; `
                                                    Value = 'Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-Bypass-Anti-Spam'} -ClientOnly)
         AdvertiseClientSettings                 = $false
         AuthMechanism                           = 'Tls', 'ExternalAuthoritative'
         Banner                                  = '220 Pester'
         BareLinefeedRejectionEnabled            = $false
         BinaryMimeEnabled                       = $true
         Bindings                                = "192.168.0.100:25"
         ChunkingEnabled                         = $true
         Comment                                 = 'Connector for relaying'
         ConnectionInactivityTimeout             = '00:05:00'
         ConnectionTimeout                       = '00:10:00'
         DefaultDomain                           = ''
         #DomainController                        = ''
         DeliveryStatusNotificationEnabled       = $true
         DomainSecureEnabled                     = $false
         EightBitMimeEnabled                     = $true
         EnableAuthGSSAPI                        = $false
         Enabled                                 = $true
         EnhancedStatusCodesEnabled              = $true
         ExtendedProtectionPolicy                = 'none'
         Fqdn                                    = "$($env:computername).pester.com"
         LongAddressesEnabled                    = $false
         MaxAcknowledgementDelay                 = '00:00:00'
         MaxHeaderSize                           = '128KB'
         MaxHopCount                             = '60'
         MaxInboundConnection                    = '5000'
         MaxInboundConnectionPercentagePerSource = '100'
         MaxInboundConnectionPerSource           = '50'
         MaxLocalHopCount                        = '12'
         MaxLogonFailures                        = '3'
         MaxMessageSize                          = '35MB'
         MaxProtocolErrors                       = '5'
         MaxRecipientsPerMessage                 = '5000'
         MessageRateLimit                        = 'Unlimited'
         MessageRateSource                       = 'IPAddress'
         OrarEnabled                             = $false
         PermissionGroups                        = 'AnonymousUsers','ExchangeServers'
         PipeliningEnabled                       = $true
         ProtocolLoggingLevel                    = 'Verbose'
         RemoteIPRanges                          = '192.16.7.99'
         RequireEHLODomain                       = $false
         RequireTLS                              = $false
         ServiceDiscoveryFqdn                    = ''
         SizeEnabled                             = 'EnabledwithoutValue'
         SuppressXAnonymousTls                   = $false
         TarpitInterval                          = '00:00:00'
         TlsCertificateName                      = $null
         TlsDomainCapabilities                   = 'contoso.com:AcceptOorgProtocol'
         TransportRole                           = 'FrontendTransport'
         Usage                                   = 'Custom'
    }

    $expectedGetResults = @{
         ExtendedRightAllowEntries               = "NT AUTHORITY\ANONYMOUS LOGON=Ms-Exch-SMTP-Accept-Any-Recipient,ms-Exch-Bypass-Anti-Spam"
         AdvertiseClientSettings                 = $false
         AuthMechanism                           = 'Tls', 'ExternalAuthoritative'
         Banner                                  = '220 Pester'
         BareLinefeedRejectionEnabled            = $false
         BinaryMimeEnabled                       = $true
         Bindings                                = "192.168.0.100:25"
         ChunkingEnabled                         = $true
         Comment                                 = 'Connector for relaying'
         ConnectionInactivityTimeout             = '00:05:00'
         ConnectionTimeout                       = '00:10:00'
         DefaultDomain                           = $null
         #DomainController                        = ''
         DeliveryStatusNotificationEnabled       = $true
         DomainSecureEnabled                     = $false
         EightBitMimeEnabled                     = $true
         EnableAuthGSSAPI                        = $false
         Enabled                                 = $true
         EnhancedStatusCodesEnabled              = $true
         ExtendedProtectionPolicy                = 'none'
         Fqdn                                    = "$($env:computername).pester.com"
         LongAddressesEnabled                    = $false
         MaxAcknowledgementDelay                 = '00:00:00'
         MaxHeaderSize                           = '128KB'
         MaxHopCount                             = '60'
         MaxInboundConnection                    = '5000'
         MaxInboundConnectionPercentagePerSource = '100'
         MaxInboundConnectionPerSource           = '50'
         MaxLocalHopCount                        = '12'
         MaxLogonFailures                        = '3'
         MaxMessageSize                          = '35MB'
         MaxProtocolErrors                       = '5'
         MaxRecipientsPerMessage                 = '5000'
         MessageRateLimit                        = 'Unlimited'
         MessageRateSource                       = 'IPAddress'
         OrarEnabled                             = $false
         PermissionGroups                        = 'AnonymousUsers','ExchangeServers','Custom'
         PipeliningEnabled                       = $true
         ProtocolLoggingLevel                    = 'Verbose'
         RemoteIPRanges                          = '192.16.7.99'
         RequireEHLODomain                       = $false
         RequireTLS                              = $false
         ServiceDiscoveryFqdn                    = $null
         SizeEnabled                             = 'EnabledwithoutValue'
         SuppressXAnonymousTls                   = $false
         TarpitInterval                          = '00:00:00'
         TlsCertificateName                      = $null
         TlsDomainCapabilities                   = 'contoso.com:AcceptOorgProtocol'
         TransportRole                           = 'FrontendTransport'
    }

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Create Receive Connector" -ExpectedGetResults $expectedGetResults
     
     #modify configuration
     $testParams.ExtendedRightDenyEntries = $(New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration `
                                            -Property @{Key = 'Domain Users'; Value = 'ms-Exch-Bypass-Anti-Spam'} -ClientOnly)
     $expectedGetResults.ExtendedRightDenyEntries = "Domain Users=ms-Exch-Bypass-Anti-Spam"

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Modify Receive Connector" -ExpectedGetResults $expectedGetResults
     
     #modify configuration
     $testParams.Ensure = 'Absent'
     $expectedGetResults = $null

     Test-TargetResourceFunctionality -Params $testParams -ContextLabel "Remove Receive Connector" -ExpectedGetResults $expectedGetResults
     }
}
else
{
    Write-Verbose "Tests in this file require that Exchange is installed to be run."
}
