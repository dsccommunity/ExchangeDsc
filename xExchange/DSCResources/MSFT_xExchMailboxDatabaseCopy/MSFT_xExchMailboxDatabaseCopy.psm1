function Get-TargetResource
{
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

        [System.String]
        $TruncationLagTime
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Establish remote Powershell session
    GetRemoteExchangeSession -Credential $Credential -CommandsToLoad "Get-MailboxDatabase","*DatabaseCopy*" -VerbosePreference $VerbosePreference

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

        [System.String]
        $TruncationLagTime
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    if ($copy -eq $null) #We need to add a new copy
    {
        #Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart"

        #Create the database
        Add-MailboxDatabaseCopy @PSBoundParameters -SeedingPostponed

        #Add original props back
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

        #See if we can find the new copy
        $copy = Get-TargetResource @PSBoundParameters

        if ($copy -ne $null) #Need to seed the database
        {
            AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = "$($Identity)\$($MailboxServer)"}
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

            Resume-MailboxDatabaseCopy @PSBoundParameters

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
            throw "Failed to add database copy"
        }
    }

    if ($copy -ne $null) #Need to set props on copy
    {
        AddParameters -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{"Identity" = "$($Identity)\$($MailboxServer)"}
        RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove "Credential","AllowServiceRestart","MailboxServer"

        Set-MailboxDatabaseCopy @PSBoundParameters
    }  
}


function Test-TargetResource
{
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

        [System.String]
        $TruncationLagTime
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Identity" = $Identity} -VerbosePreference $VerbosePreference

    #Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    if ($copy -eq $null)
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

        [System.String]
        $TruncationLagTime
    )

    RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToKeep "Identity","DomainController"

    return (Get-MailboxDatabase @PSBoundParameters -Status -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function *-TargetResource




