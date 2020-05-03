# Getting started

AllMyIT is a Powershell module for configuring Windows and Windows Server like a pro ! Automation and optimization !

French:

AllMyIT est un module Powershell permettant de configurer Windows et Windows Server comme un pro ! Automatisation et optimisation !

## Read the doc

The documentation is build master branch. [dockob.github.io/AllMyIT](https://dockob.github.io/AllMyIT)

## Download

Download latest realease: [github.com/DocKob/AllMyIT/releases/latest](https://github.com/DocKob/AllMyIT/releases/latest)

View on GitHub: [github.com/DocKob/AllMyIT](https://github.com/DocKob/AllMyIT)

## Requirements

### Minimal

- Windows 7 SP1 / Windows Server 2008 R2 SP1

-  [Windows Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)

### Recommended

- Windows 10 / Windows Server 2016 / Windows Server 2019

## Installation

### From PowerShell Gallery

```powershell
    Install-Module -Name AllMyIT
```

See module page: [powershellgallery.com/packages/AllMyIT](https://www.powershellgallery.com/packages/AllMyIT)

### From Source

Clone the repository :

```
    Git clone https://github.com/DocKob/AllMyIT.git
```

Or download the latest release : [github.com/DocKob/AllMyIT/releases/latest](https://github.com/DocKob/AllMyIT/releases/latest)

Run Powershell as Administrator :

```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force

    Import-Module -FullyQualifiedName [C:\Users\[YOUR_USERNAME]\Download\AllMyIT] -Force -Verbose
```

## Usage

```powershell
    # Invoke AllMyIT module in Wizard mode
    Invoke-Ami
```

```powershell
    # Run AllMyIT module in ConfigFile mode
    Start-Ami -ProfilePath "PATH"
```

See more about config file : [dockob.github.io/AllMyIT/configfile](https://dockob.github.io/AllMyIT/configfile/)