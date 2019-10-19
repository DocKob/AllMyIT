function Install-Modules {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Modules,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        $Modules = Read-Host "which module do you want to install ?"
    }

    ForEach ($Module in $Modules) {
        $Destination = (Join-Path $BaseFolder "modules")
        if (-not (Test-Path (Join-Path $Destination $Module))) {
            Find-Module -Name $Module -Repository 'PSGallery' | Save-Module -Path $Destination -Force | Out-Null
        }
        else {
            Write-Verbose -Message "Module already exists"
        }
        Import-Module -FullyQualifiedName (Join-Path $Destination $Module)
    }
}