function Invoke-Tools {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]

    $SelectedProfile = " Run in menu mode "
    $WizardMenu = @"
1: New-Certificate
2: Clean-Disk
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
            "1" {
                New-Certificate -Wizard $true
            }
            "2" {
                Remove-Temp -Wizard $true
            }
            "Q" {
                Clear-Host
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}