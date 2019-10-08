# Config File

How to build your config file.

## Install-Certificate

    "Install-Certificate": {
			    "Name": "AllMyIT",
			    "Export": true,
			    "Password": "Password"
    }

## Install-Modules

    "Install-Modules": [
			"PSWindowsUpdate"
    ]

## Install-Apps

Example for Chocolatey : ["adobereader", "googlechrome", "jre8", "firefox", "7zip", "microsoft-teams"]

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

    "Install-Features": [
			    "Hyper-V",
			    "Hyper-V-PowerShell",
			    "Windows-Server-Backup"
    ]

## Set-Storage

    "Set-Storage": true

