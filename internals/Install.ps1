function Install-WinRm {
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$StartService = $false
    )
    
    winrm quickconfig -q

    if ($StartService) {
        Start-Service WinRM
        Set-Service WinRM -StartupType Automatic
    }
}

function Install-PackageStore {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    Install-PackageProvider -Name $Name -Force
}

function Install-Modules {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Modules
    )

    ForEach ($Module in $Modules) {
        $Destination = (Join-Path (Get-RegKey -Key "InstallPath") "\ps-modules")
        if (-not (Test-Path (Join-Path $Destination $Module))) {
            Find-Module -Name $Module -Repository 'PSGallery' | Save-Module -Path $Destination -Force | Out-Null
        }
        else {
            Write-Verbose -Message "Module already exists"
        }
        Import-Module -FullyQualifiedName (Join-Path $Destination $Module)
    }
}

# Autorun with config file
function Install-Features {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$Features
    )

    if (! (Test-Command -Command "Install-WindowsFeature")) {
        Write-Verbose -Message "Device is not a server ! Exit"
    }
    else {
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
}

# Autorun with config file
Function Install-Apps {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet("Ninite", "Chocolatey", "Url")]
        [string]$Installer,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$Apps,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Lnk = $false,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$ExecuteExe = $false,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$UnzipArchives = $false
    )

    Switch ($Installer) {
        "Ninite" {
            Write-Host "Downloading Ninite ..."
   
            $ofs = '-'
            $niniteurl = "https://ninite.com/" + $Apps + "/ninite.exe"
            $output = (Join-Path (Get-RegKey -Key "InstallPath") "\temp\ninite.exe")
            if (Test-Path $Output) {
                Write-Verbose -Message "File alreday exist"
            }
            else {
                Invoke-WebRequest $niniteurl -OutFile $output
            }
            & $output
        } 
        "Chocolatey" {
            If (!(Test-Path -Path "$env:ProgramData\Chocolatey")) {
                Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            }

            ForEach ($PackageName in $Apps) {
                choco install $PackageName -y
            }
        }
        "Url" {
            ForEach ($PackageUrl in $Apps) {
                $OutputFile = Split-Path $PackageUrl -leaf
                $Output = (Join-Path (Get-RegKey -Key "InstallPath") ("\temp\" + $OutputFile))
                Write-Host "Downloading from $($PackageUrl)"
                if (Test-Path $Output) {
                    Write-Verbose -Message "File alreday exist"
                }
                else {
                    Start-BitsTransfer -Source $PackageUrl -Destination $Output
                }
                if ($ExecuteExe -eq $true) {

                } 
                if ($UnzipArchives -eq $true) {

                } 
                if ($Lnk -eq $true) {
                    $ShortcutFile = "$env:Public\Desktop\" + $OutputFile.name + ".lnk"
                    $WScriptShell = New-Object -ComObject WScript.Shell
                    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
                    $Shortcut.TargetPath = $Output
                    $Shortcut.Save()
                    Write-Host "Shortcut created"
                }
            } 
        }
        Default { Return }
    }
}