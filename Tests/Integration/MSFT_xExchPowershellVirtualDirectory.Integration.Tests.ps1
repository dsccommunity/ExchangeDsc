<#
    .SYNOPSIS
        Automated integration test for MSFT_xExchPowershellVirtualDirectory DSC Resource.
        This test module requires use of credentials.
        The first run through of the tests will prompt for credentials from the logged on user.
#>

#region HEADER
[System.String]$script:moduleRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
[System.String]$script:DSCModuleName = 'xExchange'
[System.String]$script:DSCResourceFriendlyName = 'xExchPowershellVirtualDirectory'
[System.String]$script:DSCResourceName = "MSFT_$($script:DSCResourceFriendlyName)"

Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Tests' -ChildPath (Join-Path -Path 'TestHelpers' -ChildPath 'xExchangeTestHelper.psm1'))) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'Modules' -ChildPath 'xExchangeHelper.psm1')) -Force
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'DSCResources' -ChildPath (Join-Path -Path "$($script:DSCResourceName)" -ChildPath "$($script:DSCResourceName).psm1")))

#Check if Exchange is installed on this machine. If not, we can't run tests
[System.Boolean]$exchangeInstalled = Get-IsSetupComplete

#endregion HEADER

if ($exchangeInstalled)
{
    #Get required credentials to use for the test
    if ($null -eq $Global:ShellCredentials)
    {
        [PSCredential]$Global:ShellCredentials = Get-Credential -Message 'Enter credentials for connecting a Remote PowerShell session to Exchange'
    }

    #Get the Server FQDN for using in URL's
    if ($null -eq $Global:ServerFqdn)
    {
        $Global:ServerFqdn = [System.Net.Dns]::GetHostByName($env:COMPUTERNAME).HostName
    }

    Describe 'Test Setting Properties with xExchPowershellVirtualDirectory' {
        $testParams = @{
            Identity =  "$($env:COMPUTERNAME)\PowerShell (Default Web Site)"
            Credential = $Global:ShellCredentials
            BasicAuthentication = $false
            CertificateAuthentication = $true
            ExternalUrl = "http://$($Global:ServerFqdn)/powershell"
            InternalUrl = "http://$($Global:ServerFqdn)/powershell"
            RequireSSL = $false                       
            WindowsAuthentication = $false           
        }

        $expectedGetResults = @{
            Identity =  "$($env:COMPUTERNAME)\PowerShell (Default Web Site)"
            BasicAuthentication = $false
            CertificateAuthentication = $true
            ExternalUrl = "http://$($Global:ServerFqdn)/powershell"
            InternalUrl = "http://$($Global:ServerFqdn)/powershell"
            RequireSSL = $false                       
            WindowsAuthentication = $false  
        }

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Set standard parameters' -ExpectedGetResults $expectedGetResults


        $testParams.ExternalUrl = ''
        $testParams.InternalUrl = ''
        $expectedGetResults.ExternalUrl = ''
        $expectedGetResults.InternalUrl = ''

        Test-TargetResourceFunctionality -Params $testParams -ContextLabel 'Try with empty URLs' -ExpectedGetResults $expectedGetResults
    }
}
else
{
    Write-Verbose -Message 'Tests in this file require that Exchange is installed to be run.'
}
    
