function Invoke-Toolbox {
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
1: New-Certificate
2: Clean-Disk
Q: Press Q to exist
"@

    Do {
        Switch (Invoke-Menu -menu $WizardMenu -title $SelectedProfile -cls) {
            "0" {
                if ([bool]($configuration.PSobject.Properties.name -match "Install-Certificate")) { 
                    New-Certificate -Name $configuration.("Install-Certificate").Name -Password $configuration.("Install-Certificate").Password -Export $configuration.("Install-Certificate").Export -Wizard $configuration.("Install-Certificate").Wizard
                }
                if ([bool]($configuration.PSobject.Properties.name -match "Clear-Disk")) { 
                    Clear-Disk -Custom $configuration.("Clear-Disk").Custom
                }
            }
            "1" {
                New-Certificate -Wizard $true
            }
            "2" {
                Clear-Disk -Wizard $true
            }
            "Q" {
                Clear-Host
                Return
            }
            Default { Start-Sleep -milliseconds 100 }
        } 
    } While ($True)
}