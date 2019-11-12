function Invoke-Ami {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param ()

    $SelectedProfile = " Run AllMyIT Wizard"
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
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile) {
            "1" {
                New-LocalAdmin -Wizard $true
            }
            "2" {
                Set-Network -Wizard $true
            }
            "3" {
                New-Certificate -Wizard $true
            }
            "4" {
                Set-Storage -Wizard $true
            }
            "5" {
                Install-Apps -Wizard $true
            }
            "6" {
                Install-Features -Wizard $true
            }
            "7" {
                Remove-Temp -Wizard $true
            }
            "8" {
                Restart-Service -Wizard $true
            }
            "9" {
                Set-ConfigMode -Wizard $true
            }
            "10" {
                Set-Accessibility -Wizard $true
            }
            "Q" {
                Read-Host "Closing..., press enter"
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}
