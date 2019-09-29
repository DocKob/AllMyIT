function Install-Features {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Features
    )

    if (! (Test-Command -Command "Install-WindowsFeature")) {
        return
    }

    $InstalledFeatures = Get-WindowsFeature | Where-Object InstallState -eq "Installed"

    foreach ($Feature in $Features) {
    
        if (!($InstalledFeatures.Name -match $Feature)) {
            Write-Host "Installing $Feature"
            Install-WindowsFeature $Feature
        }
        else {
            Write-Host "Feature $Feature is already installed"
        }
    } 
}