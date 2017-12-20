[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443"),

        [System.String]
        $ActiveSyncServer,

        [System.Boolean]
        $BadItemReportingEnabled,

        [System.Boolean]
        $BasicAuthEnabled,

        [ValidateSet("Ignore", "Accepted", "Required")]
        [System.String]
        $ClientCertAuth,

        [System.Boolean]
        $CompressionEnabled,

        [System.String]
        $DomainController,

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $InstallIsapiFilter,

        [System.String[]]
        $InternalAuthenticationMethods,

        [System.String]
        $InternalUrl,

        [System.String]
        $MobileClientCertificateAuthorityURL,

        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [System.String]
        $MobileClientCertTemplateName,

        [System.String]
        $Name,

        [ValidateSet("Allow","Block")]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [System.Boolean]
        $SendWatsonReport,   

        [System.Boolean]
        $WindowsAuthEnabled
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ActiveSyncVirtualDirectory' -VerbosePreference $VerbosePreference

    $easVdir = Get-ActiveSyncVirtualDirectoryInternal @PSBoundParameters
    
    if ($null -ne $easVdir)
    {
        $returnValue = @{
            Identity = $Identity
            ActiveSyncServer = $easVdir.ActiveSyncServer
            BadItemReportingEnabled = $easVdir.BadItemReportingEnabled
            BasicAuthEnabled = $easVdir.BasicAuthEnabled
            ClientCertAuth = $easVdir.ClientCertAuth
            CompressionEnabled = $easVdir.CompressionEnabled
            ExtendedProtectionFlags = [System.Array]$(ConvertTo-Array -InputObject $easVdir.ExtendedProtectionFlags)
            ExtendedProtectionSPNList = [System.Array]$(ConvertTo-Array -InputObject $easVdir.ExtendedProtectionSPNList)
            ExtendedProtectionTokenChecking = $easVdir.ExtendedProtectionTokenChecking
            ExternalAuthenticationMethods = [System.Array]$(ConvertTo-Array -InputObject $easVdir.ExternalAuthenticationMethods)
            ExternalUrl = $easVdir.ExternalUrl.AbsoluteUri
            InstallIsapiFilter = $(Test-ISAPIFilter)
            InternalAuthenticationMethods = [System.Array]$(ConvertTo-Array -InputObject $easVdir.InternalAuthenticationMethods)
            InternalUrl = $easVdir.InternalUrl.AbsoluteUri
            MobileClientCertificateAuthorityURL = $easVdir.MobileClientCertificateAuthorityURL
            MobileClientCertificateProvisioningEnabled = $easVdir.MobileClientCertificateProvisioningEnabled
            MobileClientCertTemplateName = $easVdir.MobileClientCertTemplateName
            Name = $easVdir.Name
            RemoteDocumentsActionForUnknownServers = $easVdir.RemoteDocumentsActionForUnknownServers
            RemoteDocumentsAllowedServers = [System.Array]$(ConvertTo-Array -InputObject $easVdir.RemoteDocumentsAllowedServers)
            RemoteDocumentsBlockedServers = [System.Array]$(ConvertTo-Array -InputObject $easVdir.RemoteDocumentsBlockedServers)
            RemoteDocumentsInternalDomainSuffixList = [System.Array]$(ConvertTo-Array -InputObject $easVdir.RemoteDocumentsInternalDomainSuffixList)
            SendWatsonReport = $easVdir.SendWatsonReport
            WindowsAuthEnabled = $easVdir.WindowsAuthEnabled
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443"),

        [System.String]
        $ActiveSyncServer,

        [System.Boolean]
        $BadItemReportingEnabled,

        [System.Boolean]
        $BasicAuthEnabled,

        [ValidateSet("Ignore", "Accepted", "Required")]
        [System.String]
        $ClientCertAuth,

        [System.Boolean]
        $CompressionEnabled,

        [System.String]
        $DomainController,

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $InstallIsapiFilter,

        [System.String[]]
        $InternalAuthenticationMethods,

        [System.String]
        $InternalUrl,

        [System.String]
        $MobileClientCertificateAuthorityURL,

        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [System.String]
        $MobileClientCertTemplateName,

        [System.String]
        $Name,

        [ValidateSet("Allow","Block")]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [System.Boolean]
        $SendWatsonReport,   

        [System.Boolean]
        $WindowsAuthEnabled
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ActiveSyncVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    
    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-ActiveSyncVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart','AutoCertBasedAuth','AutoCertBasedAuthThumbprint','AutoCertBasedAuthHttpsBindings'

    #verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw "SPN list contains DotlesSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!"
    }

    #Configure everything but CBA
    Set-ActiveSyncVirtualDirectory @PSBoundParameters
    
    if ($AutoCertBasedAuth) #Need to configure CBA
    {
        Test-PreReqsForCertBasedAuth

        if (-not ([string]::IsNullOrEmpty($AutoCertBasedAuthThumbprint)))
        {
            Enable-CertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings
        }
        else
        {
            throw "AutoCertBasedAuthThumbprint must be specified when AutoCertBasedAuth is set to `$true"
        }

        if($AllowServiceRestart) #Need to restart all of IIS for auth settings to stick
        {
            Write-Verbose "Restarting IIS"

            iisreset /noforce /timeout:300
        }
        else
        {
            Write-Warning "The configuration will not take effect until 'IISReset /noforce' is run."
        }
    }

    #Only bounce the app pool if we didn't already restart IIS for CBA
    if (-not $AutoCertBasedAuth)
    {
        if($AllowServiceRestart) 
        {
            Write-Verbose "Recycling MSExchangeSyncAppPool"

            RestartAppPoolIfExists -Name MSExchangeSyncAppPool
        }
        else
        {
            Write-Warning "The configuration will not take effect until MSExchangeSyncAppPool is manually recycled."
        }
    }

    #install IsapiFilter manually as workaround as Exchange Cmdlet doesn't do it
    if ($InstallIsapiFilter)
    {
        if (-not (Test-ISAPIFilter))
        {
            Add-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Location 'Default Web Site' -Filter "system.webServer/isapiFilters" -Name "." -value @{name='Exchange ActiveSync ISAPI Filter';path="$env:ExchangeInstallPath\FrontEnd\HttpProxy\bin\AirFilter.dll"}
        }
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443"),

        [System.String]
        $ActiveSyncServer,

        [System.Boolean]
        $BadItemReportingEnabled,

        [System.Boolean]
        $BasicAuthEnabled,

        [ValidateSet("Ignore", "Accepted", "Required")]
        [System.String]
        $ClientCertAuth,

        [System.Boolean]
        $CompressionEnabled,

        [System.String]
        $DomainController,

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $InstallIsapiFilter,

        [System.String[]]
        $InternalAuthenticationMethods,

        [System.String]
        $InternalUrl,

        [System.String]
        $MobileClientCertificateAuthorityURL,

        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [System.String]
        $MobileClientCertTemplateName,

        [System.String]
        $Name,

        [ValidateSet("Allow","Block")]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [System.Boolean]
        $SendWatsonReport,   

        [System.Boolean]
        $WindowsAuthEnabled
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ActiveSyncVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $easVdir = Get-ActiveSyncVirtualDirectoryInternal @PSBoundParameters

    if ($null -eq $easVdir)
    {
        return $false
    }
    else
    {
        if (-not (VerifySetting -Name "ActiveSyncServer" -Type "String" -ExpectedValue $ActiveSyncServer -ActualValue $easVdir.ActiveSyncServer -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "BadItemReportingEnabled" -Type "Boolean" -ExpectedValue $BadItemReportingEnabled -ActualValue $easVdir.BadItemReportingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "BasicAuthEnabled" -Type "Boolean" -ExpectedValue $BasicAuthEnabled -ActualValue $easVdir.BasicAuthEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ClientCertAuth" -Type "String" -ExpectedValue $ClientCertAuth -ActualValue $easVdir.ClientCertAuth -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "CompressionEnabled" -Type "Boolean" -ExpectedValue $CompressionEnabled -ActualValue $easVdir.CompressionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionFlags" -Type "ExtendedProtection" -ExpectedValue $ExtendedProtectionFlags -ActualValue $easVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionSPNList" -Type "Array" -ExpectedValue $ExtendedProtectionSPNList -ActualValue $easVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExtendedProtectionTokenChecking" -Type "String" -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $easVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExternalAuthenticationMethods" -Type "Array" -ExpectedValue $ExternalAuthenticationMethods -ActualValue $easVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $easVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "InternalAuthenticationMethods" -Type "Array" -ExpectedValue $InternalAuthenticationMethods -ActualValue $easVdir.InternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $easVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "MobileClientCertificateAuthorityURL" -Type "String" -ExpectedValue $MobileClientCertificateAuthorityURL -ActualValue $easVdir.MobileClientCertificateAuthorityURL -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "MobileClientCertificateProvisioningEnabled" -Type "Boolean" -ExpectedValue $MobileClientCertificateProvisioningEnabled -ActualValue $easVdir.MobileClientCertificateProvisioningEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "MobileClientCertTemplateName" -Type "String" -ExpectedValue $MobileClientCertTemplateName -ActualValue $easVdir.MobileClientCertTemplateName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "Name" -Type "String" -ExpectedValue $Name -ActualValue $easVdir.Name -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "RemoteDocumentsActionForUnknownServers" -Type "String" -ExpectedValue $RemoteDocumentsActionForUnknownServers -ActualValue $easVdir.RemoteDocumentsActionForUnknownServers -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "RemoteDocumentsAllowedServers" -Type "Array" -ExpectedValue $RemoteDocumentsAllowedServers -ActualValue $easVdir.RemoteDocumentsAllowedServers -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "RemoteDocumentsBlockedServers" -Type "Array" -ExpectedValue $RemoteDocumentsBlockedServers -ActualValue $easVdir.RemoteDocumentsBlockedServers -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "RemoteDocumentsInternalDomainSuffixList" -Type "Array" -ExpectedValue $RemoteDocumentsInternalDomainSuffixList -ActualValue $easVdir.RemoteDocumentsInternalDomainSuffixList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "SendWatsonReport" -Type "Boolean" -ExpectedValue $SendWatsonReport -ActualValue $easVdir.SendWatsonReport -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (-not (VerifySetting -Name "WindowsAuthEnabled" -Type "Boolean" -ExpectedValue $WindowsAuthEnabled -ActualValue $easVdir.WindowsAuthEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if ($AutoCertBasedAuth)
        {
            Test-PreReqsForCertBasedAuth

            if ([string]::IsNullOrEmpty($AutoCertBasedAuthThumbprint))
            {
                ReportBadSetting -SettingName "AutoCertBasedAuthThumbprint" -ExpectedValue "Not null or empty" -ActualValue "" -VerbosePreference $VerbosePreference
                return $false
            }
            elseif ($null -eq $AutoCertBasedAuthHttpsBindings -or $AutoCertBasedAuthHttpsBindings.Count -eq 0)
            {
                ReportBadSetting -SettingName "AutoCertBasedAuthHttpsBindings" -ExpectedValue "Not null or empty" -ActualValue "" -VerbosePreference $VerbosePreference
                return $false
            }
            elseif ((Test-CertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings) -eq $false)
            {
                ReportBadSetting -SettingName "TestCertBasedAuth" -ExpectedValue $true -ActualValue $false -VerbosePreference $VerbosePreference
                return $false
            }
        }

        if ($InstallIsapiFilter)
        {
            if (-not (Test-ISAPIFilter)){
                ReportBadSetting -SettingName "InstallIsapiFilter" -ExpectedValue $InstallIsapiFilter -ActualValue "false" -VerbosePreference $VerbosePreference
                return $false
            }
        }
    }

    #If the code got to this point, all conditions are true   
    return $true
}

function Get-ActiveSyncVirtualDirectoryInternal
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AutoCertBasedAuth = $false,

        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443"),

        [System.String]
        $ActiveSyncServer,

        [System.Boolean]
        $BadItemReportingEnabled,

        [System.Boolean]
        $BasicAuthEnabled,

        [ValidateSet("Ignore", "Accepted", "Required")]
        [System.String]
        $ClientCertAuth,

        [System.Boolean]
        $CompressionEnabled,

        [System.String]
        $DomainController,

        [ValidateSet("None","Proxy","NoServiceNameCheck","AllowDotlessSpn","ProxyCohosting")]
        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $InstallIsapiFilter,

        [System.String[]]
        $InternalAuthenticationMethods,

        [System.String]
        $InternalUrl,

        [System.String]
        $MobileClientCertificateAuthorityURL,

        [System.Boolean]
        $MobileClientCertificateProvisioningEnabled,

        [System.String]
        $MobileClientCertTemplateName,

        [System.String]
        $Name,

        [ValidateSet("Allow","Block")]
        [System.String]
        $RemoteDocumentsActionForUnknownServers,

        [System.String[]]
        $RemoteDocumentsAllowedServers,

        [System.String[]]
        $RemoteDocumentsBlockedServers,

        [System.String[]]
        $RemoteDocumentsInternalDomainSuffixList,

        [System.Boolean]
        $SendWatsonReport,   

        [System.Boolean]
        $WindowsAuthEnabled
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-ActiveSyncVirtualDirectory @PSBoundParameters)
}

function Enable-CertBasedAuth
{
    param
    (
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443")
    )
    
    $appCmdExe = "$($env:SystemRoot)\System32\inetsrv\appcmd.exe"

    #Enable cert auth in IIS, and require SSL on the AS vdir
    $output = &$appCmdExe set config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:"True" /commit:apphost
    Write-Verbose "$output"
    
    $output = &$appCmdExe set config "Default Web Site" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:"True" /commit:apphost
    Write-Verbose "$output"
    
    $output = &$appCmdExe set config "Default Web Site/Microsoft-Server-ActiveSync" /section:access /sslFlags:"Ssl, SslNegotiateCert, SslRequireCert, Ssl128" /commit:apphost
    Write-Verbose "$output"
    
    $output = &$appCmdExe set config "Default Web Site/Microsoft-Server-ActiveSync" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:"True" /commit:apphost
    Write-Verbose "$output"

    #Set DSMapperUsage to enabled on all the required SSL bindings
    $appId = "{4dc3e181-e14b-4a21-b022-59fc669b0914}" #The appId of all IIS applications

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        Enable-DSMapperUsage -IpPortCombo $binding -CertThumbprint $AutoCertBasedAuthThumbprint -AppId $appId
    }
}

function Test-CertBasedAuth
{
    param
    (
        [System.String]
        $AutoCertBasedAuthThumbprint,

        [System.String[]]
        $AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443", "127.0.0.1:443")
    )

    $appCmdExe = "$($env:SystemRoot)\System32\inetsrv\appcmd.exe"

    $serverWideClientCertMappingAuth = &$appCmdExe list config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -AppCmdOutput $serverWideClientCertMappingAuth -SearchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $clientCertMappingAuth = &$appCmdExe list config "Default Web Site" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -AppCmdOutput $clientCertMappingAuth -SearchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $asClientCertMappingAuth = &$appCmdExe list config "Default Web Site/Microsoft-Server-ActiveSync" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication

    if (-not (Test-AppCmdOutputContainsString -appCmdOutput $asClientCertMappingAuth -searchString "clientCertificateMappingAuthentication enabled=`"true`""))
    {
        return $false
    }

    $sslFlags = &$appCmdExe list config "Default Web Site/Microsoft-Server-ActiveSync" /section:access

    if (-not (Test-AppCmdOutputContainsString -appCmdOutput $sslFlags -searchString "access sslFlags=`"Ssl, SslNegotiateCert, SslRequireCert, Ssl128`""))
    {
        return $false
    }

    $netshOutput = netsh http show sslcert

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName "DS Mapper Usage" -SettingValue "Enabled"))
        {
            return $false
        }
        
        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName "Certificate Hash" -SettingValue $AutoCertBasedAuthThumbprint))
        {
            return $false
        }

        if (-not (Test-NetshSslCertSetting -IpPort $binding -NetshSslCertOutput $netshOutput -SettingName "Certificate Store Name" -SettingValue "MY"))
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
        $NetshOutput
    )

    if ($null -ne $NetshOutput -and $NetshOutput.GetType().Name -eq "Object[]")
    {
        for ($i = 0; $i -lt $NetshOutput.Count; $i++)
        {
            if ($NetshOutput[$i].Contains("IP:port"))
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
    #See if a binding already exists, and if so, delete it
    $bindingOutput = netsh http show sslcert ipport=$($IpPortCombo)

    if (Test-IsSslBinding $bindingOutput)
    {
        $output = netsh http delete sslcert ipport=$($IpPortCombo)
        Write-Verbose "$output"
    }
    
    #Add the binding back with new settings
    $output = netsh http add sslcert ipport=$($IpPortCombo) certhash=$($CertThumbprint) appid=$($AppId) dsmapperusage=enable certstorename=MY
    Write-Verbose "$output"
}

function Test-AppCmdOutputContainsString
{
    param
    (
        $AppCmdOutput,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SearchString
    )

    if ($null -ne $AppCmdOutput -and $AppCmdOutput.GetType().Name -eq "Object[]")
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
    
    if ($null -ne $NetshSslCertOutput -and $NetshSslCertOutput.GetType().Name -eq "Object[]")
    {
        $foundSetting = $false
        for ($i = 0; $i -lt $NetshSslCertOutput.Count -and -not $foundSetting; $i++)
        {
            if ($NetshSslCertOutput[$i].ToLower().Contains("ip:port") -and $NetshSslCertOutput[$i].Contains($IpPort))
            {
                $i++
                
                while (-not $NetshSslCertOutput[$i].ToLower().Contains("ip:port") -and -not $foundSetting)
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

#Ensures that required uto Certification Based Authentication prereqs are installed 
function Test-PreReqsForCertBasedAuth
{
    $hasAllPreReqs = $true

    $webClientAuth = Get-WindowsFeature Web-Client-Auth
    $webCertAuth = Get-WindowsFeature Web-Cert-Auth

    if ($webClientAuth.InstallState -ne "Installed")
    {
        $hasAllPreReqs = $false

        Write-Error "The Web-Client-Auth feature needs to be installed before the Auto Certification Based Authentication feature can be used"
    }

    if ($webCertAuth.InstallState -ne "Installed")
    {
        $hasAllPreReqs = $false

        Write-Error "The Web-Cert-Auth feature needs to be installed before the Auto Certification Based Authentication feature can be used"
    }

    if ($hasAllPreReqs -eq $false)
    {
        throw "Required Windows features need to be installed before the Auto Certification Based Authentication feature can be used"
    }
}

function Test-ISAPIFilter
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [string]$WebSite = 'Default Web Site',
        [string]$ISAPIFilterName = 'Exchange ActiveSync ISAPI Filter'
    )
Begin
{
    $ISAPIFilters=Get-WebConfigurationProperty -PSPath 'MACHINE/WEBROOT/APPHOST' -Location $WebSite -Filter 'system.webServer/isapiFilters' -Name '.'
    [boolean]$ReturnValue = $false
}
Process
{
    if ($ISAPIFilters.Collection.Count -gt 0)
    {
        if ($ISAPIFilters.Collection.Name.Contains($ISAPIFilterName)){
            Write-Verbose "Filter $($ISAPIFilterName) was found"
            $ReturnValue = $true
        }
    }
}
End{
    return $ReturnValue
}
}

Export-ModuleMember -Function *-TargetResource



