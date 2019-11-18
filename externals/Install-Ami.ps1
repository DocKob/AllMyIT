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
        $configuration = Confirm-Configuration -Profile "Install" -Configuration (Import-Configuration -Profile $ProfilePath) -StrictMode $true
    }
    else {
        $configuration = Import-Template -Profile "Install"
    }
    
    $Mode = $configuration.("Device-Infos").Mode
    $InstallPath = $configuration.("Install-Options").RootFolder
    $AmiVersion = ((Get-Module AllMyIT).Version)

    New-Folders -Folders @("export", "temp", "ps-modules", "tools", "config") -Path $InstallPath
    Set-RegKey -Key "InstallPath" -Value $InstallPath -Type "String"
    Set-RegKey -Key "Mode" -Value $Mode -Type "String"
    Set-RegKey -Key "AmiVersion" -Value ([string]$AmiVersion.Major + "." + [string]$AmiVersion.Minor) -Type "String"
    Install-PackageStore -Name Nuget
    Get-DeviceInfos -Export $true
    Install-Modules -Modules @("PendingReboot", "PSWindowsUpdate")
    Save-Configuration -Configuration $configuration
}