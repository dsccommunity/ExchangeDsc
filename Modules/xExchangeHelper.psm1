<#
    .SYNOPSIS
        Gets the existing Remote PowerShell session to Exchange, if it exists
#>
function Get-ExistingRemoteExchangeSession
{
    [CmdletBinding()]
    param ()

    return (Get-PSSession -Name 'DSCExchangeSession' -ErrorAction SilentlyContinue)
}

<#
    .SYNOPSIS
        Establishes an Exchange remote PowerShell session to the local server.
        Reuses the session if it already exists.

    .PARAMETER Credential
        The Credentials to use when creating a remote PowerShell session to
        Exchange.

    .PARAMETER CommandsToLoad
        A list of the cmdlets that should be imported in the remote PowerShell
        session.

    .PARAMETER SetupProcessName
        The name of the primary Exchange Setup process. If this process is
        detected by this function, an exception will be thrown.
#>
function Get-RemoteExchangeSession
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String[]]
        $CommandsToLoad,

        [Parameter()]
        [System.String]
        $SetupProcessName = 'ExSetup*'
    )

    # Check if Exchange Setup is running. If so, we need to throw an exception, as a running Exchange DSC resource will block Exchange Setup from working properly.
    if (Test-ExchangeSetupRunning -SetupProcessName $SetupProcessName)
    {
        throw 'Exchange Setup is currently running. Preventing creation of new Remote PowerShell session to Exchange.'
    }

    # See if the session already exists
    $Session = Get-ExistingRemoteExchangeSession

    # Attempt to reuse the session if we found one
    if ($null -ne $Session)
    {
        if ($Session.State -eq 'Opened')
        {
            Write-Verbose -Message 'Reusing existing Remote Powershell Session to Exchange'
        }
        else # Session is in an unexpected state. Remove it so we can rebuild it
        {
            Remove-RemoteExchangeSession
            $Session = $null
        }
    }

    # Either the session didn't exist, or it was broken and we nulled it out. Create a new one
    if ($null -eq $Session)
    {
        # First make sure we are on a valid server version, and that Exchange is fully installed
        if (!(Test-ExchangeSetupComplete -Verbose:$VerbosePreference))
        {
            throw 'A supported version of Exchange is either not present, or not fully installed on this machine.'
        }

        Write-Verbose -Message 'Creating new Remote Powershell session to Exchange'

        # Get local server FQDN
        $machineDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain.ToLower()
        $serverName = $env:computername.ToLower()
        $serverFQDN = $serverName + "." + $machineDomain

        # Override chatty banner, because chatty
        New-Alias Get-ExBanner Out-Null
        New-Alias Get-Tip Out-Null

        # Load built in Exchange functions, and create session
        $exbin = Join-Path -Path ((Get-ItemProperty HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\Setup).MsiInstallPath) -ChildPath "bin"
        $remoteExchange = Join-Path -Path "$exbin" -ChildPath 'RemoteExchange.ps1'
        . $remoteExchange
        $Session = _NewExchangeRunspace -fqdn $serverFQDN -credential $Credential -UseWIA $false -AllowRedirection $false

        # Remove the aliases we created earlier
        Remove-Item Alias:Get-ExBanner
        Remove-Item Alias:Get-Tip

        if ($null -ne $Session)
        {
            $Session.Name = 'DSCExchangeSession'
        }
    }

    # If the session is still null here, things went wrong. Throw exception
    if ($null -eq $Session)
    {
        throw "Failed to establish remote Powershell session to FQDN: $serverFQDN"
    }
    else # Import the session globally
    {
        # Temporarily set Verbose to SilentlyContinue so the Session and Module import isn't noisy
        $oldVerbose = $VerbosePreference
        $VerbosePreference = 'SilentlyContinue'

        if ($CommandsToLoad.Count -gt 0)
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -CommandName $CommandsToLoad -Verbose:0
        }
        else
        {
            $moduleInfo = Import-PSSession $Session -WarningAction SilentlyContinue -DisableNameChecking -AllowClobber -Verbose:0
        }

        Import-Module $moduleInfo -Global -DisableNameChecking

        # Set Verbose back
        $VerbosePreference = $oldVerbose
    }
}

<#
    .SYNOPSIS
        Removes any Remote Exchange PowerShell Sessions that have been setup by
        xExchange.
#>
function Remove-RemoteExchangeSession
{
    [CmdletBinding()]
    param ()

    $sessions = Get-ExistingRemoteExchangeSession

    if ($null -ne $sessions)
    {
        Write-Verbose -Message 'Removing existing remote Powershell sessions'

        Get-ExistingRemoteExchangeSession | Remove-PSSession
    }
}

<#
    .SYNOPSIS
        Checks whether a supported version of Exchange is at least partially
        installed.
#>
function Test-ExchangePresent
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $version = Get-ExchangeVersionYear

    if ($version -in '2013','2016','2019')
    {
        return $true
    }
    else
    {
        return $false
    }
}

<#
    .SYNOPSIS
        Gets the installed Exchange Version, and returns the number as a
        string. Returns N/A if the version cannot be found, and will
        optionally throw an exception if ThrowIfUnknownVersion was set to
        $true.

    .PARAMETER ThrowIfUnknownVersion
        Whether the function should throw an exception if the version cannot
        be found. Defauls to $false.
#>
function Get-ExchangeVersionYear
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $ThrowIfUnknownVersion = $false
    )

    $version = 'N/A'

    try
    {
        $displayVersion = Get-ExchangeVersionDetailed -ThrowIfUnknownDisplayVersion -ErrorAction Stop
    }
    catch
    {
        throw $_.Exception
    }

    if($null -ne $displayVersion)
    {
        if($displayVersion.VersionMajor -eq 15)
        {
            switch ( $displayVersion.VersionMinor )
            {
                0 { $version = '2013' }
                1 { $version = '2016' }
                2 { $version = '2019' }
            }
        }
    }
    else
    {
        throw -Message "Get-ExchangeVersionYear: Get-ExchangeVersionDetailed could not determine the version of installed Exchange instance."
    }
    
    return $version
}


<#
    .SYNOPSIS
        Gets the installed Exchange buildnumber, which refers to the installed updates / CU,
        and returns a hashtable with Major, Minor, Update versions. Returns NULL if the version cannot be found, and will
        optionally throw an exception if ThrowIfUnknownVersion was set to $true.

    .PARAMETER ThrowIfUnknownVersion
        Whether the function should throw an exception if the version cannot
        be found. Defauls to $false.
#>

function Get-ExchangeVersionDetailed
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.Boolean]
        $ThrowIfUnknownDisplayVersion = $false
    )

    $displayVersion = $null

    $uninstall20162019Key = Get-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CD981244-E9B8-405A-9026-6AEB9DCEF1F1}' -ErrorAction SilentlyContinue

    $uninstall2013Key = Get-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{4934D1EA-BE46-48B1-8847-F1AF20E892C1}' -ErrorAction SilentlyContinue

    if ($null -ne $uninstall20162019Key)
    {
        if ($uninstall20162019Key.GetValue('VersionMajor') -eq 15 -and $uninstall20162019Key.GetValue('VersionMinor') -eq 1)
        {
            # Case of E2016 is installed
            $displayVersionString = $uninstall20162019Key.GetValue('DisplayVersion')

        }
    }
    elseif ($null -ne $uninstall2013Key)
    {
        $displayVersionString = $uninstall2013Key.GetValue('DisplayVersion')
    }
    elseif ($ThrowIfUnknownDisplayVersion)
    {
        throw 'Failed to discover a known Exchange Version'
    }

    if($null -ne $displayVersionString)
    {
        $displayVersionString -match '(?<VersionMajor>\d+).(?<VersionMinor>\d+).(?<VersionBuild>\d+)'
        if($Matches)
        {
            $displayVersion = @{

                VersionMajor =  [System.Int32]$Matches.VersionMajor
                VersionMinor =  [System.Int32]$Matches.VersionMinor
                VersionBuild =  [System.Int32]$Matches.VersionBuild

            }
        }
        else {

            throw -Message 'Get-ExchangeVersionDetailed: Major, Minor, Update versions cannot be parsed from registry.'

        }
    }
    else
    {
        throw -Message "Get-ExchangeVersionDetailed function could not read the 'DisplayVersion' of Exchange from registry."
    }

    return $displayVersion

}

<#
    .SYNOPSIS
        Returns whether Exchange Setup has fully and successfully completed.
#>
function Test-ExchangeSetupComplete
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $exchangePresent = Test-ExchangePresent
    $setupPartiallyCompleted = Test-ExchangeSetupPartiallyCompleted -Verbose:$VerbosePreference

    if ($exchangePresent -eq $true -and $setupPartiallyCompleted -eq $false)
    {
        Write-Verbose -Message 'Exchange is present and setup is detected as being fully complete.'

        $isSetupComplete = $true
    }
    else
    {
        Write-Verbose -Message "Exchange setup detected as not being fully complete. Exchange Present: $exchangePresent. Setup Partially Complete: $setupPartiallyCompleted."

        $isSetupComplete = $false
    }

    return $isSetupComplete
}

<#
    .SYNOPSIS
        Checks whether any Setup watermark keys exist which means that a
        previous installation of setup had already started but not completed.
#>
function Test-ExchangeSetupPartiallyCompleted
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    Write-Verbose -Message 'Checking if setup is partially complete'

    $isPartiallyCompleted = $false

    # Now check if setup actually completed successfully
    [System.String[]] $roleKeys = @( 'CafeRole', 'ClientAccessRole', 'FrontendTransportRole', 'HubTransportRole', 'MailboxRole', 'UnifiedMessagingRole' )

    foreach ($key in $roleKeys)
    {
        $values = $null
        $values = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key" -ErrorAction SilentlyContinue

        if ($null -ne $values)
        {
            Write-Verbose -Message "Checking values at key 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key'"

            if ($null -ne $values.UnpackedVersion)
            {
                # If ConfiguredVersion is missing, or Action or Watermark or present, setup needs to be resumed
                if ($null -eq $values.ConfiguredVersion)
                {
                    Write-Warning -Message "Registry value missing. Setup considered partially complete. Location: 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key\ConfiguredVersion'."

                    $isPartiallyCompleted = $true
                }

                if ($null -ne $values.Action)
                {
                    Write-Warning -Message "Registry value present. Setup considered partially complete. Location: 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key\Action'. Value: '$($values.Action)'."

                    $isPartiallyCompleted = $true
                }

                if ($null -ne $values.Watermark)
                {
                    Write-Warning -Message "Registry value present. Setup considered partially complete. Location: 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key\Watermark'. Value: '$($values.Watermark)'."

                    $isPartiallyCompleted = $true
                }
            }
            else
            {
                Write-Verbose -Message "Value not present 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\$key\UnpackedVersion'. Skipping remaining value checks for key."
            }
        }
    }

    return $isPartiallyCompleted
}

<#
    .SYNOPSIS
        Checks for the exact status of Exchange setup and returns the results
        in a Hashtable.

    .PARAMETER Arguments
        The command line arguments to be passed to Exchange Setup.
#>
function Get-ExchangeInstallStatus
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Arguments
    )

    Write-Verbose -Message 'Checking Exchange Install Status'

    $shouldStartInstall = $false

    $shouldInstallLanguagePack = Test-ShouldInstallUMLanguagePack -Arguments $Arguments
    $setupRunning = Test-ExchangeSetupRunning
    $setupComplete = Test-ExchangeSetupComplete -Verbose:$VerbosePreference
    $exchangePresent = Test-ExchangePresent    

    if ($setupRunning -or $setupComplete)
    {
        if($shouldInstallLanguagePack -and $setupComplete)
        {
            $shouldStartInstall = $true
        }
        else
        {
            # Do nothing. Either Install is already running, or it's already finished successfully
        }
    }
    elseif (!$setupComplete)
    {
        $shouldStartInstall = $true
    }

    # Exchange CU install / update support
    if(($Arguments -match '/mode:upgrade') -or ($Arguments -match '/m:upgrade'))
    {
        # get Exchange setup.exe version
        $setupexeVersionInfo = (Get-ChildItem -Path $Path).VersionInfo.ProductVersionRaw

        Write-Verbose -Message "Setup.exe version is: '$($setupexeVersion.ToString())'"    
        
        $setupExeVersion = @{

            VersionMajor =  [System.Int32]$setupexeVersionInfo.Major
            VersionMinor =  [System.Int32]$setupexeVersionInfo.Minor
            VersionBuild =  [System.Int32]$setupexeVersionInfo.Build

        }

        $exchangeVersion = Get-ExchangeVersionYear -ThrowIfUnknownVersion $true

        if($null -ne $exchangeVersion)
        { # If we have an exchange installed

            Write-Verbose -Message "Comparing setup.exe version and installed Exchange's version."

            $exchangeDisplayVersion = Get-ExchangeVersionDetailed -ThrowIfUnknownDisplayVersion $true
            
            if(($exchangeDisplayVersion.VersionMajor -eq $setupExeVersion.VersionMajor)`
                -and ($exchangeDisplayVersion.VersionMinor -eq $setupExeVersion.VersionMinor)`
                -and ($exchangeDisplayVersion.VersionBuild -le $setupExeVersion.VersionBuild) ) 
            { # If server has lower version of CU installed

                Write-Verbose -Message 'Version upgrade is requested.'
                # Executing with the upgrade.
                $shouldStartInstall = $true

            }

        }
        else {

            Write-Error -Message "Get-ExchangeInstallStatus: Script cannot determin installed Exchange's version. Please check if Exchange is installed."

        }
    
    }

    Write-Verbose -Message "Finished Checking Exchange Install Status. ShouldInstallLanguagePack: $shouldInstallLanguagePack. SetupRunning: $setupRunning. SetupComplete: $setupComplete. ExchangePresent: $exchangePresent. ShouldStartInstall: $shouldStartInstall."

    $returnValue = @{
        ShouldInstallLanguagePack = $shouldInstallLanguagePack
        SetupRunning = $setupRunning
        SetupComplete = $setupComplete
        ExchangePresent = $exchangePresent
        ShouldStartInstall = $shouldStartInstall
    }

    $returnValue
}

<#
    .SYNOPSIS
        Check for missing registry keys that may cause Exchange setup to try to
        restart WinRM mid setup , which will in turn cause the DSC resource to
        fail. If any required keys are missing, configure WinRM, then force a
        reboot.
#>
function Set-WSManConfigStatus
{
    # Suppressing this rule because $global:DSCMachineStatus is used to trigger a reboot.
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    <#
        Suppressing this rule because $global:DSCMachineStatus is only set,
        never used (by design of Desired State Configuration).
    #>
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Scope='Function', Target='DSCMachineStatus')]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param ()

    $needReboot = $false

    $wsmanKey = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN' -ErrorAction SilentlyContinue

    if ($null -ne $wsmanKey)
    {
        if ($null -eq $wsmanKey.UpdatedConfig)
        {
            $needReboot = $true

            Write-Verbose -Message "Value 'UpdatedConfig' missing from registry key HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN. Running: winrm i restore winrm/config"

            Set-Location "$($env:windir)\System32\inetsrv"
            winrm i restore winrm/config | Out-Null

            Write-Verbose -Message 'Machine needs to be rebooted before Exchange setup can proceed'

            $global:DSCMachineStatus = 1
        }
    }
    else
    {
        throw 'Unable to find registry key: HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WSMAN'
    }

    return $needReboot
}

<#
    .SYNOPSIS
        Given the specified Exchange Setup arguments, determines whether an
        Exchange UM Language Pack should be installed or not.

    .PARAMETER Arguments
        The command line arguments to be passed to Exchange Setup.
#>
function Test-ShouldInstallUMLanguagePack
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $Arguments
    )

    if($Arguments -match '(?<=/AddUMLanguagePack:)(([a-z]{2}-[A-Z]{2},?)+)(?=\s)')
    {
        $Cultures = $Matches[0]
        Write-Verbose -Message "AddUMLanguagePack parameters detected: $Cultures"
        $Cultures = $Cultures -split ','

        foreach($Culture in $Cultures)
        {
            if((Test-UMLanguagePackInstalled -Culture $Culture) -eq $false)
            {
                Write-Verbose -Message "UM Language Pack: $Culture is not installed"
                return $true
            }
        }
    }

    return $false
}

<#
    .SYNOPSIS
        Checks whether Exchange Setup is running by checking if the
        ExSetup.exe process currently exists as a running process.

    .PARAMETER SetupProcessName
        The name of the process to check if running. Defaults to ExSetup*.
#>
function Test-ExchangeSetupRunning
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $SetupProcessName = 'ExSetup*'
    )

    return ($null -ne (Get-Process -Name $SetupProcessName -ErrorAction SilentlyContinue))
}

<#
    .SYNOPSIS
        Checks if two strings are equal, or are both either null or empty.
        If IgnoreCase is specified, returns true if both strings are like
        each other, regardless of case. Without IgnoreCase, only returns
        true if both strings are identical. Also returns true if both strings
        are either null or empty. Returns false for all other cases.

    .PARAMETER String1
        The first System.String object to compare.

    .PARAMETER String2
        The second System.String object to compare

    .PARAMETER IgnoreCase
        Whether case should be ignored when comparing the two strings.
#>
function Compare-StringToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $String1,

        [Parameter()]
        [System.String]
        $String2,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IgnoreCase
    )

    if (([System.String]::IsNullOrEmpty($String1) -and [System.String]::IsNullOrEmpty($String2)))
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

<#
    .SYNOPSIS
        Compares two Nullable Boolean objects and returns true if they are both
        set to true, both set to false, or both set to either null or false.

    .PARAMETER Bool1
        The first System.Boolean object to compare.

    .PARAMETER Bool2
        The second System.Boolean object to compare.
#>
function Compare-BoolToBool
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [Nullable[System.Boolean]]
        $Bool1,

        [Parameter()]
        [Nullable[System.Boolean]]
        $Bool2
    )

    if ($Bool1 -ne $Bool2)
    {
        if (!(($null -eq $Bool1 -and $Bool2 -eq $false) -or ($null -eq $Bool2 -and $Bool1 -eq $false)))
        {
            return $false
        }
    }

    return $true
}

<#
    .SYNOPSIS
        Takes a string which should be in timespan format, and compares it to
        an actual EnhancedTimeSpan object. Returns true if they are equal.

    .PARAMETER TimeSpan
        The Microsoft.Exchange.Data.EnhancedTimeSpan object to compare.

    .PARAMETER String
        The System.String object to compare.
#>
function Compare-TimespanToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [Microsoft.Exchange.Data.EnhancedTimeSpan]
        $TimeSpan,

        [Parameter()]
        [System.String]
        $String
    )

    try
    {
        $converted = [Microsoft.Exchange.Data.EnhancedTimeSpan]::Parse($String)

        return ($TimeSpan.Equals($converted))
    }
    catch
    {
        throw "String '$String' is not in a valid format for an EnhancedTimeSpan"
    }

    return $false
}

<#
    .SYNOPSIS
        Takes a string which should be in ByteQuantifiedSize format, and
        compares it to an actual ByteQuantifiedSize object. Returns true if
        they are equal.

    .PARAMETER ByteQuantifiedSize
        The Microsoft.Exchange.Data.ByteQuantifiedSize object to compare.

    .PARAMETER String
        The System.String object to compare.
#>
function Compare-ByteQuantifiedSizeToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [Microsoft.Exchange.Data.ByteQuantifiedSize]
        $ByteQuantifiedSize,

        [Parameter()]
        [System.String]
        $String
    )

    try
    {
        $converted = [Microsoft.Exchange.Data.ByteQuantifiedSize]::Parse($String)

        return ($ByteQuantifiedSize.Equals($converted))
    }
    catch
    {
        throw "String '$String' is not in a valid format for a ByteQuantifiedSize"
    }
}

<#
    .SYNOPSIS
        Takes a string which should be in Microsoft.Exchange.Data.Unlimited
        format, and compares with an actual Unlimited object. Returns true if
        they are equal.

    .PARAMETER Unlimited
        The Microsoft.Exchange.Data.Unlimited object to compare.

    .PARAMETER String
        The System.String object to compare.
#>
function Compare-UnlimitedToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Object]
        $Unlimited,

        [Parameter()]
        [System.String]
        $String
    )

    if ($Unlimited.IsUnlimited)
    {
        return (Compare-StringToString -String1 'Unlimited' -String2 $String -IgnoreCase)
    }
    elseif ((Compare-StringToString -String1 'Unlimited' -String2 $String -IgnoreCase) -and !$Unlimited.IsUnlimited)
    {
        return $false
    }
    elseif (($Unlimited.Value -is [System.Int32]) -and !$Unlimited.IsUnlimited)
    {
        return (Compare-StringToString -String1 $Unlimited -String2 $String -IgnoreCase)
    }
    else
    {
        return (Compare-ByteQuantifiedSizeToString -ByteQuantifiedSize $Unlimited -String $String)
    }
}

<#
    .SYNOPSIS
        Takes an ADObjectId, gets a recipient from it using Get-Recipient, and
        checks if the EmailAddresses property contains the given AddressString.
        The Get-Recipient cmdlet must be loaded for this function to succeed.

    .PARAMETER ADObjectId
        The ADObjectID to run Get-Recipient against and compare against the
        given AddressString.

    .PARAMETER AddressString
        The AddressString to compare against the EmailAddresses property of the
        Get-Recipient results.
#>
function Compare-ADObjectIdToSmtpAddressString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Object]
        $ADObjectId,

        [Parameter()]
        [System.String]
        $AddressString
    )

    if ($null -ne (Get-Command -Name 'Get-Recipient' -ErrorAction SilentlyContinue))
    {
        if ($null -eq $ADObjectId -and ![System.String]::IsNullOrEmpty($AddressString))
        {
            return $false
        }
        elseif ($null -ne $ADObjectId -and [System.String]::IsNullOrEmpty($AddressString))
        {
            return $false
        }
        elseif ($null -eq $ADObjectId -and [System.String]::IsNullOrEmpty($AddressString))
        {
            return $true
        }

        $recipient = Get-Recipient -Identity $ADObjectId.DistinguishedName -ErrorAction SilentlyContinue

        if ($null -eq $recipient)
        {
            throw "Failed to Get-Recipient for ADObjectID with distinguishedName: $($ADObjectId.DistinguishedName)"
        }

        return ($null -ne ($recipient.EmailAddresses | Where-Object {$_.AddressString -like $AddressString}))
    }
    else
    {
        throw 'Compare-ADObjectIdToSmtpAddressString requires the Get-Recipient cmdlet. Make sure this is in the RBAC scope of the executing user account.'
    }
}

<#
    .SYNOPSIS
        Takes a string containing a given separator, and breaks it into a
        string array.

    .PARAMETER StringIn
        The System.String object to split into an array.

    .PARAMETER Separator
        The System.Char object to use as a separater when splitting the
        given System.String object.
#>
function Convert-StringToArray
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String]
        $StringIn,

        [Parameter()]
        [System.Char]
        $Separator
    )

    [System.String[]] $array = $StringIn.Split($Separator)

    for ($i = 0; $i -lt $array.Length; $i++)
    {
        $array[$i] = $array[$i].Trim()
    }

    return $array
}

<#
    .SYNOPSIS
        Takes an array of strings and converts each element in the array to
        all lowercase characters.

    .PARAMETER Array
        The array of System.String objects to convert into lowercase strings.
#>
function Convert-StringArrayToLowerCase
{
    [CmdletBinding()]
    [OutputType([System.String[]])]
    param
    (
        [Parameter()]
        [System.String[]]
        $Array
    )

    for ($i = 0; $i -lt $Array.Count; $i++)
    {
        if (!([System.String]::IsNullOrEmpty($Array[$i])))
        {
            $Array[$i] = $Array[$i].ToLower()
        }
    }

    return $Array
}

<#
    .SYNOPSIS
        Returns whether two string arrays have the same contents, where element
        order doesn't matter.

    .PARAMETER Array1
        The first System.String[] object to compare.

    .PARAMETER Array2
        The second System.String[] object to compare.

    .PARAMETER IgnoreCase
        Specifies that case should be ignored when comparing array contents.
#>
function Compare-ArrayContent
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String[]]
        $Array1,

        [Parameter()]
        [System.String[]]
        $Array2,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IgnoreCase
    )

    $hasSameContents = $true

    if ($Array1.Length -ne $Array2.Length)
    {
        $hasSameContents = $false
    }
    elseif ($Array1.Count -gt 0 -and $Array2.Count -gt 0)
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = Convert-StringArrayToLowerCase -Array $Array1
            $Array2 = Convert-StringArrayToLowerCase -Array $Array2
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

<#
    .SYNOPSIS
        Given two System.String[] objects, Array 1 and Array 2, returns whether
        Array2 contains all elements of Array1, in any order. Array2 may be
        larger than Array1, as long as it contains all elements of Array1.

    .PARAMETER Array1
        The System.String[] object to check whether its elements exist in
        Array2.

    .PARAMETER Array2
        The System.String[] object to check whether the elements of Array1 are
        a part of.

    .PARAMETER IgnoreCase
        Whether case should be ignored when comparing strings from each array.
#>
function Test-ArrayElementsInSecondArray
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String[]]
        $Array1,

        [Parameter()]
        [System.String[]]
        $Array2,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $IgnoreCase
    )

    $hasContents = $true

    if ($Array1.Length -eq 0) # Do nothing, as Array2 at a minimum contains nothing
    {}
    elseif ($Array2.Length -eq 0) # Array2 is empty and Array1 is not. Return false
    {
        $hasContents = $false
    }
    else
    {
        if ($IgnoreCase -eq $true)
        {
            $Array1 = Convert-StringArrayToLowerCase -Array $Array1
            $Array2 = Convert-StringArrayToLowerCase -Array $Array2
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

<#
    .SYNOPSIS
        Takes $PSBoundParameters from another function and adds in the keys and
        values from the given Hashtable.

    .PARAMETER PSBoundParametersIn
        The $PSBoundParameters Hashtable from the calling function.

    .PARAMETER ParamsToAdd
        A Hashtable containing new Key/Value pairs to add to the given
        PSBoundParametersIn Hashtable.
#>
function Add-ToPSBoundParametersFromHashtable
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $PSBoundParametersIn,

        [Parameter()]
        [System.Collections.Hashtable]
        $ParamsToAdd
    )

    foreach ($key in $ParamsToAdd.Keys)
    {
        if (!($PSBoundParametersIn.ContainsKey($key))) # Key doesn't exist, so add it with value
        {
            $PSBoundParametersIn.Add($key, $ParamsToAdd[$key]) | Out-Null
        }
        else # Key already exists, so just replace the value
        {
            $PSBoundParametersIn[$key] = $ParamsToAdd[$key]
        }
    }
}

<#
    .SYNOPSIS
        Takes $PSBoundParameters from another function, and modifies it based
        on the contents of the given Hashtable. If ParamsToRemove is specified,
        it will remove each param. If ParamsToKeep is specified, everything but
        those params will be removed. If both ParamsToRemove and ParamsToKeep
        are specified, only ParamsToKeep will be used.

    .PARAMETER PSBoundParametersIn
        The $PSBoundParameters Hashtable from the calling function.

    .PARAMETER ParamsToKeep
        A String array containing the list of parameter names to keep in the
        given PSBoundParametersIn HashTable.

    .PARAMETER ParamsToRemove
        A String array containing the list of parameter names to remove in the
        given PSBoundParametersIn HashTable.
#>
function Remove-FromPSBoundParametersUsingHashtable
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $PSBoundParametersIn,

        [Parameter()]
        [System.String[]]
        $ParamsToKeep,

        [Parameter()]
        [System.String[]]
        $ParamsToRemove
    )

    if ($ParamsToKeep.Count -gt 0)
    {
        [System.String[]] $ParamsToRemove = @()

        $lowerParamsToKeep = Convert-StringArrayToLowerCase -Array $ParamsToKeep

        foreach ($key in $PSBoundParametersIn.Keys)
        {
            if (!($lowerParamsToKeep.Contains($key.ToLower())))
            {
                $ParamsToRemove += $key
            }
        }
    }

    if ($ParamsToRemove.Count -gt 0)
    {
        foreach ($param in $ParamsToRemove)
        {
            $PSBoundParametersIn.Remove($param) | Out-Null
        }
    }
}

<#
    .SYNOPSIS
        Inspects the input $PSBoundParametersIn hashtable, and removes any
        parameters that do not work with the version of Exchange on this
        server.

    .PARAMETER PSBoundParametersIn
        The $PSBoundParameters hashtable from the calling function.

    .PARAMETER ParamName
        The parameter to check for and remove if not applicable to this
        server version.

    .PARAMETER ResourceName
        The name of the DSC resource from which parameters are being checked.

    .PARAMETER ParamExistsInVersion
        The parameter to check for and remove if not applicable to this
        server version.
#>
function Remove-NotApplicableParamsForVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $PSBoundParametersIn,

        [Parameter()]
        [System.String]
        $ParamName,

        [Parameter()]
        [System.String]
        $ResourceName,

        [Parameter()]
        [ValidateSet('2013','2016','2019')]
        [System.String[]]
        $ParamExistsInVersion
    )

    if ($PSBoundParametersIn.ContainsKey($ParamName))
    {
        $serverVersion = Get-ExchangeVersionYear

        if ($serverVersion -notin $ParamExistsInVersion)
        {
            Write-Warning "$ParamName is not a valid parameter for $ResourceName in Exchange $serverVersion. Skipping usage."
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParametersIn -ParamsToRemove $ParamName
        }
    }
}

<#
    .SYNOPSIS
        Takes a Hashtable object (generally PSBoundParameters), looks for any
        values that are of type System.String and are empty strings (""), and
        sets them to a value of $null instead.

    .PARAMETER PSBoundParametersIn
        The $PSBoundParameters hashtable from the calling function.
#>
function Set-EmptyStringParamsToNull
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        $PSBoundParametersIn
    )

    [System.String[]] $emptyStringKeys = @()

    # First find all parameters that are a string, and are an empty string ("")
    foreach ($key in $PSBoundParametersIn.Keys)
    {
        if ($null -ne $PSBoundParametersIn[$key] -and $PSBoundParametersIn[$key].GetType().Name -eq 'String' -and $PSBoundParametersIn[$key] -eq '')
        {
            $emptyStringKeys += $key
        }
    }

    # Now that we have the keys, set their values to null
    foreach ($key in $emptyStringKeys)
    {
        $PSBoundParametersIn[$key] = $null
    }
}

<#
    .SYNOPSIS
        Takes an expected setting value and an actual setting value, and
        returns true if they are both comparable.

    .PARAMETER Name
        The name of the setting that is being compared.

    .PARAMETER Type
        The object type of the setting that is being compared.

    .PARAMETER ExpectedValue
        The expected value of the setting that is being compared.

    .PARAMETER ActualValue
        The actual value of the setting that is being compared.

    .PARAMETER PSBoundParametersIn
        The PSBoundParameters Hashtable of the calling function.
#>
function Test-ExchangeSetting
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Type,

        [Parameter()]
        [System.Object]
        $ExpectedValue,

        [Parameter()]
        [System.Object]
        $ActualValue,

        [Parameter()]
        [System.Collections.Hashtable]
        $PSBoundParametersIn
    )

    $returnValue = $true

    if ($PSBoundParametersIn.ContainsKey($Name))
    {
        if ($Type -like 'String')
        {
            if ((Compare-StringToString -String1 $ExpectedValue -String2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'Boolean')
        {
            if ((Compare-BoolToBool -Bool1 $ExpectedValue -Bool2 $ActualValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'Array')
        {
            if ((Compare-ArrayContent -Array1 $ExpectedValue -Array2 $ActualValue -IgnoreCase) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'Int')
        {
            if ($ExpectedValue -ne $ActualValue)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'Unlimited')
        {
            if ((Compare-UnlimitedToString -Unlimited $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'Timespan')
        {
            if ((Compare-TimespanToString -TimeSpan $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'ADObjectID')
        {
            if ((Compare-ADObjectIdToSmtpAddressString -ADObjectId $ActualValue -AddressString $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'ByteQuantifiedSize')
        {
            if ((Compare-ByteQuantifiedSizeToString -ByteQuantifiedSize $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'IPAddress')
        {
            if ((Compare-IPAddressToString -IPAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'IPAddresses')
        {
            if ((Compare-IPAddressesToArray -IPAddresses $ActualValue -Array $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'SMTPAddress')
        {
            if ((Compare-SmtpAddressToString -SmtpAddress $ActualValue -String $ExpectedValue) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'PSCredential')
        {
            if ((Compare-PSCredential -Cred1 $ActualValue -Cred2 $ExpectedValue ) -eq $false)
            {
                $returnValue = $false
            }
        }
        elseif ($Type -like 'ExtendedProtection')
        {
            if ((Convert-StringArrayToLowerCase $ExpectedValue).Contains('none'))
            {
                if (-not [System.String]::IsNullOrEmpty($ActualValue))
                {
                    $returnValue = $false
                }
            }
            else
            {
                if ((Compare-ArrayContent -Array1 $ExpectedValue -Array2 $ActualValue -IgnoreCase) -eq $false)
                {
                    $returnValue = $false
                }
            }
        }
        else
        {
            throw "Type not found: $Type"
        }
    }

    if ($returnValue -eq $false)
    {
        Write-InvalidSettingVerbose -SettingName $Name -ExpectedValue $ExpectedValue -ActualValue $ActualValue -Verbose:$VerbosePreference
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Writes to the Verbose output stream that an invalid setting was
        detected.

    .PARAMETER SettingName
        The name of the setting being reported as Invalid.

    .PARAMETER ExpectedValue
        The expected value of the Invalid setting.

    .PARAMETER ActualValue
        The actual value of the Invalid setting.
#>
function Write-InvalidSettingVerbose
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $SettingName,

        [Parameter()]
        [System.Object]
        $ExpectedValue,

        [Parameter()]
        [System.Object]
        $ActualValue
    )

    Write-Verbose -Message "Invalid setting '$SettingName'. Expected value: '$ExpectedValue'. Actual value: '$ActualValue'"
}

<#
    .SYNOPSIS
        Writes to the Verbose output stream the name of the calling function,
        as well as any relevant parameter names and values.

    .PARAMETER Parameters
        A Hashtable containing relevant parameter names and values to include
        in the output.
#>
function Write-FunctionEntry
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Collections.Hashtable]
        $Parameters
    )

    $callingFunction = (Get-PSCallStack)[1].FunctionName

    if ($Parameters.Count -gt 0)
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

        Write-Verbose -Message "Entering function '$callingFunction'. Notable parameters: $parametersString"
    }
    else
    {
        Write-Verbose -Message "Entering function '$callingFunction'."
    }
}

<#
    .SYNOPSIS
        Creates and starts a new Scheduled Task using the specified parameters.

    .PARAMETER Path
        Specifies the path to an executable file.

    .PARAMETER Arguments
        Specifies arguments for the command-line operation.

    .PARAMETER Credential
        Specifies the name <run as> credentials to use when running the task.

    .PARAMETER TaskName
        Specifies the name of a scheduled task.

    .PARAMETER WorkingDirectory
        Specifies a directory where Task Scheduler will run the task. If you do
        not specify a working directory, Task Scheduler runs the task in the
        %windir%\system32 directory.

    .PARAMETER MaxWaitMinutes
        The amount of time in minutes that is allowed to complete the task. If
        set to 0 (the default), there is no time limit.

    .PARAMETER TaskPriority
        The priority level (0-10) of the task. Defaults to 4. Priority level 0
        is the highest priority, and priority level 10 is the lowest priority.
        Priority levels 7 and 8 are used for background tasks, and priority
        levels 4, 5, and 6 are used for interactive tasks.
#>
function Start-ExchangeScheduledTask
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter()]
        [System.String]
        $Arguments,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [System.String]
        $TaskName,

        [Parameter()]
        [System.String]
        $WorkingDirectory,

        [Parameter()]
        [System.UInt32]
        $MaxWaitMinutes = 0,

        [Parameter()]
        [System.UInt32]
        $TaskPriority = 4
    )

    $tName = "$([System.Guid]::NewGuid().ToString())"

    if ($PSBoundParameters.ContainsKey('TaskName'))
    {
        $tName = "$TaskName $tName"
    }

    $action = New-ScheduledTaskAction -Execute "$Path" -Argument "$Arguments"

    if ($PSBoundParameters.ContainsKey('WorkingDirectory'))
    {
        $action.WorkingDirectory = $WorkingDirectory
    }

    Write-Verbose -Message "Created Scheduled Task with name: $tName"
    Write-Verbose -Message "Task Action: $Path $Arguments"

    # Use 'NT AUTHORITY\SYSTEM' as the run as account unless a specific Credential was provided
    $credParams = @{
        User = 'NT AUTHORITY\SYSTEM'
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $credParams['User'] = $Credential.UserName
        $credParams.Add('Password', $Credential.GetNetworkCredential().Password)
    }

    $task = Register-ScheduledTask @credParams -TaskName "$tName" -Action $action -RunLevel Highest -ErrorVariable errRegister -ErrorAction SilentlyContinue

    if (0 -lt $errRegister.Count)
    {
        throw $errRegister[0]
    }
    elseif ($null -ne $task -and $task.State -eq 'Ready')
    {
        # Set a time limit on the task
        $taskSettings = $task.Settings
        $taskSettings.ExecutionTimeLimit = "PT$($MaxWaitMinutes)M"
        $taskSettings.Priority = $TaskPriority
        Set-ScheduledTask @credParams -TaskName "$($task.TaskName)" -Settings $taskSettings

        Write-Verbose -Message "Starting task at: $([DateTime]::Now)"

        $task | Start-ScheduledTask
    }
    else
    {
        throw 'Failed to register Scheduled Task'
    }
}

<#
    .SYNOPSIS
        Returns whether or not the specified cmdlet has the given parameter
        name as an available parameter.

    .PARAMETER CmdletName
        The cmdlet name to check for parameters.

    .PARAMETER ParameterName
        The name of the parameter to check for.
#>
function Test-CmdletHasParameter
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String]
        $CmdletName,

        [Parameter()]
        [System.String]
        $ParameterName
    )

    [System.Boolean] $hasParameter = $false

    $command = Get-Command -Name $CmdletName -ErrorAction SilentlyContinue

    if ($null -ne $command -and $null -ne $command.Parameters)
    {
        if ($command.Parameters.ContainsKey($ParameterName))
        {
            $hasParameter = $true
        }
    }

    return $hasParameter
}

<#
    .SYNOPSIS
        Returns the most recent error in the $Global:Error Variable
#>
function Get-PreviousError
{
    # Suppressing this rule to allow use of the built-in Global:Error variable
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [CmdletBinding()]
    [OutputType([System.Management.Automation.ErrorRecord])]
    param ()

    $previousError = $null

    if ($Global:Error.Count -gt 0)
    {
        $previousError = $Global:Error[0]
    }

    return $previousError
}

<#
    .SYNOPSIS
        Compares the most recent error in the $Global:Error variable to the input
        $PreviousError variable. If they are not the same, throws an exception.

    .PARAMETER CmdletBeingRun
        The name of the cmdlet that was run immediately prior to calling
        this function.

    .PARAMETER PreviousError
        The previous known error variable to compare against the most recent
        error that has occurred.
#>
function Assert-NoNewError
{
    # Suppressing this rule to allow use of the built-in Global:Error variable
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $CmdletBeingRun,

        [Parameter()]
        [System.Management.Automation.ErrorRecord]
        $PreviousError
    )

    # Throw an exception if errors were encountered
    if ($Global:Error.Count -gt 0 -and $PreviousError -ne $Global:Error[0])
    {
        throw "Failed to run $CmdletBeingRun with: $($Global:Error[0])"
    }
}

<#
    .SYNOPSIS
        Checks whether the IIS Application Pool with the given name exists, and
        if so, restarts it. Does nothing if the Application Pool does not
        exist.

    .PARAMETER Name
        The name of the IIS Application Pool to check for and restart.
#>
function Restart-ExistingAppPool
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $Name
    )

    $state = Get-WebAppPoolState -Name $Name -ErrorAction SilentlyContinue

    if ($null -ne $state)
    {
        Restart-WebAppPool -Name $Name
    }
    else
    {
        Write-Verbose -Message "Application pool with name '$Name' does not exist. Skipping application pool restart."
    }
}

<#
    .SYNOPSIS
        Returns whether the UM language pack for the specified culture is
        installed.

    .PARAMETER Culture
        The Culture of the UM language pack to check for.
#>
function Test-UMLanguagePackInstalled
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Culture
    )

    return [System.Boolean] (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ExchangeServer\v15\UnifiedMessagingRole\LanguagePacks').$Culture
}

<#
    .SYNOPSIS
        Returns whether the given IPAddress object is comparable to the given
        string.

    .PARAMETER IPAddress
        The System.Net.IPAddress object to compare.

    .PARAMETER String
        The System.String object to compare.
#>
function Compare-IPAddressToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Net.IPAddress]
        $IPAddress,

        [Parameter()]
        [System.String]
        $String
    )

    if (($null -eq $IPAddress -and !([System.String]::IsNullOrEmpty($String))) -or ($null -ne $IPAddress -and [System.String]::IsNullOrEmpty($String)))
    {
        $returnValue = $false
    }
    elseif ($null -eq $IPAddress -and [System.String]::IsNullOrEmpty($String))
    {
        $returnValue = $true
    }
    else
    {
        $returnValue =($IPAddress.Equals([System.Net.IPAddress]::Parse($string)))
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Returns whether the given SmtpAddress object is comparable to the given
        string.

    .PARAMETER SmtpAddress
        The Microsoft.Exchange.Data.SmtpAddress object to compare.

    .PARAMETER String
        The System.String object to compare.
#>
function Compare-SmtpAddressToString
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [Nullable[Microsoft.Exchange.Data.SmtpAddress]]
        $SmtpAddress,

        [Parameter()]
        [System.String]
        $String
    )

    if (($null -eq $SmtpAddress) -and ([System.String]::IsNullOrEmpty($String)))
    {
        Write-Verbose -Message 'Expected and actual value is empty, therefore equal!'
        return $true
    }
    elseif (($null -eq $SmtpAddress) -and -not ([System.String]::IsNullOrEmpty($String)))
    {
        return $false
    }
    elseif ($SmtpAddress.Gettype() -eq [Microsoft.Exchange.Data.SmtpAddress])
    {
        if ([System.String]::IsNullOrEmpty($String))
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
        Write-Verbose -Message 'No type of [Microsoft.Exchange.Data.SmtpAddress]!'
        return $false
    }
}

<#
    .SYNOPSIS
        Returns whether the given array of IPAddress objects is comparable
        to the given Array.

    .PARAMETER IPAddresses
        The array of IPAddress objects to compare.

    .PARAMETER Array
        The other array of objects to compare.
#>
function Compare-IPAddressesToArray
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Net.IPAddress[]]
        $IPAddresses,

        [Parameter()]
        [System.Array]
        $Array
    )

    if (([System.String]::IsNullOrEmpty($IPAddresses)) -and ([System.String]::IsNullOrEmpty($Array)))
    {
        $returnValue = $true
    }
    elseif ((([System.String]::IsNullOrEmpty($IPAddresses)) -and !(([System.String]::IsNullOrEmpty($Array)))) -or (!(([System.String]::IsNullOrEmpty($IPAddresses))) -and ([System.String]::IsNullOrEmpty($Array))))
    {
        $returnValue = $false
    }
    else
    {
        Compare-ArrayContent -Array1 $IPAddresses -Array2 $Array
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Returns whether the two PSCredential objects are equal.

    .PARAMETER Cred1
        The first PSCredential object to compare.

    .PARAMETER Cred2
        The second PSCredential object to compare.
#>
function Compare-PSCredential
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Cred1,

        [Parameter()]
        [System.Management.Automation.PSCredential]
        $Cred2
    )

    begin
    {
        $returnValue = $false

        if ($null -ne $Cred1)
        {
            $Cred1User = $Cred1.UserName
            $Cred1Password = $Cred1.GetNetworkCredential().Password
        }

        if ($null -ne $Cred2)
        {
            $Cred2User = $Cred2.UserName
            $Cred2Password = $Cred2.GetNetworkCredential().Password
        }
    }
    process
    {
        if (($Cred1User -ceq $Cred2User) -and ($Cred1Password -ceq $Cred2Password))
        {
            Write-Verbose -Message 'Credentials match'
            $returnValue = $true
        }
        else
        {
            Write-Verbose -Message "Credentials don't match"
            Write-Verbose -Message "Cred1:$Cred1User Cred2:$Cred2User"
        }
    }
    end
    {
        return $returnValue
    }
}

<#
    .SYNOPSIS
        Returns whether the list of Service Principal Names is valid given the
        list of SPN Flags being used.

    .PARAMETER SPNList
        The list of Service Principal Names to inspect.

    .PARAMETER Flags
        The SPN Flags to use when inspecting the SPN List.
#>
function Test-ExtendedProtectionSPNList
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter()]
        [System.String[]]
        $SPNList,

        [Parameter()]
        [System.String[]]
        $Flags
    )

    begin
    {
        # Initialize variable
        [System.Boolean] $IsDotless = $false
        [System.Boolean] $returnValue = $true
        [System.Boolean] $InvalidFlags = $false

        # Check for invalid ExtendedProtectionFlags
        if (-not [System.String]::IsNullOrEmpty($Flags))
        {
            if ((Convert-StringArrayToLowerCase $Flags).Contains('none') -and ($Flags.Count -gt 1))
            {
                Write-Verbose -Message 'Invalid combination of ExtendedProtectionFlags detected!'
                $InvalidFlags = $true
                $returnValue = $false
            }
        }

        # Check for invalid formatted and Dotless SPNs
        if ((-not [System.String]::IsNullOrEmpty($SPNList)) -and (-not $InvalidFlags))
        {
            # Check for Dotless SPN
            foreach ($S in $SPNList)
            {
                $Name = $S.Split('/')[1]

                if ([System.String]::IsNullOrEmpty($Name))
                {
                    Write-Verbose -Message "Invalid SPN:$S"
                    break
                }
                else
                {
                    if (-not $Name.Contains('.'))
                    {
                        Write-Verbose -Message "Found Dotless SPN:$Name"
                        $IsDotless = $true
                        break
                    }
                }
            }
        }
    }
    process
    {
        # Check if AllowDotless is set in Flags
        if($IsDotless)
        {
            if([System.String]::IsNullOrEmpty($Flags))
            {
                Write-Verbose -Message 'AllowDotless SPN found, but Flags is NULL!'
                $returnValue = $false
            }
            else
            {
                if( -not (Convert-StringArrayToLowerCase $Flags).Contains('allowdotlessspn'))
                {
                    Write-Verbose -Message 'AllowDotless is not found in Flags!'
                    $returnValue = $false
                }
            }
        }
    }
    end
    {
        $returnValue
    }
}

<#
    .SYNOPSIS
        Checks if the current Exchange Server version is contained within the
        $SupportedVersions parameter. If it is not, throws an exception.

    .PARAMETER ObjectOrOperationName
        The name of object type or operation name that is about to be utilized
        if the call to this function does not throw an exception.

    .PARAMETER SupportedVersions
        The allowed Exchange Server versions that the object or operation is
        allowed to be utilized on.
#>
function Assert-IsSupportedWithExchangeVersion
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.String]
        $ObjectOrOperationName,

        [Parameter()]
        [System.String[]]
        $SupportedVersions
    )

    $serverVersion = Get-ExchangeVersionYear

    if ($serverVersion -notin $SupportedVersions)
    {
        throw "$ObjectOrOperationName is not supported in Exchange Server $serverVersion"
    }
}

Export-ModuleMember -Function *
