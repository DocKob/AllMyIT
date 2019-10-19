[CmdletBinding(
    SupportsShouldProcess = $true
)]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    $Profile = "Default"
)

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PSCommandArgs" -WorkingDirectory $pwd -Verb RunAs
    Exit
}

.("$PSScriptRoot/internals/Functions.ps1")

$BaseFolder = Get-RegKey -Key "BaseFolder"

$Modules = Get-ChildItem (Join-Path $BaseFolder "/modules") | Where-Object { $_.Attributes -match 'Directory' }
foreach ($m in $Modules) {
    Write-Verbose -Message ("Importing module {0}." -f $m.Name)
    Import-Module -FullyQualifiedName (Join-Path (Join-Path $BaseFolder "/modules") $m.Name)
}

$VerbNoun = '*-*'
$Functions = Get-ChildItem -Path (Join-Path $BaseFolder "/internals") -Filter $VerbNoun
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}

$DeviceInfos = Get-DeviceInfos -Export $true
$configuration = Import-Configuration -Profile $Profile

$SelectedProfile = " Run with profile: " + $configuration.Filename
$WizardMenu = @"
0: Open Installer
1: Open Toolbox
2: Manage Device
3: New-AmiModule
4: Restart Computer (if needed)
Q: Press Q to exist
"@

Do {
    Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile) {
        "0" {
            Install-Device -Configuration $configuration
        }
        "1" {
            Invoke-Toolbox -Configuration $configuration
        }
        "2" {
            Edit-Device -Configuration $configuration
        }
        "3" {
            $Name = Read-Host "Wich name for the module ?"
            $Path = Join-Path $BaseFolder "/modules"
            New-AmiModule -Path $Path -Name $Name
        }
        "4" {
            Install-Modules -Modules @("PendingReboot")
            $TestReboot = Test-PendingReboot -SkipConfigurationManagerClientCheck -SkipPendingFileRenameOperationsCheck -Detailed
            $DeviceInfos | Add-Member -NotePropertyMembers @{Reboot = $TestReboot.IsRebootPending }
            if ($DeviceInfos.Reboot) {
                Write-Verbose -Message "Reboot pending"
                switch (Read-Host "Reboot pending! do you want to restart now ? (y)es to confim") {
                    "y" { Restart-Computer }
                    Default { }
                }
            }
            else {
                Write-Host "No reboot needed"
            }
        }
        "Q" {
            Save-Configuration $configuration
            Read-Host "Config file saved, press enter"
            Return
        }
        Default { Start-Sleep -milliseconds 100 }
    } 
} While ($True)