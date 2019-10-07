Function Get-DeviceInfos {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Export
    )

    $os = Get-WmiObject -class win32_operatingsystem
    # $net = Get-WmiObject -class Win32_NetworkAdapterConfiguration | where-object { $_.IPAddress -ne $null }

    $DeviceInfo = @{ }
    $DeviceInfo.add("Operating System", $os.name.split("|")[0])
    $DeviceInfo.add("Version", $os.Version)
    $DeviceInfo.add("Architecture", $os.OSArchitecture)
    $DeviceInfo.add("Serial Number", $os.SerialNumber)
    $DeviceInfo.add("System Name", $env:COMPUTERNAME)
    # $DeviceInfo.add("IP Address", ($net.IPAddress -join (", ")))
    # $DeviceInfo.add("Subnet", ($net.IPSubnet -join (", ")))
    # $DeviceInfo.add("MAC Address", ($net.MACAddress -join (", ")))

    $out += New-Object PSObject -Property $DeviceInfo | Select-Object `
        "System Name", "Serial Number", "Operating System", `
        "Version", "Architecture"

    if ($Export -eq $true) {
        Write-Verbose ($out | Out-String) -Verbose             
        $out | Export-CSV (Join-Path $BaseFolder "export\Device_Infos.csv") -Delimiter ";" -NoTypeInformation
    }
}