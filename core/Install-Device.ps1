function Install-Device {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Computer', 'Server')]
        $Mode,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $configuration
    )

    $SelectedProfile = " Run with profile: " + $configuration.Filename
    $WizardMenu = @"
0: Install device from config file
1: Install Module
2: Install App
3: Install Server Feature
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile) {
            "0" {
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Modules")) {
                    Install-Modules -Modules $configuration.("Install-Modules")
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
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Features") -and ($Mode -match "Server")) { 
                    Install-Features -Features $configuration.("Install-Features")
                }
            }
            "1" {
                $Module = Read-Host "which module do you want to install ?"
                Install-Modules -Modules @($Module)
            }
            "2" {
                Switch (Read-Host "which store do you want to use ? (1)Chocolatey (2)Url") {
                    "1" {
                        $App = Read-Host "which application do you want to install ?"
                        Install-Apps -Installer "Chocolatey" -Apps @($App)
                    }
                    "2" {
                        $App = Read-Host "which application do you want to install ?"
                        Install-Apps -Installer "Url" -Apps @($App)
                    }
                }
                
            }
            "3" {
                if ($Mode -match "Server") {
                    $Feature = Read-Host "which server feature do you want to install ?"
                    Install-Features -Features @($Feature)
                }
                else {
                    Write-Verbose -Message "Device is not a server ! Exit"
                }
            }
            "Q" {
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}