function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Thumbprint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [System.Boolean]
        $AllowExtraServices = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [System.String]
        $CertFilePath,

        [System.String]
        $DomainController,

        [System.String[]]
        $Services
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Thumbprint" = $Thumbprint} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ExchangeCertificate" -VerbosePreference $VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    if ($null -ne $cert)
    {
        $returnValue = @{
            Thumbprint = $Thumbprint
            Services = $cert.Services.ToString()
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
        $Thumbprint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [System.Boolean]
        $AllowExtraServices = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [System.String]
        $CertFilePath,

        [System.String]
        $DomainController,

        [System.String[]]
        $Services
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Thumbprint" = $Thumbprint} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*ExchangeCertificate" -VerbosePreference $VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    #Check whether any UM services are being enabled, and if they weren't enable before. If so, we should stop those services, enable the cert, then start them up
    $needUMServiceReset = $false
    $needUMCallRouterServiceReset = $false

    if ($null -ne $cert)
    {
        $currentServices = StringToArray -StringIn $cert.Services -Separator ','
    }

    if ((Array2ContainsArray1Contents -Array2 $Services -Array1 "UM" -IgnoreCase $true) -eq $true)
    {
        if ($null -eq $cert -or (Array2ContainsArray1Contents -Array2 $currentServices -Array1 "UM" -IgnoreCase $true) -eq $false)
        {
            $needUMServiceReset = $true
        }
    }

    if ((Array2ContainsArray1Contents -Array2 $Services -Array1 "UMCallRouter" -IgnoreCase $true) -eq $true)
    {
        if ($null -eq $cert -or (Array2ContainsArray1Contents -Array2 $currentServices -Array1 "UMCallRouter" -IgnoreCase $true) -eq $false)
        {
            $needUMCallRouterServiceReset = $true
        }
    }

    #Stop required services before working with the cert
    if ($needUMServiceReset -eq $true)
    {
        Write-Verbose "Stopping service MSExchangeUM before enabling the UM service on the certificate"
        Stop-Service -Name MSExchangeUM -Confirm:$false
    }

    if ($needUMCallRouterServiceReset -eq $true)
    {
        Write-Verbose "Stopping service MSExchangeUMCR before enabling the UMCallRouter service on the certificate"
        Stop-Service -Name MSExchangeUMCR -Confirm:$false
    }

    #The desired cert is not present. Deal with that scenario.
    if ($null -eq $cert)
    {
        #If the cert is null and it's supposed to be present, then we need to import one
        if ($Ensure -eq "Present")
        {
            $cert = Import-ExchangeCertificate -FileData ([Byte[]]$(Get-Content -Path "$($CertFilePath)" -Encoding Byte -ReadCount 0)) -Password:$CertCreds.Password -Server $env:COMPUTERNAME
        }
    }
    else
    {
        #cert is present and it shouldn't be. Remove it
        if ($Ensure -eq "Absent")
        {
            Remove-ExchangeCertificate -Thumbprint $Thumbprint -Confirm:$false -Server $env:COMPUTERNAME
        }
    }

    #Cert is present. Set props on it
    if ($Ensure -eq "Present")
    {
        if ($null -ne $cert)
        {
            NotePreviousError

            Enable-ExchangeCertificate -Thumbprint $Thumbprint -Services $Services -Force -Server $env:COMPUTERNAME

            ThrowIfNewErrorsEncountered -CmdletBeingRun "Enable-ExchangeCertificate" -VerbosePreference $VerbosePreference
        }
        else
        {
            Write-Error "Failed to install certificate"
        }
    }

    #Start UM services that we started
    if ($needUMServiceReset -eq $true)
    {
        Write-Verbose "Starting service MSExchangeUM"
        Start-Service -Name MSExchangeUM -Confirm:$false
    }

    if ($needUMCallRouterServiceReset -eq $true)
    {
        Write-Verbose "Starting service MSExchangeUMCR"
        Start-Service -Name MSExchangeUMCR -Confirm:$false
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
        $Thumbprint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [System.Boolean]
        $AllowExtraServices = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [System.String]
        $CertFilePath,

        [System.String]
        $DomainController,

        [System.String[]]
        $Services
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Thumbprint" = $Thumbprint} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-ExchangeCertificate" -VerbosePreference $VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    $result = $false

    if ($null -ne $cert)
    {
        if ($Ensure -eq "Present")
        {
            $result = CompareCertServices -ServicesActual $cert.Services -ServicesDesired $Services -AllowExtraServices $AllowExtraServices
        }
    }
    elseif ($Ensure -eq "Absent")
    {
        $result = $true
    }

    $result
}

#Runs Get-ExchangeCertificate, only specifying Thumbprint, ErrorAction, and optionally DomainController
function GetExchangeCertificate
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Thumbprint,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [System.Boolean]
        $AllowExtraServices = $false,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [System.String]
        $CertFilePath,

        [System.String]
        $DomainController,

        [System.String[]]
        $Services
    )

    #Remove params we don't want to pass into the next command
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Thumbprint","DomainController"

    return (Get-ExchangeCertificate @PSBoundParameters -ErrorAction SilentlyContinue -Server $env:COMPUTERNAME)
}

<#
.Synopsis
Compares whether services from a certificate object match the services that were requested.
If AllowsExtraServices is true, it is OK for more services to be on the cert than were requested,
as long as the requested services are present.
#>

function CompareCertServices
{
    param([string]$ServicesActual, [string[]]$ServicesDesired, [boolean]$AllowExtraServices)
    
    $actual = StringToArray -StringIn $ServicesActual -Separator ','

    if ($AllowExtraServices -eq $true)
    {
        if (!([string]::IsNullOrEmpty($ServicesDesired)) -and $ServicesDesired.Contains("NONE"))
        {
            $result = $true
        }
        else
        {
            $result = Array2ContainsArray1Contents -Array1 $ServicesDesired -Array2 $actual -IgnoreCase
        }
    }
    else
    {
        $result = CompareArrayContents -Array1 $actual -Array2 $ServicesDesired -IgnoreCase
    }

    return $result
}


Export-ModuleMember -Function *-TargetResource
Export-ModuleMember -Function CompareCertServices


