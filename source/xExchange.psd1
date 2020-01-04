@{
    # Version number of this module.
    moduleVersion     = '1.30.0.0'

    # ID used to uniquely identify this module
    GUID              = '9a908ca3-8a67-485c-a014-66ba37fcc2a4'

    # Author of this module
    Author            = 'DSC Community'

    # Company or vendor of this module
    CompanyName       = 'DSC Community'

    # Copyright statement for this module
    Copyright         = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description       = 'Module with DSC Resources for deployment and configuration of Microsoft Exchange Server.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '4.0'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules     = @("Modules\xExchangeHelper.psm1")

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport   = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess.
    # This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData       = @{

        PSData = @{
            IconUri      = 'https://dsccommunity.org/images/DSC_Logo_300p.png'

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @('DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri   = 'https://github.com/dsccommunity/xExchange/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/dsccommunity/xExchange'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = ''

            Prerelease   = ''
        } # End of PSData hashtable

    } # End of PrivateData hashtable
}










