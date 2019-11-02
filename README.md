
# Getting started

AllMyIT is a Powershell Module !

Mini app to manage Microsoft services


![AllMyIT Alpha 2.0.0](https://i2.wp.com/hitea.fr/wp-content/uploads/2019/11/AllMyIT_Alpha_2.jpg?fit=695%2C258&ssl=1)


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

Or download the latest release : [github.com/DocKob/AllMyIT/releases/latest](https://github.com/DocKob/AllMyIT/releases/latest)


Run Powershell as Administrator :

```powershell
    Set-ExecutionPolicy Bypass -Scope Process -Force

    Import-Module -FullyQualifiedName [C:\Users\[YOUR_USERNAME]\Download\AllMyIT] -Force -Verbose
    
    # Install AllMyIT
    Install-Ami

    # Launch AllMyIT
    Invoke-Ami
```


And read the doc for usage : [dockob.github.io/AllMyIT/usage](https://dockob.github.io/AllMyIT/usage/)