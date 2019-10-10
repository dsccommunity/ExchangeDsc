function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443'),

        [Parameter()]
        [System.String]
        $ActiveSyncServer,

        [Parameter()]
        [System.Boolean]
        $BadItemReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $BasicAuthEnabled,

        [Parameter()]
        [ValidateSet('Ignore', 'Accepted', 'Required')]
        [System.String]
        $ClientCertAuth,

        [Parameter()]
        [System.Boolean]
        $CompressionEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $InstallIsapiFilter,

        [Parameter()]
        [System.String[]]
        $InternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.String]
        $MobileClientCertificateAuthorityURL,

        [Parameter()]
        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [Parameter()]
        [System.String]
        $MobileClientCertTemplateName,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Allow', 'Block')]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [Parameter()]
        [System.Boolean]
        $SendWatsonReport,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthEnabled
    )

    Write-Verbose -Message 'Getting the Exchange ActiveSyncVirtualDirectory settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ActiveSyncVirtualDirectory' -Verbose:$VerbosePreference

    $easVdir = Get-ActiveSyncVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $easVdir)
    {
        $returnValue = @{
            Identity                                   = [System.String] $Identity
            ActiveSyncServer                           = [System.String] $easVdir.ActiveSyncServer
            BadItemReportingEnabled                    = [System.Boolean] $easVdir.BadItemReportingEnabled
            BasicAuthEnabled                           = [System.Boolean] $easVdir.BasicAuthEnabled
            ClientCertAuth                             = [System.String] $easVdir.ClientCertAuth
            CompressionEnabled                         = [System.Boolean] $easVdir.CompressionEnabled
            ExtendedProtectionFlags                    = [System.String[]] $easVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList                  = [System.String[]] $easVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking            = [System.String] ($easVdir.ExtendedProtectionTokenChecking)
            ExternalAuthenticationMethods              = [System.String[]] $easVdir.ExternalAuthenticationMethods
            ExternalUrl                                = [System.String] $easVdir.ExternalUrl.AbsoluteUri
            InstallIsapiFilter                         = [System.Boolean] (Test-ISAPIFilter)
            InternalAuthenticationMethods              = [System.String[]] $easVdir.InternalAuthenticationMethods
            InternalUrl                                = [System.String] $easVdir.InternalUrl.AbsoluteUri
            MobileClientCertificateAuthorityURL        = [System.String] $easVdir.MobileClientCertificateAuthorityURL
            MobileClientCertificateProvisioningEnabled = [System.Boolean] $easVdir.MobileClientCertificateProvisioningEnabled
            MobileClientCertTemplateName               = [System.String] $easVdir.MobileClientCertTemplateName
            Name                                       = [System.String] $easVdir.Name
            RemoteDocumentsActionForUnknownServers     = [System.String] $easVdir.RemoteDocumentsActionForUnknownServers
            RemoteDocumentsAllowedServers              = [System.String[]] $easVdir.RemoteDocumentsAllowedServers
            RemoteDocumentsBlockedServers              = [System.String[]] $easVdir.RemoteDocumentsBlockedServers
            RemoteDocumentsInternalDomainSuffixList    = [System.String[]] $easVdir.RemoteDocumentsInternalDomainSuffixList
            SendWatsonReport                           = [System.Boolean] $easVdir.SendWatsonReport
            WindowsAuthEnabled                         = [System.Boolean] $easVdir.WindowsAuthEnabled
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443'),

        [Parameter()]
        [System.String]
        $ActiveSyncServer,

        [Parameter()]
        [System.Boolean]
        $BadItemReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $BasicAuthEnabled,

        [Parameter()]
        [ValidateSet('Ignore', 'Accepted', 'Required')]
        [System.String]
        $ClientCertAuth,

        [Parameter()]
        [System.Boolean]
        $CompressionEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $InstallIsapiFilter,

        [Parameter()]
        [System.String[]]
        $InternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.String]
        $MobileClientCertificateAuthorityURL,

        [Parameter()]
        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [Parameter()]
        [System.String]
        $MobileClientCertTemplateName,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Allow', 'Block')]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [Parameter()]
        [System.Boolean]
        $SendWatsonReport,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthEnabled
    )

    Write-Verbose -Message 'Setting the Exchange ActiveSyncVirtualDirectory settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ActiveSyncVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    # Remove Credential and AllowServiceRestart because those parameters do not exist on Set-ActiveSyncVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart', 'AutoCertBasedAuth', 'AutoCertBasedAuthThumbprint', 'AutoCertBasedAuthHttpsBindings'

    # Verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw 'SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
    }

    # Configure everything but CBA
    Set-ActiveSyncVirtualDirectory @PSBoundParameters

    if ($AutoCertBasedAuth)
    {
        # Need to configure CBA
        Test-PreReqsForCertBasedAuth

        if (-not ([System.String]::IsNullOrEmpty($AutoCertBasedAuthThumbprint)))
        {
            Enable-CertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings
        }
        else
        {
            throw 'AutoCertBasedAuthThumbprint must be specified when AutoCertBasedAuth is set to true'
        }

        if ($AllowServiceRestart)
        {
            # Need to restart all of IIS for auth settings to stick
            Write-Verbose -Message 'Restarting IIS'

            iisreset /noforce /timeout:300
        }
        else
        {
            Write-Warning -Message 'The configuration will not take effect until IISReset /noforce is run.'
        }
    }

    # Only bounce the app pool if we didn't already restart IIS for CBA
    if (-not $AutoCertBasedAuth)
    {
        if ($AllowServiceRestart)
        {
            Write-Verbose -Message 'Recycling MSExchangeSyncAppPool'

            Restart-ExistingAppPool -Name MSExchangeSyncAppPool
        }
        else
        {
            Write-Warning -Message 'The configuration will not take effect until MSExchangeSyncAppPool is manually recycled.'
        }
    }

    # Install IsapiFilter manually as workaround as Exchange Cmdlet doesn't do it
    if ($InstallIsapiFilter)
    {
        if (-not (Test-ISAPIFilter))
        {
            Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
                -Location 'Default Web Site' `
                -Filter 'system.webServer/isapiFilters' `
                -Name '.' `
                -value @{
                    name = 'Exchange ActiveSync ISAPI Filter'
                    path = "$env:ExchangeInstallPath\FrontEnd\HttpProxy\bin\AirFilter.dll"
            }
        }
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443'),

        [Parameter()]
        [System.String]
        $ActiveSyncServer,

        [Parameter()]
        [System.Boolean]
        $BadItemReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $BasicAuthEnabled,

        [Parameter()]
        [ValidateSet('Ignore', 'Accepted', 'Required')]
        [System.String]
        $ClientCertAuth,

        [Parameter()]
        [System.Boolean]
        $CompressionEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $InstallIsapiFilter,

        [Parameter()]
        [System.String[]]
        $InternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.String]
        $MobileClientCertificateAuthorityURL,

        [Parameter()]
        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [Parameter()]
        [System.String]
        $MobileClientCertTemplateName,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Allow', 'Block')]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [Parameter()]
        [System.Boolean]
        $SendWatsonReport,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthEnabled
    )

    Write-Verbose -Message 'Testing the Exchange ActiveSyncVirtualDirectory settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ActiveSyncVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $easVdir = Get-ActiveSyncVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $easVdir)
    {
        Write-Error -Message 'Unable to retrieve ActiveSync Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (-not (Test-ExchangeSetting -Name 'ActiveSyncServer' -Type 'String' -ExpectedValue $ActiveSyncServer -ActualValue $easVdir.ActiveSyncServer -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'BadItemReportingEnabled' -Type 'Boolean' -ExpectedValue $BadItemReportingEnabled -ActualValue $easVdir.BadItemReportingEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'BasicAuthEnabled' -Type 'Boolean' -ExpectedValue $BasicAuthEnabled -ActualValue $easVdir.BasicAuthEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ClientCertAuth' -Type 'String' -ExpectedValue $ClientCertAuth -ActualValue $easVdir.ClientCertAuth -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'CompressionEnabled' -Type 'Boolean' -ExpectedValue $CompressionEnabled -ActualValue $easVdir.CompressionEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionFlags' -Type 'ExtendedProtection' -ExpectedValue $ExtendedProtectionFlags -ActualValue $easVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionSPNList' -Type 'Array' -ExpectedValue $ExtendedProtectionSPNList -ActualValue $easVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExtendedProtectionTokenChecking' -Type 'String' -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $easVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $easVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $easVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'InternalAuthenticationMethods' -Type 'Array' -ExpectedValue $InternalAuthenticationMethods -ActualValue $easVdir.InternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $easVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'MobileClientCertificateAuthorityURL' -Type 'String' -ExpectedValue $MobileClientCertificateAuthorityURL -ActualValue $easVdir.MobileClientCertificateAuthorityURL -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'MobileClientCertificateProvisioningEnabled' -Type 'Boolean' -ExpectedValue $MobileClientCertificateProvisioningEnabled -ActualValue $easVdir.MobileClientCertificateProvisioningEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'MobileClientCertTemplateName' -Type 'String' -ExpectedValue $MobileClientCertTemplateName -ActualValue $easVdir.MobileClientCertTemplateName -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'Name' -Type 'String' -ExpectedValue $Name -ActualValue $easVdir.Name -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'RemoteDocumentsActionForUnknownServers' -Type 'String' -ExpectedValue $RemoteDocumentsActionForUnknownServers -ActualValue $easVdir.RemoteDocumentsActionForUnknownServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'RemoteDocumentsAllowedServers' -Type 'Array' -ExpectedValue $RemoteDocumentsAllowedServers -ActualValue $easVdir.RemoteDocumentsAllowedServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'RemoteDocumentsBlockedServers' -Type 'Array' -ExpectedValue $RemoteDocumentsBlockedServers -ActualValue $easVdir.RemoteDocumentsBlockedServers -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'RemoteDocumentsInternalDomainSuffixList' -Type 'Array' -ExpectedValue $RemoteDocumentsInternalDomainSuffixList -ActualValue $easVdir.RemoteDocumentsInternalDomainSuffixList -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'SendWatsonReport' -Type 'Boolean' -ExpectedValue $SendWatsonReport -ActualValue $easVdir.SendWatsonReport -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (-not (Test-ExchangeSetting -Name 'WindowsAuthEnabled' -Type 'Boolean' -ExpectedValue $WindowsAuthEnabled -ActualValue $easVdir.WindowsAuthEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if ($AutoCertBasedAuth)
        {
            Test-PreReqsForCertBasedAuth

            if ([System.String]::IsNullOrEmpty($AutoCertBasedAuthThumbprint))
            {
                Write-InvalidSettingVerbose -SettingName 'AutoCertBasedAuthThumbprint' `
                    -ExpectedValue 'Not null or empty' `
                    -ActualValue '' `
                    -Verbose:$VerbosePreference
                $testResults = $false
            }
            elseif ($null -eq $AutoCertBasedAuthHttpsBindings -or $AutoCertBasedAuthHttpsBindings.Count -eq 0)
            {
                Write-InvalidSettingVerbose -SettingName 'AutoCertBasedAuthHttpsBindings' `
                    -ExpectedValue 'Not null or empty' `
                    -ActualValue '' `
                    -Verbose:$VerbosePreference
                $testResults = $false
            }
            elseif ((Test-CertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings) -eq $false)
            {
                Write-InvalidSettingVerbose -SettingName 'TestCertBasedAuth' `
                    -ExpectedValue $true `
                    -ActualValue $false `
                    -Verbose:$VerbosePreference
                $testResults = $false
            }
        }

        if ($InstallIsapiFilter)
        {
            if (-not (Test-ISAPIFilter))
            {
                Write-InvalidSettingVerbose -SettingName 'InstallIsapiFilter' -ExpectedValue $InstallIsapiFilter -ActualValue 'false' -Verbose:$VerbosePreference
                $testResults = $false
            }
        }
    }

    return $testResults
}

function Get-ActiveSyncVirtualDirectoryInternal
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443'),

        [Parameter()]
        [System.String]
        $ActiveSyncServer,

        [Parameter()]
        [System.Boolean]
        $BadItemReportingEnabled,

        [Parameter()]
        [System.Boolean]
        $BasicAuthEnabled,

        [Parameter()]
        [ValidateSet('Ignore', 'Accepted', 'Required')]
        [System.String]
        $ClientCertAuth,

        [Parameter()]
        [System.Boolean]
        $CompressionEnabled,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        [System.String[]]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [ValidateSet('None', 'Allow', 'Require')]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $InstallIsapiFilter,

        [Parameter()]
        [System.String[]]
        $InternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.String]
        $MobileClientCertificateAuthorityURL,

        [Parameter()]
        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [Parameter()]
        [System.String]
        $MobileClientCertTemplateName,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [ValidateSet('Allow', 'Block')]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [Parameter()]
        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [Parameter()]
        [System.Boolean]
        $SendWatsonReport,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthEnabled
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-ActiveSyncVirtualDirectory @PSBoundParameters)
}

function Enable-CertBasedAuth
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443')
    )

    $appCmdExe = "$($env:SystemRoot)\System32\inetsrv\appcmd.exe"

    # Enable cert auth in IIS, and require SSL on the AS vdir
    $output = &$appCmdExe set config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:'True' /commit:apphost
    Write-Verbose -Message "$output"

    $output = &$appCmdExe set config 'Default Web Site' -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:'True' /commit:apphost
    Write-Verbose -Message "$output"

    $output = &$appCmdExe set config 'Default Web Site/Microsoft-Server-ActiveSync' /section:access /sslFlags:'Ssl, SslNegotiateCert, SslRequireCert, Ssl128' /commit:apphost
    Write-Verbose -Message "$output"

    $output = &$appCmdExe set config 'Default Web Site/Microsoft-Server-ActiveSync' -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:'True' /commit:apphost
    Write-Verbose -Message "$output"

    # Set DSMapperUsage to enabled on all the required SSL bindings
    $appId = '{4dc3e181-e14b-4a21-b022-59fc669b0914}' # The appId of all IIS applications

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        Enable-DSMapperUsage -IpPortCombo $binding -CertThumbprint $AutoCertBasedAuthThumbprint -AppId $appId
    }
}

function Test-CertBasedAuth
{
    param
    (
        [Parameter()]
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [Parameter()]
        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @('0.0.0.0:443', '127.0.0.1:443')
    )

    $appCmdExe = "$($env:SystemRoot)\System32\inetsrv\appcmd.exe"

    $serverWideClientCertMappingAuth = &$appCmdExe list config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -AppCmdOutput $serverWideClientCertMappingAuth -SearchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $clientCertMappingAuth = &$appCmdExe list config 'Default Web Site' -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -AppCmdOutput $clientCertMappingAuth -SearchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $asClientCertMappingAuth = &$appCmdExe list config 'Default Web Site/Microsoft-Server-ActiveSync' -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -appCmdOutput $asClientCertMappingAuth -searchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $sslFlags = &$appCmdExe list config 'Default Web Site/Microsoft-Server-ActiveSync' /section:access

    if (-not (Test-AppCmdOutputContainsString -appCmdOutput $sslFlags -searchString "access sslFlags=`"Ssl, SslNegotiateCert, SslRequireCert, Ssl128`""))
    {
        return $false
    }

    $netshOutput = netsh.exe http show sslcert

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName 'DS Mapper Usage' -SettingValue 'Enabled'))
        {
            return $false
        }

        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName 'Certificate Hash' -SettingValue $AutoCertBasedAuthThumbprint))
        {
            return $false
        }

        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName 'Certificate Store Name' -SettingValue 'MY'))
        {
            return $false
        }
    }

    return $true
}

function Test-IsSslBinding
{
    param
    (
        [Parameter()]
        $NetshOutput
    )

    if ($null -ne $NetshOutput -and $NetshOutput.GetType().Name -eq 'Object[]')
    {
        for ($i = 0; $i -lt $NetshOutput.Count; $i++)
        {
            if ($NetshOutput[$i].Contains('IP:port'))
            {
                return $true
            }
        }
    }

    return $false
}

function Enable-DSMapperUsage
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $IpPortCombo,

        [Parameter(Mandatory = $true)]
        [System.String]
        $CertThumbprint,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AppId
    )
    # See if a binding already exists, and if so, delete it
    $bindingOutput = netsh.exe http show sslcert ipport=$($IpPortCombo)

    if (Test-IsSslBinding $bindingOutput)
    {
        $output = netsh.exe http delete sslcert ipport=$($IpPortCombo)
        Write-Verbose -Message "$output"
    }

    # Add the binding back with new settings
    $output = netsh.exe http add sslcert ipport=$($IpPortCombo) certhash=$($CertThumbprint) appid=$($AppId) dsmapperusage=enable certstorename=MY
    Write-Verbose -Message "$output"
}

function Test-AppCmdOutputContainsString
{
    param
    (
        [Parameter()]
        $AppCmdOutput,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SearchString
    )

    if ($null -ne $AppCmdOutput -and $AppCmdOutput.GetType().Name -eq 'Object[]')
    {
        foreach ($line in $AppCmdOutput)
        {
            if ($line.ToLower().Contains($SearchString.ToLower()))
            {
                return $true
            }
        }
    }

    return $false
}

function Test-NetshSslCertSetting
{
    param
    (
        [Parameter()]
        $NetshSslCertOutput,

        [Parameter(Mandatory = $true)]
        [System.String]
        $IpPort,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SettingValue
    )

    $SettingName = $SettingName.ToLower()
    $SettingValue = $SettingValue.ToLower()

    if ($null -ne $NetshSslCertOutput -and $NetshSslCertOutput.GetType().Name -eq 'Object[]')
    {
        $foundSetting = $false
        for ($i = 0; $i -lt $NetshSslCertOutput.Count -and -not $foundSetting; $i++)
        {
            if ($NetshSslCertOutput[$i].ToLower().Contains('ip:port') -and $NetshSslCertOutput[$i].Contains($IpPort))
            {
                $i++

                while ( -not $NetshSslCertOutput[$i].ToLower().Contains('ip:port') -and -not $foundSetting )
                {
                    if ($NetshSslCertOutput[$i].ToLower().Contains($SettingName))
                    {
                        $foundSetting = $true

                        if ($NetshSslCertOutput[$i].ToLower().Contains($SettingValue))
                        {
                            return $true
                        }
                    }

                    $i++
                }
            }
        }
    }

    return $false
}

# Ensures that required Certification Based Authentication prereqs are installed
function Test-PreReqsForCertBasedAuth
{
    $hasAllPreReqs = $true

    $webClientAuth = Get-WindowsFeature -Name Web-Client-Auth
    $webCertAuth = Get-WindowsFeature -Name Web-Cert-Auth

    if ($webClientAuth.InstallState -ne 'Installed')
    {
        $hasAllPreReqs = $false

        Write-Error -Message 'The Web-Client-Auth feature needs to be installed before the Auto Certification Based Authentication feature can be used'
    }

    if ($webCertAuth.InstallState -ne 'Installed')
    {
        $hasAllPreReqs = $false

        Write-Error -Message 'The Web-Cert-Auth feature needs to be installed before the Auto Certification Based Authentication feature can be used'
    }

    if ($hasAllPreReqs -eq $false)
    {
        throw 'Required Windows features need to be installed before the Auto Certification Based Authentication feature can be used'
    }
}

function Test-ISAPIFilter
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $WebSite = 'Default Web Site',

        [Parameter()]
        [System.String]
        $ISAPIFilterName = 'Exchange ActiveSync ISAPI Filter'
    )

    begin
    {
        $ReturnValue = $false

        $ISAPIFilters = Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' `
            -Location $WebSite `
            -Filter 'system.webServer/isapiFilters' `
            -Name '.'
    }
    process
    {
        if ($ISAPIFilters.Collection.Count -gt 0)
        {
            if ($ISAPIFilters.Collection.Name.Contains($ISAPIFilterName))
            {
                Write-Verbose -Message "Filter $($ISAPIFilterName) was found"
                $ReturnValue = $true
            }
        }
    }
    end
    {
        return $ReturnValue
    }
}

Export-ModuleMember -Function *-TargetResource
