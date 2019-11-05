<#
    .SYNOPSIS
        Gets the resource configuration.
    .PARAMETER Name
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER ConditionalCompany
        The ConditionalCompany parameter specifies a precanned filter that's based on the value of the recipient's Company property.
    .PARAMETER ConditionalCustomAttribute1
        The ConditionalCustomAttribute1 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute1 property.
    .PARAMETER ConditionalCustomAttribute2
        The ConditionalCustomAttribute2 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute2 property.
    .PARAMETER ConditionalCustomAttribute3
        The ConditionalCustomAttribute3 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute3 property.
    .PARAMETER ConditionalCustomAttribute4
        The ConditionalCustomAttribute4 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute4 property.
    .PARAMETER ConditionalCustomAttribute5
        The ConditionalCustomAttribute5 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute5 property.
    .PARAMETER ConditionalCustomAttribute6
        The ConditionalCustomAttribute6 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute6 property.
    .PARAMETER ConditionalCustomAttribute7
        The ConditionalCustomAttribute7 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute7 property.
    .PARAMETER ConditionalCustomAttribute8
        The ConditionalCustomAttribute8 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute8 property.
    .PARAMETER ConditionalCustomAttribute9
        The ConditionalCustomAttribute9 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute9 property.
    .PARAMETER ConditionalCustomAttribute10
        The ConditionalCustomAttribute10 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute10 property.
    .PARAMETER ConditionalCustomAttribute11
        The ConditionalCustomAttribute11 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute11 property.
    .PARAMETER ConditionalCustomAttribute12
        The ConditionalCustomAttribute12 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute12 property.
    .PARAMETER ConditionalCustomAttribute13
        The ConditionalCustomAttribute13 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute13 property.
    .PARAMETER ConditionalCustomAttribute14
        The ConditionalCustomAttribute14 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute14 property.
    .PARAMETER ConditionalCustomAttribute15
        The ConditionalCustomAttribute15 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute15 property.
    .PARAMETER ConditionalDepartment
        The ConditionalDepartment parameter specifies a precanned filter that's based on the value of the recipient's Department property.
    .PARAMETER ConditionalStateOrProvince
        The ConditionalStateOrProvince parameter specifies a precanned filter that's based on the value of the recipient's StateOrProvince  property.
    .PARAMETER Container
        The Container parameter specifies where to create the address list.
    .PARAMETER DisplayName
        Specifies the displayname.
    .PARAMETER IncludedRecipients
        Specifies a precanned filter that's based on the recipient type.
    .PARAMETER RecipientContainer
        The RecipientContainer parameter specifies a filter that's based on the recipient's location in Active Directory.
    .PARAMETER RecipientFilter
        The RecipientFilter parameter specifies a custom OPath filter that's based on the value of any available recipient property.
#>
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Write-Verbose -Message 'Getting the Exchange Address List'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-AddressList' -Verbose:$VerbosePreference

    $addressList = Get-AddressList -Identity $Name -ErrorAction SilentlyContinue

    $addressListProperties = @(
        'Name'
        'IncludedRecipients'
        'ConditionalCompany'
        'ConditionalCustomAttribute1'
        'ConditionalCustomAttribute10'
        'ConditionalCustomAttribute11'
        'ConditionalCustomAttribute12'
        'ConditionalCustomAttribute13'
        'ConditionalCustomAttribute14'
        'ConditionalCustomAttribute15'
        'ConditionalCustomAttribute2'
        'ConditionalCustomAttribute3'
        'ConditionalCustomAttribute4'
        'ConditionalCustomAttribute5'
        'ConditionalCustomAttribute6'
        'ConditionalCustomAttribute7'
        'ConditionalCustomAttribute8'
        'ConditionalCustomAttribute9'
        'ConditionalDepartment'
        'ConditionalStateOrProvince'
        'Container'
        'DisplayName'
        'RecipientContainer'
        'RecipientFilter'
    )

    if ($null -ne $addressList)
    {
        $returnValue = @{
            Ensure = 'Present'
        }
        foreach ($property in $addressList.PSObject.Properties.Name)
        {
            if ($addressList.$property -and $addressListProperties -contains $property)
            {
                if ($property -eq 'RecipientFilter')
                {
                    $returnValue[$property] = "{$($addressList.$property)}"
                }
                else
                {
                    $returnValue[$property] = $addressList.$property
                }
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
        Sets the resource configuration.
    .PARAMETER Name
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER ConditionalCompany
        The ConditionalCompany parameter specifies a precanned filter that's based on the value of the recipient's Company property.
    .PARAMETER ConditionalCustomAttribute1
        The ConditionalCustomAttribute1 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute1 property.
    .PARAMETER ConditionalCustomAttribute2
        The ConditionalCustomAttribute2 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute2 property.
    .PARAMETER ConditionalCustomAttribute3
        The ConditionalCustomAttribute3 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute3 property.
    .PARAMETER ConditionalCustomAttribute4
        The ConditionalCustomAttribute4 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute4 property.
    .PARAMETER ConditionalCustomAttribute5
        The ConditionalCustomAttribute5 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute5 property.
    .PARAMETER ConditionalCustomAttribute6
        The ConditionalCustomAttribute6 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute6 property.
    .PARAMETER ConditionalCustomAttribute7
        The ConditionalCustomAttribute7 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute7 property.
    .PARAMETER ConditionalCustomAttribute8
        The ConditionalCustomAttribute8 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute8 property.
    .PARAMETER ConditionalCustomAttribute9
        The ConditionalCustomAttribute9 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute9 property.
    .PARAMETER ConditionalCustomAttribute10
        The ConditionalCustomAttribute10 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute10 property.
    .PARAMETER ConditionalCustomAttribute11
        The ConditionalCustomAttribute11 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute11 property.
    .PARAMETER ConditionalCustomAttribute12
        The ConditionalCustomAttribute12 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute12 property.
    .PARAMETER ConditionalCustomAttribute13
        The ConditionalCustomAttribute13 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute13 property.
    .PARAMETER ConditionalCustomAttribute14
        The ConditionalCustomAttribute14 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute14 property.
    .PARAMETER ConditionalCustomAttribute15
        The ConditionalCustomAttribute15 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute15 property.
    .PARAMETER ConditionalDepartment
        The ConditionalDepartment parameter specifies a precanned filter that's based on the value of the recipient's Department property.
    .PARAMETER ConditionalStateOrProvince
        The ConditionalStateOrProvince parameter specifies a precanned filter that's based on the value of the recipient's StateOrProvince  property.
    .PARAMETER Container
        The Container parameter specifies where to create the address list.
    .PARAMETER DisplayName
        Specifies the displayname.
    .PARAMETER IncludedRecipients
        Specifies a precanned filter that's based on the recipient type.
    .PARAMETER RecipientContainer
        The RecipientContainer parameter specifies a filter that's based on the recipient's location in Active Directory.
    .PARAMETER RecipientFilter
        The RecipientFilter parameter specifies a custom OPath filter that's based on the value of any available recipient property.
#>
function Set-TargetResource
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [System.String]
        $Container,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateSet('MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources', 'AllRecipients')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String]
        $RecipientContainer,

        [Parameter()]
        [System.String]
        $RecipientFilter
    )

    Write-Verbose -Message 'Setting the Exchange AddresslList settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad '*-AddressList' -Verbose:$VerbosePreference

    if ($PSBoundParameters.ContainsKey('RecipientFilter') -and
        ($PSBoundParameters.ContainsKey('IncludedRecipients') -or
            $PSBoundParameters.Keys -contains 'Condit'))
    {
        throw 'You can''t use customized filters and precanned filters at the same time!'
    }

    # Ensure an empty string is $null and not a string
    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters
    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove Credential, Ensure

    $addressList = Get-TargetResource -Name $Name -Credential $Credential

    if ($addressList['Ensure'] -eq 'Present')
    {
        if ($Ensure -eq 'Absent')
        {
            Write-Verbose -Message ('Removing the address list {0}' -f $addressList.Name)
            Remove-AddressList -Identity $addressList.Name -Confirm:$false
        }
        else
        {
            Write-Verbose -Message ('Address list {0} not compliant. Setting the desired attributes.' -f $addressList.Name)

            $PSBoundParameters['Identity'] = $Name

            if ($PSBoundParameters.ContainsKey('Container'))
            {
                Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove Container
            }

            if ($null -eq $PSBoundParameters['DisplayName'])
            {
                $PSBoundParameters['DisplayName'] = $Name
            }
            if ($PSBoundParameters['RecipientFilter'])
            {
                $PSBoundParameters['RecipientFilter'] = [ScriptBlock]::Create($PSBoundParameters['RecipientFilter'])
                Set-AddressList @PSBoundParameters -Confirm:$false
            }
            else
            {
                Set-AddressList @PSBoundParameters -Confirm:$false
            }
        }
    }
    else
    {
        Write-Verbose -Message ('Address list {0} does not exist. Creating it...' -f $addressList.Name)
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure'
        New-AddressList @PSBoundParameters -Confirm:$false
    }
}

<#
    .SYNOPSIS
        Tests the resource configuration.
    .PARAMETER Name
        The name of the address list.
    .PARAMETER Credential
        Credentials used to establish a remote PowerShell session to Exchange.
    .PARAMETER ConditionalCompany
        The ConditionalCompany parameter specifies a precanned filter that's based on the value of the recipient's Company property.
    .PARAMETER ConditionalCustomAttribute1
        The ConditionalCustomAttribute1 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute1 property.
    .PARAMETER ConditionalCustomAttribute2
        The ConditionalCustomAttribute2 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute2 property.
    .PARAMETER ConditionalCustomAttribute3
        The ConditionalCustomAttribute3 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute3 property.
    .PARAMETER ConditionalCustomAttribute4
        The ConditionalCustomAttribute4 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute4 property.
    .PARAMETER ConditionalCustomAttribute5
        The ConditionalCustomAttribute5 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute5 property.
    .PARAMETER ConditionalCustomAttribute6
        The ConditionalCustomAttribute6 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute6 property.
    .PARAMETER ConditionalCustomAttribute7
        The ConditionalCustomAttribute7 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute7 property.
    .PARAMETER ConditionalCustomAttribute8
        The ConditionalCustomAttribute8 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute8 property.
    .PARAMETER ConditionalCustomAttribute9
        The ConditionalCustomAttribute9 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute9 property.
    .PARAMETER ConditionalCustomAttribute10
        The ConditionalCustomAttribute10 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute10 property.
    .PARAMETER ConditionalCustomAttribute11
        The ConditionalCustomAttribute11 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute11 property.
    .PARAMETER ConditionalCustomAttribute12
        The ConditionalCustomAttribute12 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute12 property.
    .PARAMETER ConditionalCustomAttribute13
        The ConditionalCustomAttribute13 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute13 property.
    .PARAMETER ConditionalCustomAttribute14
        The ConditionalCustomAttribute14 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute14 property.
    .PARAMETER ConditionalCustomAttribute15
        The ConditionalCustomAttribute15 parameter specifies a precanned filter that's based on the value of the recipient's ConditionalCustomAttribute15 property.
    .PARAMETER ConditionalDepartment
        The ConditionalDepartment parameter specifies a precanned filter that's based on the value of the recipient's Department property.
    .PARAMETER ConditionalStateOrProvince
        The ConditionalStateOrProvince parameter specifies a precanned filter that's based on the value of the recipient's StateOrProvince  property.
    .PARAMETER Container
        The Container parameter specifies where to create the address list.
    .PARAMETER DisplayName
        Specifies the displayname.
    .PARAMETER IncludedRecipients
        Specifies a precanned filter that's based on the recipient type.
    .PARAMETER RecipientContainer
        The RecipientContainer parameter specifies a filter that's based on the recipient's location in Active Directory.
    .PARAMETER RecipientFilter
        The RecipientFilter parameter specifies a custom OPath filter that's based on the value of any available recipient property.
#>
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter()]
        [ValidateSet('Present', 'Absent')]
        [System.String]
        $Ensure = 'Present',

        [Parameter()]
        [System.String[]]
        $ConditionalCompany,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [System.String[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [System.String[]]
        $ConditionalDepartment,

        [Parameter()]
        [System.String[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [System.String]
        $Container,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [ValidateSet('MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources', 'AllRecipients')]
        [System.String[]]
        $IncludedRecipients,

        [Parameter()]
        [System.String]
        $RecipientContainer,

        [Parameter()]
        [System.String]
        $RecipientFilter
    )

    Write-Verbose -Message 'Testing the Exchange AddresslList settings'

    Write-FunctionEntry -Parameters @{
        'Identity' = $Name
    } -Verbose:$VerbosePreference

    Set-EmptyStringParamsToNull -PSBoundParametersIn $PSBoundParameters

    $targetResourceInCompliance = $true

    $addressList = Get-TargetResource -Name $Name -Credential $Credential

    Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Verbose'
    $DifferenceObjectHashTable = @{ } + $PSBoundParameters

    if ($null -eq $PSBoundParameters['Container'])
    {
        $DifferenceObjectHashTable['Container'] = '\'
    }
    if ($null -eq $PSBoundParameters['DisplayName'])
    {
        $DifferenceObjectHashTable['DisplayName'] = $Name
    }

    if ($addressList['Ensure'] -eq 'Absent' -and $Ensure -ne 'Absent')
    {
        $targetResourceInCompliance = $false
    }
    else
    {
        $referenceObject = [PSCustomObject] $addressList
        $differenceObject = [PSCustomObject] $DifferenceObjectHashTable

        foreach ($property in $DifferenceObjectHashTable.Keys)
        {
            if (Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -Property $property)
            {
                Write-Verbose -Message ("Invalid setting '{0}'. Expected value: {1}. Actual value: {2}" -f $property, $DifferenceObjectHashTable[$property], $addressList[$property])
                $targetResourceInCompliance = $false
                break;
            }
        }
    }

    return $targetResourceInCompliance
}
