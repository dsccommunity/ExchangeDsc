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

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Int32]
        $SchemaVersion,

        [System.Int32]
        $OrganizationVersion,

        [System.Int32]
        $DomainVersion,

        [System.String[]]
        $ExchangeDomains,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 30
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    $dse = GetADRootDSE -Credential $Credential

    if ($PSBoundParameters.ContainsKey("SchemaVersion"))
    {
        #Check for existence of schema object
        $schemaObj = GetADObject -Credential $credential -DistinguishedName "CN=ms-Exch-Schema-Version-Pt,$($dse.schemaNamingContext)" -Properties "rangeUpper"

        if ($null -ne $schemaObj)
        {
            $currentSchemaVersion = $schemaObj.rangeUpper
        }
        else
        {
            Write-Warning "Unable to find schema object 'CN=ms-Exch-Schema-Version-Pt,$($dse.schemaNamingContext)'. This is either because Exchange /PrepareSchema has not been run, or because the configured account does not have permissions to access this object."
        }
    }

    if ($PSBoundParameters.ContainsKey("OrganizationVersion"))
    {
        $exchangeContainer = GetADObject -Credential $credential -DistinguishedName "CN=Microsoft Exchange,CN=Services,$($dse.configurationNamingContext)" -Properties "rangeUpper"

        if ($null -ne $exchangeContainer)
        {
            $orgContainer = GetADObject -Credential $Credential -Searching $true -DistinguishedName "CN=Microsoft Exchange,CN=Services,$($dse.configurationNamingContext)" -Properties "objectVersion" -Filter "objectClass -like 'msExchOrganizationContainer'" -SearchScope "OneLevel"

            if ($null -ne $orgContainer)
            {
                $currentOrganizationVersion = $orgContainer.objectVersion
            }
            else
            {
                Write-Warning "Unable to find any objects of class msExchOrganizationContainer under 'CN=Microsoft Exchange,CN=Services,$($dse.configurationNamingContext)'. This is either because Exchange /PrepareAD has not been run, or because the configured account does not have permissions to access this object."
            }
        }
        else
        {
            Write-Warning "Unable to find Exchange Configuration Container at 'CN=Microsoft Exchange,CN=Services,$($dse.configurationNamingContext)'. This is either because Exchange /PrepareAD has not been run, or because the configured account does not have permissions to access this object."
        }  
    }

    if ($PSBoundParameters.ContainsKey("DomainVersion"))
    {
        #Get this server's domain
        [string]$machineDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain.ToLower()

        #Figure out all domains we need to inspect
        [string[]]$targetDomains = @()
        $targetDomains += $machineDomain

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

        #Populate the return value in a hashtable of domains and versions
        [Hashtable]$currentDomainVersions = @{}

        foreach ($domain in $targetDomains)
        {
            $domainDn = DomainDNFromFQDN -Fqdn $domain

            $mesoContainer = GetADObject -Credential $Credential -DistinguishedName "CN=Microsoft Exchange System Objects,$($domainDn)" -Properties "objectVersion"

            $mesoVersion = $null

            if ($null -ne $mesoContainer)
            {
                $mesoVersion = $mesoContainer.objectVersion
            }
            else
            {
                Write-Warning "Unable to find object with DN 'CN=Microsoft Exchange System Objects,$($domainDn)'. This is either because Exchange /PrepareDomain has not been run for this domain, or because the configured account does not have permissions to access this object."
            }

            if ($null -eq $currentDomainVersions)
            {
                $currentDomainVersions = @{$domain = $mesoVersion}
            }
            else
            {
                $currentDomainVersions.Add($domain, $mesoVersion)
            }
        }
    }

    $returnValue = @{
        SchemaVersion = $currentSchemaVersion
        OrganizationVersion = $currentOrganizationVersion
        DomainVersion = $currentDomainVersions
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

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Int32]
        $SchemaVersion,

        [System.Int32]
        $OrganizationVersion,

        [System.Int32]
        $DomainVersion,

        [System.String[]]
        $ExchangeDomains,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 30
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    $testResults = Test-TargetResource @PSBoundParameters

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        if ($testResults -eq $false)
        {
            Write-Verbose "AD has still not been fully prepped as of $([DateTime]::Now). Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec

            $testResults = Test-TargetResource @PSBoundParameters
        }
        else
        {
            break
        }
    }
    
    if ($testResults -eq $false)
    {
        throw "AD has still not been prepped after the maximum amount of retries."
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

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.Int32]
        $SchemaVersion,

        [System.Int32]
        $OrganizationVersion,

        [System.Int32]
        $DomainVersion,

        [System.String[]]
        $ExchangeDomains,

        [System.UInt32]
        $RetryIntervalSec = 60,

        [System.UInt32]
        $RetryCount = 30
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -VerbosePreference $VerbosePreference

    $adStatus = Get-TargetResource @PSBoundParameters

    $returnValue = $true

    if ($null -eq $adStatus)
    {
        $returnValue = $false
    }
    else
    {
        if (!(VerifySetting -Name "SchemaVersion" -Type "Int" -ExpectedValue $SchemaVersion -ActualValue $adStatus.SchemaVersion -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $returnValue = $false
        }

        if (!(VerifySetting -Name "OrganizationVersion" -Type "Int" -ExpectedValue $OrganizationVersion -ActualValue $adStatus.OrganizationVersion -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $returnValue = $false
        }

        if ($PSBoundParameters.ContainsKey("DomainVersion"))
        {
            #Get this server's domain
            [string]$machineDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain.ToLower()

            #Figure out all domains we need to inspect
            [string[]]$targetDomains = @()
            $targetDomains += $machineDomain

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
            
            #Compare the desired DomainVersion with the actual version of each domain
            foreach ($domain in $targetDomains)
            {
                if (!(VerifySetting -Name "DomainVersion" -Type "Int" -ExpectedValue $DomainVersion -ActualValue $adStatus.DomainVersion[$domain] -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
                {
                    $returnValue = $false
                }
            }       
        }
    }

    return $returnValue
}

function GetADRootDSE
{
    param ([PSCredential]$Credential)

    if ($null -eq $Credential)
    {
        $dse = Get-ADRootDSE -ErrorAction SilentlyContinue -ErrorVariable errVar
    }
    else
    {
        $dse = Get-ADRootDSE -Credential $Credential -ErrorAction SilentlyContinue -ErrorVariable errVar
    }

    return $dse
}

function GetADObject
{
    param([PSCredential]$Credential, [boolean]$Searching = $false, [string]$DistinguishedName, [string[]]$Properties, [string]$Filter, [string]$SearchScope)

    if ($Searching -eq $false)
    {
        $getAdObjParams = @{"Identity" = $DistinguishedName}
    }
    else
    {
        $getAdObjParams = @{"SearchBase" = $DistinguishedName}

        if ([string]::IsNullOrEmpty($Filter) -eq $false)
        {
            $getAdObjParams.Add("Filter", $Filter)
        }

        if ([string]::IsNullOrEmpty($SearchScope) -eq $false)
        {
            $getAdObjParams.Add("SearchScope", $SearchScope)
        }
    }

    if ($null -ne $Credential)
    {
        $getAdObjParams.Add("Credential", $Credential)
    }

    if ([string]::IsNullOrEmpty($Properties) -eq $false)
    {
        $getAdObjParams.Add("Properties", $Properties)
    }

    #ErrorAction SilentlyContinue doesn't seem to work with Get-ADObject. Doing in Try/Catch instead
    try
    {
        $object = Get-ADObject @getAdObjParams
    }
    catch{} #Don't do anything here. The caller can decide how to handle this

    return $object
}

function DomainDNFromFQDN
{
    param([string]$Fqdn)

    if ($Fqdn.Contains('.'))
    {
        $domainParts = $Fqdn.Split('.')

        $domainDn = "DC=$($domainParts[0])"

        for ($i = 1; $i -lt $domainParts.Count; $i++)
        {
            $domainDn = "$($domainDn),DC=$($domainParts[$i])"
        }
    }
    elseif ($Fqdn.Length -gt 0)
    {
        $domainDn = "DC=$($Fqdn)"
    }
    else
    {
        throw "Empty value specified for domain name"
    }

    return $domainDn
}

Export-ModuleMember -Function *-TargetResource



