[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscTestsPresent", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCDscExamplesPresent", "")]
[CmdletBinding()]
param()

function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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

    if ($null -ne $dag -and $null -ne $dag.Servers)
    {
        #See if this server is already in the DAG
        $server = $dag.Servers | Where-Object {$_.Name -eq "$($MailboxServer)"}

        if ($null -ne $server)
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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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

    $failoverClusteringRole = Get-WindowsFeature -Name Failover-Clustering -ErrorAction SilentlyContinue

    #Make sure the Failover-Clustering role is installed before trying to add the member to the DAG
    if ($null -eq $failoverClusteringRole -or !$failoverClusteringRole.Installed)
    {
        Write-Error "The Failover-Clustering role must be fully installed before the server can be added to the cluster."
        return
    }
    #Force a reboot if the cluster is in an InstallPending state
    elseif ($failoverClusteringRole.InstallState -like "InstallPending")
    {
        Write-Warning "A reboot is required to finish installing the Failover-Clustering role. This must occur before the server can be added to the DAG."
        $global:DSCMachineStatus = 1
        return
    }

    Add-DatabaseAvailabilityGroupServer @PSBoundParameters
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
        $MailboxServer,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
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

    if ($null -ne $dag -and $dag.Name -like "$($DAGName)")
    {
        $server = $dag.Servers | Where-Object {$_.Name -eq "$($MailboxServer)"}

        return ($null -ne $server)
    }

    return $false
}


Export-ModuleMember -Function *-TargetResource



