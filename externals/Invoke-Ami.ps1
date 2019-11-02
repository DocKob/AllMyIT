function Invoke-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Profile = "Config"
    )

    $configuration = Import-Configuration -Profile $Profile
    $Profile = $configuration.Filename

    $SelectedProfile = " Run with profile: " + $Profile
    $WizardMenu = @"
0: Run config file
1: New local admin
2: Set Network config
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile) {
            "0" {
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Certificate")) { 
                    New-Certificate -Name $configuration.("Install-Certificate").Name -Password $configuration.("Install-Certificate").Password -Export $configuration.("Install-Certificate").Export -Wizard $configuration.("Install-Certificate").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Apps")) {
                    $apps = $configuration.("Install-Apps")
                    if ($configuration.("Install-Apps").Wizard -eq $true) {
                        Install-Apps -Wizard $configuration.("Install-Apps").Wizard
                    }
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
                    Install-Features -Features $configuration.("Install-Features").Features -Wizard $configuration.("Install-Features").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage").Run -eq $true)) { 
                    Set-Storage -Run $configuration.("Set-Storage").Run -Wizard $configuration.("Set-Storage").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Remove-Temp")) { 
                    Remove-Temp -AddFolder $configuration.("Remove-Temp").AddFolder -Wizard $configuration.("Remove-Temp").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Restart-Service")) {
                    Restart-Service -ServiceName $configuration.("Restart-Service").Name -Wizard $configuration.("Restart-Service").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Set-Network")) {
                    Set-Network -IPAddress $configuration.("Set-Network").IPAddress -PrefixLength $configuration.("Set-Network").PrefixLength -DefaultGateway $configuration.("Set-Network").DefaultGateway -Dns $configuration.("Set-Network").Dns -Wizard $configuration.("Set-Network").Wizard
                }
            }
            "1" {
                New-LocalAdmin -Wizard $true
            }
            "2" {
                Set-Network -Wizard $true
            }
            "Q" {
                Save-Configuration -Configuration $configuration
                Read-Host "Closing..., press enter"
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}
