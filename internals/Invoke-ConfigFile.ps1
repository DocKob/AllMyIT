function Invoke-ConfigFile {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $configuration
    )
    
    if ([bool]($configuration.PSobject.Properties.name -match "Install-Certificate")) { 
        New-Certificate -Name $configuration.("Install-Certificate").Name -Password $configuration.("Install-Certificate").Password -Export $configuration.("Install-Certificate").Export -Wizard $configuration.("Install-Certificate").Wizard
    }
    Pause
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
    Pause
    if ([bool]($configuration.PSobject.Properties.name -match "Install-Features")) { 
        Install-Features -Features $configuration.("Install-Features").Features -Wizard $configuration.("Install-Features").Wizard
    }
    Pause
    if ([bool]($configuration.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage").Run -eq $true)) { 
        Set-Storage -Run $configuration.("Set-Storage").Run -Wizard $configuration.("Set-Storage").Wizard
    }
    Pause
    if ([bool]($configuration.PSobject.Properties.name -match "Remove-Temp")) { 
        Remove-Temp -AddFolder $configuration.("Remove-Temp").AddFolder -Wizard $configuration.("Remove-Temp").Wizard
    }
    Pause
    if ([bool]($configuration.PSobject.Properties.name -match "Restart-Service")) {
        Restart-Service -ServiceName $configuration.("Restart-Service").Name -Wizard $configuration.("Restart-Service").Wizard
    }
    
}