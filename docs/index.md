
# Getting started

  

Deploy and configure Windows devices with Powershell

  

## Download



Download latest realease: https://github.com/DocKob/AllMyIT/releases/latest



View on GitHub: https://github.com/DocKob/AllMyIT



## Requirements

  

### Minimal

  

- Windows 7 SP1 / Windows Server 2008 R2 SP1

-  [Windows Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)

  

### Recommended

  

- Windows 10 / Windows Server 2016 / Windows Server 2019



## Installation

Clone the repository :

    Git clone https://github.com/DocKob/AllMyIT.git

Or download the latest release : 

    Invoke-WebRequest https://github.com/DocKob/AllMyIT/releases/download/1.0.1/AllMyIT_Alpha_1.0.1.zip -OutFile AllMyIT_Alpha_1.0.1.zip
    Expand-Archive -LiteralPath C:\Users\AllMyIT\Download\AllMyIT_Alpha_1.0.1.zip -DestinationPath C:\Users\AllMyIT\Download\AllMyIT

Run AllMyIT in Powershell (run as Administrator)

    cd C:\Users\AllMyIT\Download\AllMyIT
    Set-ExecutionPolicy Bypass -Scope Process -Force | .\Install-Device.ps1 -Mode Computer -Verbose