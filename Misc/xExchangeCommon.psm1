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
    if ($null -ne $Session)
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
    if ($null -eq $Session)
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

        if ($null -ne $Session)
        {
            $Session.Name = "DSCExchangeSession"
        }
    }
    
    #If the session is still null here, things went wrong. Throw exception
    if ($null -eq $Session)
    {
        throw "Failed to establish remote Powershell session to FQDN: $($serverFQDN)"
    }
    else #Import the session globally
    {
        #Temporarily set Verbose to SilentlyContinue so the Session and Module import isn't noisy
        $oldVerbose = $VerbosePreference
        $VerbosePreference = "SilentlyContinue"

        if ($null -ne $CommandsToLoad -and $CommandsToLoad.Count -gt 0)
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

    if ($null -ne $sessions)
    {
        Write-Verbose "Removing existing remote Powershell sessions"

        GetExistingExchangeSession | Remove-PSSession
    }
}

#Ensures that Exchange is installed, and that it is the correct version (2013 or 2016)
function VerifyServerVersion
{
    [CmdletBinding()]
    param($VerbosePreference)

    $unsupportedMsg = "A supported version of Exchange is either not present, or not fully installed on this machine."

    if ($Global:ServerVersionGood -eq $true)
    {
        #Do nothing
    }
    elseif ($Global:ServerVersionGood -eq $false)
    {
        throw $unsupportedMsg
    }
    else
    {
        $setupComplete = IsSetupComplete

        if ($setupComplete -eq $false)
        {
            $Global:ServerVersionGood = $false

            throw $unsupportedMsg
        }
        else
        {
            $Global:ServerVersionGood = $true
        }
    }
}

#Gets the WMI object corresponding to the Exchange Product
function GetExchangeProduct
{
    if ($null -eq $Global:CheckedExchangeProduct -or $Global:CheckedExchangeProduct -eq $false)
    {
        $Global:ExchangeProduct = Get-WmiObject -Class Win32_Product -Filter {Name = "Microsoft Exchange Server"}

        $Global:CheckedExchangeProduct = $true
    }

    return $Global:ExchangeProduct
}

#Checks whether a supported version of Exchange is at least partially installed by looking for Exchange's product GUID
function IsExchangePresent
{   
    $version = GetExchangeVersion

    if ($version -eq "2013" -or $version -eq "2016")
    {
        return $true
    }
    else
    {
        return $false
    }
}

#Gets the installed Exchange Version, and returns the number as a string.
#Returns N/A if the version cannot be found, and will optionally throw an exception
#if ThrowIfUnknownVersion was set to $true.
function GetExchangeVersion
{
    param ([bool]$ThrowIfUnknownVersion = $false)
    
    $version = "N/A"

    $product = GetExchangeProduct
    
    if ($null -ne $product)
    {
        if ($product.IdentifyingNumber -eq '{4934D1EA-BE46-48B1-8847-F1AF20E892C1}') #Exchange 2013
        {
            return "2013"
        }
        elseif($product.IdentifyingNumber -eq '{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}') #Exchange 2016
        {
            return "2016"
        }     
    }

    if ($version -eq "N/A" -and $ThrowIfUnknownVersion)
    {
        throw "Failed to discover a known Exchange Version"
    }
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

        if ($null -ne $values)
        {
            if ($null -ne $values.UnpackedVersion)
            {
                #If ConfiguredVersion is missing, or Action or Watermark or present, setup needs to be resumed
                if ($null -eq $values.ConfiguredVersion -or $null -ne $values.Action -or $null -ne $values.Watermark)
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

    return ($null -ne (Get-Process -Name $SetupProcessName -ErrorAction SilentlyContinue))
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
        if (!(($null -eq $Bool1 -and $Bool2 -eq $false) -or ($null -eq $Bool2 -and $Bool1 -eq $false)))
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

    if ($null -ne (Get-Command Get-Mailbox -ErrorAction SilentlyContinue))
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
    
    if ($null -ne $Array)
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

    if (($null -eq $Array1 -and $null -ne $Array2) -or ($null -ne $Array1 -and $null -eq $Array2) -or ($Array1.Length -ne $Array2.Length))
    {
        $hasSameContents = $false
    }
    elseif ($null -ne $Array1 -and $null -ne $Array2)
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

    if ($null -eq $Array1 -or $Array1.Length -eq 0) #Do nothing, as Array2 at a minimum contains nothing    
    {} 
    elseif ($null -eq $Array2 -or $Array2.Length -eq 0) #Array2 is empty and Array1 is not. Return false
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

    if ($null -ne $ParamsToKeep -and $ParamsToKeep.Count -gt 0)
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

    if ($null -ne $ParamsToRemove -and $ParamsToRemove.Count -gt 0)
    {
        foreach ($param in $ParamsToRemove)
        {
            $PSBoundParametersIn.Remove($param) | Out-Null
        }
    }
}

function RemoveVersionSpecificParameters
{
    param($PSBoundParametersIn, [string]$ParamName, [string]$ResourceName, [ValidateSet("2013","2016")][string]$ParamExistsInVersion)

    if ($PSBoundParameters.ContainsKey($ParamName))
    {
        $serverVersion = GetExchangeVersion

        if ($serverVersion -ne $ParamExistsInVersion)
        {
            Write-Warning "$($ParamName) is not a valid parameter for $($ResourceName) in Exchange $($serverVersion). Skipping usage."
            RemoveParameters -PSBoundParametersIn $PSBoundParameters -ParamsToRemove $ParamName
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
        if ($null -ne $PSBoundParametersIn[$key] -and $PSBoundParametersIn[$key].GetType().Name -eq "String" -and $PSBoundParametersIn[$key] -eq "")
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

    if ($null -ne $Parameters -and $Parameters.Count -gt 0)
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

    if ($null -ne $errRegister)
    {
        throw $errRegister[0]
    }
    elseif ($null -ne $task -and $task.State -eq "Ready")
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

    if ($null -ne $command -and $null -ne $command.Parameters)
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

    if ($null -ne $Global:error -and $Global:error.Count -gt 0)
    {
        $Global:previousError = $Global:error[0]
    }    
}

function ThrowIfNewErrorsEncountered
{
    [CmdletBinding()]
    param([string]$CmdletBeingRun, $VerbosePreference)

    #Throw an exception if errors were encountered
    if ($null -ne $Global:error -and $Global:error.Count -gt 0 -and $Global:previousError -ne $Global:error[0])
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

    if ($null -ne $state)
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
    if (($null -eq $IPAddress -and !([string]::IsNullOrEmpty($String))) -or ($null -ne $IPAddress -and [string]::IsNullOrEmpty($String)))
    {
        $returnValue = $false
    }
    elseif ($null -eq $IPAddress -and [string]::IsNullOrEmpty($String))
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
    if (($null -eq $SmtpAddress) -and ([string]::IsNullOrEmpty($String)))
    {
        Write-Verbose "Expected and actual value is empty, therefore equal!"
        return $true
    }
    elseif (($null -eq $SmtpAddress) -and -not ([string]::IsNullOrEmpty($String)))
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
