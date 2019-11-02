function Install-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Profile = "Install"
    )

    $configuration = Import-Configuration -Profile $Profile
    if ([bool]($configuration.PSobject.Properties.name -match "Device-Infos")) { 
        $Mode = $configuration.("Device-Infos").Mode
    }
    
    if ([bool]($configuration.PSobject.Properties.name -match "Install-Options")) { 
        $InstallPath = $configuration.("Install-Options").RootFolder
    }

    New-Folders -Folders @("export", "temp", "ps-modules") -Path $InstallPath
    Set-RegKey -Key "InstallPath" -Value $InstallPath -Type "String"
    Set-RegKey -Key "Mode" -Value $Mode -Type "String"
    Install-WinRm -StartService $True
    Install-PackageStore -Name Nuget
    Get-DeviceInfos -Export $true
    Install-Modules -Modules @("PendingReboot", "PSWindowsUpdate")
    if ($Mode -match "Server") {
        Enable-PSRemoting -Force
    }
    Save-Configuration -Configuration $configuration
}