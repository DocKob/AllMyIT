
# Getting started


Deploy and configure Windows devices with Powershell


![AllMyIT Alpha 1.0.2](https://i2.wp.com/hitea.fr/wp-content/uploads/2019/10/AllMyIT.jpg?fit=609%2C103&ssl=1)


## Read the doc


The documentation is build for latest release, not for the repository branchs

[dockob.github.io/AllMyIT](https://dockob.github.io/AllMyIT)


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

```
    Git clone https://github.com/DocKob/AllMyIT.git
```

Or download the latest release : 

```powershell
    cd C:\Users\[YOUR_USERNAME]\Download
    Invoke-WebRequest http://hitea.fr/wp-content/uploads/2019/10/AllMyIT.zip -OutFile AllMyIT.zip
    Expand-Archive -LiteralPath C:\Users\[YOUR_USERNAME]\Download\AllMyIT.zip -DestinationPath C:\Users\[YOUR_USERNAME]\Download\AllMyIT
```

Run AllMyIT in Powershell (run as Administrator)

```powershell
    cd C:\Users\[YOUR_USERNAME]\Download\AllMyIT
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # If Computer :
    .\Install-Ami.ps1 -Mode Computer -Verbose

    # If Server:
    .\Install-Ami.ps1 -Mode Server -Verbose
```


And read the doc for usage : [dockob.github.io/AllMyIT/usage](https://dockob.github.io/AllMyIT/usage/)