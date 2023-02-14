<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Identity of the ECP Virtual Directory.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to recycle the app pool after making changes. Defaults
        to $true.

    .PARAMETER AdminEnabled
        The AdminEnabled parameter specifies that the EAC isn't able to be
        accessed through the Internet. For more information, see Turn off
        access to the Exchange admin center.

    .PARAMETER AdfsAuthentication
        The AdfsAuthentication parameter specifies that the ECP virtual
        directory allows users to authenticate through Active Directory
        Federation Services (AD FS) authentication. This parameter accepts
        $true or $false. The default value is $false.

    .PARAMETER BasicAuthentication
        The BasicAuthentication parameter specifies whether Basic
        authentication is enabled on the virtual directory.

    .PARAMETER DigestAuthentication
        The DigestAuthentication parameter specifies whether Digest
        authentication is enabled on the virtual directory.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ExternalAuthenticationMethods
        The ExternalAuthenticationMethods parameter specifies the
        authentication methods supported on the Exchange server from outside
        the firewall.

    .PARAMETER ExternalUrl
        The ExternalURL parameter specifies the URL that's used to connect to
        the virtual directory from outside the firewall.

    .PARAMETER FormsAuthentication
        The FormsAuthentication parameter specifies whether forms-based
        authentication is enabled on the ECP virtual directory

    .PARAMETER GzipLevel
        The GzipLevel parameter sets Gzip configuration information for the
        ECP virtual directory.

    .PARAMETER InternalUrl
        The InternalURL parameter specifies the URL that's used to connect to
        the virtual directory from inside the firewall.

    .PARAMETER WindowsAuthentication
        The WindowsAuthentication parameter specifies whether Integrated
        Windows authentication is enabled on the virtual directory.
#>
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
        $AdminEnabled,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [System.String]
        [ValidateSet('None', 'Allow', 'Require')]
        $ExtendedProtectionTokenChecking,

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
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $OwaOptionsEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -Verbose:$VerbosePreference

    $EcpVdir = Get-EcpVirtualDirectoryInternal @PSBoundParameters

    if ($null -ne $EcpVdir)
    {
        $returnValue = @{
            Identity                        = [System.String] $Identity
            AdminEnabled                    = [System.Boolean] $EcpVdir.AdminEnabled
            AdfsAuthentication              = [System.Boolean] $EcpVdir.AdfsAuthentication
            BasicAuthentication             = [System.Boolean] $EcpVdir.BasicAuthentication
            DigestAuthentication            = [System.Boolean] $EcpVdir.DigestAuthentication
            ExtendedProtectionFlags         = [System.String[]] $EcpVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList       = [System.String[]] $EcpVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking = [System.String] $EcpVdir.ExtendedProtectionTokenChecking
            ExternalAuthenticationMethods   = [System.String[]] $EcpVdir.ExternalAuthenticationMethods
            ExternalUrl                     = [System.String] $EcpVdir.ExternalUrl
            FormsAuthentication             = [System.Boolean] $EcpVdir.FormsAuthentication
            GzipLevel                       = [System.String] $EcpVdir.GzipLevel
            InternalUrl                     = [System.String] $EcpVdir.InternalUrl
            WindowsAuthentication           = [System.Boolean] $EcpVdir.WindowsAuthentication
            OwaOptionsEnabled               = [System.Boolean] $EcpVdir.OwaOptionsEnabled
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The Identity of the ECP Virtual Directory.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to recycle the app pool after making changes. Defaults
        to $true.

    .PARAMETER AdminEnabled
        The AdminEnabled parameter specifies that the EAC isn't able to be
        accessed through the Internet. For more information, see Turn off
        access to the Exchange admin center.

    .PARAMETER AdfsAuthentication
        The AdfsAuthentication parameter specifies that the ECP virtual
        directory allows users to authenticate through Active Directory
        Federation Services (AD FS) authentication. This parameter accepts
        $true or $false. The default value is $false.

    .PARAMETER BasicAuthentication
        The BasicAuthentication parameter specifies whether Basic
        authentication is enabled on the virtual directory.

    .PARAMETER DigestAuthentication
        The DigestAuthentication parameter specifies whether Digest
        authentication is enabled on the virtual directory.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ExternalAuthenticationMethods
        The ExternalAuthenticationMethods parameter specifies the
        authentication methods supported on the Exchange server from outside
        the firewall.

    .PARAMETER ExternalUrl
        The ExternalURL parameter specifies the URL that's used to connect to
        the virtual directory from outside the firewall.

    .PARAMETER FormsAuthentication
        The FormsAuthentication parameter specifies whether forms-based
        authentication is enabled on the ECP virtual directory

    .PARAMETER GzipLevel
        The GzipLevel parameter sets Gzip configuration information for the
        ECP virtual directory.

    .PARAMETER InternalUrl
        The InternalURL parameter specifies the URL that's used to connect to
        the virtual directory from inside the firewall.

    .PARAMETER WindowsAuthentication
        The WindowsAuthentication parameter specifies whether Integrated
        Windows authentication is enabled on the virtual directory.
#>
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
        $AdminEnabled,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [System.String]
        [ValidateSet('None', 'Allow', 'Require')]
        $ExtendedProtectionTokenChecking,

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
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $OwaOptionsEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-EcpVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    # Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'AllowServiceRestart'

    # Verify SPNs depending on AllowDotlesSPN
    if ( -not (Test-ExtendedProtectionSPNList -SPNList $ExtendedProtectionSPNList -Flags $ExtendedProtectionFlags))
    {
        throw 'SPN list contains DotlessSPN, but AllowDotlessSPN is not added to ExtendedProtectionFlags or invalid combination was used!'
    }

    Set-EcpVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeECPAppPool'

        Restart-ExistingAppPool -Name MSExchangeECPAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeECPAppPool is manually recycled.'
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The Identity of the ECP Virtual Directory.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to recycle the app pool after making changes. Defaults
        to $true.

    .PARAMETER AdminEnabled
        The AdminEnabled parameter specifies that the EAC isn't able to be
        accessed through the Internet. For more information, see Turn off
        access to the Exchange admin center.

    .PARAMETER AdfsAuthentication
        The AdfsAuthentication parameter specifies that the ECP virtual
        directory allows users to authenticate through Active Directory
        Federation Services (AD FS) authentication. This parameter accepts
        $true or $false. The default value is $false.

    .PARAMETER BasicAuthentication
        The BasicAuthentication parameter specifies whether Basic
        authentication is enabled on the virtual directory.

    .PARAMETER DigestAuthentication
        The DigestAuthentication parameter specifies whether Digest
        authentication is enabled on the virtual directory.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ExternalAuthenticationMethods
        The ExternalAuthenticationMethods parameter specifies the
        authentication methods supported on the Exchange server from outside
        the firewall.

    .PARAMETER ExternalUrl
        The ExternalURL parameter specifies the URL that's used to connect to
        the virtual directory from outside the firewall.

    .PARAMETER FormsAuthentication
        The FormsAuthentication parameter specifies whether forms-based
        authentication is enabled on the ECP virtual directory

    .PARAMETER GzipLevel
        The GzipLevel parameter sets Gzip configuration information for the
        ECP virtual directory.

    .PARAMETER InternalUrl
        The InternalURL parameter specifies the URL that's used to connect to
        the virtual directory from inside the firewall.

    .PARAMETER WindowsAuthentication
        The WindowsAuthentication parameter specifies whether Integrated
        Windows authentication is enabled on the virtual directory.
#>
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
        $AdminEnabled,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        [ValidateSet('None', 'Proxy', 'NoServiceNameCheck', 'AllowDotlessSpn', 'ProxyCohosting')]
        $ExtendedProtectionFlags,

        [Parameter()]
        [System.String[]]
        $ExtendedProtectionSPNList,

        [Parameter()]
        [System.String]
        [ValidateSet('None', 'Allow', 'Require')]
        $ExtendedProtectionTokenChecking,

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
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $OwaOptionsEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $EcpVdir = Get-EcpVirtualDirectoryInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $EcpVdir)
    {
        Write-Error -Message 'Unable to retrieve ECP Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $EcpVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $EcpVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'FormsAuthentication' -Type 'Boolean' -ExpectedValue $FormsAuthentication -ActualValue $EcpVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $EcpVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $EcpVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $EcpVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AdfsAuthentication' -Type 'Boolean' -ExpectedValue $AdfsAuthentication -ActualValue $EcpVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $EcpVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AdminEnabled' -Type 'Boolean' -ExpectedValue $AdminEnabled -ActualValue $EcpVdir.AdminEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'GzipLevel' -Type 'String' -ExpectedValue $GzipLevel -ActualValue $EcpVdir.GzipLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
        if (!(Test-ExchangeSetting -Name 'OwaOptionsEnabled' -Type 'Boolean' -ExpectedValue $OwaOptionsEnabled -ActualValue $EcpVdir.OwaOptionsEnabled -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-EcpVirtualDirectory. Runs
        Get-EcpVirtualDirectory, only specifying Identity, and optionally
        DomainController, and returns the results.

    .PARAMETER Identity
        The Identity of the ECP Virtual Directory.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AllowServiceRestart
        Whether it is OK to recycle the app pool after making changes. Defaults
        to $true.

    .PARAMETER AdminEnabled
        The AdminEnabled parameter specifies that the EAC isn't able to be
        accessed through the Internet. For more information, see Turn off
        access to the Exchange admin center.

    .PARAMETER AdfsAuthentication
        The AdfsAuthentication parameter specifies that the ECP virtual
        directory allows users to authenticate through Active Directory
        Federation Services (AD FS) authentication. This parameter accepts
        $true or $false. The default value is $false.

    .PARAMETER BasicAuthentication
        The BasicAuthentication parameter specifies whether Basic
        authentication is enabled on the virtual directory.

    .PARAMETER DigestAuthentication
        The DigestAuthentication parameter specifies whether Digest
        authentication is enabled on the virtual directory.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ExternalAuthenticationMethods
        The ExternalAuthenticationMethods parameter specifies the
        authentication methods supported on the Exchange server from outside
        the firewall.

    .PARAMETER ExternalUrl
        The ExternalURL parameter specifies the URL that's used to connect to
        the virtual directory from outside the firewall.

    .PARAMETER FormsAuthentication
        The FormsAuthentication parameter specifies whether forms-based
        authentication is enabled on the ECP virtual directory

    .PARAMETER GzipLevel
        The GzipLevel parameter sets Gzip configuration information for the
        ECP virtual directory.

    .PARAMETER InternalUrl
        The InternalURL parameter specifies the URL that's used to connect to
        the virtual directory from inside the firewall.

    .PARAMETER WindowsAuthentication
        The WindowsAuthentication parameter specifies whether Integrated
        Windows authentication is enabled on the virtual directory.
#>
function Get-EcpVirtualDirectoryInternal
{
    [CmdletBinding()]
    [OutputType([System.Object])]
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
        $AdminEnabled,

        [Parameter()]
        [System.Boolean]
        $AdfsAuthentication,

        [Parameter()]
        [System.Boolean]
        $BasicAuthentication,

        [Parameter()]
        [System.Boolean]
        $DigestAuthentication,

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
        $FormsAuthentication,

        [Parameter()]
        [ValidateSet('Off', 'Low', 'High', 'Error')]
        [System.String]
        $GzipLevel,

        [Parameter()]
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $OwaOptionsEnabled,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-EcpVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
