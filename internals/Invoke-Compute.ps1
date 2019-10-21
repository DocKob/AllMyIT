function Invoke-Compute {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]

    $SelectedProfile = " Run in menu mode "
    $WizardMenu = @"
1: Set-Storage
2: Restart-Service
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
            "1" {
                Set-Storage -Wizard $true
            }
            "2" {
                Restart-Service -Wizard $true
            }
            "Q" {
                Clear-Host
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}