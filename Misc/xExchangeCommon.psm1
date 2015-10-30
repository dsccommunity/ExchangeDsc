#Gets the existing Remote PowerShell session to Exchange, if it exists
function GetExistingExchangeSession
{
    return (Get-PSSession -Name "DSCExchangeSession" -ErrorAction SilentlyContinue)
}

#Establishes a Exchange remote powershell session to the local server. Reuses the session if it already exists.
function GetRemoteExchangeSession
{
    [CmdletBinding()]
    param([PSCredential]$Credential, [string[]]$CommandsToLoad, $VerbosePreference, $SetupProcessName = "ExSetup*")

    #Check if Exchange Setup is running. If so, we need to throw an exception, as a running Exchange DSC resource will block Exchange Setup from working properly.
    if (IsSetupRunning -SetupProcessName $SetupProcessName)
    {
        throw "Exchange Setup is currently running. Preventing creation of new Remote PowerShell session to Exchange."
    }

    #See if the session already exists
    $Session = GetExistingExchangeSession

    #Attempt to reuse the session if we found one
    if ($Session -ne $null)
    {
        if ($Session.State -eq "Opened")
        {
            Write-Verbose "Reusing existing Remote Powershell Session to Exchange"
        }
        else #Session is in an unexpected state. Remove it so we can rebuild it
        {
            RemoveExistingRemoteSession
            $Session = $null
        }
    }

    #Either the session didn't exist, or it was broken and we nulled it out. Create a new one
    if ($Session -eq $null)
    {
        #First make sure we are on a valid server version, and that Exchange is fully installed
        VerifyServerVersion -VerbosePreference $VerbosePreference

        Write-Verbose "Creating new Remote Powershell session to Exchange"

        #Get local server FQDN
        $machineDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain.ToLower()
        $serverName = $env:computername.ToLower()
        $serverFQDN = $serverName + "." + $machineDomain

        #Override chatty banner, because chatty
        New-Alias Get-ExBanner Out-Null
        New-Alias Get-Tip Out-Null

        #Load built in Exchange functions, and create session
        $exbin = Join-Path -Path ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup).MsiInstallPath) -ChildPath "bin"
        $remoteExchange = Join-Path -Path "$($exbin)" -ChildPath "RemoteExchange.ps1"
        . $remoteExchange
        $Session = _NewExchangeRunspace -fqdn $serverFQDN -credential $Credential -UseWIA $false -AllowRedirection $false
        
        #Remove the aliases we created earlier
        Remove-Item Alias:Get-ExBanner
        Remove-Item Alias:Get-Tip

        if ($Session -ne $null)
        {
            $Session.Name = "DSCExchangeSession"
        }
    }
    
    #If the session is still null here, things went wrong. Throw exception
    if ($Session -eq $null)
    {
        throw "Failed to establish remote Powershell session to FQDN: $($serverFQDN)"
    }
    else #Import the session globally
    {
        #Temporarily set Verbose to SilentlyContinue so the Session and Module import isn't noisy
        $oldVerbose = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"

        if ($CommandsToLoad -ne $null -and $CommandsToLoad.Count -gt 0)
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -CommandName $CommandsToLoad -Verbose:0
        }
        else
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -Verbose:0
        }

        Import-Module $moduleInfo -Global -DisableNameChecking

        #Set Verbose back
        $VerbosePreference = $oldVerbose
    }   
}

#Removes any Remote Sessions that have been setup by us
function RemoveExistingRemoteSession
{
    [CmdletBinding()]
    param($VerbosePreference)

    $sessions = GetExistingExchangeSession

    if ($sessions -ne $null)
    {
        Write-Verbose "Removing existing remote Powershell sessions"

        GetExistingExchangeSession | Remove-PSSession
    }
}

#Ensures that Exchange is installed, and that it is the correct version (2013)
function VerifyServerVersion
{
    [CmdletBinding()]
    param($VerbosePreference)

    if ($global:alreadyConfirmedServerVersion -eq $true)
    {
        return
    }
    else
    {
        #First check for the presence of Exchange 2013 specific setup reg keys
        $key = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup -ErrorAction SilentlyContinue

        if ($key -eq $null)
        {
            throw "Exchange is not installed on this machine"
        }
        else
        {
            $version = $key.MsiProductMajor

            if ($version -ne 15)
            {
                throw "Server running an unsupported version of Exchange. Major version must be 15. Major version detected as $($key.MsiProductMajor)."
            }
        }

        #Check if setup is partially completed.
        $setupPartiallyComplete = IsSetupPartiallyCompleted

        if ($setupPartiallyComplete -eq $true)
        {
            $setupRunning = IsSetupRunning

            if ($setupRunning -eq $true)
            {
                throw "Exchange setup is currently running. Wait for setup to complete before running this xExchange resource."
            }
            else
            {
                throw "Exchange setup is in a partially completed state, but setup is not currently running. You must successfully finish Exchange setup before running this xExchange resource."
            }
        }

        #If we made it here, everything is good. No need to check again in the future
        $global:alreadyConfirmedServerVersion = $true
    }
}

#Checks whether Exchange is at least partially installed by looking for Exchange 2013's product GUID
function IsExchangePresent
{
    return ((Get-WmiObject -Class Win32_Product -Filter "IdentifyingNumber = '{4934D1EA-BE46-48B1-8847-F1AF20E892C1}'") -ne $null)
}

#Checks whether Setup fully completed
function IsSetupComplete
{
    $exchangePresent = IsExchangePresent
    $setupPartiallyCompleted = IsSetupPartiallyCompleted

    if ($exchangePresent -eq $true -and $setupPartiallyCompleted -eq $false)
    {
        $isSetupComplete = $true
    }
    else
    {
        $isSetupComplete = $false
    }

    return $isSetupComplete
}

#Returns a hashtable containing properties showing the exact status of Exchange setup.
function GetExchangeInstallStatus
{
    $shouldStartInstall = $false

    $setupRunning = IsSetupRunning
    $setupComplete = IsSetupComplete
    $exchangePresent = IsExchangePresent
    $setupPartiallyComplete = IsSetupPartiallyCompleted

    if ($setupRunning -eq $true -or $setupComplete -eq $true)
    {
        #Do nothing. Either Install is already running, or it's already finished successfully
    }
    elseif ($exchangePresent -eq $false -or $setupPartiallyComplete -eq $true)
    {
        $shouldStartInstall = $true
    }

    $returnValue = @{
        Path = $Path
        Arguments = $Arguments
        SetupRunning = $setupRunning
        SetupComplete = $setupComplete
        ExchangePresent = $exchangePresent
        SetupPartiallyComplete = $setupPartiallyComplete
        ShouldStartInstall = $shouldStartInstall
    }

    return $returnValue
}

#If Verbose is specified, outputs the install status from GetExchangeInstallStatus to the screen
function ReportInstallStatus
{
    [CmdletBinding()]
    param([Hashtable]$InstallStatus, $VerbosePreference)

    if ($InstallStatus.ShouldStartInstall -eq $true)
    {
        Write-Verbose "Exchange is either not installed, or a previous install only partially completed."
    }
    else
    {
        if ($InstallStatus.SetupComplete)
        {
            Write-Verbose "Exchange setup has already successfully completed."
        }
        else
        {
            Write-Verbose "Exchange setup is already in progress."
        }
    }
}

#Checks whether any Setup watermark keys exist which means that a previous installation of setup had already started but not completed
function IsSetupPartiallyCompleted
{
    $isPartiallyCompleted = $false

    #Now check if setup actually completed successfully
    [string[]]$roleKeys = "CafeRole","ClientAccessRole","FrontendTransportRole","HubTransportRole","MailboxRole","UnifiedMessagingRole"

    foreach ($key in $roleKeys)
    {
        $values = $null
        $values = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$($key)" -ErrorAction SilentlyContinue

        if ($values -ne $null)
        {
            if ($values.UnpackedVersion -ne $null)
            {
                #If ConfiguredVersion is missing, or Action or Watermark or present, setup needs to be resumed
                if ($values.ConfiguredVersion -eq $null -or $values.Action -ne $null -or $values.Watermark -ne $null)
                {
                    $isPartiallyCompleted = $true
                    break
                }
            }
        }
    }
    
    return $isPartiallyCompleted
}

#Checks whether setup is running by looking for if the ExSetup.exe process currently exists
function IsSetupRunning
{
    param([string]$SetupProcessName = "ExSetup*")

    return ((Get-Process -Name $SetupProcessName -ErrorAction SilentlyContinue) -ne $null)
}

#Checks if two strings are equal, or are both either null or empty
function CompareStrings
{
    param([string]$String1, [string]$String2, [switch]$IgnoreCase)

    if (([string]::IsNullOrEmpty($String1) -and [string]::IsNullOrEmpty($String2)))
    {
        return $true
    }
    else
    {
        if ($IgnoreCase -eq $true)
        {
            return ($String1 -like $String2)
        }
        else
        {
            return ($String1 -clike $String2)
        }
    }
}

#Checks if two bools are equal, or are both either null or false
function CompareBools($Bool1, $Bool2)
{
    if($Bool1 -ne $Bool2)
    {
        if (!(($Bool1 -eq $null -and $Bool2 -eq $false) -or ($Bool2 -eq $null -and $Bool1 -eq $false)))
        {
            return $false
        }
    }

    return $true
}

#Takes a string which should be in timespan format, and compares it to an actual EnhancedTimeSpan object. Returns true if they are equal
function CompareTimespanWithString
{
    param([Microsoft.Exchange.Data.EnhancedTimeSpan]$TimeSpan, [string]$String)

    try
    {
        $converted = [Microsoft.Exchange.Data.EnhancedTimeSpan]::Parse($String)

        return ($TimeSpan.Equals($converted))
    }
    catch
    {
        throw "String '$($String)' is not in a valid format for an EnhancedTimeSpan"
    }

    return $false
}

#Takes a string which should be in ByteQuantifiedSize format, and compares it to an actual ByteQuantifiedSize object. Returns true if they are equal
function CompareByteQuantifiedSizeWithString
{
    param([Microsoft.Exchange.Data.ByteQuantifiedSize]$ByteQuantifiedSize, [string]$String)

    try
    {
        $converted = [Microsoft.Exchange.Data.ByteQuantifiedSize]::Parse($String)

        return ($ByteQuantifiedSize.Equals($converted))
    }
    catch
    {
        throw "String '$($String)' is not in a valid format for a ByteQuantifiedSize"
    }
}

#Takes a string which should be in Microsoft.Exchange.Data.Unlimited format, and compares with an actual Unlimited object. Returns true if they are equal.
function CompareUnlimitedWithString
{
    param($Unlimited, [string]$String)

    if ($Unlimited.IsUnlimited)
    {
        return (CompareStrings -String1 "Unlimited" -String2 $String -IgnoreCase)
    }
    elseif ($Unlimited.Value.GetType() -ne [Microsoft.Exchange.Data.ByteQuantifiedSize])
    {
        return (CompareStrings -String1 $Unlimited -String2 $String -IgnoreCase)
    }
    else
    {
        return (CompareByteQuantifiedSizeWithString -ByteQuantifiedSize $Unlimited -String $String)
    }
}

#Takes an ADObjectId, gets a mailbox from it, and checks if it's EmailAddresses property contains the given string.
#The Get-Mailbox cmdlet must be loaded for this function to succeed.
function CompareADObjectIdWithEmailAddressString
{
    param([Microsoft.Exchange.Data.Directory.ADObjectId]$ADObjectId, [string]$String)

    if ((Get-Command Get-Mailbox -ErrorAction SilentlyContinue) -ne $null)
    {
        $mailbox = $ADObjectId | Get-Mailbox -ErrorAction SilentlyContinue

        return ($mailbox.EmailAddresses.Contains($String))
    }
    else
    {
        Write-Error "CompareADObjectIdWithEmailAddressString requires the Get-Mailbox cmdlert"

        return $false
    }  
}

#Takes a string containing a given separator, and breaks it into a string array
function StringToArray
{
    param([string]$StringIn, [char]$Separator)

    [string[]]$array = $StringIn.Split($Separator)

    for ($i = 0; $i -lt $array.Length; $i++)
    {
        $array[$i] = $array[$i].Trim()
    }

    return $array
}

#Takes an array of strings and converts all elements to lowercase
function StringArrayToLower
{
    param([string[]]$Array)
    
    if ($Array -ne $null)
    {
        for ($i = 0; $i -lt $Array.Count; $i++)
        {
            if (!([string]::IsNullOrEmpty($Array[$i])))
            {
                $Array[$i] = $Array[$i].ToLower()
            }
        }
    }

    return $Array
}

#Checks whether two arrays have the same contents, where element order doesn't matter
function CompareArrayContents
{
    param([string[]]$Array1, [string[]]$Array2, [switch]$IgnoreCase)

    $hasSameContents = $true

    if (($Array1 -eq $null -and $Array2 -ne $null) -or ($Array1 -ne $null -and $Array2 -eq $null) -or ($Array1.Length -ne $Array2.Length))
    {
        $hasSameContents = $false
    }
    elseif ($Array1 -ne $null -and $Array2 -ne $null)
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = StringArrayToLower -Array $Array1
            $Array2 = StringArrayToLower -Array $Array2
        }

        foreach ($str in $Array1)
        {
            if (!($Array2.Contains($str)))
            {
                $hasSameContents = $false
                break
            }
        }
    }

    return $hasSameContents
}

#Checks whether Array2 contains all elements of Array1 (Array2 may be larger than Array1)
function Array2ContainsArray1Contents
{
    param([string[]]$Array1, [string[]]$Array2, [switch]$IgnoreCase)

    $hasContents = $true

    if ($Array1 -eq $null -or $Array1.Length -eq 0) #Do nothing, as Array2 at a minimum contains nothing    
    {} 
    elseif ($Array2 -eq $null -or $Array2.Length -eq 0) #Array2 is empty and Array1 is not. Return false
    {
        $hasContents = $false
    }
    else
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = StringArrayToLower -Array $Array1
            $Array2 = StringArrayToLower -Array $Array2
        }

        foreach ($str in $Array1)
        {
            if (!($Array2.Contains($str)))
            {
                $hasContents = $false
                break
            }
        }
    }

    return $hasContents
}

#Takes $PSBoundParameters from another function and adds in the keys and values from the given Hashtable
function AddParameters
{
    param($PSBoundParametersIn, [Hashtable]$ParamsToAdd)

    foreach ($key in $ParamsToAdd.Keys)
    {
        if (!($PSBoundParametersIn.ContainsKey($key))) #Key doesn't exist, so add it with value
        {
            $PSBoundParametersIn.Add($key, $ParamsToAdd[$key]) | Out-Null
        }
        else #Key already exists, so just replace the value
        {
            $PSBoundParametersIn[$key] = $ParamsToAdd[$key]
        }
    }
}

#Takes $PSBoundParameters from another function. If ParamsToRemove is specified, it will remove each param.
#If ParamsToKeep is specified, everything but those params will be removed. If both ParamsToRemove and ParamsToKeep
#are specified, only ParamsToKeep will be used.
function RemoveParameters
{
    param($PSBoundParametersIn, [string[]]$ParamsToKeep, [string[]]$ParamsToRemove)

    if ($ParamsToKeep -ne $null -and $ParamsToKeep.Count -gt 0)
    {
        [string[]]$ParamsToRemove = @()

        $lowerParamsToKeep = StringArrayToLower -Array $ParamsToKeep

        foreach ($key in $PSBoundParametersIn.Keys)
        {
            if (!($lowerParamsToKeep.Contains($key.ToLower())))
            {
                $ParamsToRemove += $key
            }
        }
    }

    if ($ParamsToRemove -ne $null -and $ParamsToRemove.Count -gt 0)
    {
        foreach ($param in $ParamsToRemove)
        {
            $PSBoundParametersIn.Remove($param) | Out-Null
        }
    }
}

function SetEmptyStringParamsToNull
{
    param($PSBoundParametersIn)

    [string[]] $emptyStringKeys = @()

    #First find all parameters that are a string, and are an empty string ("")
    foreach ($key in $PSBoundParametersIn.Keys)
    {
        if ($PSBoundParametersIn[$key] -ne $null -and $PSBoundParametersIn[$key].GetType().Name -eq "String" -and $PSBoundParametersIn[$key] -eq "")
        {
            $emptyStringKeys += $key
        }
    }

    #Now that we have the keys, set their values to null
    foreach ($key in $emptyStringKeys)
    {
        $PSBoundParametersIn[$key] = $null
    }
}

function VerifySetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([string]$Name, [string]$Type, $ExpectedValue, $ActualValue, $PSBoundParametersIn, $VerbosePreference)

    $returnValue = $true

    if ($PSBoundParametersIn.ContainsKey($Name))
    {
        if ($Type -like "String")
        {
            if ((CompareStrings -String1 $ExpectedValue -String2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Boolean")
        {
            if ((CompareBools -Bool1 $ExpectedValue -Bool2 $ActualValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Array")
        {
            if ((CompareArrayContents -Array1 $ExpectedValue -Array2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Int")
        {
            if ($ExpectedValue -ne $ActualValue)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Unlimited")
        {
            if ((CompareUnlimitedWithString -Unlimited $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "Timespan")
        {
            if ((CompareTimespanWithString -TimeSpan $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "ADObjectID")
        {
            if ((CompareADObjectIdWithEmailAddressString -ADObjectId $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "ByteQuantifiedSize")
        {
            if ((CompareByteQuantifiedSizeWithString -ByteQuantifiedSize $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "IPAddress")
        {
            if ((CompareIPAddresseWithString -IPAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "IPAddresses")
        {
            if ((CompareIPAddressesWithArray -IPAddresses $ActualValue -Array $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like "SMTPAddress")
        {
            if ((CompareSmtpAdressWithString -SmtpAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        else
        {
            throw "Type not found: $($Type)"
        }
    }

    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $Name -ExpectedValue $ExpectedValue -ActualValue $ActualValue -VerbosePreference $VerbosePreference
    }

    return $returnValue
}

function ReportBadSetting
{
    param($SettingName, $ExpectedValue, $ActualValue, $VerbosePreference)

    Write-Verbose "Invalid setting '$($SettingName)'. Expected value: '$($ExpectedValue)'. Actual value: '$($ActualValue)'"
}

function LogFunctionEntry
{
    param([Hashtable]$Parameters, $VerbosePreference)

    $callingFunction = (Get-PSCallStack)[1].FunctionName

    if ($Parameters -ne $null -and $Parameters.Count -gt 0)
    {
        $parametersString = ""

        foreach ($key in $Parameters.Keys)
        {
            $value = $Parameters[$key]

            if ($parametersString -ne "")
            {
                $parametersString += ", "
            }

            $parametersString += "$($key) = '$($value)'"
        }    

        Write-Verbose "Entering function '$($callingFunction)'. Notable parameters: $($parametersString)"
    }
    else
    {
        Write-Verbose "Entering function '$($callingFunction)'."
    }
}

function StartScheduledTask
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [System.String]
        $Arguments,

        [System.Management.Automation.PSCredential]
        $Credential,

        [System.String]
        $TaskName,

        [System.String]
        $WorkingDirectory,

        [System.UInt32]
        $MaxWaitMinutes = 0,

        [System.UInt32]
        $TaskPriority = 4,

        $VerbosePreference
    )

    $tName = "$([guid]::NewGuid().ToString())"

    if ($PSBoundParameters.ContainsKey("TaskName"))
    {
        $tName = "$($TaskName) $($tName)"
    }

    $action = New-ScheduledTaskAction -Execute "$($Path)" -Argument "$($Arguments)"
    
    if ($PSBoundParameters.ContainsKey("WorkingDirectory"))
    {
        $action.WorkingDirectory = $WorkingDirectory
    }

    Write-Verbose "Created Scheduled Task with name: $($tName)"
    Write-Verbose "Task Action: $($Path) $($Arguments)"

    #Use 'NT AUTHORITY\SYSTEM' as the run as account unless a specific Credential was provided
    $credParams = @{User = "NT AUTHORITY\SYSTEM"}

    if ($PSBoundParameters.ContainsKey("Credential"))
    {
        $credParams["User"] = $Credential.UserName
        $credParams.Add("Password", $Credential.GetNetworkCredential().Password)
    }

    $task = Register-ScheduledTask @credParams -TaskName "$($tName)" -Action $action -RunLevel Highest -ErrorVariable errRegister -ErrorAction SilentlyContinue

    if ($errRegister -ne $null)
    {
        throw $errRegister[0]
    }
    elseif ($task -ne $null -and $task.State -eq "Ready")
    {
        #Set a time limit on the task
        $taskSettings = $task.Settings
        $taskSettings.ExecutionTimeLimit = "PT$($MaxWaitMinutes)M"
        $taskSettings.Priority = $TaskPriority
        Set-ScheduledTask @credParams -TaskName "$($task.TaskName)" -Settings $taskSettings

        Write-Verbose "Starting task at: $([DateTime]::Now)"

        $task | Start-ScheduledTask
    }
    else
    {
        throw "Failed to register Scheduled Task"
    }
}

function CheckForCmdletParameter
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([string]$CmdletName, [string]$ParameterName)

    [bool]$hasParameter = $false

    $command = Get-Command -Name "$($CmdletName)" -ErrorAction SilentlyContinue

    if ($command -ne $null -and $command.Parameters -ne $null)
    {
        if ($command.Parameters.ContainsKey($ParameterName))
        {
            $hasParameter = $true
        }
    }

    return $hasParameter
}

function NotePreviousError
{
    $Global:previousError = $null

    if ($Global:error -ne $null -and $Global:error.Count -gt 0)
    {
        $Global:previousError = $Global:error[0]
    }    
}

function ThrowIfNewErrorsEncountered
{
    [CmdletBinding()]
    param([string]$CmdletBeingRun, $VerbosePreference)

    #Throw an exception if errors were encountered
    if ($Global:error -ne $null -and $Global:error.Count -gt 0 -and $Global:previousError -ne $Global:error[0])
    {
        [string]$errorMsg = "Failed to run $($CmdletBeingRun) with: " + $Global:error[0]
        Write-Error $errorMsg
        throw $errorMsg
    }
}

function RestartAppPoolIfExists
{
    [CmdletBinding()]
    param([string]$Name)

    $state = Get-WebAppPoolState -Name $Name -ErrorAction SilentlyContinue

    if ($state -ne $null)
    {
        Restart-WebAppPool -Name $Name
    }
    else
    {
        Write-Verbose "Application pool with name '$($Name)' does not exist. Skipping application pool restart."
    }
}

#Checks if the UM language pack for the specified culture is installed
function IsUMLanguagePackInstalled
{
    Param
    (
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Culture
    )

    return [bool](Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\UnifiedMessagingRole\LanguagePacks').$Culture
}

#Compares a single IPAddress with a string
function CompareIPAddresseWithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param([System.Net.IPAddress]$IPAddress, [String]$String)
    if (($IPAddress -eq $null -and !([string]::IsNullOrEmpty($String))) -or ($IPAddress -ne $null -and [string]::IsNullOrEmpty($String)))
    {
        $returnValue = $false
    }
    elseif ($IPAddress -eq $null -and [string]::IsNullOrEmpty($String))
    {
        $returnValue = $true
    }
    else
    {
        $returnValue =($IPAddress.Equals([System.Net.IPAddress]::Parse($string)))
    }
    
    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $IPAddress -ExpectedValue $ExpectedValue -ActualValue $IPAddress -VerbosePreference $VerbosePreference
    }
    return $returnValue
}

#Compares a SMTP address with a string
function CompareSmtpAdressWithString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param($SmtpAddress,[String]$String)
    if (($SmtpAddress -eq $null) -and ([string]::IsNullOrEmpty($String)))
    {
        Write-Verbose "Expected and actual value is empty, therefore equal!"
        return $true
    }
    elseif (($SmtpAddress -eq $null) -and -not ([string]::IsNullOrEmpty($String)))
    {
        return $false
    }
    elseif ($SmtpAddress.Gettype() -eq [Microsoft.Exchange.Data.SmtpAddress])
    {
        if ([string]::IsNullOrEmpty($String))
        {
            return $false
        }
        else
        {
            return($SmtpAddress.Equals([Microsoft.Exchange.Data.SmtpAddress]::Parse($string)))
        }
    }
    else
    {
        Write-Verbose "No type of [Microsoft.Exchange.Data.SmtpAddress]!"
        return $false
    }
}

#Compares IPAddresses with an array
function CompareIPAddressesWithArray
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param($IPAddresses, [Array]$Array)
    if (([string]::IsNullOrEmpty($IPAddresses)) -and ([string]::IsNullOrEmpty($Array)))
    {
        $returnValue = $true
    }
    elseif ((([string]::IsNullOrEmpty($IPAddresses)) -and !(([string]::IsNullOrEmpty($Array)))) -or (!(([string]::IsNullOrEmpty($IPAddresses))) -and ([string]::IsNullOrEmpty($Array))))
    {
        $returnValue = $false
    }
    else
    {
        CompareArrayContents -Array1 $IPAddresses -Array2 $Array
    }
    if ($returnValue -eq $false)
    {
        ReportBadSetting -SettingName $IPAddresses -ExpectedValue $ExpectedValue -ActualValue $IPAddress -VerbosePreference $VerbosePreference
    }
    return $returnValue
}

Export-ModuleMember -Function *