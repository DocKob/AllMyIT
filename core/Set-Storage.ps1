function Set-Storage {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Run = $true,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Wizard = $true
    )

    $AvailableDisks = Get-Disk | Where-Object PartitionStyle -eq "RAW"

    if ($AvailableDisks) {
        foreach ($Disk in $AvailableDisks) {
            if ($Wizard) {
                switch (Read-Host "Do you want configure disk: $($Disk.FriendlyName) (Number: $($Disk.Number)) (Y)es") {
                    "Y" {
                        Initialize-Disk $Disk.Number
                        $Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -AssignDriveLetter
                        Format-Volume -DriveLetter $Partition.DriveLetter
                        $DriveLabel = Read-Host "Type a label for the volume: "
                        Set-Volume -DriveLetter $Partition.DriveLetter -NewFileSystemLabel $DriveLabel
                    }
                    Default { Write-Verbose -Message "Drive not configured" }
                }
            }
            else {
                Write-Verbose -Message "Wizard if off"
            }
        } 
    }
    else {
        Write-Host "All disks are already configured "
    }
}