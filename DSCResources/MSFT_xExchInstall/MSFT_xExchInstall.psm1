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

    Write-FunctionEntry -Parameters @{
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

    Write-FunctionEntry -Parameters @{
        'Path'       = $Path
        'Arguments' = $Arguments
    } -Verbose:$VerbosePreference

    $installStatus = Get-ExchangeInstallStatus -Path $Path -Arguments $Arguments -Verbose:$VerbosePreference

    $waitingForSetup = $false

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        # Check if WSMan needs to be configured, as it will require an immediate reboot
        $needReboot = Set-WSManConfigStatus

        if ($needReboot -eq $true)
        {
            Write-Warning -Message 'Server needs a reboot before the installation of Exchange can begin.'
            return
        }

        Write-Verbose -Message "Initiating Exchange Setup. Command: $Path $Arguments"

        Start-ExchangeScheduledTask -Path "$Path" -Arguments "$Arguments" -Credential $Credential -TaskName 'Install Exchange' -Verbose:$VerbosePreference

        $detectedExsetup = Wait-ForProcessStart -ProcessName 'ExSetup' -Verbose:$VerbosePreference

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
        # Now wait for setup to finish
        Wait-ForProcessStop -ProcessName 'ExSetup' -Verbose:$VerbosePreference | Out-Null
    }

    Assert-ExchangeSetupArgumentsComplete -Path $Path -Arguments $Arguments -Verbose:$VerbosePreference
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

    Write-FunctionEntry -Parameters @{
        'Path'      = $Path
        'Arguments' = $Arguments
    } -Verbose:$VerbosePreference

    $installStatus = Get-ExchangeInstallStatus -Path $Path -Arguments $Arguments -Verbose:$VerbosePreference

    [System.Boolean] $shouldStartOrWaitForInstall = $false

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        if ($installStatus.ShouldInstallLanguagePack -eq $true)
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
