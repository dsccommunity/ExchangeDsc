<#
    .SYNOPSIS
        Gets the state of the resource
    .PARAMETER DomainName
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AllowedOOFType
        The AllowedOOFType parameter specifies the type of automatic replies or out-of-office (also known as OOF) notifications than can be sent to recipients in the remote domain.
    .PARAMETER AutoForwardEnabled
        The AutoForwardEnabled parameter specifies whether to allow messages that are auto-forwarded by client email programs in your organization.
    .PARAMETER AutoReplyEnabled
        The AutoReplyEnabled parameter specifies whether to allow messages that are automatic replies from client email programs in your organization
    .PARAMETER ContentType
        The ContentType parameter specifies the outbound message content type and formatting.
    .PARAMETER DeliveryReportEnabled
        The DeliveryReportEnabled parameter specifies whether to allow delivery reports from client software in your organization to recipients in the remote domain.
    .PARAMETER DisplaySenderName
        The DisplaySenderName parameter specifies whether to show the sender's Display Name in the From email address for messages sent to recipients in the remote domain.
    .PARAMETER IsInternal
        The IsInternal parameter specifies whether the recipients in the remote domain are considered to be internal recipients.
    .PARAMETER MeetingForwardNotificationEnabled
        The MeetingForwardNotificationEnabled parameter specifies whether to enable meeting forward notifications for recipients in the remote domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the remote domain object.
    .PARAMETER NDREnabled
        The NDREnabled parameter specifies whether to allow non-delivery reports.
    .PARAMETER NonMimeCharacterSet
        The NonMimeCharacterSet parameter specifies a character set for plain text messages without defined character sets that are sent from your organization to recipients in the remote domain.
    .PARAMETER UseSimpleDisplayName
        The UseSimpleDisplayName parameter specifies whether the sender's simple display name is used for the From email address in messages sent to recipients in the remote domain.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    param (
        # The name of the address book
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Write-Verbose -Message 'Getting the Exchange Remote Domains List'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-RemoteDomain' -Verbose:$VerbosePreference

    $RemoteDomain = Get-RemoteDomain -ErrorAction SilentlyContinue | Where-Object -FilterScript { $PSItem.DomainName -eq $DomainName }

    if ($null -eq $RemoteDomain -and $DomainName -match '^\*\.')
    {
        #try to match based on name - covering some edge cases
        $RemoteDomain = Get-RemoteDomain -ErrorAction SilentlyContinue | Where-Object -FilterScript { $PSItem.Name -eq $DomainName.Trim('*.') }
    }

    $RemoteDomainProperties = @(
        'DomainName'
        'Name'
        'AllowedOOFType'
        'AutoForwardEnabled'
        'AutoReplyEnabled'
        'ContentType'
        'DeliveryReportEnabled'
        'DisplaySenderName'
        'IsInternal'
        'MeetingForwardNotificationEnabled'
        'NDREnabled'
        'NonMimeCharacterSet'
        'UseSimpleDisplayName'
    )

    if ($null -ne $RemoteDomain)
    {
        $returnValue = @{
            Ensure = 'Present'
        }
        foreach ($property in $RemoteDomain.PSObject.Properties.Name)
        {
            if ([String] $RemoteDomain.$property -and $RemoteDomainProperties -contains $property)
            {
                $returnValue[$property] = $RemoteDomain.$property
            }
        }
    }
    else
    {
        $returnValue = @{
            Ensure = 'Absent'
        }
    }

    return $returnValue
}

<#
    .SYNOPSIS
        Sets the state of the resource
    .PARAMETER DomainName
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AllowedOOFType
        The AllowedOOFType parameter specifies the type of automatic replies or out-of-office (also known as OOF) notifications than can be sent to recipients in the remote domain.
    .PARAMETER AutoForwardEnabled
        The AutoForwardEnabled parameter specifies whether to allow messages that are auto-forwarded by client email programs in your organization.
    .PARAMETER AutoReplyEnabled
        The AutoReplyEnabled parameter specifies whether to allow messages that are automatic replies from client email programs in your organization
    .PARAMETER ContentType
        The ContentType parameter specifies the outbound message content type and formatting.
    .PARAMETER DeliveryReportEnabled
        The DeliveryReportEnabled parameter specifies whether to allow delivery reports from client software in your organization to recipients in the remote domain.
    .PARAMETER DisplaySenderName
        The DisplaySenderName parameter specifies whether to show the sender's Display Name in the From email address for messages sent to recipients in the remote domain.
    .PARAMETER IsInternal
        The IsInternal parameter specifies whether the recipients in the remote domain are considered to be internal recipients.
    .PARAMETER MeetingForwardNotificationEnabled
        The MeetingForwardNotificationEnabled parameter specifies whether to enable meeting forward notifications for recipients in the remote domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the remote domain object.
    .PARAMETER NDREnabled
        The NDREnabled parameter specifies whether to allow non-delivery reports.
    .PARAMETER NonMimeCharacterSet
        The NonMimeCharacterSet parameter specifies a character set for plain text messages without defined character sets that are sent from your organization to recipients in the remote domain.
    .PARAMETER UseSimpleDisplayName
        The UseSimpleDisplayName parameter specifies whether the sender's simple display name is used for the From email address in messages sent to recipients in the remote domain.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        # The name of the accepted domain
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [string]
        $AllowedOOFType,

        [Parameter()]
        [bool]
        $AutoForwardEnabled = $true,

        [Parameter()]
        [bool]
        $AutoReplyEnabled = $true,

        [Parameter()]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [string]
        $ContentType,

        [Parameter()]
        [bool]
        $DeliveryReportEnabled = $true,

        [Parameter()]
        [bool]
        $DisplaySenderName = $true,

        [Parameter()]
        [bool]
        $IsInternal = $false,

        [Parameter()]
        [bool]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter()]
        [bool]
        $NDREnabled = $true,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $NonMimeCharacterSet,

        [Parameter()]
        [bool]
        $UseSimpleDisplayName = $false
    )

    Write-Verbose -Message 'Setting the Exchange Remote Domain settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*-RemoteDomain' -Verbose:$VerbosePreference

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove Credential, Ensure, 'Default'

    $RemoteDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    if ($RemoteDomain['Ensure'] -eq 'Present')
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ('Removing the remote domain {0}' -f $RemoteDomain.Name)
            Remove-RemoteDomain -Identity $RemoteDomain.Name -confirm:$false
        }
        elseif ($RemoteDomain['DomainName'] -ne $DomainName)
        {
            #domain name changes can only be performed by deleting the existing domain and creating it new
            if ([String]::IsNullOrEmpty($Name))
            {
                $Name = $DomainName
            }

            Write-Verbose -Message ("Remote domain {0} requies a domain name changes. New domain name is: {1}.The domain will be removed and added again." -f $RemoteDomain['Name'], $DomainName )
            Remove-RemoteDomain -Identity $RemoteDomain.Name -confirm:$false
            New-RemoteDomain -DomainName $DomainName -Name $Name -confirm:$false
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
            Set-RemoteDomain @PSBoundParameters -Identity $Name -confirm:$false
        }
        else
        {
            Write-Verbose -Message ('Remote Domain {0} not compliant. Setting the desired attributes.' -f $RemoteDomain.Name)
            $PSBoundParameters['Identity'] = $RemoteDomain['Name']
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
            Set-RemoteDomain @PSBoundParameters -confirm:$false
        }
    }
    else
    {
        Write-Verbose -Message ('Remote domain {0} does not exist. Creating it...' -f $RemoteDomain.Name)

        if ([String]::IsNullOrEmpty($Name))
        {
            $Name = $DomainName
        }

        New-RemoteDomain -DomainName $DomainName -Name $Name -confirm:$false
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
        Set-RemoteDomain @PSBoundParameters -Identity $Name -confirm:$false
    }
}

<#
    .SYNOPSIS
        Tests the state of the resource
    .PARAMETER DomainName
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER AllowedOOFType
        The AllowedOOFType parameter specifies the type of automatic replies or out-of-office (also known as OOF) notifications than can be sent to recipients in the remote domain.
    .PARAMETER AutoForwardEnabled
        The AutoForwardEnabled parameter specifies whether to allow messages that are auto-forwarded by client email programs in your organization.
    .PARAMETER AutoReplyEnabled
        The AutoReplyEnabled parameter specifies whether to allow messages that are automatic replies from client email programs in your organization
    .PARAMETER ContentType
        The ContentType parameter specifies the outbound message content type and formatting.
    .PARAMETER DeliveryReportEnabled
        The DeliveryReportEnabled parameter specifies whether to allow delivery reports from client software in your organization to recipients in the remote domain.
    .PARAMETER DisplaySenderName
        The DisplaySenderName parameter specifies whether to show the sender's Display Name in the From email address for messages sent to recipients in the remote domain.
    .PARAMETER IsInternal
        The IsInternal parameter specifies whether the recipients in the remote domain are considered to be internal recipients.
    .PARAMETER MeetingForwardNotificationEnabled
        The MeetingForwardNotificationEnabled parameter specifies whether to enable meeting forward notifications for recipients in the remote domain.
    .PARAMETER Name
        The Name parameter specifies a unique name for the remote domain object.
    .PARAMETER NDREnabled
        The NDREnabled parameter specifies whether to allow non-delivery reports.
    .PARAMETER NonMimeCharacterSet
        The NonMimeCharacterSet parameter specifies a character set for plain text messages without defined character sets that are sent from your organization to recipients in the remote domain.
    .PARAMETER UseSimpleDisplayName
        The UseSimpleDisplayName parameter specifies whether the sender's simple display name is used for the From email address in messages sent to recipients in the remote domain.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        # The name of the accepted domain
        [Parameter(Mandatory = $true)]
        [string]
        $DomainName,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [string]
        $AllowedOOFType,

        [Parameter()]
        [bool]
        $AutoForwardEnabled = $true,

        [Parameter()]
        [bool]
        $AutoReplyEnabled = $true,

        [Parameter()]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [string]
        $ContentType,

        [Parameter()]
        [bool]
        $DeliveryReportEnabled = $true,

        [Parameter()]
        [bool]
        $DisplaySenderName = $true,

        [Parameter()]
        [bool]
        $IsInternal = $false,

        [Parameter()]
        [bool]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter()]
        [bool]
        $NDREnabled = $true,

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $NonMimeCharacterSet,

        [Parameter()]
        [bool]
        $UseSimpleDisplayName = $false
    )

    Write-Verbose -Message 'Testing the Exchange Remote Domain settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $targetResourceInCompliance = $true

    $RemoteDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose'
    $DifferenceObjectHashTable = @{} + $PSBoundParameters

    if ($null -eq $PSBoundParameters['Name'])
    {
        $DifferenceObjectHashTable['Name'] = $DomainName
    }

    if ($RemoteDomain['Ensure'] -eq 'Absent' -and $Ensure -ne 'Absent')
    {
        Write-Verbose -Message "Domain $DomainName does not exist."
        $targetResourceInCompliance = $false
    }
    elseif ($RemoteDomain['Ensure'] -ne 'Absent' -and $Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Domain $DomainName will be deleted."
        $targetResourceInCompliance = $false
    }
    else
    {
        $referenceObject = [PSCustomObject]$RemoteDomain
        $differenceObject = [PSCustomObject]$DifferenceObjectHashTable

        foreach ($property in $DifferenceObjectHashTable.Keys)
        {
            if (Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -Property $property)
            {
                Write-Verbose -Message ("Invalid setting '{0}'. Expected value: {1}. Actual value: {2}" -f $property, $DifferenceObjectHashTable[$property], $RemoteDomain[$property])
                $targetResourceInCompliance = $false
                break;
            }
        }
    }

    return $targetResourceInCompliance
}
