@{
    # Version number of this module.
    moduleVersion = '1.21.0.0'

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
        ReleaseNotes = '- Added CHANGELOG.md file
- Added .markdownlint.json file
- Updated README.md and CHANGELOG.md files to respect MD009, MD0013 and MD032 rules
- Added .MetaTestOptIn.json file
- Updated appveyor.yml file
- Added .codecov.yml file
- Renamed Test folder to Tests
- Updated README.md: Add codecov badges
- Fixed PSSA required rules in:
  - xExchClientAccessServer.psm1
  - xExchInstall.psm1
  - xExchMaintenanceMode.psm1
  - TransportMaintenance.psm1
  - xExchTransportService.psm1
- Fixed Validate Example files in:
  - ConfigureAutoMountPoints-FromCalculator.ps1
  - ConfigureAutoMountPoints-Manual.ps1
  - ConfigureDatabases-FromCalculator.ps1
  - InternetFacingSite.ps1
  - RegionalNamespaces.ps1
  - SingleNamespace.ps1
  - ConfigureVirtualDirectories.ps1
  - CreateAndConfigureDAG.ps1
  - EndToEndExample 1 to 10 files
  - JetstressAutomation
  - MaintenanceMode
  - PostInstallationConfiguration.ps1
  - InstallExchange.ps1
  - QuickStartTemplate.ps1
  - WaitForADPrep.ps1
- Remove default value for Switch Parameter in
  TransportMaintenance.psm1 for functions:
  - Clear-DiscardEvent
  - LogIfRemain
  - Wait-EmptyEntriesCompletion
  - Update-EntriesTracker
  - Remove-CompletedEntriesFromHashtable
- Fixed PSSA custom rules in:
  - xExchActiveSyncVirtualDirectory.psm1
  - xExchAntiMalwareScanning.psm1
  - xExchAutodiscoverVirtualDirectory.psm1
  - xExchAutoMountPoint.psm1
  - xExchClientAccessServer.psm1
  - xExchDatabaseAvailabilityGroup.psm1
  - xExchDatabaseAvailabilityGroupMember.psm1
  - xExchDatabaseAvailabilityGroupNetwork.psm1
  - xExchEcpVirtualDirectory.psm1
  - xExchEventLogLevel.psm1
  - xExchExchangeCertificate.psm1
  - xExchExchangeServer.psm1
  - xExchImapSettings.psm1
  - xExchInstall.psm1
  - xExchJetstress.psm1
  - xExchJetstressCleanup.psm1
  - xExchMailboxDatabase.psm1
  - xExchMailboxDatabaseCopy.psm1
  - xExchMailboxServer.psm1
  - xExchMailboxTransportService.psm1
  - xExchMaintenanceMode.psm1
  - xExchMapiVirtualDirectory.psm1
  - xExchOabVirtualDirectory.psm1
  - xExchOutlookAnywhere.psm1
  - xExchOwaVirtualDirectory.psm1
  - xExchPopSettings.psm1
  - xExchPowerShellVirtualDirectory.psm1
  - xExchReceiveConnector.psm1
  - xExchUMCallRouterSettings.psm1
  - xExchUMService.psm1
  - xExchWaitForADPrep.psm1
  - xExchWaitForDAG.psm1
  - xExchWaitForMailboxDatabase.psm1
  - xExchWebServicesVirtualDirectory.psm1
- Updated xExchange.psd1
- Added issue template file (ISSUE\_TEMPLATE.md) for "New Issue" and pull request
  template file (PULL\_REQUEST\_TEMPLATE.md) for "New Pull Request".
- Fix issue Diagnostics.CodeAnalysis.SuppressMessageAttribute best practices
- Renamed xExchangeCommon.psm1 to xExchangeHelper.psm1
- Renamed the folder MISC (that contains the helper) to Modules
- Added xExchangeHelper.psm1 in xExchange.psd1 (section NestedModules)
- Removed all lines with Import-Module xExchangeCommon.psm1
- Updated .MetaTestOptIn.json file with Custom Script Analyzer Rules
- Added Integration, TestHelpers and Unit folder
- Moved Data folder in Tests
- Moved Integration tests to Integration folder
- Moved Unit test to Unit folder
- Renamed xEchange.Tests.Common.psm1 to xExchangeTestHelper.psm1
- Renamed xEchangeCommon.Unit.Tests.ps1 to xExchangeCommon.Tests.ps1
- Renamed function PrepTestDAG to Initialize-TestForDAG
- Moved function Initialize-TestForDAG to xExchangeTestHelper.psm1
- Fix error-level PS Script Analyzer rules for TransportMaintenance.psm1

'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}

