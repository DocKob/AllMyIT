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

    $DeviceInfo = @{ }
    $DeviceInfo.add("OperatingSystem", $os.name.split("|")[0])
    $DeviceInfo.add("Version", $os.Version)
    $DeviceInfo.add("Architecture", $os.OSArchitecture)
    $DeviceInfo.add("SerialNumber", $os.SerialNumber)
    $DeviceInfo.add("SystemName", $env:COMPUTERNAME)

    $pagefile = Get-PageFile -ComputerName $env:COMPUTERNAME
    $DeviceInfo.add("PageFileSize", $pagefile.("TotalSize(in MB)"))
    $DeviceInfo.add("PageFileCurrentSize", $pagefile.("CurrentUsage(in MB)"))
    $DeviceInfo.add("PageFilePeakSize", $pagefile.("PeakUsage(in MB)"))

    $out += New-Object PSObject -Property $DeviceInfo | Select-Object `
        "SystemName", "SerialNumber", "OperatingSystem", `
        "Version", "Architecture", "PageFileSize", "PageFileCurrentSize", "PageFilePeakSize"

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