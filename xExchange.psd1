@{
    # Version number of this module.
    moduleVersion = '1.27.0.0'

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
        ReleaseNotes = '- Added additional parameters to the MSFT_xExchTransportService resource
- Added additional parameters to the MSFT_xExchEcpVirtualDirectory resource
- Added additional unit tests to the MSFT_xExchAutodiscoverVirutalDirectory resource
- Added additional parameters to the MSFT_xExchExchangeCertificate resource
- MSFT_xExchMailboxDatabase: Fixes issue with DataMoveReplicationConstraint
  parameter (401)
- Added additional parameters and comment based help to the
  MSFT_xExchMailboxDatabase resource
- Move code that sets $global:DSCMachineStatus into a dedicated helper
  function.
  [Issue 407](https://github.com/PowerShell/xExchange/issues/407)
- Add missing parameters for xExchMailboxDatabaseCopy, adds comment based help,
  and adds remaining Unit tests.

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}







