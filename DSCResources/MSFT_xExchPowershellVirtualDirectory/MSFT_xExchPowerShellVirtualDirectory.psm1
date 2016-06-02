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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-PowerShellVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetPowerShellVirtualDirectory @PSBoundParameters

    if ($null -ne $vdir)
    {
        $returnValue = @{
            Identity = $Identity
            BasicAuthentication = $vdir.BasicAuthentication
            CertificateAuthentication = $vdir.CertificateAuthentication
            ExternalUrl = $vdir.ExternalUrl.AbsoluteUri
            InternalUrl = $vdir.InternalUrl.AbsoluteUri
            RequireSSL = $vdir.RequireSSL
            WindowsAuthentication = $vdir.WindowsAuthentication
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-PowerShellVirtualDirectory" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-PowerShellVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        #Remove existing PS sessions, as we're about to break them
        RemoveExistingRemoteSession -VerbosePreference $VerbosePreference

        Write-Verbose "Recycling MSExchangePowerShellAppPool and MSExchangePowerShellFrontEndAppPool"

        RestartAppPoolIfExists -Name MSExchangePowerShellAppPool
        RestartAppPoolIfExists -Name MSExchangePowerShellFrontEndAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangePowerShellAppPool and MSExchangePowerShellFrontEndAppPool are manually recycled."
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-PowerShellVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetPowerShellVirtualDirectory @PSBoundParameters

    if ($null -eq $vdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $vdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "CertificateAuthentication" -Type "Boolean" -ExpectedValue $CertificateAuthentication -ActualValue $vdir.CertificateAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $vdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $vdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "RequireSSL" -Type "Boolean" -ExpectedValue $RequireSSL -ActualValue $vdir.RequireSSL -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "WindowsAuthentication" -Type "Boolean" -ExpectedValue $WindowsAuthentication -ActualValue $vdir.WindowsAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }       
    }
    
    return $true
}

function GetPowerShellVirtualDirectory
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
        $BasicAuthentication,

        [System.Boolean]
        $CertificateAuthentication,

        [System.String]
        $DomainController,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-PowerShellVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource



