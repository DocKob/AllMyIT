Function Get-DeviceInfos {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Full,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Export
    )

    Install-Folders -Folders @("Export")

}