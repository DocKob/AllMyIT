[CmdletBinding(
    SupportsShouldProcess = $true
)]
param (        
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Computer', 'Server')]
    $Mode = "Computer",
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    $Profile = "Default"
)

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
    Exit
}

$BaseFolder = $PSScriptRoot
.("$BaseFolder/core/Functions.ps1")
.("$BaseFolder/core/DeviceInfos.ps1")
New-Folders -Folders @("export", "temp")

$DeviceInfos = Get-DeviceInfos -Export $true

winrm quickconfig -q
Start-Service WinRM
Set-Service WinRM -StartupType Automatic

$Modules = Get-ChildItem (Join-Path $BaseFolder "/modules") | Where-Object { $_.Attributes -match 'Directory' }
foreach ($m in $Modules) {
    Write-Verbose -Message ("Importing module {0}." -f $m.Name)
    Import-Module -FullyQualifiedName (Join-Path (Join-Path $BaseFolder "/modules") $m.Name)
}

$VerbNoun = '*-*'
$Functions = Get-ChildItem -Path (Join-Path $BaseFolder "/core/include") -Filter $VerbNoun
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}

Install-Modules -Modules @("PendingReboot")
$TestReboot = Test-PendingReboot -SkipConfigurationManagerClientCheck -SkipPendingFileRenameOperationsCheck -Detailed
$DeviceInfos | Add-Member -NotePropertyMembers @{Reboot = $TestReboot.IsRebootPending }

if ($DeviceInfos.Reboot) {
    Write-Verbose -Message "Reboot pending"
}
else {
    Write-Verbose -Message "No reboot needed"
}

$configuration = Import-Configuration -Profile $Profile -Type $Mode

$SelectedProfile = " Run with profile: " + $configuration.Filename
$WizardMenu = @"
0: Open Installer
1: Open Toolbox
Q: Press Q to exist
"@

Do {
    Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile) {
        "0" {
            Install-Device -Mode $Mode -Configuration $configuration
        }
        "1" {
            Invoke-Toolbox -Configuration $configuration
        }
        "Q" {
            Save-Configuration $configuration
            Read-Host "Config file saved, press enter"
            Return
        }
        Default { Start-Sleep -milliseconds 100 }
    } 
} While ($True)