function Set-Storage {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param()

    $AvailableDisks = Get-Disk | Where-Object PartitionStyle -eq "RAW"

    if ($AvailableDisks) {
        foreach ($Disk in $AvailableDisks) { 
            switch (Read-Host "Do you want configure disk: $($Disk.FriendlyName) (Number: $($Disk.Number)) (Y)es") {
                "Y" {
                    Initialize-Disk $Disk.Number
                    $Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -AssignDriveLetter
                    Format-Volume -DriveLetter $Partition.DriveLetter
                    $DriveLabel = Read-Host "Type a label for the volume: "
                    Set-Volume -DriveLetter $Partition.DriveLetter -NewFileSystemLabel $DriveLabel
                }
                Default { }
            }
        }
    }
    else {
        Write-Host "All disks are already configured"
    }
}