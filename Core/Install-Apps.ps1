Function Install-Apps {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Installer,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Apps,
        [Parameter(Mandatory = $false)]
        $Lnk = $false,
        [Parameter(Mandatory = $false)]
        $ExecuteExe = $false,
        [Parameter(Mandatory = $false)]
        $UnzipArchives = $false
    )

    Install-Folders -Folders @("Temp")
    
    Switch ($Installer) {
        "Ninite" {
            Write-Host "Downloading Ninite ..."
   
            $ofs = '-'
            $niniteurl = "https://ninite.com/" + $Apps + "/ninite.exe"
            $output = (Join-Path $BaseFolder "Temp/ninite.exe")
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
                $Output = Join-Path $BaseFolder ("Temp/" + $OutputFile)
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