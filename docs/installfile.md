# Install File

Warning, if you set the password in config file, he's in clear !

After script run, please delete the config file or restrict file access.

## Naning the config file

Only use Alphanumeric characters for the filename.

### Device-Infos

    "Device-Infos":  {
                         "Mode":  "Computer"
                     }

Mode: Set installation mode

### Install-Options

    "Install-Options":  {
                            "RootFolder":  "C:\\AllMyIT"
                        }

RootFolder: Set custom install folder

## Install process

During the installation process AllMyIT exports a device information file (this one is in CSV format and is located in "Install_Path\Export")

Powershell modules are also installed by default: (the list can be evolved) :

- PSWindowsUpdate
- PendingReboot

Finally, a registry key is created in: "HKLM:\SOFTWARE\AllMyIT"

It stores important parameters such as device type or installation path

And read the doc for usage : [dockob.github.io/AllMyIT/usage](https://dockob.github.io/AllMyIT/usage/)