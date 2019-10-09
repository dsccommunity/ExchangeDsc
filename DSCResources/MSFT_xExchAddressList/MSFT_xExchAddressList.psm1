function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]

    param(
        # The name of the address book
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential
    )

    Write-Verbose -Message 'Getting the Exchange Address List'

    Write-FunctionEntry -Parameters @{'Identity' = $Name } -Verbose:$VerbosePreference

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
function Set-TargetResource
{
    [CmdletBinding()]
    param(
        # The name of the address book
        [Parameter(Mandatory = $true)]
        [string]
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
        [string[]]
        $ConditionalCompany,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [string[]]
        $ConditionalDepartment,

        [Parameter()]
        [string[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [string]
        $Container,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [ValidateSet('MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources', 'AllRecipients')]
        [string[]]
        $IncludedRecipients,

        [Parameter()]
        [string]
        $RecipientContainer,

        [Parameter()]
        [string]
        $RecipientFilter
    )

    Write-Verbose -Message 'Setting the Exchange AddresslList settings'

    Write-FunctionEntry -Parameters @{'Identity' = $Name } -Verbose:$VerbosePreference

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
            Remove-AddressList -Identity $addressList.Name -confirm:$false
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
                $PSBoundParameters['RecipientFilter'] = [scriptblock]::Create($PSBoundParameters['RecipientFilter'])
                Set-AddressList @PSBoundParameters -confirm:$false
            }
            else
            {
                Set-AddressList @PSBoundParameters -confirm:$false
            }
        }
    }
    else
    {
        Write-Verbose -Message ('Address list {0} does not exist. Creating it...' -f $addressList.Name)
        Remove-FromPSBoundParametersUsingHashtable -PSBoundParametersIn $PSBoundParameters -ParamsToRemove 'Credential', 'Ensure'
        New-AddressList @PSBoundParameters -confirm:$false
    }
}
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param(
        # The name of the address book
        [Parameter(Mandatory = $true)]
        [string]
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
        [string[]]
        $ConditionalCompany,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute1,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute2,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute3,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute4,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute5,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute6,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute7,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute8,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute9,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute10,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute11,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute12,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute13,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute14,

        [Parameter()]
        [string[]]
        $ConditionalCustomAttribute15,

        [Parameter()]
        [string[]]
        $ConditionalDepartment,

        [Parameter()]
        [string[]]
        $ConditionalStateOrProvince,

        [Parameter()]
        [string]
        $Container,

        [Parameter()]
        [string]
        $DisplayName,

        [Parameter()]
        [ValidateSet('MailboxUsers', 'MailContacts', 'MailGroups', 'MailUsers', 'Resources', 'AllRecipients')]
        [string[]]
        $IncludedRecipients,

        [Parameter()]
        [string]
        $RecipientContainer,

        [Parameter()]
        [string]
        $RecipientFilter
    )

    Write-Verbose -Message 'Testing the Exchange AddresslList settings'

    Write-FunctionEntry -Parameters @{'Identity' = $Name } -Verbose:$VerbosePreference

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
        $referenceObject = [PSCustomObject]$addressList
        $differenceObject = [PSCustomObject]$DifferenceObjectHashTable

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
