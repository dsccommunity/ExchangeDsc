<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        Not actually used. Enter anything, as long as it's not null.

    .PARAMETER Credential
        Credentials used to perform Active Directory lookups against the
        Schema, Configuration, and Domain naming contexts.

    .PARAMETER SchemaVersion
        Specifies that the Active Directory schema should have been prepared
        using Exchange 'setup /PrepareSchema', and should be at the
        specified version.

    .PARAMETER OrganizationVersion
        Specifies that the Exchange Organization should have been prepared
        using Exchange 'setup /PrepareAD', and should be at the specified
        version.

    .PARAMETER DomainVersion
        Specifies that the domains containing the target Exchange servers were
        prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains,
        and should be at the specified version.

    .PARAMETER ExchangeDomains
        The FQDN's of domains that should be checked for DomainVersion in
        addition to the domain that this Exchange server belongs to.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether AD has
        been prepped. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to see if AD has been prepped
        before an exception is thrown. Defaults to 30.
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

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Int32]
        $SchemaVersion,

        [Parameter()]
        [System.Int32]
        $OrganizationVersion,

        [Parameter()]
        [System.Int32]
        $DomainVersion,

        [Parameter()]
        [System.String[]]
        $ExchangeDomains,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 30
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    $adRootDSE = Get-ADRootDSEInternal -Credential $Credential

    if ($null -eq $adRootDSE)
    {
        throw 'Unable to retrieve ADRootDSE'
    }

    $currentSchemaVersion = Get-SchemaVersion -ADRootDSE $adRootDSE -Credential $Credential
    $currentOrganizationVersion = Get-OrganizationVersion -ADRootDSE $adRootDSE -Credential $Credential
    $currentDomainVersions = Get-DomainsVersion -Credential $Credential -ExchangeDomains $ExchangeDomains

    $returnValue = @{
        SchemaVersion          = [System.Int32] $currentSchemaVersion
        OrganizationVersion    = [System.Int32] $currentOrganizationVersion
        DomainVersionHashtable = [System.Collections.Hashtable] $currentDomainVersions
        DomainVersion          = [System.Int32] ($currentDomainVersions.Values | Sort-Object | Select-Object -First 1)
        ExchangeDomains        = [System.String[]] (Get-StringFromHashtable -Hashtable $currentDomainVersions).Split(';')
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        Not actually used. Enter anything, as long as it's not null.

    .PARAMETER Credential
        Credentials used to perform Active Directory lookups against the
        Schema, Configuration, and Domain naming contexts.

    .PARAMETER SchemaVersion
        Specifies that the Active Directory schema should have been prepared
        using Exchange 'setup /PrepareSchema', and should be at the
        specified version.

    .PARAMETER OrganizationVersion
        Specifies that the Exchange Organization should have been prepared
        using Exchange 'setup /PrepareAD', and should be at the specified
        version.

    .PARAMETER DomainVersion
        Specifies that the domains containing the target Exchange servers were
        prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains,
        and should be at the specified version.

    .PARAMETER ExchangeDomains
        The FQDN's of domains that should be checked for DomainVersion in
        addition to the domain that this Exchange server belongs to.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether AD has
        been prepped. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to see if AD has been prepped
        before an exception is thrown. Defaults to 30.
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

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Int32]
        $SchemaVersion,

        [Parameter()]
        [System.Int32]
        $OrganizationVersion,

        [Parameter()]
        [System.Int32]
        $DomainVersion,

        [Parameter()]
        [System.String[]]
        $ExchangeDomains,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 30
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    $testResults = Wait-ForTrueTestTargetResource @PSBoundParameters

    if (!$testResults)
    {
        throw 'AD has still not been prepped after the maximum amount of retries.'
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        Not actually used. Enter anything, as long as it's not null.

    .PARAMETER Credential
        Credentials used to perform Active Directory lookups against the
        Schema, Configuration, and Domain naming contexts.

    .PARAMETER SchemaVersion
        Specifies that the Active Directory schema should have been prepared
        using Exchange 'setup /PrepareSchema', and should be at the
        specified version.

    .PARAMETER OrganizationVersion
        Specifies that the Exchange Organization should have been prepared
        using Exchange 'setup /PrepareAD', and should be at the specified
        version.

    .PARAMETER DomainVersion
        Specifies that the domains containing the target Exchange servers were
        prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains,
        and should be at the specified version.

    .PARAMETER ExchangeDomains
        The FQDN's of domains that should be checked for DomainVersion in
        addition to the domain that this Exchange server belongs to.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether AD has
        been prepped. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to see if AD has been prepped
        before an exception is thrown. Defaults to 30.
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

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Int32]
        $SchemaVersion,

        [Parameter()]
        [System.Int32]
        $OrganizationVersion,

        [Parameter()]
        [System.Int32]
        $DomainVersion,

        [Parameter()]
        [System.String[]]
        $ExchangeDomains,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 30
    )

    Write-FunctionEntry -Verbose:$VerbosePreference

    $adStatus = Get-TargetResource @PSBoundParameters

    $testResults = $true

    if ($PSBoundParameters.ContainsKey('SchemaVersion'))
    {
        if ($SchemaVersion -gt $adStatus.SchemaVersion)
        {
            Write-InvalidSettingVerbose -SettingName 'SchemaVersion' `
                -ExpectedValue $SchemaVersion `
                -ActualValue $adStatus.SchemaVersion `
                -Verbose:$VerbosePreference

            $testResults = $false
        }
    }

    if ($PSBoundParameters.ContainsKey('OrganizationVersion'))
    {
        if ($OrganizationVersion -gt $adStatus.OrganizationVersion)
        {
            Write-InvalidSettingVerbose -SettingName 'OrganizationVersion' `
                -ExpectedValue $OrganizationVersion `
                -ActualValue $adStatus.OrganizationVersion `
                -Verbose:$VerbosePreference

            $testResults = $false
        }
    }

    if ($PSBoundParameters.ContainsKey('DomainVersion'))
    {
        [System.String[]] $targetDomains = Get-EachExchangeDomainFQDN -ExchangeDomains $ExchangeDomains

        # Compare the desired DomainVersion with the actual version of each domain
        foreach ($domain in $targetDomains)
        {
            if ($DomainVersion -gt $adStatus.DomainVersionHashtable[$domain])
            {
                Write-InvalidSettingVerbose -SettingName "DomainVersion: $domain" `
                    -ExpectedValue $DomainVersion `
                    -ActualValue $adStatus.DomainVersionHashtable[$domain] `
                    -Verbose:$VerbosePreference

                $testResults = $false
            }
        }
    }

    return $testResults
}

<#
    .SYNOPSIS
        Executes Get-ADRootDSE and returns the results.

    .PARAMETER Credential
        The credentials to use when running Get-ADRootDSE.
#>
function Get-ADRootDSEInternal
{
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $cmdletParams = @{
        ErrorAction = 'SilentlyContinue'
    }

    if ($null -ne $Credential)
    {
        $cmdletParams.Add('Credential', $Credential)
    }

    return (Get-ADRootDSE @cmdletParams)
}

<#
    .SYNOPSIS
        Executes Get-ADObject with the specified parameters and returns the
        results.

    .PARAMETER Credential
        The credentials to use when running Get-ADObject.

    .PARAMETER Searching
        Whether Get-ADObject should search within the specified DN, or access
        it directly.

    .PARAMETER DistinguishedName
        The distinguishedName of the ADObject to access.

    .PARAMETER Properties
        The properties that Get-ADObject should retrieve.

    .PARAMETER Filter
        The filter to pass to Get-ADObject.

    .PARAMETER SearchScope
        The search scope to pass to Get-ADObject.
#>
function Get-ADObjectInternal
{
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Boolean]
        $Searching = $false,

        [Parameter()]
        [System.String]
        $DistinguishedName,

        [Parameter()]
        [System.String[]]
        $Properties,

        [Parameter()]
        [System.String]
        $Filter,

        [Parameter()]
        [System.String]
        $SearchScope
    )

    if ($Searching -eq $false)
    {
        $getAdObjParams = @{
            'Identity' = $DistinguishedName
        }
    }
    else
    {
        $getAdObjParams = @{
            'SearchBase' = $DistinguishedName
        }

        if ([System.String]::IsNullOrEmpty($Filter) -eq $false)
        {
            $getAdObjParams.Add('Filter', $Filter)
        }

        if ([System.String]::IsNullOrEmpty($SearchScope) -eq $false)
        {
            $getAdObjParams.Add('SearchScope', $SearchScope)
        }
    }

    if ($null -ne $Credential)
    {
        $getAdObjParams.Add('Credential', $Credential)
    }

    if ($Properties.Count -gt 0)
    {
        $getAdObjParams.Add('Properties', $Properties)
    }

    # ErrorAction SilentlyContinue doesn't seem to work with Get-ADObject. Doing in Try/Catch instead
    try
    {
        $object = Get-ADObject @getAdObjParams
    }
    catch
    {
        Write-Warning "Failed to find object at '$DistinguishedName' using Get-ADObject."
    }

    return $object
}

<#
    .SYNOPSIS
        Gets the Exchange Schema version in Int32 form. Returns null if the
        Schema Version cannot be retrieved.

    .PARAMETER ADRootDSE
        The ADRootDSE object to use when determining the Exchange Schema
        version.

    .PARAMETER Credential
        The Credentials to use when trying to determine the Exchange Schema
        version.
#>
function Get-SchemaVersion
{
    [CmdletBinding()]
    [OutputType([Nullable[System.Int32]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ADRootDSE,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $currentSchemaVersion = $null

    # Check for existence of schema object
    $schemaObj = Get-ADObjectInternal -Credential $Credential -DistinguishedName "CN=ms-Exch-Schema-Version-Pt,$($ADRootDSE.schemaNamingContext)" -Properties 'rangeUpper'

    if ($null -ne $schemaObj)
    {
        $currentSchemaVersion = $schemaObj.rangeUpper
    }
    else
    {
        Write-Warning "Unable to find schema object 'CN=ms-Exch-Schema-Version-Pt,$($ADRootDSE.schemaNamingContext)'. This is either because Exchange /PrepareSchema has not been run, or because the configured account does not have permissions to access this object."
    }

    return $currentSchemaVersion
}

<#
    .SYNOPSIS
        Gets the Exchange Organization version in Int32 form. Returns null if
        the Organization Version cannot be retrieved.

    .PARAMETER ADRootDSE
        The ADRootDSE object to use when determining the Exchange Organization
        version.

    .PARAMETER Credential
        The Credentials to use when trying to determine the Exchange
        Organization version.
#>
function Get-OrganizationVersion
{
    [CmdletBinding()]
    [OutputType([Nullable[System.Int32]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Object]
        $ADRootDSE,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    $currentOrganizationVersion = $null

    $exchangeContainer = Get-ADObjectInternal -Credential $Credential -DistinguishedName "CN=Microsoft Exchange,CN=Services,$($ADRootDSE.configurationNamingContext)" -Properties 'rangeUpper'

    if ($null -ne $exchangeContainer)
    {
        $orgContainer = Get-ADObjectInternal -Credential $Credential -Searching $true -DistinguishedName "CN=Microsoft Exchange,CN=Services,$($ADRootDSE.configurationNamingContext)" -Properties 'objectVersion' -Filter "objectClass -like 'msExchOrganizationContainer'" -SearchScope 'OneLevel'

        if ($null -ne $orgContainer)
        {
            $currentOrganizationVersion = $orgContainer.objectVersion
        }
        else
        {
            Write-Warning "Unable to find any objects of class msExchOrganizationContainer under 'CN=Microsoft Exchange,CN=Services,$($ADRootDSE.configurationNamingContext)'. This is either because Exchange /PrepareAD has not been run, or because the configured account does not have permissions to access this object."
        }
    }
    else
    {
        Write-Warning "Unable to find Exchange Configuration Container at 'CN=Microsoft Exchange,CN=Services,$($ADRootDSE.configurationNamingContext)'. This is either because Exchange /PrepareAD has not been run, or because the configured account does not have permissions to access this object."
    }

    return $currentOrganizationVersion
}

<#
    .SYNOPSIS
        Gets a Hashtable containing the Exchange Domain version of each
        configured domain. Always returns at least the current Exchange
        Server's domain. Will also add an explicitly configured Exchange
        Domains if they are not already in the list.

    .PARAMETER Credential
        The Credentials to use when trying to determine the Exchange
        Domain versions.

    .PARAMETER ExchangeDomains
        A list of Exchange Domains to check for version in addition to the
        current server's domain.
#>
function Get-DomainsVersion
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String[]]
        $ExchangeDomains
    )

    [System.Collections.Hashtable] $currentDomainVersions = @{}

    [System.String[]] $targetDomains = Get-EachExchangeDomainFQDN -ExchangeDomains $ExchangeDomains

    foreach ($domain in $targetDomains)
    {
        $domainDn = Get-DomainDNFromFQDN -Fqdn $domain

        $mesoContainer = Get-ADObjectInternal -Credential $Credential -DistinguishedName "CN=Microsoft Exchange System Objects,$($domainDn)" -Properties 'objectVersion'

        $mesoVersion = $null

        if ($null -ne $mesoContainer)
        {
            $mesoVersion = $mesoContainer.objectVersion
        }
        else
        {
            Write-Warning "Unable to find object with DN 'CN=Microsoft Exchange System Objects,$($domainDn)'. This is either because Exchange /PrepareDomain has not been run for this domain, or because the configured account does not have permissions to access this object."
        }

        $currentDomainVersions.Add($domain, $mesoVersion)
    }

    return $currentDomainVersions
}

<#
    .SYNOPSIS
        Gets a list of Exchange domains to check the domain version for.
        Always returns at least the current Exchange Server's domain. Will
        also add an explicitly configured Exchange Domains if they are not
        already in the list.

    .PARAMETER ExchangeDomains
        A list of Exchange Domains to check for version in addition to the
        current server's domain.
#>
function Get-EachExchangeDomainFQDN
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String[]]
        $ExchangeDomains
    )

    [System.String[]] $targetDomains = @()

    # Get this server's domain and add it to the list
    [System.String] $machineDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain.ToLower()

    $targetDomains += $machineDomain

    # Add any additional explicitly configured, non-duplicate domain to the list
    if ($null -ne $ExchangeDomains)
    {
        foreach ($domain in $ExchangeDomains)
        {
            $domainLower = $domain.ToLower()

            if ($targetDomains.Contains($domainLower) -eq $false)
            {
                $targetDomains += $domainLower
            }
        }
    }

    return $targetDomains
}

<#
    .SYNOPSIS
        Waits for a specified amount of time until Test-TargetResource returns
        $true.

    .PARAMETER Identity
        Not actually used. Enter anything, as long as it's not null.

    .PARAMETER Credential
        Credentials used to perform Active Directory lookups against the
        Schema, Configuration, and Domain naming contexts.

    .PARAMETER SchemaVersion
        Specifies that the Active Directory schema should have been prepared
        using Exchange 'setup /PrepareSchema', and should be at the
        specified version.

    .PARAMETER OrganizationVersion
        Specifies that the Exchange Organization should have been prepared
        using Exchange 'setup /PrepareAD', and should be at the specified
        version.

    .PARAMETER DomainVersion
        Specifies that the domains containing the target Exchange servers were
        prepared using setup /PrepareAD, /PrepareDomain, or /PrepareAllDomains,
        and should be at the specified version.

    .PARAMETER ExchangeDomains
        The FQDN's of domains that should be checked for DomainVersion in
        addition to the domain that this Exchange server belongs to.

    .PARAMETER RetryIntervalSec
        How many seconds to wait between retries when checking whether AD has
        been prepped. Defaults to 60.

    .PARAMETER RetryCount
        How many retry attempts should be made to see if AD has been prepped
        before an exception is thrown. Defaults to 30.
#>
function Wait-ForTrueTestTargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.Int32]
        $SchemaVersion,

        [Parameter()]
        [System.Int32]
        $OrganizationVersion,

        [Parameter()]
        [System.Int32]
        $DomainVersion,

        [Parameter()]
        [System.String[]]
        $ExchangeDomains,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 30
    )

    $testResults = $false

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        $testResults = Test-TargetResource @PSBoundParameters

        if ($testResults -eq $false)
        {
            Write-Verbose -Message "AD has still not been fully prepped as of $([DateTime]::Now). Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec
        }
        else
        {
            break
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
