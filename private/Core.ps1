function Install-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $InstallPath
    )
    
    $AmiVersion = ((Get-Module AllMyIT).Version)

    if ((Test-Path "$($BaseFolder)/Config/Installed.txt") -and (Test-Path $InstallPath)) {
        return
    }

    New-Folders -Folders @("export", "temp", "tools", "config") -Path $InstallPath
    Get-ChildItem -Path (Join-Path $BaseFolder "example") | Resolve-Path | ForEach-Object { Copy-Item $_ -Destination (Join-Path $InstallPath "config") }
    Set-RegKey -Key "InstallPath" -Value $InstallPath -Type "String"
    Set-RegKey -Key "AmiVersion" -Value ([string]$AmiVersion.Major + "." + [string]$AmiVersion.Minor) -Type "String"
    Install-PackageStore -Name Nuget
    Get-Date | Out-File -Encoding UTF8 -FilePath "$($BaseFolder)/Private/Installed.txt"
}

function Import-Configuration() {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Profile
    )

    if (Test-Path $Profile) {
        $Configuration = (Get-Content $Profile | Out-String | ConvertFrom-Json)
    }
    else {
        Read-Host "Profile error, exit... "
        exit
    }
    $Configuration | Add-Member Filename $Profile
    return $Configuration
}

function Save-Configuration() {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        $Configuration
    )
    
    $excluded = @('Filename')
    $Configuration | Select-Object -Property * -ExcludeProperty $excluded | ConvertTo-Json | Set-Content -Encoding UTF8 -Path $Configuration.Filename
    Write-Verbose -Message "Config file saved !"
}

function Confirm-Configuration() {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        $Configuration,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $StrictMode
        
    )

    $Template = Import-Template

    foreach ($ConfigItem in $Configuration.PSobject.Properties) {
        if ([bool]($Template.PSobject.Properties.name -match $ConfigItem.Name)) { 
            Write-Verbose -Message ($ConfigItem.Name + " is set in template")
        }
        else {
            Write-Verbose -Message ($ConfigItem.Name + " is no set in template, removing it !")
            $Configuration.PSObject.Properties.Remove($ConfigItem.Name)
        }
    }

    foreach ($TemplateItem in $Template.PSobject.Properties) {
        if (!([bool]($Configuration.PSobject.Properties.name -match $TemplateItem.Name)) -and ($StrictMode -eq $true)) {
            Write-Verbose -Message ($ConfigItem.Name + " is no set in config file ! it's a required field, exiting...")
            Read-Host "Press Enter !"
            exit
        }
    }

    return $Configuration
}

function Import-Template() {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param()

    $filename = (Join-Path $BaseFolder ("template/Config.json"))

    if (Test-Path $filename) {
        $Template = (Get-Content $filename | Out-String | ConvertFrom-Json)
    }
    else {
        Read-Host "Profile error, exit... "
        exit
    }
    $Template | Add-Member Filename $filename
    return $Template
}

function Test-Command {
    param($Command)
 
    $found = $false
    $match = [Regex]::Match($Command, "(?<Verb>[a-z]{3,11})-(?<Noun>[a-z]{3,})", "IgnoreCase")
    if ($match.Success) {
        if (Get-Command -Verb $match.Groups["Verb"] -Noun $match.Groups["Noun"]) {
            $found = $true
        }
    }

    $found
}

function Test-HtPsRunAs {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

Function New-Folders {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Folders,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Path
    )
    ForEach ($Folder in $Folders) {
        $location = (Join-Path $Path $Folder)
        if (!(Test-Path $location)) {
            New-Item -Path $location -ItemType Directory | Out-Null
            Write-Verbose -Message "Create folder $($Folder) at location $($location)"
        }
        else {
            Write-Verbose -Message "Folder $($Folder) already exist at location $($location)"
        }
    } 
}

function Test-GroupMember {
    param (
        [Parameter(Mandatory = $true)]
        $User,
        [Parameter(Mandatory = $false)]
        $Group = "Administrateurs"
    )
    
    $groupObj = [ADSI]"WinNT://./$Group,group" 
    $membersObj = @($groupObj.psbase.Invoke("Members"))
    $members = ($membersObj | foreach { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) })

    If ($members -contains $User) {
        return $true
    }
    Else {
        return $false
    }
}

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

function Set-RegKey {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Key,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Value,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Type
    )

    $BasePath = "HKLM:\SOFTWARE\HiteaNet\"

    if (!(Test-Path (Join-Path $BasePath "AllMyIT"))) {
        New-Item -Path $BasePath -Name "AllMyIT"
        # New-PSDrive -Name "AllMyCloud" -PSProvider "Registry" -Root "HKLM:\SOFTWARE\AllMyCloud"
    }

    $BasePath = (Join-Path $BasePath "AllMyIT")

    if (Get-ItemProperty -Path $BasePath -Name $Key) {
        Remove-ItemProperty -Path $BasePath -Name $Key -Force
    }
    New-ItemProperty -Path $BasePath -Name $Key -Value $Value -PropertyType $Type

}

function Get-RegKey {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Key
    )

    $BasePath = "HKLM:\SOFTWARE\HiteaNet\AllMyIT"

    $RegKey = Get-ItemProperty -Path $BasePath -Name $Key

    return $RegKey.$Key
    
}