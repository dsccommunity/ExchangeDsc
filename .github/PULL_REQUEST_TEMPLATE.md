<!--
    Thanks for submitting a Pull Request (PR) to this project.
    Your contribution to this project is greatly appreciated!

    Please prefix the PR title with the resource name,
    e.g. 'ResourceName: My short description'.
    If this is a breaking change, then also prefix the PR title
    with 'BREAKING CHANGE:',
    e.g. 'BREAKING CHANGE: ResourceName: My short description'.

    You may remove this comment block, and the other comment blocks, but please
    keep the headers and the task list.
-->
#### Pull Request (PR) description
Adding support of Exchange CU installation to xExchInstall resource.
Added new function Get-ExchangeDisplayVersion to xExchangeHelper.psm1.
Modified Get-ExchangeInstallStatus function in xExchangeHelper.psm1 in order to check for CU install / update scenario.

#### This Pull Request (PR) fixes the following issues
None.

#### Task list
<!--
    To aid community reviewers in reviewing and merging your PR, please take
    the time to run through the below checklist and make sure your PR has
    everything updated as required.

    Change to [x] for each task in the task list that applies to your PR.
    For those task that don't apply to you PR, leave those as is.
-->
- [x] Added an entry under the Unreleased section of the change log in the CHANGELOG.md.
      Entry should say what was changed, and how that affects users (if applicable).
- [x] Resource documentation added/updated in README.md.
- [ ] Resource parameter descriptions added/updated in README.md, schema.mof
      and comment-based help.
- [ ] Comment-based help added/updated.
- [ ] Localization strings added/updated in all localization files as appropriate.
- [ ] Examples appropriately added/updated.
- [ ] Unit tests added/updated. See [DSC Resource Testing Guidelines](https://github.com/PowerShell/DscResources/blob/master/TestsGuidelines.md).
- [ ] Integration tests added/updated (where possible). See [DSC Resource Testing Guidelines](https://github.com/PowerShell/DscResources/blob/master/TestsGuidelines.md).
- [ ] New/changed code adheres to [DSC Resource Style Guidelines](https://github.com/PowerShell/DscResources/blob/master/StyleGuidelines.md) and [Best Practices](https://github.com/PowerShell/DscResources/blob/master/BestPractices.md).
