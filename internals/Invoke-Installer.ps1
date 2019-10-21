function Invoke-Installer {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]

    $SelectedProfile = " Run in menu mode "
    $WizardMenu = @"
1: Install App
2: Install Server Feature
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
            "1" {
                Install-Apps -Wizard $true
            }
            "2" {
                Install-Features -Wizard $true
            }
            "Q" {
                Clear-Host
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}