# Config File

How to build your config file.

## Install-Certificate

Warning! if you set the password in config file, he's in clear ! after script run, please delete the config file or restrict config folder access.

    "Install-Certificate": {
			    "Name": "AllMyIT",
			    "Export": true,
			    "Password": "Password",
                "Wizard": false
    }

## Install-Modules

Search module on [powershellgallery.com](https://www.powershellgallery.com)

    "Install-Modules": [
			"PSWindowsUpdate"
    ]

## Install-Apps

Official Website: [chocolatey.org/packages](https://chocolatey.org/packages)
Example for Chocolatey : ["adobereader", "googlechrome", "jre8", "firefox", "7zip", "microsoft-teams"]


Official Website: [ninite.com](https://ninite.com)
Example for Ninite: ["firefox", "7zip", "filezilla", "onedrive", "vscode", "windirstat", "winscp"]

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

## Install-Features

You can execute : Get-WindowsFeature in Powershell and search feature name

    "Install-Features": [
			    "Hyper-V",
			    "Hyper-V-PowerShell",
			    "Windows-Server-Backup"
    ]

## Set-Storage

This function list all uninitialized disk and ask you if you want to configure it (Letter, Name, Size ...)

    "Set-Storage": {
			    "Run": true,
                "Wizard": true
    }


