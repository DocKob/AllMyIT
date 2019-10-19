function Edit-Device {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $configuration
    )

    $SelectedProfile = " Run with profile: " + $configuration.Filename
    $WizardMenu = @"
0: Run tools from config file
1: Set-Storage
2: Restart-Service
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
            "0" {
                if ([bool]($configuration.PSobject.Properties.name -match "Set-Storage") -and ($configuration.("Set-Storage").Run -eq $true)) { 
                    Set-Storage -Run $configuration.("Set-Storage").Run -Wizard $configuration.("Set-Storage").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Restart-Service")) {
                    Restart-Service -ServiceName $configuration.("Restart-Service")
                }
            }
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