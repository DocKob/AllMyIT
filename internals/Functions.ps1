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

    $filename = (Join-Path $BaseFolder (Join-Path "config/" ($profile + ".json")))

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

function Save-Configuration($config) {
    $excluded = @('Filename')
    $configuration | Select-Object -Property * -ExcludeProperty $excluded | `
        ConvertTo-Json | Set-Content -Encoding UTF8 -Path $configuration.Filename
}

Function New-Folders {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Folders,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Path = $BaseFolder
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

    $BasePath = "HKLM:\SOFTWARE\"

    if (!(Test-Path (Join-Path $BasePath "AllMyIT"))) {
        New-Item -Path $BasePath -Name "AllMyIT"
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

    $BasePath = "HKLM:\SOFTWARE\AllMyIT"

    $RegKey = Get-ItemProperty -Path $BasePath -Name $Key

    return $RegKey.$Key
    
}

function New-AmiModule {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $location = Join-Path $Path $Name

    if (!(Test-Path ($location))) {
        New-Item -Path $location -ItemType Directory | Out-Null
        Write-Verbose -Message "Create module $($Name) at location $($location)"
    }
    else {
        Write-Verbose -Message "Module $($Name) already exist at location $($location)"
    }

    New-ModuleManifest -Path (Join-Path $Path ($Name + "\$Name.psd1")) -PassThru
    
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

    $os = Get-WmiObject -class win32_operatingsystem
    $pc = Get-WmiObject -Class Win32_ComputerSystem

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

    $pagefile = Get-PageFile -ComputerName $env:COMPUTERNAME
    $DeviceInfo.add("PageFileSize", $pagefile.("TotalSize(in MB)"))
    $DeviceInfo.add("PageFileCurrentSize", $pagefile.("CurrentUsage(in MB)"))
    $DeviceInfo.add("PageFilePeakSize", $pagefile.("PeakUsage(in MB)"))

    $out += New-Object PSObject -Property $DeviceInfo | Select-Object `
        "SystemName", "SerialNumber", "OperatingSystem", `
        "Version", "Architecture", "PageFileSize", "PageFileCurrentSize", "PageFilePeakSize", "PsVersion", "Domain", "WorkGroup", "CurrentUserName"

    if ($Export -eq $true) {

        Write-Verbose -Message "Config file exported in export folder"
        $out | Export-CSV (Join-Path $BaseFolder "export\Device_Infos.csv") -Delimiter ";" -NoTypeInformation
    }
    return $out
}

<# 
 .Notes 
  NAME: Get-PageFileInfo 
  AUTHOR: Mike Kanakos 
  Version: v1.1
  LASTEDIT: Thursday, August 30, 2018 2:19:18 PM
#> 

function Get-PageFile {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True)]  
        [string[]]$ComputerName
    )
  
    Foreach ($computer in $ComputerName) {

        $online = Test-Connection -ComputerName $computer -Count 2 -Quiet
        if ($online -eq $true) {
            $PageFileResults = Get-CimInstance -Class Win32_PageFileUsage -ComputerName $Computer | Select-Object *
            $CompSysResults = Get-CimInstance -Class Win32_ComputerSystem -ComputerName $Computer | Select-Object *
    
            $PageFileStats = [PSCustomObject]@{
                Computer              = $computer
                FilePath              = $PageFileResults.Description
                AutoManagedPageFile   = $CompSysResults.AutomaticManagedPagefile
                "TotalSize(in MB)"    = $PageFileResults.AllocatedBaseSize
                "CurrentUsage(in MB)" = $PageFileResults.CurrentUsage
                "PeakUsage(in MB)"    = $PageFileResults.PeakUsage
                TempPageFileInUse     = $PageFileResults.TempPageFile
            } #END PSCUSTOMOBJECT
        } #END IF
        else {
            # Computer is not reachable!
            Write-Host "Error: $computer not online" -Foreground white -BackgroundColor Red
        } # END ELSE


        $PageFileStats
 
    } #END FOREACH

}
