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

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("Allow","None","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [System.Boolean]
        $ExternalClientsRequireSsl,

        [System.String]
        $ExternalHostname,

        [System.String[]]
        $IISAuthenticationMethods,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $InternalClientAuthenticationMethod,

        [System.String]
        $InternalHostname,

        [System.Boolean]
        $InternalClientsRequireSsl,

        [System.Boolean]
        $SSLOffloading
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OutlookAnywhere' -VerbosePreference $VerbosePreference

    $RpcVdir = GetOutlookAnywhere @PSBoundParameters

    if ($null -ne $RpcVdir)
    {
        $returnValue = @{
            Identity = $Identity
            InternalHostname = $RpcVdir.InternalHostname.HostnameString
            ExternalHostname = $RpcVdir.ExternalHostname.HostnameString
            InternalClientAuthenticationMethod = $RpcVdir.InternalClientAuthenticationMethod
            ExternalClientAuthenticationMethod = $RpcVdir.ExternalClientAuthenticationMethod
            IISAuthenticationMethods = $RpcVdir.IISAuthenticationMethods
            ExtendedProtectionFlags = $RpcVdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList = $RpcVdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking = $RpcVdir.ExtendedProtectionTokenChecking
            ExternalClientsRequireSsl = $RpcVdir.ExternalClientsRequireSsl
            InternalClientsRequireSsl = $RpcVdir.InternalClientsRequireSsl
            SSLOffloading = $RpcVdir.SSLOffloading
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

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("Allow","None","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [System.Boolean]
        $ExternalClientsRequireSsl,

        [System.String]
        $ExternalHostname,

        [System.String[]]
        $IISAuthenticationMethods,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $InternalClientAuthenticationMethod,

        [System.String]
        $InternalHostname,

        [System.Boolean]
        $InternalClientsRequireSsl,

        [System.Boolean]
        $SSLOffloading
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-OutlookAnywhere' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential','AllowServiceRestart'

    Set-OutlookAnywhere @PSBoundParameters

    if($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeRpcProxyAppPool and MSExchangeRpcProxyFrontEndAppPool"

        RestartAppPoolIfExists -Name MSExchangeRpcProxyAppPool
        RestartAppPoolIfExists -Name MSExchangeRpcProxyFrontEndAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeRpcProxyAppPool and MSExchangeRpcProxyFrontEndAppPool are manually recycled."
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

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("Allow","None","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [System.Boolean]
        $ExternalClientsRequireSsl,

        [System.String]
        $ExternalHostname,

        [System.String[]]
        $IISAuthenticationMethods,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $InternalClientAuthenticationMethod,

        [System.String]
        $InternalHostname,

        [System.Boolean]
        $InternalClientsRequireSsl,

        [System.Boolean]
        $SSLOffloading
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-OutlookAnywhere' -VerbosePreference $VerbosePreference

    #Ensure an empty string is $null and not a string
    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $RpcVdir = GetOutlookAnywhere @PSBoundParameters

    if ($null -eq $RpcVdir)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "InternalHostname" -Type "String" -ExpectedValue $InternalHostname -ActualValue $RpcVdir.InternalHostname.HostnameString -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExternalHostname" -Type "String" -ExpectedValue $ExternalHostname -ActualValue $RpcVdir.ExternalHostname.HostnameString -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalClientAuthenticationMethod" -Type "String" -ExpectedValue $InternalClientAuthenticationMethod -ActualValue $RpcVdir.InternalClientAuthenticationMethod -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionTokenChecking" -Type "String" -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $RpcVdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        #ExternalClientsRequireSsl will only actually return as $true if ExternalHostname was also set
        if (![string]::IsNullOrEmpty($ExternalHostname) -and !(VerifySetting -Name "ExternalClientsRequireSsl" -Type "Boolean" -ExpectedValue $ExternalClientsRequireSsl -ActualValue $RpcVdir.ExternalClientsRequireSsl -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "InternalClientsRequireSsl" -Type "Boolean" -ExpectedValue $InternalClientsRequireSsl -ActualValue $RpcVdir.InternalClientsRequireSsl -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "SSLOffloading" -Type "Boolean" -ExpectedValue $SSLOffloading -ActualValue $RpcVdir.SSLOffloading -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "IISAuthenticationMethods" -Type "Array" -ExpectedValue $IISAuthenticationMethods -ActualValue $RpcVdir.IISAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionFlags" -Type "Array" -ExpectedValue $ExtendedProtectionFlags -ActualValue $RpcVdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionSPNList" -Type "Array" -ExpectedValue $ExtendedProtectionSPNList -ActualValue $RpcVdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    #If the code made it this far all properties are in a desired state
    return $true
}

function GetOutlookAnywhere
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

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("Allow","None","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $ExternalClientAuthenticationMethod,

        [System.Boolean]
        $ExternalClientsRequireSsl,

        [System.String]
        $ExternalHostname,

        [System.String[]]
        $IISAuthenticationMethods,

        [ValidateSet("Ntlm","Basic","Negotiate")]
        [System.String]
        $InternalClientAuthenticationMethod,

        [System.String]
        $InternalHostname,

        [System.Boolean]
        $InternalClientsRequireSsl,

        [System.Boolean]
        $SSLOffloading
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-OutlookAnywhere @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource



