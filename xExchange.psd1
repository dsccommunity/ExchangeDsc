@{
    # Version number of this module.
    moduleVersion = '1.25.0.0'

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
        ReleaseNotes = '- Opt-in for the common test flagged Script Analyzer rules
  ([issue 234](https://github.com/PowerShell/xExchange/issues/234)).
- Opt-in for the common test testing for relative path length.
- Removed the property `PSDscAllowPlainTextPassword` from all examples
  so the examples are secure by default. The property
  `PSDscAllowPlainTextPassword` was previously needed to (test) compile
  the examples in the CI pipeline, but now the CI pipeline is using a
  certificate to compile the examples.
- Opt-in for the common test that validates the markdown links.
- Fix typo of the word "Certificate" in several example files.
- Add spaces between array members.
- Add initial set of Unit Tests (mostly Get-TargetResource tests) for all
  remaining resource files.
- Add WaitForComputerObject parameter to xExchWaitForDAG
- Add spaces between comment hashtags and comments.
- Add space between variable types and variables.
- Fixes issue where xExchMailboxDatabase fails to test for a Journal Recipient
  because the module did not load the Get-Recipient cmdlet (335).
- Fixes broken Integration tests in
  MSFT_xExchMaintenanceMode.Integration.Tests.ps1 (336).
- Fix issue where Get-ReceiveConnector against an Absent connector causes an
  error to be logged in the MSExchange Management log.
- Rename poorly named functions in xExchangeDiskPart.psm1 and
  MSFT_xExchAutoMountPoint.psm1, and add comment based help.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}





