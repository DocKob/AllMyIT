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

Get-DeviceInfos -Export $true

$configuration = Import-Configuration -Profile $Profile -Type $Mode
$SelectedProfile = " Run with profile: " + $configuration.Filename
$InstallFunctions = $configuration | Select-Object -Property * -ExcludeProperty @('Filename')
$InstallerMenu = @"
R: Install all available features from config file
Q: Press Q to exist
"@

Do {
    Switch (Invoke-Menu -menu $InstallerMenu -title $SelectedProfile) {
        "R" {
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage") -eq $true) -and ($Mode -match "Server")) { 
                Set-Storage
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Certificate")) { 
                New-Certificate -Name $configuration.("Install-Certificate").Name -Password $configuration.("Install-Certificate").Password -Export $configuration.("Install-Certificate").Export
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Modules")) {
                Install-Modules -Modules $configuration.("Install-Modules")
            }
            if ([bool]($InstallFunctions.PSobject.Properties.name -match "Install-Apps")) {
                $apps = $configuration.("Install-Apps")
                # @("firefox", "7zip", "filezilla", "onedrive", "vscode", "windirstat", "winscp")
                if ([bool]($apps.PSobject.Properties.name -match "Ninite")) {
                    Install-Apps -Installer "Ninite" -Apps $configuration.("Install-Apps").Ninite
                }
                # @('adobereader', 'googlechrome', 'jre8', 'firefox', '7zip', 'microsoft-teams')
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
        "Q" {
            Save-Configuration $configuration
            Read-Host "Config file saved, press enter"
            Return
        }
        Default { Start-Sleep -milliseconds 50 }
    }
} While ($True)