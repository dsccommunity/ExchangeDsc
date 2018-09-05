@{
    # Version number of this module.
    moduleVersion = '1.23.0.0'

    # ID used to uniquely identify this module
    GUID = '9a908ca3-8a67-485c-a014-66ba37fcc2a4'

    # Author of this module
    Author = 'Microsoft Corporation'

    # Company or vendor of this module
    CompanyName = 'Microsoft Corporation'

    # Copyright statement for this module
    Copyright = '(c) 2018 Microsoft Corporation. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'Module with DSC Resources for deployment and configuration of Microsoft Exchange Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @("Modules\xExchangeHelper.psm1")

    # Functions to export from this module
    FunctionsToExport = '*'

    # Cmdlets to export from this module
    CmdletsToExport = '*'

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/PowerShell/xExchange/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/PowerShell/xExchange'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
        ReleaseNotes = '- Fixes issue with xExchMaintenanceMode on Exchange 2016 where the cluster
  does not get paused when going into maintenance mode. Also fixes issue
  where services fail to stop, start, pause, or resume.
- Explicitly cast member types in Get-DscConfiguration return hashtables to
  align with the types defined in the resource schemas. Fixes an issue where
  Get-DscConfiguration fails to return a value.
- xExchClientAccessServer: Fixes issue where AlternateServiceAccountConfiguration
  or RemoveAlternateServiceAccountCredentials parameters can"t be used at the
  same time as other optional parameters.
- xExchInstall: Fixes issue where Test-TargetResource returns true if setup is
  running. Fixes issue where setup is not detected as having been successfully
  completed even if setup was successful. Adds initial set of unit tests for
  xExchInstall and related functions.
- Remove VerbosePreference from function parameters and update all calls to
  changed functions.
- Fixes multiple PSScriptAnalyzer issues. Specifically, fixes all instances of
  PSAvoidTrailingWhitespace, PSAvoidGlobalVars,
  PSAvoidUsingConvertToSecureStringWithPlainText, PSUseSingularNouns, and
  fixes many instances of PSUseDeclaredVarsMoreThanAssignments.
- Add support for Exchange Server 2019 - Preview

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}



