# Welcome to the xExchange wiki

<sup>*xExchange v#.#.#*</sup>

Here you will find all the information you need to make use of the xExchange
DSC resources in the latest release. This includes details of the resources
that are available, current capabilities, known issues, and information to
help plan a DSC based implementation of xExchange.

Please leave comments, feature requests, and bug reports for this module in
the [issues section](https://github.com/dsccommunity/xExchange/issues)
for this repository.

## Getting started

To get started either:

- Install from the PowerShell Gallery using PowerShellGet by running the
  following command:

```powershell
Install-Module -Name xExchange -Repository PSGallery
```

- Download xExchange from the [PowerShell Gallery](https://www.powershellgallery.com/packages/xExchange)
  and then unzip it to one of your PowerShell modules folders (such as
  `$env:ProgramFiles\WindowsPowerShell\Modules`).

To confirm installation, run the below command and ensure you see the xExchange
DSC resources available:

```powershell
Get-DscResource -Module xExchange
```

## Prerequisites

The minimum Windows Management Framework (PowerShell) version required is 5.0
or higher, which ships with Windows 10 or Windows Server 2016,
but can also be installed on Windows 7 SP1, Windows 8.1, Windows Server 2012,
and Windows Server 2012 R2.

## Requirements

The minimum Windows Management Framework (PowerShell) version required is 4.0,
which ships with Windows Server 2012 and Windows Server 2012 R2, but can also
be installed on Windows 2008 R2 (the minimum supported OS version for Exchange
Server 2013).

Note that while the xExchange module may work with newer releases of
PowerShell, the Microsoft Exchange Product Group does not support running
Microsoft Exchange Server with versions of PowerShell newer than the one that
shipped with the Windows Server version that Exchange is installed on. See the
**Windows PowerShell** section of the [Exchange Server Supportability Matrix](<https://technet.microsoft.com/en-us/library/ff728623(v=exchg.160).aspx>)
for more information.

## Change log

A full list of changes in each version can be found in the [change log](https://github.com/dsccommunity/xExchange/blob/main/CHANGELOG.md).
