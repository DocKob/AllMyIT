function Install-Modules {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Modules
    )

    ForEach ($Module in $Modules) {
        $Destination = (Join-Path $BaseFolder "modules")
        if (-not (Test-Path (Join-Path $Destination $Module))) {
            Find-Module -Name $Module -Repository 'PSGallery' | Save-Module -Path $Destination | Out-Null
        }
        else {
            Write-Verbose -Message "Module already exists"
        }
        Import-Module -FullyQualifiedName (Join-Path $Destination $Module)
    }
}