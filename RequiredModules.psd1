@{
    # Set up a mini virtual environment...
    PSDependOptions             = @{
        AddToPath  = $True
        Target     = 'output\RequiredModules'
        Parameters = @{
        }
    }

    Sampler                     = 'latest'
    invokeBuild                 = 'latest'
    PSScriptAnalyzer            = 'latest'
    pester                      = 'latest'
    Plaster                     = 'latest'
    ModuleBuilder               = '1.0.0'
    MarkdownLinkCheck           = 'latest'
    ChangelogManagement         = 'latest'
    'DscResource.Test'          = 'latest'
    'DscResource.AnalyzerRules' = 'latest'
    xDscResourceDesigner        = 'latest'
    'DscResource.Common'        = 'latest'
    'xPendingReboot'            = '0.4.0'
    'xWebAdministration'        = '3.1.1'
}
