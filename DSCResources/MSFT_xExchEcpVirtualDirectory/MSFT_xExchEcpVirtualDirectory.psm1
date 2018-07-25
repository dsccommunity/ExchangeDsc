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
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    if ($null -ne $EcpVdir)
    {
        $returnValue = @{
            DigestAuthentication = $EcpVdir.DigestAuthentication
            AdfsAuthentication = $EcpVdir.AdfsAuthentication
            ExternalAuthenticationMethods = $EcpVdir.ExternalAuthenticationMethods
            Identity = $Identity
            InternalUrl = $EcpVdir.InternalUrl
            ExternalUrl = $EcpVdir.ExternalUrl
            FormsAuthentication = $EcpVdir.FormsAuthentication
            WindowsAuthentication = $EcpVdir.WindowsAuthentication
            BasicAuthentication = $EcpVdir.BasicAuthentication

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
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters  
  
    #Remove Credential and AllowServiceRestart because those parameters do not exist on Set-OwaVirtualDirectory
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-EcpVirtualDirectory @PSBoundParameters
  
    If($AllowServiceRestart -eq $true)
    {
        Write-Verbose -Message 'Recycling MSExchangeECPAppPool'

        RestartAppPoolIfExists -Name MSExchangeECPAppPool
    }
    else
    {
        Write-Warning -Message 'The configuration will not take effect until MSExchangeECPAppPool is manually recycled.'
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
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session    
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EcpVirtualDirectory' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    
    $EcpVdir = GetEcpVirtualDirectory @PSBoundParameters

    $testResults = $true

    if ($null -eq $EcpVdir)
    {
        Write-Error -Message 'Unable to retrieve ECP Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(VerifySetting -Name 'InternalUrl' -Type 'String' -ExpectedValue $InternalUrl -ActualValue $EcpVdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'ExternalUrl' -Type 'String' -ExpectedValue $ExternalUrl -ActualValue $EcpVdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'FormsAuthentication' -Type 'Boolean' -ExpectedValue $FormsAuthentication -ActualValue $EcpVdir.FormsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'WindowsAuthentication' -Type 'Boolean' -ExpectedValue $WindowsAuthentication -ActualValue $EcpVdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'BasicAuthentication' -Type 'Boolean' -ExpectedValue $BasicAuthentication -ActualValue $EcpVdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'DigestAuthentication' -Type 'Boolean' -ExpectedValue $DigestAuthentication -ActualValue $EcpVdir.DigestAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'AdfsAuthentication' -Type 'Boolean' -ExpectedValue $AdfsAuthentication -ActualValue $EcpVdir.AdfsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name 'ExternalAuthenticationMethods' -Type 'Array' -ExpectedValue $ExternalAuthenticationMethods -ActualValue $EcpVdir.ExternalAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }
    }
   
    return $testResults 
}

function GetEcpVirtualDirectory
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
        [System.String]
        $InternalUrl,

        [Parameter()]
        [System.Boolean]
        $WindowsAuthentication
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity','DomainController'

    return (Get-EcpVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
