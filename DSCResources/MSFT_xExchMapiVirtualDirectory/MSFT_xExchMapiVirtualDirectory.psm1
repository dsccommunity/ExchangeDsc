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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetMapiVirtualDirectory @PSBoundParameters

    if ($null -ne $vdir)
    {
        $returnValue = @{
            Identity                 = [System.String] $Identity
            IISAuthenticationMethods = [System.String[]] $vdir.IISAuthenticationMethods
            ExternalUrl              = [System.String] $vdir.ExternalUrl.AbsoluteUri
            InternalUrl              = [System.String] $vdir.InternalUrl.AbsoluteUri
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-MapiVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool"

        RestartAppPoolIfExists -Name MSExchangeMapiFrontEndAppPool
        RestartAppPoolIfExists -Name MSExchangeMapiMailboxAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeMapiFrontEndAppPool and MSExchangeMapiMailboxAppPool are manually recycled."
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MapiVirtualDirectory" -VerbosePreference $VerbosePreference

    $vdir = GetMapiVirtualDirectory @PSBoundParameters

    $testResults = $true

    if ($null -eq $vdir)
    {
        Write-Error -Message 'Unable to retrieve MAPI Virtual Directory for server'

        $testResults = $false
    }
    else
    {
        if (!(VerifySetting -Name "IISAuthenticationMethods" -Type "Array" -ExpectedValue $IISAuthenticationMethods -ActualValue $vdir.IISAuthenticationMethods -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name "ExternalUrl" -Type "String" -ExpectedValue $ExternalUrl -ActualValue $vdir.ExternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }

        if (!(VerifySetting -Name "InternalUrl" -Type "String" -ExpectedValue $InternalUrl -ActualValue $vdir.InternalUrl.AbsoluteUri -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            $testResults = $false
        }    
    }
    
    return $testResults
}

function GetMapiVirtualDirectory
{
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ExternalUrl,

        [Parameter(Mandatory = $true)]
        [System.String[]]
        $IISAuthenticationMethods,

        [Parameter()]
        [System.String]
        $InternalUrl
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MapiVirtualDirectory @PSBoundParameters)
}

Export-ModuleMember -Function *-TargetResource
