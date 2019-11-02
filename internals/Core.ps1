Function Invoke-Menu {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Choice an Option !")]
        [ValidateNotNullOrEmpty()]
        [string]$Menu,
        [Parameter(Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$Title = "",
        [Alias("cls")]
        [switch]$ClearScreen
    )

    if ($ClearScreen) { 
        Clear-Host 
    }

    $menuprompt = "-" * $title.Length
    $menuprompt += "`n"
    $menuprompt += "-" * $title.Length
    $menuprompt += "`n"
    $menuPrompt += $title
    $menuprompt += "`n"
    $menuprompt += "-" * $title.Length
    $menuprompt += "`n"
    $menuprompt += "-" * $title.Length
    $menuprompt += "`n"
    $menuprompt += "`n"
    $menuPrompt += $menu
    $menuprompt += "`n`n`n"
    $menuprompt += "Choose an option "
    
 
    Read-Host -Prompt $menuprompt
 
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

    $filename = (Join-Path $BaseFolder ("config/" + $profile + ".json"))

    if (Test-Path $filename) {
        $configuration = (Get-Content $filename | Out-String | ConvertFrom-Json)
    }
    else {
        Read-Host "Profile error, exit... "
        exit
    }
    $configuration | Add-Member Filename $filename
    return $configuration
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
    $configuration | Select-Object -Property * -ExcludeProperty $excluded | ConvertTo-Json | Set-Content -Encoding UTF8 -Path $configuration.Filename
    Write-Verbose -Message "Config file saved !"
}

function Set-ConfigMode {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $IsEnabled = $false
    )

    if ($IsEnabled -eq $true) {
        netsh advfirewall set allprofiles state off
        Enable-WSManCredSSP -Role server
    }
    else {
        netsh advfirewall set allprofiles state on
        Disable-WSManCredSSP -Role Server
    }
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

Function Get-DeviceInfos {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Export = $true
    )

    $os = Get-WmiObject -class win32_operatingsystem | Select-Object *
    $pc = Get-WmiObject -Class Win32_ComputerSystem | Select-Object *
    $pf = Get-CimInstance -Class Win32_PageFileUsage | Select-Object *

    $DeviceInfo = @{ }
    $DeviceInfo.add("OperatingSystem", $os.name.split("|")[0])
    $DeviceInfo.add("Version", $os.Version)
    $DeviceInfo.add("Architecture", $os.OSArchitecture)
    $DeviceInfo.add("SerialNumber", $os.SerialNumber)
    $DeviceInfo.add("PsVersion", [string]($PSVersionTable.PSVersion.Major) + "." + [string]($PSVersionTable.PSVersion.Minor))

    $DeviceInfo.add("SystemName", $env:COMPUTERNAME)
    $DeviceInfo.add("Domain", $pc.PartOfDomain)
    $DeviceInfo.add("WorkGroup", $pc.Workgroup)
    $DeviceInfo.add("CurrentUserName", $env:UserName)

    $PageFileStats = [PSCustomObject]@{
        Computer              = $computer
        FilePath              = $pf.Description
        AutoManagedPageFile   = $pc.AutomaticManagedPagefile
        "TotalSize(in MB)"    = $pf.AllocatedBaseSize
        "CurrentUsage(in MB)" = $pf.CurrentUsage
        "PeakUsage(in MB)"    = $pf.PeakUsage
        TempPageFileInUse     = $pf.TempPageFile
    }

    $DeviceInfo.add("PageFileSize", $PageFileStats.("TotalSize(in MB)"))
    $DeviceInfo.add("PageFileCurrentSize", $PageFileStats.("CurrentUsage(in MB)"))
    $DeviceInfo.add("PageFilePeakSize", $PageFileStats.("PeakUsage(in MB)"))

    $out += New-Object PSObject -Property $DeviceInfo | Select-Object `
        "SystemName", "SerialNumber", "OperatingSystem", `
        "Version", "Architecture", "PageFileSize", "PageFileCurrentSize", "PageFilePeakSize", "PsVersion", "Domain", "WorkGroup", "CurrentUserName"

    if ($Export -eq $true) {

        Write-Verbose -Message "Config file exported in export folder"
        $out | Export-CSV (Join-Path (Get-RegKey -Key "InstallPath") "\export\Device_Infos.csv") -Delimiter ";" -NoTypeInformation
    }
    return $out
}