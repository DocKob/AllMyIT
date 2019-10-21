function Restart-Service {
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$ServiceName,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        $ServiceName = Read-Host "which service do you want to restart ?"
    }

    [System.Collections.ArrayList]$ServicesToRestart = @()

    function Custom-GetDependServices($ServiceInput) {
        #Write-Host"Nameof`$ServiceInput:$($ServiceInput.Name)"
        #Write-Host"Numberofdependents:$($ServiceInput.DependentServices.Count)"
        If ($ServiceInput.DependentServices.Count -gt 0) {
            ForEach ($DepService in $ServiceInput.DependentServices) {
                #Write-Host"Dependentof$($ServiceInput.Name):$($Service.Name)"
                If ($DepService.Status -eq "Running") {
                    #Write-Host"$($DepService.Name)isrunning."
                    $CurrentService = Get-Service -Name $DepService.Name

                    #getdependanciesofrunningservice
                    Custom-GetDependServices $CurrentService
                }
                Else {
                    Write-Host "$($DepService.Name) is stopped. No Need to stop or start or check dependancies."
                }

            }
        }
        Write-Host "Service to restart $($ServiceInput.Name)"
        if ($ServicesToRestart.Contains($ServiceInput.Name) -eq $false) {
            Write-Host "Adding service to restart $($ServiceInput.Name)"
            $ServicesToRestart.Add($ServiceInput.Name)
        }
    }

    #Getthemainservice
    $Service = Get-Service -Name $ServiceName

    #Getdependanciesandstoporder
    Custom-GetDependServices -ServiceInput $Service


    Write-Host "-------------------------------------------"
    Write-Host "Stopping Services"
    Write-Host "-------------------------------------------"
    foreach ($ServiceToStop in $ServicesToRestart) {
        Write-Host "StopService $ServiceToStop"
        Stop-Service $ServiceToStop -Force -Verbose
    }
    Write-Host "-------------------------------------------"
    Write-Host "Starting Services"
    Write-Host "-------------------------------------------"
    #Reversestopordertogetstartorder
    $ServicesToRestart.Reverse()

    foreach ($ServiceToStart in $ServicesToRestart) {
        Write-Host "StartService $ServiceToStart"
        Start-Service $ServiceToStart -Verbose
    }
    Write-Host "-------------------------------------------"
    Write-Host "Restart of services completed"
    Write-Host "-------------------------------------------"   
}