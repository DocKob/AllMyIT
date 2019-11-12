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

# Autorun with config file
function Set-Storage {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Run = $true,
        [Parameter(Mandatory = $false)]
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

# Autorun with config file
function Remove-Temp {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $False)]
        $AddFolder = $false,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        switch (Read-Host "Add custom folders ? (1)Lenovo") {
            "1" {
                $AddFolder = "Lenovo"
            }
            default { }
        }
    }
    
    $objShell = New-Object -ComObject Shell.Application
    
    $temp = (get-ChildItem "env:\TEMP").Value
    $FoldersList = @($temp, "c:\Windows\Temp\*")

    foreach ($Folder in $FoldersList) {
        write-Host "Removing Junk files in $Folder." -ForegroundColor Magenta 
        Remove-Item -Recurse  "$Folder\*" -Force -Verbose
    }

    if ($AddFolder -match "Lenovo") {
        $Lenovo = "C:\Program Files\Lenovo\System Update\session\*"
        $swtools = "c:\SWTOOLS\*"
        write-Host "Lenovo folders."
        Remove-Item -Recurse  -Path $Lenovo -Exclude system, temp, updates.ser, "*.xml"   -Verbose -Force
        write-Host "Emptying $swtools folder."
        Remove-Item -Recurse $swtools   -Verbose -Force -WhatIf
    }

    write-Host "Emptying Recycle Bin." -ForegroundColor Cyan
    $objFolder = $objShell.Namespace(0xA)
    $objFolder.items() | % { remove-item $_.path -Recurse -Confirm:$false }
	
    write-Host "Finally now , Running Windows disk Clean up Tool" -ForegroundColor Cyan
    cleanmgr /sagerun:1 | out-Null
	
    write-Host "I finished the cleanup task,Bye Bye " -ForegroundColor Yellow

}