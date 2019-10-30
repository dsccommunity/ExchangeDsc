function Get-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Lowest', 'Low', 'Medium', 'High', 'Expert')]
        [System.String]
        $Level
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EventLogLevel' -Verbose:$VerbosePreference

    $eventLogLevel = Get-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)"

    if ($null -ne $eventLogLevel)
    {
        $returnValue = @{
            Identity = [System.String] $Identity
            Level    = [System.String] $eventLogLevel.EventLevel
        }
    }

    $returnValue
}

function Set-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Lowest', 'Low', 'Medium', 'High', 'Expert')]
        [System.String]
        $Level
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Set-EventLogLevel' -Verbose:$VerbosePreference

    Set-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)" -Level $Level
}

function Test-TargetResource
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSDSCUseVerboseMessageInDSCResource", "")]
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Identity,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Lowest', 'Low', 'Medium', 'High', 'Expert')]
        [System.String]
        $Level
    )

    Write-FunctionEntry -Parameters @{
        'Identity' = $Identity
    } -Verbose:$VerbosePreference

    # Establish remote PowerShell session
    Get-RemoteExchangeSession -Credential $Credential -CommandsToLoad 'Get-EventLogLevel' -Verbose:$VerbosePreference

    $eventLogLevel = Get-EventLogLevel -Identity "$($env:COMPUTERNAME)\$($Identity)"

    $testResults = $true

    if ($null -eq $eventLogLevel)
    {
        Write-Error -Message 'Failed to retrieve any objects with specified Identity.'

        $testResults = $false
    }
    else
    {
        if (!(Test-ExchangeSetting -Name 'Level' -Type 'String' -ExpectedValue $Level -ActualValue $eventLogLevel.EventLevel -PSBoundParametersIn $PSBoundParameters -Verbose:$VerbosePreference))
        {
            $testResults = $false
        }
    }

    return $testResults
}

Export-ModuleMember -Function *-TargetResource
