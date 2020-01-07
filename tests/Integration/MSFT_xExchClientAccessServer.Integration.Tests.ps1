<#
    .SYNOPSIS
        Automated unit integration for MSFT_xExchClientAccessServer DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String] $script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String] $script:DSCModuleName = 'xExchange'
[System.String] $script:DSCResourceFriendlyName = 'xExchClientAccessServer'
[System.String] $script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper\xExchangeHelper.psd1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'source' -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1"))))

# Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean] $exchangeInstalled = Test-ExchangeSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    # Get required credentials to use for the test
    $shellCredentials = Get-TestCredential

    # Get the Server FQDN for using in URL's
    if ($null -eq $serverFqdn)
    {
        $serverFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    # Make sure all AlternateServiceAccount's are cleared before beginning tests
    Set-TargetResource -Identity $env:COMPUTERNAME -Credential $shellCredentials -RemoveAlternateServiceAccountCredentials $true
    $getResults = Get-TargetResource -Identity $env:COMPUTERNAME -Credential $shellCredentials

    Describe 'Test Setting Properties with xExchClientAccessServer' {
        # Confirm that the AlternateServiceAccount was actually cleared before doing any tests
        It 'AlternateServiceAccount has been cleared' {
            ($null -ne $getResults -and $null -eq $getResults.AlternateServiceAccountCredential) | Should -Be $true
        }

        # Do standard URL and scope tests
        $testParams = @{
            Identity =  $env:COMPUTERNAME
            Credential = $shellCredentials
            AutoDiscoverServiceInternalUri = "https://$($serverFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope = 'Site1'
        }

        $expectedGetResults = @{
            Identity =  $env:COMPUTERNAME
            AutoDiscoverServiceInternalUri = "https://$($serverFqdn)/autodiscover/autodiscover.xml"
            AutoDiscoverSiteScope = 'Site1'
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set autod url and site scope' `
                                         -ExpectedGetResults $expectedGetResults

        # Now set the URL to empty
        $testParams.AutoDiscoverServiceInternalUri = ''
        $expectedGetResults.AutoDiscoverServiceInternalUri = ''

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set url to empty' `
                                         -ExpectedGetResults $expectedGetResults

        # Now try multiple sites in the site scope
        $testParams.AutoDiscoverSiteScope = 'Site1', 'Site2'
        $expectedGetResults = @{}

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set site scope to multi value'`
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.AutoDiscoverSiteScope `
                                -GetResultParameterName 'AutoDiscoverSiteScope' `
                                -ContextLabel 'Verify AutoDiscoverSiteScope' `
                                -ItLabel 'AutoDiscoverSiteScope should contain two values'

        # Now set the site scope to $null
        $testParams.AutoDiscoverSiteScope = $null
        $expectedGetResults = @{
            AutoDiscoverSiteScope = [String[]] @()
        }

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set site scope to null' `
                                         -ExpectedGetResults $expectedGetResults

        Test-ArrayContentsEqual -TestParams $testParams `
                                -DesiredArrayContents $testParams.AutoDiscoverSiteScope `
                                -GetResultParameterName 'AutoDiscoverSiteScope' `
                                -ContextLabel 'Verify AutoDiscoverSiteScope' `
                                -ItLabel 'AutoDiscoverSiteScope should be empty'

        # Create AlternateServiceAccount credentials
        if ($null -eq $asaCredentials)
        {
            $UserASA = 'Fabrikam\ASA'
            $PWordASA = New-Object -TypeName System.Security.SecureString
            $asaCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList $UserASA, $PWordASA
        }

        # Now set AlternateServiceAccount account
        $testParams.Add('AlternateServiceAccountCredential',$asaCredentials)
        $expectedGetResults.Add('AlternateServiceAccountCredential',$asaCredentials)

        # Alter Autodiscover settings and make sure they're picked up along with AlternateServiceAccount change
        $testParams.AutoDiscoverSiteScope = 'Site3'
        $expectedGetResults.AutoDiscoverSiteScope = 'Site3'

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Set AlternateServiceAccountCredential' `
                                         -ExpectedGetResults $expectedGetResults

        # Test for invalid AlternateServiceAccount account format
        Context 'Test looking for invalid format of AlternateServiceAccount account' {
            $UserASA = 'Fabrikam/ASA'
            $PWordASA = New-Object -TypeName System.Security.SecureString
            $asaCredentials = New-Object -TypeName System.Management.Automation.PSCredential `
                                                -ArgumentList $UserASA, $PWordASA

            # Set the invalid credentials
            $testParams['AlternateServiceAccountCredential'] = $asaCredentials

            It 'Should hit exception for invalid AlternateServiceAccount account format' {
                { Set-TargetResource @testParams } | Should -Throw
            }

            It 'Test results should be false after adding invalid AlternateServiceAccount account' {
                $testResults = Test-TargetResource @testParams
                $testResults | Should -Be $false
            }
        }

        # Now clear AlternateServiceAccount account credentials
        $testParams.Remove('AlternateServiceAccountCredential')
        $testParams.Add('RemoveAlternateServiceAccountCredentials',$true)
        $expectedGetResults.Remove('AlternateServiceAccountCredential')

        # Alter Autodiscover settings and make sure they're picked up along with AlternateServiceAccount change
        $testParams.AutoDiscoverSiteScope = 'Site4'
        $expectedGetResults.AutoDiscoverSiteScope = 'Site4'

        Test-TargetResourceFunctionality -Params $testParams `
                                         -ContextLabel 'Clear AlternateServiceAccountCredential' `
                                         -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
