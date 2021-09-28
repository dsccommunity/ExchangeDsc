# Contributing

Please check out common DSC Community [contributing guidelines](https://dsccommunity.org/guidelines/contributing).

## How to Run Integration Tests

This section describes the necessary information to be able to run the integration tests successfully.

### Prerequisites
 - Read the contributing guidelines document
 - Make sure you have an Exchange Server **LAB** environment that is fully functioning with at least the following servers:
    - 1 Domain Controller
    - 2 Mailbox Servers
        - Configured with one Database availability group (DAG)

> **Warning:** Please do not run the integration tests in a production environment.

### Domain Controller Server

1. Go to Active Directory Users and Computers - OU Builtin - Double-click Administrators - Members tab and add "Exchange Trusted Subsystem"
2. Create new and computer: Name DAG, on security tab chose "Exchange Trusted Subsystem" and give full control  

### File Server

We need to make sure that we have a file server so it can act as File Witness for the Database availability group. This could be a Domain Controller in a testing environment, but this is not recommended in a production environment.

1. Install Failover Clustering:
    ```powershell
    Install-WindowsFeature Failover-Clustering
    ```
2. Add "Exchange Trusted Subsystem" account into "Administrator group"
3. Create the file witness directory "C:\Witness" and shared for everyone with full access.
4. Reboot the server

### Mailbox Servers
We need to make sure that we are able to register the default repository for the PowerShell modules and add needed tools for testing:

1. Add default repository: 
    ```powershell
    Register-PSRepository -Default -InstallationPolicy Trusted
    ```
2. Install Chocolatey
    ```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    ```
3. Once chocolatey has been installed, please install git and vscode:
    ```powershell
    choco install git
    choco install vscode
    ```
4. Log in to the Exchange Control Panel (ECP), the Web-based management interface, and create the DAG. In the Windows Server, follow this steps:
    *  Start Icon - Find the Exchange Administrative Center - logon - Click on Servers - Click on Database Availability Groups tab - " + " :
        * Add Database availability group name: DAG (the same on the point 2 for DC)
        * Add Witness server: fileserver
        * Add path of the Witness directory: C:\Witness
    * Go to MailFlow -> RecieveConnector and remove the default FrontEnd, if you don't remove the test fails.

5. Now, you are ready to adjust the code. Please do the following in one of your mailbox servers:
    ```powershell
    # Create source folder
    mkdir src
    # Clone your forked xExchange repository
    git clone https://github.com/yourusername/PULLREQUEST
    # Go into the correct the cloned repository
    cd .\xExchange\
    # Checkout a branch
    git checkout [branch_name]
    ```
### Run Integration Tests

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
