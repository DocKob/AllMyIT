function Install-Modules {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Modules
    )

    Install-Folders -Folders @("Modules")

    ForEach ($Module in $Modules) {
        $Destination = (Join-Path $BaseFolder "Modules")
        if (-not (Test-Path (Join-Path $Destination $Module))) {
            Find-Module -Name $Module -Repository 'PSGallery' | Save-Module -Path $Destination | Out-Null
        }
        else {
            Write-Host "Module already exists"
        }
        Import-Module -FullyQualifiedName (Join-Path $Destination $Module)
    }
}