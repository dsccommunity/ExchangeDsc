function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [Parameter()]
        [System.Boolean]
        $AllowExtraServices = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [Parameter()]
        [System.String]
        $CertFilePath,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Services
    )

    Write-FunctionEntry -Parameters @{'Thumbprint' = $Thumbprint} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeCertificate' -Verbose:$VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    if ($null -ne $cert)
    {
        $returnValue = @{
            Thumbprint = [System.String] $Thumbprint
            Services   = [System.String[]] $cert.Services.ToString().Split(',').Trim()
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
        $Thumbprint,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [Parameter()]
        [System.Boolean]
        $AllowExtraServices = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [Parameter()]
        [System.String]
        $CertFilePath,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Services
    )

    Write-FunctionEntry -Parameters @{'Thumbprint' = $Thumbprint} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*ExchangeCertificate' -Verbose:$VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    #Check whether any UM services are being enabled, and if they weren't enable before. If so, we should stop those services, enable the cert, then start them up
    $needUMServiceReset = $false
    $needUMCallRouterServiceReset = $false

    if ($null -ne $cert)
    {
        $currentServices = Convert-StringToArray -StringIn $cert.Services -Separator ','
    }

    if ((Test-ArrayElementsInSecondArray -Array2 $Services -Array1 'UM' -IgnoreCase) -eq $true)
    {
        if ($null -eq $cert -or (Test-ArrayElementsInSecondArray -Array2 $currentServices -Array1 'UM' -IgnoreCase) -eq $false)
        {
            $needUMServiceReset = $true
        }
    }

    if ((Test-ArrayElementsInSecondArray -Array2 $Services -Array1 'UMCallRouter' -IgnoreCase) -eq $true)
    {
        if ($null -eq $cert -or (Test-ArrayElementsInSecondArray -Array2 $currentServices -Array1 'UMCallRouter' -IgnoreCase) -eq $false)
        {
            $needUMCallRouterServiceReset = $true
        }
    }

    #Stop required services before working with the cert
    if ($needUMServiceReset -eq $true)
    {
        Write-Verbose -Message 'Stopping service MSExchangeUM before enabling the UM service on the certificate'
        Stop-Service -Name MSExchangeUM -Confirm:$false
    }

    if ($needUMCallRouterServiceReset -eq $true)
    {
        Write-Verbose -Message 'Stopping service MSExchangeUMCR before enabling the UMCallRouter service on the certificate'
        Stop-Service -Name MSExchangeUMCR -Confirm:$false
    }

    #The desired cert is not present. Deal with that scenario.
    if ($null -eq $cert)
    {
        #If the cert is null and it's supposed to be present, then we need to import one
        if ($Ensure -eq 'Present')
        {
            $cert = Import-ExchangeCertificate -FileData ([Byte[]]$(Get-Content -Path "$($CertFilePath)" -Encoding Byte -ReadCount 0)) -Password:$CertCreds.Password -Server $env:COMPUTERNAME
        }
    }
    else
    {
        #cert is present and it shouldn't be. Remove it
        if ($Ensure -eq 'Absent')
        {
            Remove-ExchangeCertificate -Thumbprint $Thumbprint -Confirm:$false -Server $env:COMPUTERNAME
        }
    }

    #Cert is present. Set props on it
    if ($Ensure -eq 'Present')
    {
        if ($null -ne $cert)
        {
            $previousError = Get-PreviousError

            Enable-ExchangeCertificate -Thumbprint $Thumbprint -Services $Services -Force -Server $env:COMPUTERNAME

            Assert-NoNewError -CmdletBeingRun 'Enable-ExchangeCertificate' -PreviousError $previousError -Verbose:$VerbosePreference
        }
        else
        {
            Write-Error 'Failed to install certificate'
        }
    }

    #Start UM services that we started
    if ($needUMServiceReset -eq $true)
    {
        Write-Verbose -Message 'Starting service MSExchangeUM'
        Start-Service -Name MSExchangeUM -Confirm:$false
    }

    if ($needUMCallRouterServiceReset -eq $true)
    {
        Write-Verbose -Message 'Starting service MSExchangeUMCR'
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [Parameter()]
        [System.Boolean]
        $AllowExtraServices = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [Parameter()]
        [System.String]
        $CertFilePath,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Services
    )

    Write-FunctionEntry -Parameters @{'Thumbprint' = $Thumbprint} -Verbose:$VerbosePreference

    #Establish remote Powershell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-ExchangeCertificate' -Verbose:$VerbosePreference

    $cert = GetExchangeCertificate @PSBoundParameters

    $testResults = $true

    if ($null -ne $cert)
    {
        if ($Ensure -eq 'Present')
        {
            if (!(CompareCertServices -ServicesActual $cert.Services -ServicesDesired $Services -AllowExtraServices $AllowExtraServices))
            {
                Write-InvalidSettingVerbose -SettingName 'Services' -ExpectedValue $Services -ActualValue $cert.Services -Verbose:$VerbosePreference
                $testResults = $false
            }
        }
        else
        {
            Write-Verbose -Message "Certificate with thumbprint $Thumbprint still exists"
            $testResults = $false
        }
    }
    else
    {
        if ($Ensure -ne 'Absent')
        {
            Write-Verbose -Message "Certificate with thumbprint $Thumbprint does not exist"
            $testResults = $false
        }
    }

    return $testResults
}

#Runs Get-ExchangeCertificate, only specifying Thumbprint, ErrorAction, and optionally DomainController
function GetExchangeCertificate
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Thumbprint,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure,

        #Only used by Test-TargetResource
        [Parameter()]
        [System.Boolean]
        $AllowExtraServices = $false,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $CertCreds,

        [Parameter()]
        [System.String]
        $CertFilePath,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String[]]
        $Services
    )

    #Remove params we don't want to pass into the next command
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Thumbprint', 'DomainController'

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
    param
    (
        [Parameter()]
        [System.String]
        $ServicesActual,

        [Parameter()]
        [System.String[]]
        $ServicesDesired,

        [Parameter()]
        [System.Boolean]
        $AllowExtraServices
    )

    $actual = Convert-StringToArray -StringIn $ServicesActual -Separator ','

    if ($AllowExtraServices -eq $true)
    {
        if (!([System.String]::IsNullOrEmpty($ServicesDesired)) -and $ServicesDesired.Contains('NONE'))
        {
            $result = $true
        }
        else
        {
            $result = Test-ArrayElementsInSecondArray -Array1 $ServicesDesired -Array2 $actual -IgnoreCase
        }
    }
    else
    {
        $result = Compare-ArrayContent -Array1 $actual -Array2 $ServicesDesired -IgnoreCase
    }

    return $result
}

Export-ModuleMember -Function *-TargetResource
Export-ModuleMember -Function CompareCertServices
