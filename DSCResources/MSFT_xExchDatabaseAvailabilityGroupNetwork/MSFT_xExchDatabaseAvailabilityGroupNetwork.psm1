function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $DomainController,

        [System.Boolean]
        $IgnoreNetwork,

        [System.Boolean]
        $ReplicationEnabled,

        [System.String[]]
        $Subnets
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name; "DatabaseAvailabilityGroup" = $DatabaseAvailabilityGroup} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroupNetwork" -VerbosePreference $VerbosePreference

    $dagNet = GetDatabaseAvailabilityGroupNetwork @PSBoundParameters

    if ($null -ne $dagNet)
    {
        $returnValue = @{
            Name = $Name
            DatabaseAvailabilityGroup = $DatabaseAvailabilityGroup
            IgnoreNetwork = $dagNet.IgnoreNetwork
            ReplicationEnabled = $dagNet.ReplicationEnabled
            Subnets = $dagNet.Subnets
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
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $DomainController,

        [System.Boolean]
        $IgnoreNetwork,

        [System.Boolean]
        $ReplicationEnabled,

        [System.String[]]
        $Subnets
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name; "DatabaseAvailabilityGroup" = $DatabaseAvailabilityGroup} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "*DatabaseAvailabilityGroup*" -VerbosePreference $VerbosePreference

    $dagId = "$($DatabaseAvailabilityGroup)\$($Name)"

    $dagNet = GetDatabaseAvailabilityGroupNetwork @PSBoundParameters

    if ($Ensure -eq "Absent")
    {
        #Only try to remove the network if it has 0 associated subnets
        if ($null -ne $dagNet)
        {
            if ($null -eq $dagNet.Subnets -or $dagNet.Subnets.Count -eq 0)
            {
                Remove-DatabaseAvailabilityGroupNetwork -Identity "$($dagId)" -Confirm:$false
            }
            else
            {
                throw "Unable to remove network, as it still has associated subnets."
            }
        }
    }
    else
    {
        #Remove Credential and Ensure so we don't pass it into the next command
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","Ensure"

        SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

        if ($null -eq $dagNet) #Need to create a new network
        {
            $dagNet = New-DatabaseAvailabilityGroupNetwork @PSBoundParameters
            Set-DatabaseAvailabilityGroup -Identity $DatabaseAvailabilityGroup -DiscoverNetworks
        }
        else #Set props on the existing network
        {
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $dagId}
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Name","DatabaseAvailabilityGroup"
                   
            Set-DatabaseAvailabilityGroupNetwork @PSBoundParameters
        }
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
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $DomainController,

        [System.Boolean]
        $IgnoreNetwork,

        [System.Boolean]
        $ReplicationEnabled,

        [System.String[]]
        $Subnets
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Name" = $Name; "DatabaseAvailabilityGroup" = $DatabaseAvailabilityGroup} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-DatabaseAvailabilityGroupNetwork" -VerbosePreference $VerbosePreference

    $dagNet = GetDatabaseAvailabilityGroupNetwork @PSBoundParameters

    if ($null -eq $dagNet)
    {
        if ($Ensure -eq "Present")
        {
            ReportBadSetting -SettingName "Ensure" -ExpectedValue "Present" -ActualValue "Absent" -VerbosePreference $VerbosePreference
            return $false
        }
        else
        {
            return $true
        }
    }
    else
    {
        if ($Ensure -eq "Absent")
        {
            ReportBadSetting -SettingName "Ensure" -ExpectedValue "Absent" -ActualValue "Present" -VerbosePreference $VerbosePreference
            return $false
        }
        else
        {
            if (!(VerifySetting -Name "IgnoreNetwork" -Type "Boolean" -ExpectedValue $IgnoreNetwork -ActualValue $dagNet.IgnoreNetwork -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "ReplicationEnabled" -Type "Boolean" -ExpectedValue $ReplicationEnabled -ActualValue $dagNet.ReplicationEnabled -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }

            if (!(VerifySetting -Name "Subnets" -Type "Array" -ExpectedValue $Subnets -ActualValue (SubnetsToArray -Subnets $dagNet.Subnets) -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
            {
                return $false
            }
        }     
    }

    #If we made it here, all tests passed
    return $true
}

#Runs Get-DatabaseAvailabilityGroupNetwork, only specifying Identity, and optionally DomainController
function GetDatabaseAvailabilityGroupNetwork
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $DatabaseAvailabilityGroup,

        [parameter(Mandatory = $true)]
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure,

        [System.String]
        $DomainController,

        [System.Boolean]
        $IgnoreNetwork,

        [System.Boolean]
        $ReplicationEnabled,

        [System.String[]]
        $Subnets
    )

    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = "$($DatabaseAvailabilityGroup)\$($Name)"; "ErrorAction" = "SilentlyContinue"}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","ErrorAction","DomainController"

    return (Get-DatabaseAvailabilityGroupNetwork @PSBoundParameters)
}


#Takes an array of Microsoft.Exchange.Data.DatabaseAvailabilityGroupNetworkSubnet objects and converts the SubnetId props to a string[]
function SubnetsToArray
{
    param ($Subnets)

    if ($null -ne $Subnets -and $Subnets.Count -gt 0)
    {
        [string[]]$SubnetsOut = $Subnets[0].SubnetId

        for ($i = 1; $i -lt $Subnets.Count; $i++)
        {
            $SubnetsOut += $Subnets[$i].SubnetId
        }
    }

    return $SubnetsOut
}


Export-ModuleMember -Function *-TargetResource



