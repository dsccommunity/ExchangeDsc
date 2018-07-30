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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxDatabase','Set-AdServerSettings' -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    if ($null -ne $db)
    {
        $returnValue = @{
            Identity = [System.String]$Identity
        }    
    }

    $returnValue
}

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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxDatabase','Set-AdServerSettings' -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    for ($i = 0; $i -lt $RetryCount; $i++)
    {
        if ($null -eq $db)
        {
            Write-Warning "Database '$($Identity)' does not yet exist. Sleeping for $($RetryIntervalSec) seconds."
            Start-Sleep -Seconds $RetryIntervalSec

            $db = GetMailboxDatabase @PSBoundParameters
        }
        else
        {
            break
        }
    }
    
    if ($null -eq $db)
    {
        throw "Database '$($Identity)' does not yet exist. This will prevent resources that are dependant on this resource from executing. If you are running the DSC configuration in push mode, you will need to re-run the configuration once the database has been created."
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    LogFunctionEntry -Parameters @{'Identity' = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-MailboxDatabase','Set-AdServerSettings' -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    $testResults = $true

    if ($null -eq $db)
    {
        Write-Verbose -Message "Mailbox Database does not yet exist"
        $testResults = $false
    }

    return $testResults
}

function GetMailboxDatabase
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
        [System.String]
        $DomainController,

        [Parameter()]
        [System.UInt32]
        $RetryIntervalSec = 60,

        [Parameter()]
        [System.UInt32]
        $RetryCount = 5,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity','DomainController'

    return (Get-MailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function *-TargetResource
