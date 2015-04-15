function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Performance","Stress","DatabaseBackup","SoftRecovery")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [System.UInt32]
        $MaxWaitMinutes = 4320
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath; "JetstressParams" = $JetstressParams} -VerbosePreference $VerbosePreference

    $returnValue = @{
        Type = $Type
        JetstressPath = $JetstressPath
        JetstressParams = $JetstressParams
        MaxWaitMinutes = $MaxWaitMinutes        
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Performance","Stress","DatabaseBackup","SoftRecovery")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [System.UInt32]
        $MaxWaitMinutes = 4320
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath; "JetstressParams" = $JetstressParams} -VerbosePreference $VerbosePreference

    $jetstressRunning = IsJetstressRunning
    $jetstressSuccessful = JetstressTestSuccessful @PSBoundParameters

    if ($jetstressSuccessful -eq $false -and (Get-ChildItem -LiteralPath "$($JetstressPath)" | where {$_.Name -like "$($Type)*.html"}) -ne $null)
    {
        throw "Jetstress was previously executed and resulted in a failed run. Clean up any $($Type)*.html files in the Jetstress install directory before trying to run this resource again."
    }

    if ($jetstressRunning -eq $false) #Jetstress isn't running. Kick it off
    {
        $initializingESE = $false

        #If the ESE counters haven't been registered for Perfmon, Jetstress is going to need to initialize ESE and restart the process.
        if ((Test-Path -LiteralPath "$($env:SystemRoot)\Inf\ESE\eseperf.ini") -eq $false)
        {
            $initializingESE = $true
        }

        #Create and start the Jetstress scheduled task
        StartJetstress @PSBoundParameters

        #Give an additional 60 seconds if ESE counters were just initialized.
        if ($initializingESE -eq $true)
        {
            Write-Verbose "Jetstress has never initialized performance counters for ESE. Waiting a full 60 seconds for this to occurr"
            Start-Sleep -Seconds 60

            $jetstressRunning = IsJetstressRunning

            #I've found that Jetstress doesn't always restart after loading ESE when running as local system in a scheduled task in the background
            #If Jetstress isn't running at this point, but the perf counters were registered, try to start Jetstress one more time just to make sure this didn't happen.
            if ($jetstressRunning -eq $false)
            {
                if ((Test-Path -LiteralPath "$($env:SystemRoot)\Inf\ESE\eseperf.ini") -eq $true)
                {
                    Write-Verbose "ESE performance counters were registered, but JetstressCmd.exe is not currently running. Attempting to start it one more time"

                    StartJetstress @PSBoundParameters
                }
                else
                {
                    throw "Jetstress failed to register MSExchange Database performance counters"
                }
            }
        }
        else
        {
            $jetstressRunning = IsJetstressRunning
        }

        #Wait up to a minute for Jetstress to start. If it hasn't started by then, something went wrong
        $checkMaxTime = [DateTime]::Now.AddMinutes(1)

        while ($jetstressRunning -eq $false -and $checkMaxTime -gt [DateTime]::Now)
        {
            $jetstressRunning = IsJetstressRunning

            if ($jetstressRunning -eq $false)
            {
                Start-Sleep -Seconds 1
            }
        }

        if ($jetstressRunning -eq $false)
        {
            throw "Waited 60 seconds after launching the Jetstress scheduled task, but failed to detect that JetstressCmd.exe is running"
        }
    }

    #If we made it here, Jetstress is running. Wait for it to complete for $MaxWaitMinutes minutes
    $checkMaxTime = [DateTime]::Now.AddMinutes($MaxWaitMinutes)

    while ($jetstressRunning -eq $true -and $checkMaxTime -gt [DateTime]::Now)
    {
        Write-Verbose "Jetstress is still running at '$([DateTime]::Now)'."

        #Wait for 5 minutes before logging to the screen again, but actually check every 5 seconds whether Jetstress has completed.
        for ($i = 0; $i -lt 300 -and $jetstressRunning -eq $true; $i += 5)
        {
            $jetstressRunning = IsJetstressRunning

            if ($jetstressRunning -eq $true)
            {
                Start-Sleep -Seconds 5
            }
        }
    }

    #Check the final status on the Jetstress run
    if ($jetstressRunning -eq $false)
    {
        Write-Verbose "Jetstress testing finished at '$([DateTime]::Now)'."

        $testSuccessful = JetstressTestSuccessful @PSBoundParameters

        if ($testSuccessful -eq $false)
        {
            throw "Jetstress finished running, but the test did not complete successfully"
        }
        else
        {
            Write-Verbose "Jetstress finished, and the configured test passed"
        }
    }
    else
    {
        throw "Jetstress is still running after waiting $($MaxWaitMinutes) minutes"
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Performance","Stress","DatabaseBackup","SoftRecovery")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [System.UInt32]
        $MaxWaitMinutes = 4320
    )

    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"JetstressPath" = $JetstressPath; "JetstressParams" = $JetstressParams} -VerbosePreference $VerbosePreference

    $jetstressRunning = IsJetstressRunning -MaximumWaitSeconds 1

    if ($jetstressRunning -eq $true)
    {
        return $false
    }
    else
    {
        $jetstressSuccessful = JetstressTestSuccessful @PSBoundParameters

        return $jetstressSuccessful
    }
}

#Checks whether the JetstressCmd.exe process is currently running
function IsJetstressRunning
{
    $process = Get-Process -Name JetstressCmd -ErrorAction SilentlyContinue

    return ($process -ne $null)
}

#Used to create a scheduled task which will initiate the Jetstress run
function StartJetstress
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Performance","Stress","DatabaseBackup","SoftRecovery")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [System.UInt32]
        $MaxWaitMinutes = 4320
    )

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    $fullPath = Join-Path -Path "$($JetstressPath)" -ChildPath "JetstressCmd.exe"

    StartScheduledTask -Path "$($fullPath)" -Arguments "$($JetstressParams)" -WorkingDirectory "$($JetstressPath)" -TaskName "Jetstress" -VerbosePreference $VerbosePreference
}

#Looks in the latest Type*.html file to determine whether the last Jetstress run passed
function JetstressTestSuccessful
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [ValidateSet("Performance","Stress","DatabaseBackup","SoftRecovery")]
        [System.String]
        $Type,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressPath,

        [parameter(Mandatory = $true)]
        [System.String]
        $JetstressParams,

        [System.UInt32]
        $MaxWaitMinutes = 4320
    )

    $testSuccessful = $false

    $outputFiles = Get-ChildItem -LiteralPath "$($JetstressPath)" | where {$_.Name -like "$($Type)*.html"}

    if ($outputFiles -ne $null -and $outputFiles.Count -ge 1)
    {
        $outputFiles = $outputFiles | Sort-Object -Property LastWriteTime -Descending

        $latest = $outputFiles[0]

        $content = Get-Content -LiteralPath "$($latest.FullName)"

        $foundResults = $false

        for ($i = 0; $i -lt $content.Length -and $foundResults -eq $false; $i++)
        {
            if ($content[$i].Contains("<td class=`"grid_row_header`">Overall Test Result</td>"))
            {
                $resultStart = $content[$i + 1].IndexOf('>') + 1
                $resultEnd = $content[$i + 1].LastIndexOf('<')

                $result = $content[$i + 1].Substring($resultStart, $resultEnd - $resultStart)

                $foundResults = $true
                
                Write-Verbose "File $($latest.FullName)'' has an 'Overall Test Result' of '$($result)'"

                if ($result -like "Pass")
                {
                    $testSuccessful = $true
                }
            }
        }

        if ($foundResults -eq $false)
        {
            Write-Verbose "Unable to find 'Overall Test Result' in file '$($latest.FullName)'"
        }
    }
    else
    {
        Write-Verbose "Unable to find any files matching '$($Type)*.html' in folder '$($JetstressPath)'"
    }

    return $testSuccessful
}

Export-ModuleMember -Function *-TargetResource



