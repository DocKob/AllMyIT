
# Getting started

  

Deploy and configure Windows devices with Powershell


![AllMyIT Alpha 1.0.2](https://i2.wp.com/hitea.fr/wp-content/uploads/2019/10/AllMyIT.jpg?fit=609%2C103&ssl=1)

  

## Requirements



### Minimal

  

- Windows 7 SP1 / Windows Server 2008 R2 SP1

-  [Windows Management Framework 5.1](https://www.microsoft.com/en-us/download/details.aspx?id=54616)

  

### Recommended

  

- Windows 10 / Windows Server 2016 / Windows Server 2019



## Read the doc



[dockob.github.io/AllMyIT](https://dockob.github.io/AllMyIT)
  
  

## Installation

Clone the repository :

    Git clone https://github.com/DocKob/AllMyIT.git

Or download the latest release : 

    Invoke-WebRequest http://hitea.fr/wp-content/uploads/2019/10/AllMyIT.zip -OutFile AllMyIT_Alpha.zip
    Expand-Archive -LiteralPath C:\Users\AllMyIT\Download\AllMyIT_Alpha.zip -DestinationPath C:\Users\AllMyIT\Download\AllMyIT

Run AllMyIT in Powershell (run as Administrator)

    cd C:\Users\AllMyIT\Download\AllMyIT
    Set-ExecutionPolicy Bypass -Scope Process -Force | .\Install-Device.ps1 -Mode Computer -Verbose