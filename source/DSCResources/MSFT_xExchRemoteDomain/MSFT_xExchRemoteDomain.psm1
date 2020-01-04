<#
    .SYNOPSIS
        Gets the state of the resource
    .PARAMETER DomainName
        Specifies the SMTP domain that you want to establish as a remote domain.
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
        [Parameter(Mandatory = $true)]
        [System.String]
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

    $remoteDomain = Get-RemoteDomain -ErrorAction SilentlyContinue | Where-Object -FilterScript { $PSItem.DomainName -eq $DomainName }

    if ($null -eq $remoteDomain -and $DomainName -match '^\*\.')
    {
        # Try to match based on name - covering some edge cases
        $remoteDomain = Get-RemoteDomain -ErrorAction SilentlyContinue | Where-Object -FilterScript { $PSItem.Name -eq $DomainName.Trim('*.') }
    }

    $remoteDomainProperties = @(
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

    if ($null -ne $remoteDomain)
    {
        $returnValue = @{
            Ensure = 'Present'
        }
        foreach ($property in $remoteDomain.PSObject.Properties.Name)
        {
            if ([System.String] $remoteDomain.$property -and $remoteDomainProperties -contains $property)
            {
                $returnValue[$property] = $remoteDomain.$property
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
        Specifies the SMTP domain that you want to establish as a remote domain.
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
        [Parameter(Mandatory = $true)]
        [System.String]
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
        [System.String]
        $AllowedOOFType,

        [Parameter()]
        [System.Boolean]
        $AutoForwardEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $AutoReplyEnabled = $true,

        [Parameter()]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [System.String]
        $ContentType,

        [Parameter()]
        [System.Boolean]
        $DeliveryReportEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $DisplaySenderName = $true,

        [Parameter()]
        [System.Boolean]
        $IsInternal = $false,

        [Parameter()]
        [System.Boolean]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $NDREnabled = $true,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NonMimeCharacterSet,

        [Parameter()]
        [System.Boolean]
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

    $remoteDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    if ($remoteDomain['Ensure'] -eq 'Present')
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ('Removing the remote domain {0}' -f $remoteDomain.Name)
            Remove-RemoteDomain -Identity $remoteDomain.Name -Confirm:$false
        }
        elseif ($remoteDomain['DomainName'] -ne $DomainName)
        {
            #domain name changes can only be performed by deleting the existing domain and creating it new
            if ([System.String]::IsNullOrEmpty($Name))
            {
                $Name = $DomainName
            }

            Write-Verbose -Message ("Remote domain {0} requies a domain name changes. New domain name is: {1}.The domain will be removed and added again." -f $remoteDomain['Name'], $DomainName )
            Remove-RemoteDomain -Identity $remoteDomain.Name -Confirm:$false
            New-RemoteDomain -DomainName $DomainName -Name $Name -Confirm:$false
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
            Set-RemoteDomain @PSBoundParameters -Identity $Name -Confirm:$false
        }
        else
        {
            Write-Verbose -Message ('Remote Domain {0} not compliant. Setting the desired attributes.' -f $remoteDomain.Name)
            $PSBoundParameters['Identity'] = $remoteDomain['Name']
            Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
            Set-RemoteDomain @PSBoundParameters -Confirm:$false
        }
    }
    else
    {
        Write-Verbose -Message ('Remote domain {0} does not exist. Creating it...' -f $remoteDomain.Name)

        if ([System.String]::IsNullOrEmpty($Name))
        {
            $Name = $DomainName
        }

        New-RemoteDomain -DomainName $DomainName -Name $Name -Confirm:$false
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
        Set-RemoteDomain @PSBoundParameters -Identity $Name -Confirm:$false
    }
}

<#
    .SYNOPSIS
        Tests the state of the resource
    .PARAMETER DomainName
        Specifies the SMTP domain that you want to establish as a remote domain.
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
        [Parameter(Mandatory = $true)]
        [System.String]
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
        [System.String]
        $AllowedOOFType,

        [Parameter()]
        [System.Boolean]
        $AutoForwardEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $AutoReplyEnabled = $true,

        [Parameter()]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [System.String]
        $ContentType,

        [Parameter()]
        [System.Boolean]
        $DeliveryReportEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $DisplaySenderName = $true,

        [Parameter()]
        [System.Boolean]
        $IsInternal = $false,

        [Parameter()]
        [System.Boolean]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter()]
        [System.Boolean]
        $NDREnabled = $true,

        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $NonMimeCharacterSet,

        [Parameter()]
        [System.Boolean]
        $UseSimpleDisplayName = $false
    )

    Write-Verbose -Message 'Testing the Exchange Remote Domain settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $DomainName
    } -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $targetResourceInCompliance = $true

    $remoteDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose'
    $differenceObjectHashTable = @{} + $PSBoundParameters

    if ($null -eq $PSBoundParameters['Name'])
    {
        $differenceObjectHashTable['Name'] = $DomainName
    }

    if ($remoteDomain['Ensure'] -eq 'Absent' -and $Ensure -ne 'Absent')
    {
        Write-Verbose -Message "Domain $DomainName does not exist."
        $targetResourceInCompliance = $false
    }
    elseif ($remoteDomain['Ensure'] -ne 'Absent' -and $Ensure -eq 'Absent')
    {
        Write-Verbose -Message "Domain $DomainName will be deleted."
        $targetResourceInCompliance = $false
    }
    else
    {
        $referenceObject = [PSCustomObject] $remoteDomain
        $differenceObject = [PSCustomObject] $differenceObjectHashTable

        foreach ($property in $differenceObjectHashTable.Keys)
        {
            if (Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -Property $property)
            {
                Write-Verbose -Message ("Invalid setting '{0}'. Expected value: {1}. Actual value: {2}" -f $property, $differenceObjectHashTable[$property], $remoteDomain[$property])
                $targetResourceInCompliance = $false
                break;
            }
        }
    }

    return $targetResourceInCompliance
}
