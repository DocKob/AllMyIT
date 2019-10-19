function Install-Device {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
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
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
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
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Features")) { 
                    Install-Features -Features $configuration.("Install-Features")
                }
            }
            "1" {
                Install-Modules -Wizard $true
            }
            "2" {
                Install-Apps -Wizard $true
            }
            "3" {
                Install-Features -Wizard $true
            }
            "Q" {
                Clear-Host
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}