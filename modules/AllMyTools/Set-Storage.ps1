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
        Write-Host @($AvailableDisks).Count "disk is not configured"
        foreach ($Disk in $AvailableDisks) {
            if ($Wizard) {
                switch (Read-Host "Do you want configure disk: $($Disk.FriendlyName) (Number: $($Disk.Number)) (Y)es or press enter to cancel") {
                    "Y" {
                        Initialize-Disk $Disk.Number
                        Write-Verbose -Message ("Disk " + $Disk.Number + " initialized")
                        switch (Read-Host "use maximum size and auto assign letter ? (Y)es or press enter to set") {
                            "Y" {
                                $Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -AssignDriveLetter
                                Format-Volume -DriveLetter $Partition.DriveLetter
                                Write-Verbose -Message ("New volume created with letter: " + $Partition.DriveLetter)
                            }
                            Default {
                                $DriveSize = Read-Host "Set partition size"
                                [string]$DriveLetter = Read-Host "Set partition letter"
                                if ($DriveSize -and $DriveLetter) { 
                                    $Partition = New-Partition -DiskNumber $Disk.Number -Size $DriveSize -DriveLetter $DriveLetter
                                    Format-Volume -DriveLetter $Partition.DriveLetter
                                }
                            }
                        }
                        [string]$DriveLabel = Read-Host ("Type a label for the volume " + $Partition.DriveLetter + ":")
                        if ($DriveLabel) {
                            Set-Volume -DriveLetter $Partition.DriveLetter -NewFileSystemLabel $DriveLabel
                        }
                    }
                    Default { Write-Verbose -Message ("Disk " + $Disk.Number + " not configured") }
                }
            }
            else {
                Write-Verbose -Message "This function run only with Wizard set to true currently !"
            }
        } 
    }
    else {
        Write-Host "All disks are already configured "
    }
}