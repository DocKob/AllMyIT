function Start-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $ProfilePath
    )

    if (!(Test-HtPsRunAs)) {
        Write-Host "You must launch HtShell as admin, exit..."
        pause
        exit
    }

    $InstallPath = "C:\HiteaNet\AllMyIT"
    
    if (!(Test-Path ("HKLM:\SOFTWARE\HiteaNet\AllMyIT")) -or !(Test-Path "$($BaseFolder)/Private/Installed.txt") -or !(Test-Path $InstallPath)) {
        Install-Ami -InstallPath $InstallPath
    }
    else {
        Write-Host "Install folder is Already created !"
    }

    Read-Host "Start..., press enter"

    if ([string]$ProfilePath) {
        $configuration = Confirm-Configuration -Configuration (Import-Configuration -Profile $ProfilePath)

        if ([bool]($configuration.PSobject.Properties.name -match "New-LocalAdmin")) {
            New-LocalAdmin -NewLocalAdmin $configuration.("New-LocalAdmin").NewLocalAdmin -Password $configuration.("New-LocalAdmin").Password
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Set-Network")) {
            Set-Network -IPAddress $configuration.("Set-Network").IPAddress -PrefixLength $configuration.("Set-Network").PrefixLength -DefaultGateway $configuration.("Set-Network").DefaultGateway -Dns $configuration.("Set-Network").Dns
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage").Run -eq $true)) { 
            Set-Storage -Run $configuration.("Set-Storage").Run
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Install-Apps")) {
            $apps = $configuration.("Install-Apps")
            if ([bool]($apps.PSobject.Properties.name -match "Ninite")) {
                Install-Apps -Installer "Ninite" -Apps $configuration.("Install-Apps").Ninite
            }
            if ([bool]($apps.PSobject.Properties.name -match "Chocolatey")) {
                Install-Apps -Installer "Chocolatey" -Apps $configuration.("Install-Apps").Chocolatey
            }
            if ([bool]($apps.PSobject.Properties.name -match "AppsUrl")) {
                Install-Apps -Installer "Url" -Apps $configuration.("Install-Apps").AppsUrl
            }
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Install-Features")) { 
            Install-Features -Features $configuration.("Install-Features").Features
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Set-Accessibility")) {
            Set-Accessibility -IsEnabled $configuration.("Set-Accessibility").IsEnabled
        }

        if ([bool]($configuration.PSobject.Properties.name -match "Set-ConfigMode")) {
            Set-ConfigMode -IsEnabled $configuration.("Set-ConfigMode").IsEnabled
        }
          
        Save-Configuration -Configuration $configuration
    }
    
    Read-Host "End..., press enter"

}
