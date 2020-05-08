# Config File

Warning, if you set the password in config file, he's in clear !

After script run, please delete the config file or restrict file access.

## Naning the config file

Only use Alphanumeric characters for the filename.

## Installer section

### Install-Apps

    "Install-Apps": {
    
    "AppsUrl": [
    
    "APP_URL"
    
    ],
    
    "Ninite": [
    
    "firefox"
    
    ],
    
    "Chocolatey": [
    
    "7zip"
    
    ],
    
    "Lnk": false,
    
    "ExecuteExe": false,
    
    "UnzipArchives": false,
    
    "Wizard": false
    
    }

- AppUrl example: [https://hitea.fr/wp-content/uploads/2019/09/BleachBit-2.2-portable.zip](https://hitea.fr/wp-content/uploads/2019/09/BleachBit-2.2-portable.zip)

- Ninite example: [ninite.com](https://ninite.com)

["firefox", "7zip", "filezilla", "onedrive", "vscode", "windirstat", "winscp"]

![Ninite](https://i1.wp.com/hitea.fr/wp-content/uploads/2019/10/ninite-search.jpg?fit=750%2C422)

![Ninite 2](https://i0.wp.com/hitea.fr/wp-content/uploads/2019/10/ninite-search-2.jpg?fit=750%2C398)

- Chocolatey example: [chocolatey.org/packages](https://chocolatey.org/packages)

["adobereader", "googlechrome", "jre8", "firefox", "7zip", "microsoft-teams"]

![Chocolatey](https://i2.wp.com/hitea.fr/wp-content/uploads/2019/10/choco-search.jpg?fit=750%2C392)

### Install-Features

    "Install-Features": {
    
    "Features": [
    
    "Hyper-V",
    
    "Hyper-V-PowerShell",
    
    "Windows-Server-Backup"
    
    ],
    
    "Wizard": false
    
    }

You can execute : Get-WindowsFeature in Powershell and search feature name

## Network section

### Set-Network

    "Set-Network":  {
                        "IPAddress":  "192.168.1.100",
                        "PrefixLength":  "24",
                        "DefaultGateway":  "192.168.1.254",
                        "Dns":  "8.8.8.8",
                        "Wizard":  false
    }

Set the IP address, the application asks you for which card you want to set the IP address

## File section

### Set-Storage

    "Set-Storage": {
    
    "Run": true,
    
    "Wizard": true
    
    }

This function list all uninitialized disk and ask you if you want to configure it (Letter, Name, Size ...)


## Device section

### New-LocalAdmin

    "New-LocalAdmin": {

        "NewLocalAdmin": "Name",

        "Password": "Password"

    }

Create a new local admin, if the user name already exist the password is reset with defined

### Set-ConfigMode

    "Set-ConfigMode": {

        "IsEnabled": false

    }

Disable all firewall rules and sets WSManCredSSP to server role if set to true

### Set-Accessibility

    "Set-Accessibility": {

        "IsEnabled": false
        
    }

Enable PSRemoting, WinRM and Secure RDP mode if is set to true