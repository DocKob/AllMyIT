function Install-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (        
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $ProfilePath
    )

    if ($ProfilePath) {
        $configuration = Import-Configuration -Profile $ProfilePath
        Confirm-Configuration -Profile "Install" -Configuration $configuration -StrictMode $true
    }
    else {
        $configuration = Import-Template -Profile "Install"
    }
    
    $Mode = $configuration.("Device-Infos").Mode
    $InstallPath = $configuration.("Install-Options").RootFolder

    New-Folders -Folders @("export", "temp", "ps-modules") -Path $InstallPath
    Set-RegKey -Key "InstallPath" -Value $InstallPath -Type "String"
    Set-RegKey -Key "Mode" -Value $Mode -Type "String"
    Install-PackageStore -Name Nuget
    Get-DeviceInfos -Export $true
    Install-Modules -Modules @("PendingReboot", "PSWindowsUpdate")
    Save-Configuration -Configuration $configuration
}