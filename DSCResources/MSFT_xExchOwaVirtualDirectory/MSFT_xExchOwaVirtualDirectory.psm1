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
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $ChangePasswordEnabled,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.Boolean]
        $InstantMessagingEnabled,

        [System.String]
        $InstantMessagingCertificateThumbprint,

        [System.String]
        $InstantMessagingServerName,

        [ValidateSet("None","Ocs")]
        [System.String]
        $InstantMessagingType,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [System.Boolean]
        $WindowsAuthentication,

        [ValidateSet("FullDomain","UserName","PrincipalName")]
        [System.String]
        $LogonFormat,

        [System.String]
        $DefaultDomain
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OwaVirtualDirectory' -VerbosePreference $VerbosePreference

    $OwaVdir = GetOwaVirtualDirectory @PSBoundParameters

    if ($null -ne $OwaVdir)
    {
        $returnValue = @{
            Identity = $Identity
            InternalUrl = $OwaVdir.InternalUrl.AbsoluteUri
            ExternalUrl = $OwaVdir.ExternalUrl.AbsoluteUri
            FormsAuthentication = $OwaVdir.FormsAuthentication
            WindowsAuthentication = $OwaVdir.WindowsAuthentication
            BasicAuthentication = $OwaVdir.BasicAuthentication
            ChangePasswordEnabled = $OwaVdir.ChangePasswordEnabled
            DigestAuthentication = $OwaVdir.DigestAuthentication
            AdfsAuthentication = $OwaVdir.AdfsAuthentication
            InstantMessagingType = $OwaVdir.InstantMessagingType
            InstantMessagingEnabled = $OwaVdir.InstantMessagingEnabled
            InstantMessagingServerName = $OwaVdir.InstantMessagingServerName
            InstantMessagingCertificateThumbprint = $OwaVdir.InstantMessagingCertificateThumbprint
            LogonPagePublicPrivateSelectionEnabled = $OwaVdir.LogonPagePublicPrivateSelectionEnabled
            LogonPageLightSelectionEnabled = $OwaVdir.LogonPageLightSelectionEnabled
            ExternalAuthenticationMethods = $OwaVdir.ExternalAuthenticationMethods
            LogonFormat = $OwaVdir.LogonFormat
            DefaultDomain = $OwaVdir.DefaultDomain
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
        [System.Management.Automation.Credential()]
        $Credential,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $ChangePasswordEnabled,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.Boolean]
        $InstantMessagingEnabled,

        [System.String]
        $InstantMessagingCertificateThumbprint,

        [System.String]
        $InstantMessagingServerName,

        [ValidateSet("None","Ocs")]
        [System.String]
        $InstantMessagingType,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [System.Boolean]
        $WindowsAuthentication,

        [ValidateSet("FullDomain","UserName","PrincipalName")]
        [System.String]
        $LogonFormat,

        [System.String]
        $DefaultDomain
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-OwaVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
        
    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-OwaVirtualDirectory @PSBoundParameters    

    if($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeOWAAppPool"
        RestartAppPoolIfExists -Name MSExchangeOWAAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeOWAAppPool is manually recycled."
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
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $ChangePasswordEnabled,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.Boolean]
        $InstantMessagingEnabled,

        [System.String]
        $InstantMessagingCertificateThumbprint,

        [System.String]
        $InstantMessagingServerName,

        [ValidateSet("None","Ocs")]
        [System.String]
        $InstantMessagingType,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [System.Boolean]
        $WindowsAuthentication,

        [ValidateSet("FullDomain","UserName","PrincipalName")]
        [System.String]
        $LogonFormat,

        [System.String]
        $DefaultDomain
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0
        
    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session    
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OwaVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
  
    $OwaVdir = GetOwaVirtualDirectory @PSBoundParameters

    if ($null -eq $OwaVdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $OwaVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $OwaVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "FormsAuthentication" -Type "Boolean" -ExpectedValue $FormsAuthentication -ActualValue $OwaVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthentication" -Type "Boolean" -ExpectedValue $WindowsAuthentication -ActualValue $OwaVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $OwaVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ChangePasswordEnabled" -Type "Boolean" -ExpectedValue $ChangePasswordEnabled -ActualValue $OwaVdir.ChangePasswordEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DigestAuthentication" -Type "Boolean" -ExpectedValue $DigestAuthentication -ActualValue $OwaVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "AdfsAuthentication" -Type "Boolean" -ExpectedValue $AdfsAuthentication -ActualValue $OwaVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InstantMessagingType" -Type "String" -ExpectedValue $InstantMessagingType -ActualValue $OwaVdir.InstantMessagingType -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InstantMessagingEnabled" -Type "Boolean" -ExpectedValue $InstantMessagingEnabled -ActualValue $OwaVdir.InstantMessagingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InstantMessagingCertificateThumbprint" -Type "String" -ExpectedValue $InstantMessagingCertificateThumbprint -ActualValue $OwaVdir.InstantMessagingCertificateThumbprint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InstantMessagingServerName" -Type "String" -ExpectedValue $InstantMessagingServerName -ActualValue $OwaVdir.InstantMessagingServerName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogonPagePublicPrivateSelectionEnabled" -Type "Boolean" -ExpectedValue $LogonPagePublicPrivateSelectionEnabled -ActualValue $OwaVdir.LogonPagePublicPrivateSelectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogonPageLightSelectionEnabled" -Type "Boolean" -ExpectedValue $LogonPageLightSelectionEnabled -ActualValue $OwaVdir.LogonPageLightSelectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalAuthenticationMethods" -Type "Array" -ExpectedValue $ExternalAuthenticationMethods -ActualValue $OwaVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "LogonFormat" -Type "String" -ExpectedValue $LogonFormat -ActualValue $OwaVdir.LogonFormat -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "DefaultDomain" -Type "String" -ExpectedValue $DefaultDomain -ActualValue $OwaVdir.DefaultDomain -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    #If the code made it this for all properties are in a desired state   
    return $true
}

function GetOwaVirtualDirectory
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
        $AdfsAuthentication,

        [System.Boolean]
        $BasicAuthentication,

        [System.Boolean]
        $ChangePasswordEnabled,

        [System.Boolean]
        $DigestAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExternalAuthenticationMethods,

        [System.String]
        $ExternalUrl,

        [System.Boolean]
        $FormsAuthentication,

        [System.Boolean]
        $InstantMessagingEnabled,

        [System.String]
        $InstantMessagingCertificateThumbprint,

        [System.String]
        $InstantMessagingServerName,

        [ValidateSet("None","Ocs")]
        [System.String]
        $InstantMessagingType,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [System.Boolean]
        $WindowsAuthentication,

        [ValidateSet("FullDomain","UserName","PrincipalName")]
        [System.String]
        $LogonFormat,

        [System.String]
        $DefaultDomain
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-OwaVirtualDirectory @PSBoundParameters)
}


Export-ModuleMember -Function *-TargetResource


