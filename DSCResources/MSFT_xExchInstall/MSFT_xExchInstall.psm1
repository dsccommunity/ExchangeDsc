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
        $Credential
    )
    
    #Load helper module
    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Path" = $Path; "Arguments" = $Arguments} -VerbosePreference $VerbosePreference

    $returnValue = @{
        Path = $Path
        Arguments = $Arguments
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
        $Credential
    )

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Path" = $Path; "Arguments" = $Arguments} -VerbosePreference $VerbosePreference

    $installStatus = GetInstallStatus -Arguments $Arguments

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        #Check if WSMan needs to be configured, as it will require an immediate reboot
        $needReboot = CheckWSManConfig -AllowImmediateReboot $AllowImmediateReboot

        if ($needReboot -eq $true)
        {
            return
        }

        Write-Verbose "Initiating Exchange Setup. Command: $($Path) $($Arguments)"

        StartScheduledTask -Path "$($Path)" -Arguments "$($Arguments)" -Credential $Credential -TaskName "Install Exchange" -VerbosePreference $VerbosePreference

        $detectedExsetup = $false

        Write-Verbose "Waiting up to 60 seconds before exiting to give time for ExSetup.exe to start"

        for ($i = 0; $i -lt 60; $i++)
        {
            if ($null -eq (Get-Process -Name ExSetup -ErrorAction SilentlyContinue))
            {
                Start-Sleep -Seconds 1
            }
            else
            {
                Write-Verbose "Detected that ExSetup.exe is running"
                $detectedExsetup = $true
                break
            }
        }

        if ($detectedExsetup -eq $false)
        {
            throw "Waited 60 seconds, but was unable to detect that ExSetup.exe was started"
        }

        #Now wait for setup to finish
        while ($null -ne (Get-Process -Name ExSetup -ErrorAction SilentlyContinue))
        {
            Write-Verbose "Setup is still running at $([DateTime]::Now). Sleeping for 1 minute."
            Start-Sleep -Seconds 60
        }
    }
    else
    {
        if ($installStatus.SetupComplete)
        {
            Write-Verbose "Exchange setup has already successfully completed."
        }
        else
        {
            Write-Verbose "Exchange setup is already in progress."
        }         
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
        $Credential
    )

    Import-Module "$((Get-Item -LiteralPath "$($PSScriptRoot)").Parent.Parent.FullName)\Misc\xExchangeCommon.psm1" -Verbose:0

    LogFunctionEntry -Parameters @{"Path" = $Path; "Arguments" = $Arguments} -VerbosePreference $VerbosePreference

    $installStatus = GetInstallStatus -Arguments $Arguments

    if ($installStatus.ShouldStartInstall -eq $true)
    {
        if($installStatus.ShouldInstallLanguagePack -eq $true)
        {
            Write-Verbose "Language pack will be installed"
        }
        else
        {
            Write-Verbose "Exchange is either not installed, or a previous install only partially completed."
        }
    }
    else
    {
        if ($installStatus.SetupComplete)
        {
            Write-Verbose "Exchange setup has already successfully completed."
        }
        else
        {
            Write-Verbose "Exchange setup is already in progress."
        }
    }

    return (!($installStatus.ShouldStartInstall))
}

#Checks for the exact status of Exchange setup and returns the results in a Hashtable
function GetInstallStatus
{
    param
    (
        $Arguments
    )

    $shouldStartInstall = $false

    $shouldInstallLanguagePack = ShouldInstallLanguagePack -Arguments $Arguments
    $setupRunning = IsSetupRunning
    $setupComplete = IsSetupComplete
    $exchangePresent = IsExchangePresent
    $setupPartiallyComplete = IsSetupPartiallyCompleted

    if ($setupRunning -eq $true -or $setupComplete -eq $true)
    {
        if($shouldInstallLanguagePack -eq $true -and $setupComplete -eq $true)
        {
            $shouldStartInstall = $true
        }
        else
        {
            #Do nothing. Either Install is already running, or it's already finished successfully
        }
    }
    elseif ($exchangePresent -eq $false -or $setupPartiallyComplete -eq $true)
    {
        $shouldStartInstall = $true
    }

    $returnValue = @{
        ShouldInstallLanguagePack = $shouldInstallLanguagePack
        SetupRunning = $setupRunning
        SetupComplete = $setupComplete
        ExchangePresent = $exchangePresent
        SetupPartiallyComplete = $setupPartiallyComplete
        ShouldStartInstall = $shouldStartInstall
    }

    $returnValue
}

#Check for missing registry keys that may cause Exchange setup to try to restart WinRM mid setup , which will in turn cause the DSC resource to fail
#If any required keys are missing, configure WinRM, then force a reboot
function CheckWSManConfig
{
    $needReboot = $false

    $wsmanKey = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN" -ErrorAction SilentlyContinue

    if ($null -ne $wsmanKey)
    {
        if ($null -eq $wsmanKey.UpdatedConfig)
        {
            $needReboot = $true

            Write-Verbose "Value 'UpdatedConfig' missing from registry key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN. Running: winrm i restore winrm/config"

            Set-Location "$($env:windir)\System32\inetsrv"
            Invoke-Expression -Command "winrm i restore winrm/config" | Out-Null

            Write-Verbose "Machine needs to be rebooted before Exchange setup can proceed"

            $global:DSCMachineStatus = 1
        }
    }
    else
    {
        throw "Unable to find registry key: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN"
    }

    return $needReboot
}

function ShouldInstallLanguagePack
{
    param
    (
        [System.String]
        $Arguments
    )

    if($Arguments -match '(?<=/AddUMLanguagePack:)(([a-z]{2}-[A-Z]{2},?)+)(?=\s)')
    {
        $Cultures = $Matches[0]
        Write-Verbose "AddUMLanguagePack parameters detected: $Cultures"
        $Cultures = $Cultures -split ","

        foreach($Culture in $Cultures)
        {
            if((IsUMLanguagePackInstalled -Culture $Culture) -eq $false)
            {
                Write-Verbose "UM Language Pack: $Culture is not installed"
                return $true
            }
        }
    }
    return $false
}

Export-ModuleMember -Function *-TargetResource
