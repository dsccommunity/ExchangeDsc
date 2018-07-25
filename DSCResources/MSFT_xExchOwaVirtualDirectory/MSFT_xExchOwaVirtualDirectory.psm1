function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
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
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None','Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [ValidateSet('FullDomain','UserName','PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain
    )

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
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None','Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [ValidateSet('FullDomain','UserName','PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain
    )

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
        Write-Verbose -Message 'Recycling MSExchangeOWAAppPool'
        RestartAppPoolIfExists -Name MSExchangeOWAAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeOWAAppPool is manually recycled.'
    }
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
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
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None','Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [ValidateSet('FullDomain','UserName','PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain
    )
        
    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session    
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OwaVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
  
    $OwaVdir = GetOwaVirtualDirectory @PSBoundParameters

    $testResults = $true

    if ($null -eq $OwaVdir)
    {
        Write-Error -Message 'Unable to retrieve OWA Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(VerifySetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $OwaVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $OwaVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'FormsAuthentication' -Type 'Boolean' -ExpectedValue $FormsAuthentication -ActualValue $OwaVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $OwaVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $OwaVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'ChangePasswordEnabled' -Type 'Boolean' -ExpectedValue $ChangePasswordEnabled -ActualValue $OwaVdir.ChangePasswordEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $OwaVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'AdfsAuthentication' -Type 'Boolean' -ExpectedValue $AdfsAuthentication -ActualValue $OwaVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'InstantMessagingType' -Type 'String' -ExpectedValue $InstantMessagingType -ActualValue $OwaVdir.InstantMessagingType -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'InstantMessagingEnabled' -Type 'Boolean' -ExpectedValue $InstantMessagingEnabled -ActualValue $OwaVdir.InstantMessagingEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'InstantMessagingCertificateThumbprint' -Type 'String' -ExpectedValue $InstantMessagingCertificateThumbprint -ActualValue $OwaVdir.InstantMessagingCertificateThumbprint -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'InstantMessagingServerName' -Type 'String' -ExpectedValue $InstantMessagingServerName -ActualValue $OwaVdir.InstantMessagingServerName -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'LogonPagePublicPrivateSelectionEnabled' -Type 'Boolean' -ExpectedValue $LogonPagePublicPrivateSelectionEnabled -ActualValue $OwaVdir.LogonPagePublicPrivateSelectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'LogonPageLightSelectionEnabled' -Type 'Boolean' -ExpectedValue $LogonPageLightSelectionEnabled -ActualValue $OwaVdir.LogonPageLightSelectionEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $OwaVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'LogonFormat' -Type 'String' -ExpectedValue $LogonFormat -ActualValue $OwaVdir.LogonFormat -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'DefaultDomain' -Type 'String' -ExpectedValue $DefaultDomain -ActualValue $OwaVdir.DefaultDomain -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

function GetOwaVirtualDirectory
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
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $ChangePasswordEnabled,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $ExternalAuthenticationMethods,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter()]
        [System.Boolean]
        $FormsAuthentication,

        [Parameter()]
        [System.Boolean]
        $InstantMessagingEnabled,

        [Parameter()]
        [System.String]
        $InstantMessagingCertificateThumbprint,

        [Parameter()]
        [System.String]
        $InstantMessagingServerName,

        [Parameter()]
        [ValidateSet('None','Ocs')]
        [System.String]
        $InstantMessagingType,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $LogonPagePublicPrivateSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $LogonPageLightSelectionEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication,

        [Parameter()]
        [ValidateSet('FullDomain','UserName','PrincipalName')]
        [System.String]
        $LogonFormat,

        [Parameter()]
        [System.String]
        $DefaultDomain
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity','DomainController'

    return (Get-OwaVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
