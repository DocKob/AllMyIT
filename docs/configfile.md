
# Config File

How to build your config file.

Config files are located in "AllMyIT\config"

Warning, if you set the password in config file, he's in clear ! 

After script run, please delete the config file or restrict "AllMyIT\config" access.


## Naning the config file

Config file is .json.

Only use Alphanumeric characters for of filename.

## Installer section

### Install-Modules

    "Install-Modules": [
			"PSWindowsUpdate"
    ]

Search module on [powershellgallery.com](https://www.powershellgallery.com)

Insert module names separated by commas

![Powershell Gallery](https://i0.wp.com/hitea.fr/wp-content/uploads/2019/10/Powershell-gallery.jpg?fit=750%2C330)

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
            ]
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

    "Install-Features": [
			    "Hyper-V",
			    "Hyper-V-PowerShell",
			    "Windows-Server-Backup"
    ]

You can execute : Get-WindowsFeature in Powershell and search feature name


## Toolbox section

### Install-Certificate

    "Install-Certificate": {
			    "Name": "AllMyIT",
			    "Export": true,
			    "Password": "Password",
                "Wizard": false
    }

Create a certificat for password encryption.

Set the Name and the password. If export is true, the certificate is exported to "AllMyIT\export"

### Set-Storage

    "Set-Storage": {
			    "Run": true,
	                    "Wizard": true
    }

This function list all uninitialized disk and ask you if you want to configure it (Letter, Name, Size ...)

### Clear-Disk

    "Clear-Disk":  {
                       "Custom":  false
                   }

Perform a disk cleanup and temp folders cleanup

Set "Custom" to "Lenovo" for add the lenovo specifics folders

### Restart-Service

    "Restart-Service": [
        "NlaSvc"
    ]

Set services name for restart (dependancies restart auto)
