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

    "Install-Apps": {
	        "AppsUrl": [
        		      "APP_URL"
            ],
            "Ninite": [
        		      "firefox",
        		      "7zip"
            ],
            "Chocolatey": [
        		      "firefox",
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

