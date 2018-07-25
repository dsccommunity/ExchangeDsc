@{
    # Version number of this module.
    moduleVersion = '1.22.0.0'

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
        ReleaseNotes = '- Fixed issue in xExchInstall where winrm config command fails to execute
- Fixed issue in xExchInstall where a failed Exchange setup run is not
  reported, and subsequent DSC resources are allowed to run
- Fixed issue in xExchAutoMountPoint where Test-TargetResource fails
  after mount points have been successfully configured.
- Fixed issue in xExchAutoMountPoint where Set-TargetResource fails
  if EnsureExchangeVolumeMountPointIsLast parameter is specified.
- Updated xExchAutoMountPoint, xExchJetstressCleanup, and related DiskPart
  functions to not use global variables.
- Fixes broken tests in:
  MSFT_xExchDatabaseAvailabilityGroup.Integration.Tests.ps1,
  MSFT_xExchExchangeCertificate.Integration.Tests.ps1,
  MSFT_xExchOutlookAnywhere.Integration.Tests.ps1,
  MSFT_xExchPopSettings.Integration.Tests.ps1,
  xExchangeConfigHelper.Unit.Tests.ps1
- Update most Test-TargetResource functions to output all invalid settings,
  instead of just the first detected invalid setting

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}


