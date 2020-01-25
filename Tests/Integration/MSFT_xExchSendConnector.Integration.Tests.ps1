<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchSendConnector DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchSendConnector'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    Describe 'Set and modify a Send Connector' {
        # Set configuration with default values

        $extendedRightAllowEntries = (
            New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration  -ClientOnly -Property @{
                Key   = 'NT AUTHORITY\ANONYMOUS LOGON'
                Value = 'Ms-Exch-SMTP-Accept-Any-Sender,ms-Exch-Bypass-Anti-Spam'
            }
        )
        $getParams = @{
            Name          = "DCSTestSendConnector"
            Credential    = $shellCredentials
            AddressSpaces = 'SMTP:test.com;1'
        }
        $testParamsNoDC = @{
            Name                         = "DCSTestSendConnector"
            Credential                   = $shellCredentials
            Ensure                       = 'Present'
            AddressSpaces                = 'SMTP:test.com;1'
            ExtendedRightAllowEntries    = $extendedRightAllowEntries
            Comment                      = 'Connector for integration testing'
            ConnectionInactivityTimeout  = '00:05:00'
            ConnectorType                = 'Default'
            DomainController             = ''
            DNSRoutingEnabled            = $true
            DomainSecureEnabled          = $true
            Enabled                      = $true
            ErrorPolicies                = 'Default'
            ForceHELO                    = $true
            FrontendProxyEnabled         = $false
            Fqdn                         = 'smtp.local.test'
            IgnoreSTARTTLS               = $false
            IsScopedConnector            = $false
            Port                         = $false
            ProtocolLoggingLevel         = 'Verbose'
            RequireTLS                   = $true
            SmtpMaxMessagesPerConnection = 20
            SourceTransportServers       = $env:computername
            UseExternalDNSServersEnabled = $false
            Usage                        = 'Custom'
        }

        $expectedGetResults = @{
            Name                         = "DCSTestSendConnector"
            Ensure                       = 'Present'
            ExtendedRightAllowEntries    = $extendedRightAllowEntries
            AddressSpaces                = 'SMTP:test.com;1'
            Comment                      = 'Connector for integration testing'
            ConnectionInactivityTimeout  = '00:05:00'
            ConnectorType                = 'Default'
            DNSRoutingEnabled            = $true
            DomainSecureEnabled          = $true
            Enabled                      = $true
            ErrorPolicies                = 'Default'
            ForceHELO                    = $true
            FrontendProxyEnabled         = $false
            Fqdn                         = 'smtp.local.test'
            IgnoreSTARTTLS               = $false
            IsCoexistenceConnector       = $false
            IsScopedConnector            = $false
            Port                         = $false
            ProtocolLoggingLevel         = 'Verbose'
            RequireTLS                   = $true
            SmtpMaxMessagesPerConnection = 20
            SourceTransportServers       = $env:computername
            UseExternalDNSServersEnabled = $false
        }

        Test-TargetResourceFunctionality -GetParams $getParams -Params $testParams -ContextLabel 'Create Send Connector' -ExpectedGetResults $expectedGetResults

        # Modify configuration
        $extendedRightDenyEntries = $(New-CimInstance -ClassName MSFT_KeyValuePair -Namespace root/microsoft/Windows/DesiredStateConfiguration `
                -Property @{Key = "$($env:USERDOMAIN)\Domain Users"; Value = 'ms-Exch-Bypass-Anti-Spam' } -ClientOnly)

        $testParams.ExtendedRightDenyEntries = $extendedRightDenyEntries
        $expectedGetResults.ExtendedRightDenyEntries = $extendedRightDenyEntries

        Test-TargetResourceFunctionality -GetParams $getParams -Params $testParams -ContextLabel 'Modify Send Connector' -ExpectedGetResults $expectedGetResults

        # Modify configuration
        $testParams.Ensure = 'Absent'
        $expectedGetResults = @{
            Ensure = 'Absent'
        }

        Test-TargetResourceFunctionality -GetParams $getParams -Params $testParams -ContextLabel 'Remove Send Connector' -ExpectedGetResults $expectedGetResults

        # Try to remove the same Send connector again. This should not cause any errors.
        $testStartTime = [DateTime]::Now

        Test-TargetResourceFunctionality -GetParams $getParams -Params $testParams -ContextLabel 'Attempt Removal of Already Removed Send Connector' -ExpectedGetResults $expectedGetResults

        Context 'When Get-SendConnector is called and the connector is absent' {
            It 'Should not cause an error to be logged in the event log' {
                Get-EventLog -LogName 'MSExchange Management' -After $testStartTime -ErrorAction SilentlyContinue | `
                    Where-Object -FilterScript { $_.Message -like '*Cmdlet failed. Cmdlet Get-SendConnector, parameters -Identity*' } |`
                    Should -Be $null
            }
        }
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
