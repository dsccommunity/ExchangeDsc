function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Identity,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[System.Boolean]
		$AllowServiceRestart = $false,

		[System.Boolean]
		$AutoCertBasedAuth = $false,

		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443"),

		[System.Boolean]
		$BasicAuthEnabled,

		[ValidateSet("Ignore","Allowed","Required")]
		[System.String]
		$ClientCertAuth,

		[System.Boolean]
		$CompressionEnabled,

		[System.String]
		$DomainController,

		[System.String[]]
		$ExternalAuthenticationMethods,

		[System.String]
		$ExternalUrl,

		[System.String[]]
		$InternalAuthenticationMethods,

		[System.String]
		$InternalUrl,

		[System.Boolean]
		$WindowsAuthEnabled
	)
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
	GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ActiveSyncVirtualDirectory' -VerbosePreference $VerbosePreference

    $EasVdir = GetActiveSyncVirtualDirectory @PSBoundParameters
    
    if ($EasVdir -ne $null)
    {
	    $returnValue = @{
		    Identity = $Identity
		    InternalUrl = $EasVdir.InternalUrl.AbsoluteUri
		    ExternalUrl = $EasVdir.ExternalUrl.AbsoluteUri
		    BasicAuthEnabled = $EasVdir.BasicAuthEnabled
		    WindowsAuthEnabled = $EasVdir.WindowsAuthEnabled
		    CompressionEnabled = $EasVdir.CompressionEnabled
		    ClientCertAuth = $EasVdir.ClientCertAuth
	    }
    }

	$returnValue	
    
}

function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Identity,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[System.Boolean]
		$AllowServiceRestart = $false,

		[System.Boolean]
		$AutoCertBasedAuth = $false,

		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443"),

		[System.Boolean]
		$BasicAuthEnabled,

		[ValidateSet("Ignore","Allowed","Required")]
		[System.String]
		$ClientCertAuth,

		[System.Boolean]
		$CompressionEnabled,

		[System.String]
		$DomainController,

		[System.String[]]
		$ExternalAuthenticationMethods,

		[System.String]
		$ExternalUrl,

		[System.String[]]
		$InternalAuthenticationMethods,

		[System.String]
		$InternalUrl,

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

    #Configure everything but CBA
    Set-ActiveSyncVirtualDirectory @PSBoundParameters
	
    if ($AutoCertBasedAuth -eq $true) #Need to configure CBA
    {
        CheckForCertBasedAuthPreReqs

        if (([string]::IsNullOrEmpty($AutoCertBasedAuthThumbprint) -eq $false))
        {
            ConfigureCertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings
        }
        else
        {
            throw "AutoCertBasedAuthThumbprint must be specified when AutoCertBasedAuth is set to `$true"
        }

        if($AllowServiceRestart -eq $true) #Need to restart all of IIS for auth settings to stick
        {
            Write-Verbose "Restarting IIS"

            Invoke-Expression -Command "iisreset /noforce /timeout:300"
        }
        else
        {
            Write-Warning "The configuration will not take effect until 'IISReset /noforce' is run."
        }
    }

    #Only bounce the app pool if we didn't already restart IIS for CBA
    if ($AutoCertBasedAuth -eq $false)
    {
        if($AllowServiceRestart -eq $true) 
        {
            Write-Verbose "Recycling MSExchangeSyncAppPool"

            Restart-WebAppPool -Name MSExchangeSyncAppPool
        }
        else
        {
            Write-Warning "The configuration will not take effect until MSExchangeSyncAppPool is manually recycled."
        }
    }
}



function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Identity,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[System.Boolean]
		$AllowServiceRestart = $false,

		[System.Boolean]
		$AutoCertBasedAuth = $false,

		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443"),

		[System.Boolean]
		$BasicAuthEnabled,

		[ValidateSet("Ignore","Allowed","Required")]
		[System.String]
		$ClientCertAuth,

		[System.Boolean]
		$CompressionEnabled,

		[System.String]
		$DomainController,

		[System.String[]]
		$ExternalAuthenticationMethods,

		[System.String]
		$ExternalUrl,

		[System.String[]]
		$InternalAuthenticationMethods,

		[System.String]
		$InternalUrl,

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

    $EasVdir = GetActiveSyncVirtualDirectory @PSBoundParameters

    if ($EasVdir -eq $null)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $EasVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $EasVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "BasicAuthEnabled" -Type "Boolean" -ExpectedValue $BasicAuthEnabled -ActualValue $EasVdir.BasicAuthEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthEnabled" -Type "Boolean" -ExpectedValue $WindowsAuthEnabled -ActualValue $EasVdir.WindowsAuthEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CompressionEnabled" -Type "Boolean" -ExpectedValue $CompressionEnabled -ActualValue $EasVdir.CompressionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ClientCertAuth" -Type "String" -ExpectedValue $ClientCertAuth -ActualValue $EasVdir.ClientCertAuth -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalAuthenticationMethods" -Type "Array" -ExpectedValue $ExternalAuthenticationMethods -ActualValue $EasVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalAuthenticationMethods" -Type "Array" -ExpectedValue $InternalAuthenticationMethods -ActualValue $EasVdir.InternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        If($AutoCertBasedAuth -eq $true)
        {
            CheckForCertBasedAuthPreReqs

            if ([string]::IsNullOrEmpty($AutoCertBasedAuthThumbprint))
            {
                ReportBadSetting -SettingName "AutoCertBasedAuthThumbprint" -ExpectedValue "Not null or empty" -ActualValue "" -VerbosePreference $VerbosePreference
                return $false
            }
            elseif ($AutoCertBasedAuthHttpsBindings -eq $null -or $AutoCertBasedAuthHttpsBindings.Count -eq 0)
            {
                ReportBadSetting -SettingName "AutoCertBasedAuthHttpsBindings" -ExpectedValue "Not null or empty" -ActualValue "" -VerbosePreference $VerbosePreference
                return $false
            }
            elseif ((TestCertBasedAuth -AutoCertBasedAuthThumbprint $AutoCertBasedAuthThumbprint -AutoCertBasedAuthHttpsBindings $AutoCertBasedAuthHttpsBindings) -eq $false)
            {
                ReportBadSetting -SettingName "TestCertBasedAuth" -ExpectedValue $true -ActualValue $false -VerbosePreference $VerbosePreference
                return $false
            }
        }
    }

    #If the code got to this point of the script all conditions are true   
    $True
}

function GetActiveSyncVirtualDirectory
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Identity,

		[parameter(Mandatory = $true)]
		[System.Management.Automation.PSCredential]
		$Credential,

		[System.Boolean]
		$AllowServiceRestart = $false,

		[System.Boolean]
		$AutoCertBasedAuth = $false,

		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443"),

		[System.Boolean]
		$BasicAuthEnabled,

		[ValidateSet("Ignore","Allowed","Required")]
		[System.String]
		$ClientCertAuth,

		[System.Boolean]
		$CompressionEnabled,

		[System.String]
		$DomainController,

		[System.String[]]
		$ExternalAuthenticationMethods,

		[System.String]
		$ExternalUrl,

		[System.String[]]
		$InternalAuthenticationMethods,

		[System.String]
		$InternalUrl,

		[System.Boolean]
		$WindowsAuthEnabled
	)

	RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-ActiveSyncVirtualDirectory @PSBoundParameters)
}

function ConfigureCertBasedAuth
{
	param
	(
		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443")
	)
    
    #Enable cert auth in IIS, and require SSL on the AS vdir
    $output = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe set config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:`"True`" /commit:apphost"
    Write-Verbose "$($output)"
    
    $output = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe set config `"Default Web Site`" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:`"True`" /commit:apphost"
    Write-Verbose "$($output)"
    
    $output = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe set config `"Default Web Site/Microsoft-Server-ActiveSync`" /section:access /sslFlags:`"Ssl, SslNegotiateCert, SslRequireCert, Ssl128`" /commit:apphost"    
    Write-Verbose "$($output)"
    
    $output = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe set config `"Default Web Site/Microsoft-Server-ActiveSync`" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication /enabled:`"True`" /commit:apphost"
    Write-Verbose "$($output)"

    #Set DSMapperUsage to enabled on all the required SSL bindings
    $appId = "{4dc3e181-e14b-4a21-b022-59fc669b0914}" #The appId of all IIS applications

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        EnableDSMapperUsage -ipPortCombo $binding -certThumbprint $AutoCertBasedAuthThumbprint -appId $appId
    }
}

function TestCertBasedAuth
{
	param
	(
		[System.String]
		$AutoCertBasedAuthThumbprint,

		[System.String[]]
		$AutoCertBasedAuthHttpsBindings = @("0.0.0.0:443","127.0.0.1:443")
	)

    $serverWideClientCertMappingAuth = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe list config -section:system.webServer/security/authentication/clientCertificateMappingAuthentication"

    if ((AppCmdOutputContainsString -appCmdOutput $serverWideClientCertMappingAuth -searchString "clientCertificateMappingAuthentication enabled=`"true`"") -eq $false)
    {
        return $false
    }

    $clientCertMappingAuth = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe list config `"Default Web Site`" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication"

    if ((AppCmdOutputContainsString -appCmdOutput $clientCertMappingAuth -searchString "clientCertificateMappingAuthentication enabled=`"true`"") -eq $false)
    {
        return $false
    }

    $asClientCertMappingAuth = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe list config `"Default Web Site/Microsoft-Server-ActiveSync`" -section:system.webServer/security/authentication/clientCertificateMappingAuthentication"

    if ((AppCmdOutputContainsString -appCmdOutput $asClientCertMappingAuth -searchString "clientCertificateMappingAuthentication enabled=`"true`"") -eq $false)
    {
        return $false
    }

    $sslFlags = Invoke-Expression -Command "$($env:SystemRoot)\System32\inetsrv\appcmd.exe list config `"Default Web Site/Microsoft-Server-ActiveSync`" /section:access"  

    if ((AppCmdOutputContainsString -appCmdOutput $sslFlags -searchString "access sslFlags=`"Ssl, SslNegotiateCert, SslRequireCert, Ssl128`"") -eq $false)
    {
        return $false
    }


    $netshOutput = Invoke-Expression -Command "netsh http show sslcert"

    foreach ($binding in $AutoCertBasedAuthHttpsBindings)
    {
        if ((ValidateNetshSslcertSetting -ipPort $binding -netshSslCertOutput $netshOutput -settingName "DS Mapper Usage" -settingValue "Enabled") -eq $false)
        {
            return $false
        }
        
        if ((ValidateNetshSslcertSetting -ipPort $binding -netshSslCertOutput $netshOutput -settingName "Certificate Hash" -settingValue $AutoCertBasedAuthThumbprint) -eq $false)
        {
            return $false
        }

        if ((ValidateNetshSslcertSetting -ipPort $binding -netshSslCertOutput $netshOutput -settingName "Certificate Store Name" -settingValue "MY") -eq $false)
        {
            return $false
        }
    }

    return $true
}

function IsSslBinding($netshOutput)
{
    $isBinding = $false
    
    if ($netshOutput -ne $null -and $netshOutput.GetType().Name -eq "Object[]")
    {
        for ($i = 0; $i -lt $netshOutput.Count; $i++)
        {
            if ($netshOutput[$i].Contains("IP:port"))
            {
                $isBinding = $true
                break
            }
        }
    }
    
    return $isBinding
}

function EnableDSMapperUsage($ipPortCombo, $certThumbprint, $appId)
{
    #See if a binding already exists, and if so, delete it
    $bindingOutput = netsh http show sslcert ipport=$($ipPortCombo)

    if (IsSslBinding $bindingOutput)
    {
        $output = netsh http delete sslcert ipport=$($ipPortCombo)
        Write-Verbose "$($output)"
    }
    
    #Add the binding back with new settings
    $output = netsh http add sslcert ipport=$($ipPortCombo) certhash=$($certThumbprint) appid=$($appId) dsmapperusage=enable certstorename=MY
    Write-Verbose "$($output)"
}

function AppCmdOutputContainsString($appCmdOutput, $searchString)
{
    $containsString = $false
    
    if ($appCmdOutput -ne $null -and $appCmdOutput.GetType().Name -eq "Object[]")
    {
        foreach ($line in $appCmdOutput)
        {
            if ($line.ToLower().Contains($searchString.ToLower()))
            {
                $containsString = $true
                break
            }
        }
    }
    
    return $containsString
}

function ValidateNetshSslcertSetting($ipPort, $netshSslCertOutput, $settingName, $settingValue)
{
    $isValid = $false
    $foundSetting = $false
    
    $settingName = $settingName.ToLower()
    $settingValue = $settingValue.ToLower()
    
    if ($netshSslCertOutput -ne $null -and $netshSslCertOutput.GetType().Name -eq "Object[]")
    {
        for ($i = 0; $i -lt $netshSslCertOutput.Count -and $foundSetting -eq $false; $i++)
        {
            if ($netshSslCertOutput[$i].ToLower().Contains("ip:port") -and $netshSslCertOutput[$i].Contains($ipPort))
            {
                $i++
                
                while ($netshSslCertOutput[$i].ToLower().Contains("ip:port") -eq $false -and $foundSetting -eq $false)
                {                    
                    if ($netshSslCertOutput[$i].ToLower().Contains($settingName))
                    {
                        $foundSetting = $true
                        
                        if ($netshSslCertOutput[$i].ToLower().Contains($settingValue))
                        {
                            $isValid = $true
                        }
                    }
                    
                    $i++
                }
            }
        }
    }
    
    return $isValid
}

#Ensures that required uto Certification Based Authentication prereqs are installed 
function CheckForCertBasedAuthPreReqs
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


Export-ModuleMember -Function *-TargetResource


