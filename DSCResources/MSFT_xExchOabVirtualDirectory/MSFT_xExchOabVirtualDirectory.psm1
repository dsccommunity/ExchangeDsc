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

        [System.String[]]
        $OABsToDistribute,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Int32]
        $PollInterval,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-OabVirtualDirectory","Set-OabVirtualDirectory","Get-OfflineAddressBook","Set-OfflineAddressBook" -VerbosePreference $VerbosePreference

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $vdir = Get-OabVirtualDirectory @PSBoundParameters

    if ($null -ne $vdir)
    {        
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "DomainController"

        #Get all OAB's which this VDir distributes for, and add their names to an array
        $oabs = Get-OfflineAddressBook @PSBoundParameters | Where-Object {$_.VirtualDirectories -like "*$($Identity)*"}

        [string[]]$oabNames = @()

        if ($null -ne $oabs)
        {
            foreach ($oab in $oabs)
            {
                $oabNames += $oab.Name
            }
        }

        $returnValue = @{
            Identity = $Identity
            OABsToDistribute = $oabNames
            BasicAuthentication = $vdir.BasicAuthentication
            ExtendedProtectionFlags = $vdir.ExtendedProtectionFlags
            ExtendedProtectionSPNList = $vdir.ExtendedProtectionSPNList
            ExtendedProtectionTokenChecking = $vdir.ExtendedProtectionTokenChecking
            ExternalUrl = $vdir.ExternalUrl
            InternalUrl = $vdir.InternalUrl
            PollInterval = $vdir.PollInterval
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

        [System.String[]]
        $OABsToDistribute,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Int32]
        $PollInterval,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("OABsToDistribute"))
    {
        #Get existing Vdir props so we can tell if we need to add OAB distribution points
        $vdir = Get-TargetResource @PSBoundParameters

        foreach ($oab in $OABsToDistribute)
        {
            #If we aren't currently distributing an OAB, add it
            if ((Array2ContainsArray1Contents -Array1 $oab -Array2 $vdir.OABsToDistribute -IgnoreCase) -eq $false)
            {
                AddOabDistributionPoint @PSBoundParameters -TargetOabName "$($oab)"
            }
        }
    }
    else
    {
        #Need to establish a remote Powershell session since it wasn't done in Get-TargetResource above
        GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Set-OabVirtualDirectory"
    }

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart","OABsToDistribute"

    SetEmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    Set-OabVirtualDirectory @PSBoundParameters

    if ($AllowServiceRestart -eq $true)
    {
        Write-Verbose "Recycling MSExchangeOABAppPool"

        RestartAppPoolIfExists -Name MSExchangeOABAppPool
    }
    else
    {
        Write-Warning "The configuration will not take effect until MSExchangeOABAppPool is manually recycled."
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

        [System.String[]]
        $OABsToDistribute,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Int32]
        $PollInterval,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    $vdir = Get-TargetResource @PSBoundParameters

    if ($null -eq $vdir)
    {
        return $false
    }
    else
    {
        if ($PSBoundParameters.ContainsKey("OABsToDistribute") -and (Array2ContainsArray1Contents -Array1 $OABsToDistribute -Array2 $vdir.OABsToDistribute -IgnoreCase) -eq $false)
        {
            ReportBadSetting -SettingName "OABsToDistribute" -ExpectedValue $OABsToDistribute -ActualValue $vdir.OABsToDistribute -VerbosePreference $VerbosePreference
        }

        if (!(VerifySetting -Name "BasicAuthentication" -Type "Boolean" -ExpectedValue $BasicAuthentication -ActualValue $vdir.BasicAuthentication -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionFlags" -Type "Array" -ExpectedValue $ExtendedProtectionFlags -ActualValue $vdir.ExtendedProtectionFlags -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionSPNList" -Type "Array" -ExpectedValue $ExtendedProtectionSPNList -ActualValue $vdir.ExtendedProtectionSPNList -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ExtendedProtectionTokenChecking" -Type "String" -ExpectedValue $ExtendedProtectionTokenChecking -ActualValue $vdir.ExtendedProtectionTokenChecking -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
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

        if (!(VerifySetting -Name "PollInterval" -Type "Int" -ExpectedValue $PollInterval -ActualValue $vdir.PollInterval -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
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

#Adds a specified OAB vdir to the distribution points for an OAB
function AddOabDistributionPoint
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

        [System.String[]]
        $OABsToDistribute,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.Boolean]
        $BasicAuthentication,

        [System.String]
        $DomainController,

        [System.String[]]
        $ExtendedProtectionFlags,

        [System.String[]]
        $ExtendedProtectionSPNList,

        [ValidateSet("None","Allow","Require")]
        [System.String]
        $ExtendedProtectionTokenChecking,

        [System.String]
        $ExternalUrl,

        [System.String]
        $InternalUrl,

        [System.Int32]
        $PollInterval,

        [System.Boolean]
        $RequireSSL,

        [System.Boolean]
        $WindowsAuthentication,

        [parameter(Mandatory = $true)] #Extra parameter added just for this function
        [System.String]
        $TargetOabName
    )

    #Keep track of the OAB vdir to add
    $vdirIdentity = $Identity

    #Setup params for Get-OfflineAddressBook
    AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = $TargetOabName}
    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    $oab = Get-OfflineAddressBook @PSBoundParameters    if ($null -ne $oab)    {        #Assemble the list of existing Virtual Directories        [string[]]$allVdirs = @()              foreach ($vdir in $oab.VirtualDirectories)        {            $oabServer = ServerFromOABVdirDN -OabVdirDN $vdir.DistinguishedName                        [string]$entry = $oabServer + "\" + $vdir.Name                        $allVdirs += $entry        }        #Add desired vdir to existing list        $allVdirs += $vdirIdentity

        #Set back to the OAB
        Set-OfflineAddressBook @PSBoundParameters -VirtualDirectories $allVdirs
    }
    else
    {
        throw "Unable to find OAB '$($TargetOabName)'"
    }
}

#Gets just the server netbios name from an OAB virtual directory distinguishedNamefunction ServerFromOABVdirDN($OabVdirDN){    $startString = "CN=Protocols,CN="    $endString = ",CN=Servers"    $startIndex = $OabVdirDN.IndexOf($startString) + $startString.Length    $length = $OabVdirDN.IndexOf($endString) - $startIndex    $serverName = $OabVdirDN.Substring($startIndex, $length)        return $serverName}

Export-ModuleMember -Function *-TargetResource



