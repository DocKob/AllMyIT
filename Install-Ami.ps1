[CmdletBinding(
    SupportsShouldProcess = $true
)]
param (        
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Computer', 'Server')]
    $Mode = "Computer"
)

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
    Exit
}

$BaseFolder = $PSScriptRoot

.("$BaseFolder/internals/Functions.ps1")

New-Folders -Folders @("export", "temp")
Set-RegKey -Key "BaseFolder" -Value $BaseFolder -Type "String"
Set-RegKey -Key "Mode" -Value $Mode -Type "String"
Install-WinRm -StartService $True
Install-PackageStore -Name Nuget
Get-DeviceInfos -Export $true
Install-Modules -Modules @("PendingReboot", "PSWindowsUpdate")