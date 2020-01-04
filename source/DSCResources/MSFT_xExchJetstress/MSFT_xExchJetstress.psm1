function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Performance', 'Stress', 'DatabaseBackup', 'SoftRecovery')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $MinAchievedIOPS = 0
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath'   = $JetstressPath
        'JetstressParams' = $JetstressParams
    } -Verbose:$VerbosePreference

    $returnValue = @{
        Type            = [System.String] $Type
        JetstressPath   = [System.String] $JetstressPath
        JetstressParams = [System.String] $JetstressParams
        MaxWaitMinutes  = [System.UInt32] $MaxWaitMinutes
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Performance', 'Stress', 'DatabaseBackup', 'SoftRecovery')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $MinAchievedIOPS = 0
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath'   = $JetstressPath
        'JetstressParams' = $JetstressParams
    } -Verbose:$VerbosePreference

    $jetstressRunning = Test-JetstressRunning
    $jetstressSuccessful = Test-JetstressSuccessful @PSBoundParameters

    if ($jetstressSuccessful -eq $false -and (Get-ChildItem -LiteralPath "$($JetstressPath)" | Where-Object { $null -ne $_.Name -like "$($Type)*.html" }))
    {
        throw "Jetstress was previously executed and resulted in a failed run. Clean up any $($Type)*.html files in the Jetstress install directory before trying to run this resource again."
    }

    if ($jetstressRunning -eq $false) # Jetstress isn't running. Kick it off
    {
        $initializingESE = $false

        # If the ESE counters haven't been registered for Perfmon, Jetstress is going to need to initialize ESE and restart the process.
        if ((Test-Path -LiteralPath "$($env:SystemRoot)\Inf\ESE\eseperf.ini") -eq $false)
        {
            $initializingESE = $true
        }

        # Create and start the Jetstress scheduled task
        Start-JetstressOperation @PSBoundParameters

        # Give an additional 60 seconds if ESE counters were just initialized.
        if ($initializingESE -eq $true)
        {
            Write-Verbose -Message 'Jetstress has never initialized performance counters for ESE. Waiting a full 60 seconds for this to occurr'

            Start-Sleep -Seconds 5

            for ($i = 55; $i -gt 0; $i--)
            {
                $jetstressRunning = Test-JetstressRunning

                if ($jetstressRunning -eq $false)
                {
                    break
                }
                else
                {
                    Start-Sleep -Seconds 1
                }
            }

            <#
                I've found that Jetstress doesn't always restart after loading ESE when running as local system in a scheduled task in the background
                If Jetstress isn't running at this point, but the perf counters were registered, we probably need to reboot the server
                If Jetstress isn't running and ESE is not registered, something failed.
            #>
            if ($jetstressRunning -eq $false)
            {
                if ((Test-Path -LiteralPath "$($env:SystemRoot)\Inf\ESE\eseperf.ini") -eq $true)
                {
                    Write-Verbose -Message 'ESE performance counters were registered. Need to reboot server.'

                    Set-DSCMachineStatus -NewDSCMachineStatus 1
                    return
                }
                else
                {
                    throw 'Jetstress failed to register MSExchange Database performance counters'
                }
            }
            else
            {
                # Looks like Jetstress restarted itself successfully. Let's let it run.
            }
        }
        else
        {
            $jetstressRunning = Test-JetstressRunning
        }

        # Wait up to a minute for Jetstress to start. If it hasn't started by then, something went wrong
        $checkMaxTime = [DateTime]::Now.AddMinutes(1)

        while ($jetstressRunning -eq $false -and $checkMaxTime -gt [DateTime]::Now)
        {
            $jetstressRunning = Test-JetstressRunning

            if ($jetstressRunning -eq $false)
            {
                Start-Sleep -Seconds 1
            }
        }

        if ($jetstressRunning -eq $false)
        {
            throw 'Waited 60 seconds after launching the Jetstress scheduled task, but failed to detect that JetstressCmd.exe is running'
        }
    }

    while ($jetstressRunning -eq $true)
    {
        Write-Verbose -Message "Jetstress is still running at '$([DateTime]::Now)'."

        # Wait for 5 minutes before logging to the screen again, but actually check every 5 seconds whether Jetstress has completed.
        for ($i = 0; $i -lt 300 -and $jetstressRunning -eq $true; $i += 5)
        {
            $jetstressRunning = Test-JetstressRunning

            if ($jetstressRunning -eq $true)
            {
                Start-Sleep -Seconds 5
            }
        }
    }

    # Check the final status on the Jetstress run
    if ($jetstressRunning -eq $false)
    {
        Write-Verbose -Message "Jetstress testing finished at '$([DateTime]::Now)'."

        $overallTestSuccessful = Test-JetstressSuccessful @PSBoundParameters

        if ($overallTestSuccessful -eq $false)
        {
            throw 'Jetstress finished running, but the test did not complete successfully'
        }
        else
        {
            Write-Verbose -Message 'Jetstress finished, and the configured test passed'
        }
    }
    else
    {
        throw "Jetstress is still running after waiting $($MaxWaitMinutes) minutes"
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
        [ValidateSet('Performance', 'Stress', 'DatabaseBackup', 'SoftRecovery')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $MinAchievedIOPS = 0
    )

    Write-FunctionEntry -Parameters @{
        'JetstressPath' = $JetstressPath
        'JetstressParams' = $JetstressParams
    } -Verbose:$VerbosePreference

    $jetstressRunning = Test-JetstressRunning -MaximumWaitSeconds 1

    if ($jetstressRunning -eq $true)
    {
        return $false
    }
    else
    {
        $jetstressSuccessful = Test-JetstressSuccessful @PSBoundParameters

        return $jetstressSuccessful
    }
}

# Checks whether the JetstressCmd.exe process is currently running
function Test-JetstressRunning
{
    $process = Get-Process -Name JetstressCmd -ErrorAction SilentlyContinue

    return ($null -ne $process)
}

# Used to create a scheduled task which will initiate the Jetstress run
function Start-JetstressOperation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Performance', 'Stress', 'DatabaseBackup', 'SoftRecovery')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $MinAchievedIOPS = 0
    )

    $fullPath = Join-Path -Path "$($JetstressPath)" -ChildPath "JetstressCmd.exe"

    Start-ExchangeScheduledTask -Path "$fullPath" -Arguments "$JetstressParams" -WorkingDirectory "$JetstressPath" -TaskName 'Jetstress' -MaxWaitMinutes $MaxWaitMinutes -Verbose:$VerbosePreference -TaskPriority 1
}

# Looks in the latest Type*.html file to determine whether the last Jetstress run passed
function Test-JetstressSuccessful
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Performance', 'Stress', 'DatabaseBackup', 'SoftRecovery')]
        [System.String]
        $Type,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $MinAchievedIOPS = 0
    )

    $overallTestSuccessful = $false
    $achievedIOPSTarget = $false

    $outputFiles = Get-ChildItem -LiteralPath "$($JetstressPath)" | Where-Object { $_.Name -like "$($Type)*.html" }

    if ($null -ne $outputFiles -and $outputFiles.Count -ge 1)
    {
        $outputFiles = $outputFiles | Sort-Object -Property LastWriteTime -Descending

        $latest = $outputFiles[0]

        $content = Get-Content -LiteralPath "$($latest.FullName)"

        $foundOverallResults = $false
        $foundAchievedIOPS = $false

        for ($i = 0; $i -lt $content.Length -and ($foundOverallResults -eq $false -or $foundAchievedIOPS -eq $false); $i++)
        {
            if ($content[$i].Contains("<td class=`"grid_row_header`">Overall Test Result</td>") -or $content[$i].Contains("<td class=`"grid_row_header`">Achieved Transactional I/O per Second</td>"))
            {
                $resultStart = $content[$i + 1].IndexOf('>') + 1
                $resultEnd = $content[$i + 1].LastIndexOf('<')

                $result = $content[$i + 1].Substring($resultStart, $resultEnd - $resultStart)

                if ($content[$i].Contains("<td class=`"grid_row_header`">Overall Test Result</td>"))
                {
                    $foundOverallResults = $true

                    Write-Verbose -Message "File '$($latest.FullName)' has an 'Overall Test Result' of '$result'"

                    if ($result -like 'Pass')
                    {
                        $overallTestSuccessful = $true
                    }
                }
                else
                {
                    $foundAchievedIOPS = $true

                    if ([System.String]::IsNullOrEmpty($result) -eq $false)
                    {
                        Write-Verbose -Message "File '$($latest.FullName)' has an 'Achieved Transactional I/O per Second' value of '$result'"

                        [Decimal] $decResult = [Decimal]::Parse($result)

                        if ($decResult -ge $MinAchievedIOPS)
                        {
                            $achievedIOPSTarget = $true
                        }
                    }
                    else
                    {
                        Write-Verbose -Message "Value for 'Achieved Transactional I/O per Second' is empty"
                    }
                }
            }
        }

        if ($foundOverallResults -eq $false)
        {
            Write-Verbose -Message "Unable to find 'Overall Test Result' in file '$($latest.FullName)'"
        }

        if ($foundAchievedIOPS -eq $false)
        {
            Write-Verbose -Message "Unable to find 'Achieved Transactional I/O per Second' in file '$($latest.FullName)'"
        }
    }
    else
    {
        Write-Verbose -Message "Unable to find any files matching '$($Type)*.html' in folder '$($JetstressPath)'"
    }

    return ($overallTestSuccessful -eq $true -and $achievedIOPSTarget -eq $true)
}

Export-ModuleMember -Function *-TargetResource
