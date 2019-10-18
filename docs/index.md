
# Getting started


Deploy and configure Windows devices with Powershell


The documentation is build for latest release, not for the repository branchs


![AllMyIT Alpha 1.0.2](https://i2.wp.com/hitea.fr/wp-content/uploads/2019/10/AllMyIT.jpg?fit=609%2C103&ssl=1)


[View on GitHub](https://github.com/DocKob/AllMyIT)


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

Clone the repository :

    Git clone https://github.com/DocKob/AllMyIT.git

Or download the latest release : 

    Invoke-WebRequest http://hitea.fr/wp-content/uploads/2019/10/AllMyIT.zip -OutFile AllMyIT_Alpha.zip
    Expand-Archive -LiteralPath C:\Users\AllMyIT\Download\AllMyIT_Alpha.zip -DestinationPath C:\Users\AllMyIT\Download\AllMyIT

Run AllMyIT in Powershell (run as Administrator)

    cd C:\Users\AllMyIT\Download\AllMyIT
    Set-ExecutionPolicy Bypass -Scope Process -Force | .\Install-Device.ps1 -Mode Computer -Verbose