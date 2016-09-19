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
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.UInt32]
        $ActivationPreference,

        [System.String]
        $DomainController,

        [System.String]
        $ReplayLagTime,

        [System.Boolean]
        $SeedingPostponed,

        [System.String]
        $TruncationLagTime,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","*DatabaseCopy*","Set-AdServerSettings" -VerbosePreference $VerbosePreference

    if ($PSBoundParameters.ContainsKey("AdServerSettingsPreferredServer") -and ![string]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings –PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    $serverHasCopy = $false

    #First figure out if this server has a copy
    foreach ($copy in $db.DatabaseCopies)
    {
        if ($copy.HostServerName -like $MailboxServer)
        {
            $serverHasCopy = $true
            break
        }
    }

    #If we have a copy, parse out the values
    if ($serverHasCopy -eq $true)
    {
        foreach ($pref in $db.ActivationPreference)
        {
            if ($pref.Key.Name -like $MailboxServer)
            {
                $ActivationPreference = $pref.Value
                break
            }
        }

        foreach ($rlt in $db.ReplayLagTimes)
        {
            if ($rlt.Key.Name -like $MailboxServer)
            {
                $ReplayLagTime = $rlt.Value
                break
            }
        }

        foreach ($tlt in $db.TruncationLagTimes)
        {
            if ($tlt.Key.Name -like $MailboxServer)
            {
                $TruncationLagTime = $tlt.Value
                break
            }
        }

        $returnValue = @{
            Identity = $Identity
            MailboxServer = $MailboxServer
            ActivationPreference = $ActivationPreference
            ReplayLagTime = $ReplayLagTime
            TruncationLagTime = $TruncationLagTime
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
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.UInt32]
        $ActivationPreference,

        [System.String]
        $DomainController,

        [System.String]
        $ReplayLagTime,

        [System.Boolean]
        $SeedingPostponed,

        [System.String]
        $TruncationLagTime,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    $copyCount = 0
    $existingDb = GetMailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue
    
    if ($null -ne $existingDb)
    {
        $copyCount = $existingDb.DatabaseCopies.Count
    }

    if ($null -eq $copy) #We need to add a new copy
    {
        Write-Verbose "A copy of database '$($Identity)' does not exist on server '$($MailboxServer)'. Adding."

        #Increment the copy count to what it will be when this copy is added
        $copyCount++

        #Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart","AdServerSettingsPreferredServer"
        
        #Only send in ActivationPreference if it is less than or equal to the future copy count after adding this copy
        if ($PSBoundParameters.ContainsKey("ActivationPreference") -and $ActivationPreference -gt $copyCount)
        {
            Write-Warning "Desired activation preference '$($ActivationPreference)' is higher than the future copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "ActivationPreference"
        }

        #If SeedingPostponed was passed, turn it into a switch parameter instead of a bool
        if ($PSBoundParameters.ContainsKey("SeedingPostponed"))
        {
            if ($SeedingPostponed -eq $true)
            {
                $PSBoundParameters.Remove("SeedingPostponed")
                $PSBoundParameters.Add("SeedingPostponed", $null)
            }
            else
            {
                $PSBoundParameters.Remove("SeedingPostponed")
            }
        }        

        #Create the database
        NotePreviousError

        Add-MailboxDatabaseCopy @PSBoundParameters

        ThrowIfNewErrorsEncountered -CmdletBeingRun "Add-MailboxDatabaseCopy" -VerbosePreference $VerbosePreference

        #Increment the copy count, as if we made it here, we didn't fail
        $copyCount++

        #Add original props back
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

        #See if we can find the new copy
        $copy = Get-TargetResource @PSBoundParameters

        if ($null -ne $copy)
        {
            #Again, add original props back
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

            if ($AllowServiceRestart -eq $true)
            {
                Write-Verbose "Restarting Information Store"

                Restart-Service MSExchangeIS
            }
            else
            {
                Write-Warning "The configuration will not take effect until MSExchangeIS is manually restarted."
            }
        }
        else
        {
            throw "Failed to find database copy after running Add-MailboxDatabaseCopy"
        }
    }
    else #($null -ne $copy) #Need to set props on copy
    {
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = "$($Identity)\$($MailboxServer)"}
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart","MailboxServer","AdServerSettingsPreferredServer","SeedingPostponed"

        if ($PSBoundParameters.ContainsKey("ActivationPreference") -and $ActivationPreference -gt $copyCount)
        {
            Write-Warning "Desired activation preference '$($ActivationPreference)' is higher than current copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "ActivationPreference"
        }

        Set-MailboxDatabaseCopy @PSBoundParameters
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
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.UInt32]
        $ActivationPreference,

        [System.String]
        $DomainController,

        [System.String]
        $ReplayLagTime,

        [System.Boolean]
        $SeedingPostponed,

        [System.String]
        $TruncationLagTime,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    if ($null -eq $copy)
    {
        return $false
    }
    else
    {
        if (!(VerifySetting -Name "ActivationPreference" -Type "Int" -ExpectedValue $ActivationPreference -ActualValue $copy.ActivationPreference -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "ReplayLagTime" -Type "Timespan" -ExpectedValue $ReplayLagTime -ActualValue $copy.ReplayLagTime -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }

        if (!(VerifySetting -Name "TruncationLagTime" -Type "Timespan" -ExpectedValue $TruncationLagTime -ActualValue $copy.TruncationLagTime -PSBoundParametersIn $PSBoundParameters -VerbosePreference $VerbosePreference))
        {
            return $false
        }
    }

    return $true
}

function GetMailboxDatabase
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [System.Boolean]
        $AllowServiceRestart = $false,

        [System.UInt32]
        $ActivationPreference,

        [System.String]
        $DomainController,

        [System.String]
        $ReplayLagTime,

        [System.Boolean]
        $SeedingPostponed,

        [System.String]
        $TruncationLagTime,

        [System.String]
        $AdServerSettingsPreferredServer
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxDatabase @PSBoundParameters -Status -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function *-TargetResource



