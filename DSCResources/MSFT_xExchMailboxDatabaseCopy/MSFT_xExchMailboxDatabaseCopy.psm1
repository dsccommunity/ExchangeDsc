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

        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.UInt32]
        $ActivationPreference,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential `
                             -CommandsToLoad 'Get-MailboxDatabase', '*DatabaseCopy*', 'Set-AdServerSettings' `
                             -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $db = GetMailboxDatabase @PSBoundParameters

    $serverHasCopy = $false

    # First figure out if this server has a copy
    foreach ($copy in $db.DatabaseCopies)
    {
        if ($copy.HostServerName -like $MailboxServer)
        {
            $serverHasCopy = $true
            break
        }
    }

    # If we have a copy, parse out the values
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
            Identity             = [System.String] $Identity
            MailboxServer        = [System.String] $MailboxServer
            ActivationPreference = [System.UInt32] $ActivationPreference
            ReplayLagTime        = [System.String] $ReplayLagTime
            TruncationLagTime    = [System.String] $TruncationLagTime
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.UInt32]
        $ActivationPreference,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    $copyCount = 0
    $existingDb = GetMailboxDatabase @PSBoundParameters -ErrorAction SilentlyContinue

    if ($null -ne $existingDb)
    {
        $copyCount = $existingDb.DatabaseCopies.Count
    }

    if ($null -eq $copy) # We need to add a new copy
    {
        Write-Verbose -Message "A copy of database '$Identity' does not exist on server '$MailboxServer'. Adding."

        # Increment the copy count to what it will be when this copy is added
        $copyCount++

        # Create a copy of the original parameters
        $originalPSBoundParameters = @{} + $PSBoundParameters

        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
                         -ParamsToRemove 'Credential', 'AllowServiceRestart', 'AdServerSettingsPreferredServer'

        # Only send in ActivationPreference if it is less than or equal to the future copy count after adding this copy
        if ($PSBoundParameters.ContainsKey('ActivationPreference') -and $ActivationPreference -gt $copyCount)
        {
            Write-Warning "Desired activation preference '$($ActivationPreference)' is higher than the future copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters
                             -ParamsToRemove 'ActivationPreference'
        }

        # If SeedingPostponed was passed, turn it into a switch parameter instead of a bool
        if ($PSBoundParameters.ContainsKey('SeedingPostponed'))
        {
            if ($SeedingPostponed -eq $true)
            {
                $PSBoundParameters.Remove('SeedingPostponed')
                $PSBoundParameters.Add('SeedingPostponed', $null)
            }
            else
            {
                $PSBoundParameters.Remove('SeedingPostponed')
            }
        }

        # Create the database
        $previousError = Get-PreviousError

        Add-MailboxDatabaseCopy @PSBoundParameters

        Assert-NoNewError -CmdletBeingRun 'Add-MailboxDatabaseCopy' -PreviousError $previousError -Verbose:$VerbosePreference

        # Increment the copy count, as if we made it here, we didn't fail
        $copyCount++

        # Add original props back
        Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

        # See if we can find the new copy
        $copy = Get-TargetResource @PSBoundParameters

        if ($null -ne $copy)
        {
            # Again, add original props back
            Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd $originalPSBoundParameters

            if ($AllowServiceRestart -eq $true)
            {
                Write-Verbose -Message 'Restarting Information Store'

                Restart-Service MSExchangeIS
            }
            else
            {
                Write-Warning -Message 'The configuration will not take effect until MSExchangeIS is manually restarted.'
            }
        }
        else
        {
            throw 'Failed to find database copy after running Add-MailboxDatabaseCopy'
        }
    }
    else # ($null -ne $copy) #Need to set props on copy
    {
        Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{'Identity' = "$($Identity)\$($MailboxServer)"}
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
                         -ParamsToRemove 'Credential', 'AllowServiceRestart', 'MailboxServer', 'AdServerSettingsPreferredServer', 'SeedingPostponed'

        if ($PSBoundParameters.ContainsKey('ActivationPreference') -and $ActivationPreference -gt $copyCount)
        {
            Write-Warning "Desired activation preference '$($ActivationPreference)' is higher than current copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'ActivationPreference'
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
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.UInt32]
        $ActivationPreference,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    Write-FunctionEntry -Parameters @{'Identity' = $Identity} -Verbose:$VerbosePreference

    # Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    $testResults = $true

    if ($null -eq $copy)
    {
        Write-Verbose -Message 'Unable to retrieve Mailbox Database Copy settings or Mailbox Database Copy does not exist'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'ActivationPreference' -Type 'Int' -ExpectedValue $ActivationPreference -ActualValue $copy.ActivationPreference -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'ReplayLagTime' -Type 'Timespan' -ExpectedValue $ReplayLagTime -ActualValue $copy.ReplayLagTime -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }

        if (!(Test-ExchangeSetting -Name 'TruncationLagTime' -Type 'Timespan' -ExpectedValue $TruncationLagTime -ActualValue $copy.TruncationLagTime -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter()]
        [System.Boolean]
        $AllowServiceRestart = $false,

        [Parameter()]
        [System.UInt32]
        $ActivationPreference,

        [Parameter()]
        [System.String]
        $DomainController,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-MailboxDatabase @PSBoundParameters -Status -ErrorAction SilentlyContinue)
}

Export-ModuleMember -Function *-TargetResource
