@{
    # Version number of this module.
    moduleVersion = '1.24.0.0'

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
        ReleaseNotes = '- xExchangeHelper.psm1: Renamed common functions to use proper Verb-Noun
  format. Also addresses many common style issues in functions in the file, as
  well as in calls to these functions from other files.
- MSFT_xExchTransportService: Removed functions that were duplicates of helper
  functions in xExchangeHelper.psm1.
- Fixes an issue where only objects of type Mailbox can be specified as a
  Journal Recipient. Now MailUser and MailContact types can be used as well.
- Update appveyor.yml to use the default template.
- Added default template files .codecov.yml, .gitattributes, and .gitignore, and
  .vscode folder.
- Add Unit Tests for xExchAntiMalwareScanning
- Add remaining Unit Tests for xExchInstall, and for most common setup
  functions
- Added ActionForUnknownFileAndMIMETypes,WSSAccessOnPublicComputersEnabled,
  WSSAccessOnPrivateComputersEnabled,UNCAccessOnPublicComputersEnabled
  UNCAccessOnPrivateComputersEnabled and GzipLevel to xExchOwaVirtualDirectory.
- Added GzipLevel and AdminEnabled to xExchEcpVirtualDirectory.
- Added OAuthAuthentication to xExchOabVirtualDirectory.
- Updated readme with the new parameters and removed a bad parameter from
  xExchOwaVirtualDirectory that did not actually exist.
- Updated .gitattributes to allow test .pfx files to be saved as binary
- Added Cumulative Update / Exchange update support to xExchInstall resource.
- Add remaining Unit Tests for all xExchangeHelper functions that don"t
  require the loading of Exchange DLL"s.
- Renamed and moved file Examples/HelperScripts/ExchangeConfigHelper.psm1 to
  Modules/xExchangeCalculatorHelper.psm1. Renamed functions within the module
  to conform to proper function naming standards. Added remaining Unit tests
  for module.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}




