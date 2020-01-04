<#
    .SYNOPSIS
        Retrieves the current DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential `
        -CommandsToLoad 'Get-MailboxDatabase', '*DatabaseCopy*', 'Set-AdServerSettings' `
        -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('AdServerSettingsPreferredServer') -and ![System.String]::IsNullOrEmpty($AdServerSettingsPreferredServer))
    {
        Set-ADServerSettings -PreferredServer "$($AdServerSettingsPreferredServer)"
    }

    $serverVersion = Get-ExchangeVersionYear

    $db = Get-MailboxDatabaseInternal @PSBoundParameters

    $serverHasCopy = $false

    # First figure out if this server has a copy
    foreach ($copy in $db.DatabaseCopies)
    {
        if ($copy.HostServerName -like $MailboxServer)
        {
            $serverHasCopy = $true

            if ($serverVersion -in '2016', '2019')
            {
                $ReplayLagMaxDelay = $copy.ReplayLagMaxDelay
            }

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
            Identity                        = [System.String] $Identity
            MailboxServer                   = [System.String] $MailboxServer
            ActivationPreference            = [System.UInt32] $ActivationPreference
            AdServerSettingsPreferredServer = [System.String] $AdServerSettingsPreferredServer
            ReplayLagMaxDelay               = [System.String] $ReplayLagMaxDelay
            ReplayLagTime                   = [System.String] $ReplayLagTime
            TruncationLagTime               = [System.String] $TruncationLagTime
        }
    }

    $returnValue
}

<#
    .SYNOPSIS
        Sets the DSC configuration for this resource.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
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

        [Parameter(Mandatory = $true)]
        [System.String]
        $MailboxServer,

        [Parameter()]
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Check for non-existent parameters in Exchange 2013
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'ReplayLagMaxDelay' `
        -ResourceName 'xExchMailboxDatabaseCopy' `
        -ParamExistsInVersion '2016', '2019'

    # Don't need to establish remote session, as Get-TargetResource will do it
    $copy = Get-TargetResource @PSBoundParameters

    if ($null -eq $copy) # We need to add a new copy
    {
        Add-MailboxDatabaseCopyInternal @PSBoundParameters
    }
    else # ($null -ne $copy) #Need to set props on copy
    {
        Set-MailboxDatabaseCopyInternal @PSBoundParameters
    }
}

<#
    .SYNOPSIS
        Tests whether the desired configuration for this resource has been
        applied.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Check for non-existent parameters in Exchange 2013
    Remove-NotApplicableParamsForVersion -PSBoundParametersIn $PSBoundParameters `
        -ParamName 'ReplayLagMaxDelay' `
        -ResourceName 'xExchMailboxDatabaseCopy' `
        -ParamExistsInVersion '2016', '2019'

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

        if (!(Test-ExchangeSetting -Name 'ReplayLagMaxDelay' -Type 'Timespan' -ExpectedValue $ReplayLagMaxDelay -ActualValue $copy.ReplayLagMaxDelay -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
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

<#
    .SYNOPSIS
        Used as a wrapper for Get-MailboxDatabase. Runs
        Get-MailboxDatabase, only specifying Identity, and optionally
        DomainController, and returns the results.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
function Get-MailboxDatabaseInternal
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToKeep 'Identity', 'DomainController'

    return (Get-MailboxDatabase @PSBoundParameters -Status -ErrorAction SilentlyContinue)
}

<#
    .SYNOPSIS
        Retrieves the current database copy count for the specified database.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
function Get-MailboxDatabaseCopyCount
{
    [CmdletBinding()]
    [OutputType([System.UInt32])]
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    [System.UInt32] $copyCount = 0

    $existingDb = Get-MailboxDatabaseInternal @PSBoundParameters -ErrorAction SilentlyContinue

    if ($null -ne $existingDb)
    {
        $copyCount = [System.UInt32] $existingDb.DatabaseCopies.Count
    }

    return $copyCount
}

<#
    .SYNOPSIS
        Adds a new copy of an existing mailbox database.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
function Add-MailboxDatabaseCopyInternal
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    Write-Verbose -Message "A copy of database '$Identity' does not exist on server '$MailboxServer'. Adding."

    $copyCount = Get-MailboxDatabaseCopyCount @PSBoundParameters

    # Increment the copy count to what it will be when this copy is added
    $copyCount++

    # Create a copy of the original parameters
    $originalPSBoundParameters =@{} + $PSBoundParameters

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
        -ParamsToRemove 'Credential', 'AllowServiceRestart', 'AdServerSettingsPreferredServer'

    # Only send in ActivationPreference if it is less than or equal to the future copy count after adding this copy
    if ($PSBoundParameters.ContainsKey('ActivationPreference') -and $ActivationPreference -gt $copyCount)
    {
        Write-Warning "Desired activation preference '$($ActivationPreference)' is higher than the future copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
            -ParamsToRemove 'ActivationPreference'
    }

    # If SeedingPostponed was passed, turn it into a switch parameter instead of a bool
    if ($PSBoundParameters.ContainsKey('SeedingPostponed') -and !$SeedingPostponed)
    {
        $PSBoundParameters.Remove('SeedingPostponed')
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

<#
    .SYNOPSIS
        Sets properties on an existing database copy.

    .PARAMETER Identity
        The Identity parameter specifies the name of the database whose copy is
        being modified.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER MailboxServer
        The MailboxServer parameter specifies the name of the server that will
        host the database copy.

    .PARAMETER AdServerSettingsPreferredServer
        An optional domain controller to pass to Set-AdServerSettings
        -PreferredServer.

    .PARAMETER AllowServiceRestart
        Whether it is OK to restart Information Store after adding copy.

    .PARAMETER ActivationPreference
        The ActivationPreference parameter value is used as part of Active
        Manager's best copy selection process and to redistribute active
        mailbox databases throughout the database availability group (DAG)
        when using the RedistributeActiveDatabases.ps1 script.

    .PARAMETER DomainController
        The DomainController parameter specifies the domain controller that's
        used by this cmdlet to read data from or write data to Active
        Directory. You identify the domain controller by its fully qualified
        domain name (FQDN). For example, dc01.contoso.com.

    .PARAMETER ReplayLagMaxDelay
        The ReplayLagMaxDelay parameter specifies the maximum delay for
        lagged database copy play down (also known as deferred lagged copy
        play down).

    .PARAMETER ReplayLagTime
        The ReplayLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before replaying
        log files that have been copied to the passive database copy.

    .PARAMETER SeedingPostponed
        The SeedingPostponed switch specifies that the task doesn't seed the
        database copy, so you need to explicitly seed the database copy.

    .PARAMETER TruncationLagTime
        The TruncationLagTime parameter specifies the amount of time that the
        Microsoft Exchange Replication service should wait before truncating
        log files that have replayed into the passive copy of the database.
#>
function Set-MailboxDatabaseCopyInternal
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
        [System.String]
        $AdServerSettingsPreferredServer,

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
        $ReplayLagMaxDelay,

        [Parameter()]
        [System.String]
        $ReplayLagTime,

        [Parameter()]
        [System.Boolean]
        $SeedingPostponed,

        [Parameter()]
        [System.String]
        $TruncationLagTime
    )

    $copyCount = Get-MailboxDatabaseCopyCount @PSBoundParameters

    Add-ToPSBoundParametersFromHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToAdd @{
        'Identity' = "$($Identity)\$($MailboxServer)"
    }
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters `
        -ParamsToRemove 'Credential', 'AllowServiceRestart', 'MailboxServer', 'AdServerSettingsPreferredServer', 'SeedingPostponed'

    if ($PSBoundParameters.ContainsKey('ActivationPreference') -and $ActivationPreference -gt $copyCount)
    {
        Write-Warning -Message "Desired activation preference '$($ActivationPreference)' is higher than current copy count '$($copyCount)'. Skipping setting ActivationPreference at this point."
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'ActivationPreference'
    }

    Set-MailboxDatabaseCopy @PSBoundParameters
}

Export-ModuleMember -Function *-TargetResource
