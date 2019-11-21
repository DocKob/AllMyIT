function Invoke-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param ()

    $MenuTitle = " Run AllMyIT Wizard"
    $WizardMenu = @"

1: New Local Admin

2: Set Network Config

3: Create New Certificate

4: Set Storage Disk

5: Install App (Chocolatey, Ninite, Custom URL)

6: Install Server Feature

7: Remove Temp Files

8: Restart A Service

9: Enable/Disble config mode

10: Enable PSRemoting, WinRM and Secure RDP mode

Q: Press Q to exist

"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $MenuTitle) {
            "1" {
                New-LocalAdmin
            }
            "2" {
                Set-Network
            }
            "3" {
                New-Certificate
            }
            "4" {
                Set-Storage
            }
            "5" {
                Install-Apps
            }
            "6" {
                Install-Features
            }
            "7" {
                Remove-Temp
            }
            "8" {
                Restart-Service
            }
            "9" {
                Set-ConfigMode
            }
            "10" {
                Set-Accessibility
            }
            "Q" {
                Read-Host "Closing..., press enter"
                Return
            }
            Default {
                Clear-Host
                Start-Sleep -milliseconds 100 
            }
        } 
    } While ($True)
}
