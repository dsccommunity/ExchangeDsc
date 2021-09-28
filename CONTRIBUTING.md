# Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## Prerequisites
 - Read the contributing guidelines document
 - Make sure you have an Exchange Server environment that is fully functioning with the following servers:
    - 1 Domain Controller
    - 2 Mailbox Servers
        - With at least one Database availability group (DAG) Configured
## Run Integration Tests

Once you have made the necessary changes to the branch please run the following commands 

> **NOTE:** You might need to run this command to allow traffic to https:
```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

This command will download all dependencies that we will need to compile the code:
```powershell
.\build.ps1 -ResolveDependency -Tasks noop
```

Compiles the code with the changes you have made:
```powershell
.\build.ps1 -Tasks build
```

Run the integration tests located in the `tests/Integration`. Write tests that will ensure that the issue in the code is fixed. See [Testing Guidelines](https://dsccommunity.org/guidelines/testing-guidelines/).

```powershell
.\build.ps1 -Tasks test -PesterScript 'tests/Integration' -CodeCoverageThreshold 0
```
