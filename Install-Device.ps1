[CmdletBinding(
    SupportsShouldProcess = $true
)]
param (        
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [ValidateSet('Computer', 'Server')]
    $Mode,
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
New-Folders -Folders @("export", "temp")

$VerbNoun = '*-*'
$Functions = Get-ChildItem -Path (Join-Path $BaseFolder "/core") -Filter $VerbNoun
foreach ($f in $Functions) {
    Write-Verbose -Message ("Importing function {0}." -f $f.FullName)
    . $f.FullName
}

$Modules = Get-ChildItem (Join-Path $BaseFolder "/modules") | Where-Object { $_.Attributes -match 'Directory' }
foreach ($m in $Modules) {
    Write-Verbose -Message ("Importing module {0}." -f $m.Name)
    Import-Module -FullyQualifiedName (Join-Path (Join-Path $BaseFolder "/modules") $m.Name)
}

$DeviceInfos = Get-DeviceInfos -Export $true -Wizard $false

Install-Modules -Modules @("PendingReboot")
Start-Sleep -milliseconds 500
$TestReboot = Test-PendingReboot -SkipConfigurationManagerClientCheck -SkipPendingFileRenameOperationsCheck -Detailed
$DeviceInfos | Add-Member -NotePropertyMembers @{Reboot = $TestReboot.IsRebootPending }

if ($TestReboot.IsRebootPending) {
    Write-Verbose -Message "Reboot pending"
}
else {
    Write-Verbose -Message "No reboot needed"
}

$configuration = Import-Configuration -Profile $Profile -Type $Mode
$SelectedProfile = " Run with profile: " + $configuration.Filename
$InstallFunctions = $configuration | Select-Object -Property * -ExcludeProperty @('Filename')
$InstallerMenu = @"
1: Install all available features from config file
2: Run wizard features
Q: Press Q to exist
"@
$WizardMenuTitle = "Launch wizard features"
$WizardMenu = @"
1: Get-DeviceInfos
2: New-Certificate
3: Set-Storage
Q: Press Q to exist
"@

Do {
    Switch (Invoke-Menu -menu $InstallerMenu -title $SelectedProfile) {
        "1" {
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage").Run -eq $true)) { 
                Set-Storage -Run $configuration.("Set-Storage").Run -Wizard $configuration.("Set-Storage").Wizard
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Certificate")) { 
                New-Certificate -Name $configuration.("Install-Certificate").Name -Password $configuration.("Install-Certificate").Password -Export $configuration.("Install-Certificate").Export -Wizard $configuration.("Install-Certificate").Wizard
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Modules")) {
                Install-Modules -Modules $configuration.("Install-Modules")
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Apps")) {
                $apps = $configuration.("Install-Apps")
                if ([bool]($apps.PSobject.Properties.name -match "Ninite")) {
                    Install-Apps -Installer "Ninite" -Apps $configuration.("Install-Apps").Ninite
                }
                if ([bool]($apps.PSobject.Properties.name -match "Chocolatey")) {
                    Install-Apps -Installer "Chocolatey" -Apps $configuration.("Install-Apps").Chocolatey
                }
                if ([bool]($apps.PSobject.Properties.name -match "AppsUrl")) {
                    Install-Apps -Installer "Url" -Apps $configuration.("Install-Apps").AppsUrl
                }
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Features") -and ($Mode -match "Server")) { 
                Install-Features -Features $configuration.("Install-Features")
            }
            pause
        }
        "2" {
            Do {
                Switch (Invoke-Menu -menu $WizardMenu -title $WizardMenuTitle) {
                    "1" {
                        Get-DeviceInfos -Wizard $true
                        $exit = $PSItem
                    }
                    "2" {
                        New-Certificate -Wizard $true
                        $exit = $PSItem
                    }
                    "3" {
                        Set-Storage -Wizard $true
                        $exit = $PSItem
                    }
                    "Q" {
                        Read-Host "Return to main menu, press enter"
                        $exit = $PSItem
                    }
                    Default { Start-Sleep -milliseconds 50 }
                } 
            } While ($exit -ne "Q")
        }
        "Q" {
            Save-Configuration $configuration
            Read-Host "Config file saved, press enter"
            Return
        }
        Default { Start-Sleep -milliseconds 50 }
    }
} While ($True)