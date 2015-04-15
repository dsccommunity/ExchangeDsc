function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [System.String]
        $DomainController,

        [System.Boolean]
        $SkipDagValidation
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"MailboxServer" = $MailboxServer;"DAGName" = $DAGName} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    #Setup params
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $PSBoundParameters["DAGName"]}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $dag = Get-DatabaseAvailabilityGroup @PSBoundParameters -Status -ErrorAction SilentlyContinue

    if ($dag -ne $null -and $dag.Servers -ne $null)
    {
        #See if this server is already in the DAG
        $server = $dag.Servers | where {$_.Name -eq "$($MailboxServer)"}

        if ($server -ne $null)
        {
            $returnValue = @{
                MailboxServer = $MailboxServer
                DAGName = $dag.Name
            }
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
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [System.String]
        $DomainController,

        [System.Boolean]
        $SkipDagValidation
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"MailboxServer" = $MailboxServer;"DAGName" = $DAGName} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Add-DatabaseAvailabilityGroupServer" -VerbosePreference $VerbosePreference

    #Setup params
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $PSBoundParameters["DAGName"]}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "DAGName","Credential"

    Add-DatabaseAvailabilityGroupServer @PSBoundParameters
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DAGName,

        [System.String]
        $DomainController,

        [System.Boolean]
        $SkipDagValidation
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"MailboxServer" = $MailboxServer;"DAGName" = $DAGName} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroup" -VerbosePreference $VerbosePreference

    #Setup params
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $PSBoundParameters["DAGName"]}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $dag = Get-DatabaseAvailabilityGroup @PSBoundParameters -Status -ErrorAction SilentlyContinue

    if ($dag -ne $null -and $dag.Name -like "$($DAGName)")
    {
        $server = $dag.Servers | where {$_.Name -eq "$($MailboxServer)"}

        return ($server -ne $null)
    }

    return $false
}


Export-ModuleMember -Function *-TargetResource



