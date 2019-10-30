<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The hostname of the Client Access Server.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AlternateServiceAccountCredential
        The AlternateServiceAccountCredential parameter specifies an
        alternative service account that'stypically used for Kerberos
        authentication.

    .PARAMETER AutoDiscoverServiceInternalUri
        The AutoDiscoverServiceInternalUri parameter specifies the internal URL
        of the Autodiscover service.

    .PARAMETER AutoDiscoverSiteScope
        The AutoDiscoverSiteScope parameter specifies the Active Directory site
        that the Autodiscover service is authoritative for. Clients that
        connect to the Autodiscover service by using the internal URL need to
        exist in the specified site.

    .PARAMETER CleanUpInvalidAlternateServiceAccountCredentials
        The CleanUpInvalidAlternateServiceAccountCredentialsswitch specifies
        whether to remove a previously configured alternate service account
        that's no longer valid. You don't need to specify a value with this
        switch.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER RemoveAlternateServiceAccountCredentials
        The RemoveAlternateServiceAccountCredentialsswitch specifies whether to
        remove a previously distributed alternate service account. You don't
        need to specify a value with this switch.
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
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [ValidateNotNullOrEmpty()]
        $AlternateServiceAccountCredential,

        [Parameter()]
        [System.String]
        $AutoDiscoverServiceInternalUri,

        [Parameter()]
        [System.String[]]
        $AutoDiscoverSiteScope,

        [Parameter()]
        [System.Boolean]
        $CleanUpInvalidAlternateServiceAccountCredentials,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $RemoveAlternateServiceAccountCredentials
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ClientAccessServ*' -Verbose:$VerbosePreference

    $cas = Get-ClientAccessServerInternal @PSBoundParameters

    if ($null -ne $cas)
    {
        if ($null -ne $cas.AutoDiscoverSiteScope)
        {
            $sites = $cas.AutoDiscoverSiteScope.ToArray()
        }
        else
        {
            $sites = @()
        }

        $returnValue = @{
            Identity                                         = [System.String] $Identity
            AutoDiscoverServiceInternalUri                   = [System.String] $cas.AutoDiscoverServiceInternalUri
            AutoDiscoverSiteScope                            = [System.String[]] $sites
            CleanUpInvalidAlternateServiceAccountCredentials = [System.Boolean] $CleanUpInvalidAlternateServiceAccountCredentials
            DomainController                                 = [System.String] $DomainController
            RemoveAlternateServiceAccountCredentials         = [System.Boolean] $RemoveAlternateServiceAccountCredentials
        }

        if ($cas.AlternateServiceAccountConfiguration.EffectiveCredentials.Count -gt 0)
        {
            $returnValue.Add("AlternateServiceAccountCredential", [System.Management.Automation.PSCredential] $cas.AlternateServiceAccountConfiguration.EffectiveCredentials.Credential)
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The hostname of the Client Access Server.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AlternateServiceAccountCredential
        The AlternateServiceAccountCredential parameter specifies an
        alternative service account that'stypically used for Kerberos
        authentication.

    .PARAMETER AutoDiscoverServiceInternalUri
        The AutoDiscoverServiceInternalUri parameter specifies the internal URL
        of the Autodiscover service.

    .PARAMETER AutoDiscoverSiteScope
        The AutoDiscoverSiteScope parameter specifies the Active Directory site
        that the Autodiscover service is authoritative for. Clients that
        connect to the Autodiscover service by using the internal URL need to
        exist in the specified site.

    .PARAMETER CleanUpInvalidAlternateServiceAccountCredentials
        The CleanUpInvalidAlternateServiceAccountCredentialsswitch specifies
        whether to remove a previously configured alternate service account
        that's no longer valid. You don't need to specify a value with this
        switch.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER RemoveAlternateServiceAccountCredentials
        The RemoveAlternateServiceAccountCredentialsswitch specifies whether to
        remove a previously distributed alternate service account. You don't
        need to specify a value with this switch.
#>
function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
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
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [ValidateNotNullOrEmpty()]
        $AlternateServiceAccountCredential,

        [Parameter()]
        [System.String]
        $AutoDiscoverServiceInternalUri,

        [Parameter()]
        [System.String[]]
        $AutoDiscoverSiteScope,

        [Parameter()]
        [System.Boolean]
        $CleanUpInvalidAlternateServiceAccountCredentials,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $RemoveAlternateServiceAccountCredentials
    )

    # check for ambiguous parameter
    if (($AlternateServiceAccountCredential -and $RemoveAlternateServiceAccountCredentials) -or ($CleanUpInvalidAlternateServiceAccountCredentials -and $RemoveAlternateServiceAccountCredentials))
    {
        throw "Ambiguous parameter detected! Don't combine AlternateServiceAccountCredential with RemoveAlternateServiceAccountCredentials or CleanUpInvalidAlternateServiceAccountCredentials with RemoveAlternateServiceAccountCredentials!"
    }
    if ($AlternateServiceAccountCredential)
    {
        # check if credentials are in correct format DOMAIN\USERNAME
        $parts = @($AlternateServiceAccountCredential.Username.Split('\'))
        if ($parts.Count -ne 2 -or $parts[0] -eq '')
        {
            throw "The username must be fully qualified!"
        }
    }

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-ClientAccessServ*' -Verbose:$VerbosePreference

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential"

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $serverVersion = Get-ExchangeVersionYear -ThrowIfUnknownVersion $true

    if ($serverVersion -in '2016', '2019')
    {
        $setCasCmd = 'Set-ClientAccessService'
    }
    elseif ($serverVersion -eq '2013')
    {
        $setCasCmd = 'Set-ClientAccessServer'
    }

    # The AlternateServiceAccount can't be set with parameters other than Identity and DomainController, so execute as one off
    if ($null -ne $AlternateServiceAccountCredential)
    {
        $asaParams = @{
            Identity = $Identity
            AlternateServiceAccountCredential = $AlternateServiceAccountCredential
        }

        if (![String]::IsNullOrEmpty($DomainController))
        {
            $asaParams.Add('DomainController', $DomainController)
        }

        & $setCasCmd @asaParams

        $PSBoundParameters.Remove('AlternateServiceAccountCredential')
    }

    # Remove AlternateServiceAccount can't be performed with parameters other than Identity and DomainController, so execute as one off
    if ($RemoveAlternateServiceAccountCredentials)
    {
        $asaParams = @{
            Identity = $Identity
            RemoveAlternateServiceAccountCredentials = $true
        }

        if (![String]::IsNullOrEmpty($DomainController))
        {
            $asaParams.Add('DomainController', $DomainController)
        }

        & $setCasCmd @asaParams

        $PSBoundParameters.Remove('RemoveAlternateServiceAccountCredentials')
    }

    & $setCasCmd @PSBoundParameters
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The hostname of the Client Access Server.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AlternateServiceAccountCredential
        The AlternateServiceAccountCredential parameter specifies an
        alternative service account that'stypically used for Kerberos
        authentication.

    .PARAMETER AutoDiscoverServiceInternalUri
        The AutoDiscoverServiceInternalUri parameter specifies the internal URL
        of the Autodiscover service.

    .PARAMETER AutoDiscoverSiteScope
        The AutoDiscoverSiteScope parameter specifies the Active Directory site
        that the Autodiscover service is authoritative for. Clients that
        connect to the Autodiscover service by using the internal URL need to
        exist in the specified site.

    .PARAMETER CleanUpInvalidAlternateServiceAccountCredentials
        The CleanUpInvalidAlternateServiceAccountCredentialsswitch specifies
        whether to remove a previously configured alternate service account
        that's no longer valid. You don't need to specify a value with this
        switch.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER RemoveAlternateServiceAccountCredentials
        The RemoveAlternateServiceAccountCredentialsswitch specifies whether to
        remove a previously distributed alternate service account. You don't
        need to specify a value with this switch.
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
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [ValidateNotNullOrEmpty()]
        $AlternateServiceAccountCredential,

        [Parameter()]
        [System.String]
        $AutoDiscoverServiceInternalUri,

        [Parameter()]
        [System.String[]]
        $AutoDiscoverSiteScope,

        [Parameter()]
        [System.Boolean]
        $CleanUpInvalidAlternateServiceAccountCredentials,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $RemoveAlternateServiceAccountCredentials
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ClientAccessServ*' -Verbose:$VerbosePreference

    $cas = Get-ClientAccessServerInternal @PSBoundParameters

    $testResults = $true

    if ($null -eq $cas)
    {
        Write-Error -Message 'Unable to retrieve Client Access Server settings for server'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'AutoDiscoverServiceInternalUri' -Type 'String' -ExpectedValue $AutoDiscoverServiceInternalUri -ActualValue $cas.AutoDiscoverServiceInternalUri.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AutoDiscoverSiteScope' -Type 'Array' -ExpectedValue $AutoDiscoverSiteScope -ActualValue $cas.AutoDiscoverSiteScope -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'AlternateServiceAccountCredential' -Type 'PSCredential' -ExpectedValue $AlternateServiceAccountCredential -ActualValue ($cas.AlternateServiceAccountConfiguration.EffectiveCredentials | Sort-Object WhenAddedUTC | Select-Object -Last 1).Credential $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if ($CleanUpInvalidAlternateServiceAccountCredentials)
        {
            Write-Verbose -Message 'CleanUpInvalidAlternateServiceAccountCredentials is set to $true. Forcing Test-TargetResource to return $false.'
            $testResults = $false
        }

        if ($RemoveAlternateServiceAccountCredentials -and ($cas.AlternateServiceAccountConfiguration.EffectiveCredentials.Count -gt 0))
        {
            Write-Verbose -Message 'RemoveAlternateServiceAccountCredentials is set to $true, and AlternateServiceAccountConfiguration currently has credentials configured. Returning $false.'
            $testResults = $false
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Used as a wrapper for Get-ClientAccessServer. Runs
        Get-ClientAcccessServer, only specifying Identity, and optionally
        DomainController, and returns the results.

    .PARAMETER Identity
        The hostname of the Client Access Server.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER AlternateServiceAccountCredential
        The AlternateServiceAccountCredential parameter specifies an
        alternative service account that'stypically used for Kerberos
        authentication.

    .PARAMETER AutoDiscoverServiceInternalUri
        The AutoDiscoverServiceInternalUri parameter specifies the internal URL
        of the Autodiscover service.

    .PARAMETER AutoDiscoverSiteScope
        The AutoDiscoverSiteScope parameter specifies the Active Directory site
        that the Autodiscover service is authoritative for. Clients that
        connect to the Autodiscover service by using the internal URL need to
        exist in the specified site.

    .PARAMETER CleanUpInvalidAlternateServiceAccountCredentials
        The CleanUpInvalidAlternateServiceAccountCredentialsswitch specifies
        whether to remove a previously configured alternate service account
        that's no longer valid. You don't need to specify a value with this
        switch.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER RemoveAlternateServiceAccountCredentials
        The RemoveAlternateServiceAccountCredentialsswitch specifies whether to
        remove a previously distributed alternate service account. You don't
        need to specify a value with this switch.
#>
function Get-ClientAccessServerInternal
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
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        [ValidateNotNullOrEmpty()]
        $AlternateServiceAccountCredential,

        [Parameter()]
        [System.String]
        $AutoDiscoverServiceInternalUri,

        [Parameter()]
        [System.String[]]
        $AutoDiscoverSiteScope,

        [Parameter()]
        [System.Boolean]
        $CleanUpInvalidAlternateServiceAccountCredentials,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.Boolean]
        $RemoveAlternateServiceAccountCredentials
    )

    # Remove params we don't want to pass into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    $serverVersion = Get-ExchangeVersionYear -ThrowIfUnknownVersion $true
    if (($null -ne $AlternateServiceAccountCredential) -or ($RemoveAlternateServiceAccountCredentials))
    {
        $PSBoundParameters.Add('IncludeAlternateServiceAccountCredentialPassword',$true)
    }

    if ($serverVersion -in '2016', '2019')
    {
        return (Get-ClientAccessService @PSBoundParameters)
    }
    elseif ($serverVersion -eq '2013')
    {
        return (Get-ClientAccessServer @PSBoundParameters)
    }
}

Export-ModuleMember -Function *-TargetResource
