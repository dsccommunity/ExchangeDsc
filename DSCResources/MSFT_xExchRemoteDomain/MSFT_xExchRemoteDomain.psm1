function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    param(
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

    Write-FunctionEntry -Parameters @{'Identity' = $DomainName } -Verbose:$VerbosePreference

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
        'DependsOn'
        'IsInternal'
        'MeetingForwardNotificationEnabled'
        'NDREnabled'
        'NonMimeCharacterSet'
        'PsDscRunAsCredential'
        'UseSimpleDisplayName'
    )

    if ($null -ne $RemoteDomain)
    {
        $returnValue = @{
            Ensure = 'Present'
        }
        foreach ($property in $RemoteDomain.PSObject.Properties.Name)
        {
            if ([string]$RemoteDomain.$property -and $RemoteDomainProperties -contains $property)
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
function Set-TargetResource
{
    [CmdletBinding()]
    param(
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [string]
        $AllowedOOFType,

        [Parameter(Mandatory = $false)]
        [bool]
        $AutoForwardEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $AutoReplyEnabled = $true,

        [Parameter(Mandatory = $false)]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [string]
        $ContentType,

        [Parameter(Mandatory = $false)]
        [bool]
        $DeliveryReportEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $DisplaySenderName = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $IsInternal = $false,

        [Parameter(Mandatory = $false)]
        [bool]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $NDREnabled = $true,

        [Parameter(Mandatory = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [string]
        $NonMimeCharacterSet,

        [Parameter(Mandatory = $false)]
        [bool]
        $UseSimpleDisplayName = $false
    )

    Write-Verbose -Message 'Setting the Exchange Remote Domain settings'

    Write-FunctionEntry -Parameters @{'Identity' = $DomainName } -Verbose:$VerbosePreference

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
            if ($null -eq $Name)
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

        if ($null -eq $Name)
        {
            $Name = $DomainName
        }

        New-RemoteDomain -DomainName $DomainName -Name $Name -confirm:$false
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove DomainName
        Set-RemoteDomain @PSBoundParameters -Identity $Name -confirm:$false
    }
}
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
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

        [Parameter(Mandatory = $false)]
        [ValidateSet('External', 'ExternalLegacy', 'InternalLegacy', 'None')]
        [string]
        $AllowedOOFType,

        [Parameter(Mandatory = $false)]
        [bool]
        $AutoForwardEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $AutoReplyEnabled = $true,

        [Parameter(Mandatory = $false)]
        [ValidateSet('MimeHtml', 'MimeHtmlText', 'MimeText')]
        [string]
        $ContentType,

        [Parameter(Mandatory = $false)]
        [bool]
        $DeliveryReportEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $DisplaySenderName = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $IsInternal = $false,

        [Parameter(Mandatory = $false)]
        [bool]
        $MeetingForwardNotificationEnabled = $true,

        [Parameter(Mandatory = $false)]
        [bool]
        $NDREnabled = $true,

        [Parameter(Mandatory = $false)]
        [string]
        $Name,

        [Parameter(Mandatory = $false)]
        [string]
        $NonMimeCharacterSet,

        [Parameter(Mandatory = $false)]
        [bool]
        $UseSimpleDisplayName = $false
    )

    Write-Verbose -Message 'Testing the Exchange Remote Domain settings'

    Write-FunctionEntry -Parameters @{'Identity' = $DomainName } -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $targetResourceInCompliance = $true

    $RemoteDomain = Get-TargetResource -DomainName $DomainName -Credential $Credential

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose'
    $DifferenceObjectHashTable = @{ } + $PSBoundParameters

    if ($null -eq $PSBoundParameters['Name'])
    {
        $DifferenceObjectHashTable['Name'] = $DomainName
    }

    if ($RemoteDomain['Ensure'] -eq 'Absent' -and $Ensure -ne 'Absent')
    {
        Write-Verbose -Message "Domain $DomainName does not exist."
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
