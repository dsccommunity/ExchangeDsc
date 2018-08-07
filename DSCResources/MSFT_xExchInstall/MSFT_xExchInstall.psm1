function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [System.String]
        $Arguments,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    LogFunctionEntry -Parameters @{
        'Path' = $Path
        'Arguments' = $Arguments
    } -Verbose:$VerbosePreference

    $returnValue = @{
        Path      = [System.String] $Path
        Arguments = [System.String] $Arguments
    }

    $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [System.String]
        $Arguments,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    LogFunctionEntry -Parameters @{"Path" = $Path; "Arguments" = $Arguments} -Verbose:$VerbosePreference

    $installStatus = Get-InstallStatus -Arguments $Arguments -Verbose:$VerbosePreference

    $waitingForSetup = $false

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        #Check if WSMan needs to be configured, as it will require an immediate reboot
        $needReboot = Set-WSManConfigStatus

        if ($needReboot -eq $true)
        {
            Write-Warning -Message 'Server needs a reboot before the installation of Exchange can begin.'
            return
        }

        Write-Verbose "Initiating Exchange Setup. Command: $($Path) $($Arguments)"

        StartScheduledTask -Path "$($Path)" -Arguments "$($Arguments)" -Credential $Credential -TaskName 'Install Exchange' -Verbose:$VerbosePreference

        $detectedExsetup = $false

        Write-Verbose -Message 'Waiting up to 60 seconds before exiting to give time for ExSetup.exe to start'

        for ($i = 0; $i -lt 60; $i++)
        {
            if ($null -eq (Get-Process -Name ExSetup -ErrorAction SilentlyContinue))
            {
                Start-Sleep -Seconds 1
            }
            else
            {
                Write-Verbose -Message 'Detected that ExSetup.exe is running'
                $detectedExsetup = $true
                break
            }
        }

        if ($detectedExsetup -eq $false)
        {
            throw 'Waited 60 seconds, but was unable to detect that ExSetup.exe was started'
        }

        $waitingForSetup = $true
    }
    elseif ($installStatus.SetupRunning)
    {
        Write-Verbose -Message 'Exchange setup is already in progress.'

        $waitingForSetup = $true
    }
    elseif ($installStatus.SetupComplete)
    {
        Write-Verbose -Message 'Exchange setup has already successfully completed.'
        return
    }

    if ($waitingForSetup)
    {
        #Now wait for setup to finish
        while ($null -ne (Get-Process -Name ExSetup -ErrorAction SilentlyContinue))
        {
            Write-Verbose "Setup is still running at $([DateTime]::Now). Sleeping for 1 minute."
            Start-Sleep -Seconds 60
        }
    }

    #Check install status one more time and see if setup was successful
    $installStatus = Get-InstallStatus -Arguments $Arguments -Verbose:$VerbosePreference

    if ($installStatus.SetupComplete)
    {
        Write-Verbose -Message 'Exchange setup completed successfully'
    }
    else
    {
        throw 'Exchange setup did not complete successfully. See "<system drive>\ExchangeSetupLogs\ExchangeSetup.log" for details.'
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory=$true)]
        [System.String]
        $Path,

        [Parameter(Mandatory=$true)]
        [System.String]
        $Arguments,

        [Parameter(Mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    LogFunctionEntry -Parameters @{"Path" = $Path; "Arguments" = $Arguments} -Verbose:$VerbosePreference

    $installStatus = Get-InstallStatus -Arguments $Arguments -Verbose:$VerbosePreference

    [System.Boolean]$shouldStartOrWaitForInstall = $false

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        if($installStatus.ShouldInstallLanguagePack -eq $true)
        {
            Write-Verbose -Message 'Language pack will be installed'
        }
        else
        {
            Write-Verbose -Message 'Exchange is either not installed, or a previous install only partially completed.'
        }

        $shouldStartOrWaitForInstall = $true
    }
    else
    {
        if ($installStatus.SetupComplete)
        {
            Write-Verbose -Message 'Exchange setup has already successfully completed.'
        }
        else
        {
            Write-Verbose -Message 'Exchange setup is already in progress.'

            $shouldStartOrWaitForInstall = $true
        }
    }

    return !$shouldStartOrWaitForInstall
}

Export-ModuleMember -Function *-TargetResource
