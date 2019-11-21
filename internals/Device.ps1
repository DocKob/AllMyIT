# Autorun with config file
function New-Certificate {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Export = $false
    )

    $OldCert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.FriendlyName -eq $Name }
    if ($OldCert) {
        Write-Host "Cert Alreday Exist, Return "
        Return
    }
    else {
        $Create_Cert = New-SelfSignedCertificate -Subject "CN=$Name" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage KeyEncipherment, DataEncipherment, KeyAgreement -Type DocumentEncryptionCert -FriendlyName $Name
        Write-Host "New Certificate created"
        if (($Export -eq $true)) {
            if (Test-Path (Join-Path (Get-RegKey -Key "InstallPath") "export\Cert_Export.pfx")) {
                Remove-Item (Join-Path (Get-RegKey -Key "InstallPath") "export\Cert_Export.pfx")
                Write-Verbose -Message "File alreday exist: removed"
            }
            $cert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $($Create_Cert.Thumbprint) }
            Export-PfxCertificate -Cert $cert -FilePath (Join-Path (Get-RegKey -Key "InstallPath") "export\Cert_Export.pfx") -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
            Write-Host "Certificate Exported"
        }
    }
}

# Autorun with config file
function New-LocalAdmin {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$NewLocalAdmin,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Password
    )

    if (Get-LocalUser -Name $NewLocalAdmin) {
        Write-Verbose -Message "User already exist, reseting the password..."
        Get-LocalUser -Name $NewLocalAdmin | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
    }
    else {
        New-LocalUser -Name $NewLocalAdmin -Password (ConvertTo-SecureString -AsPlainText $Password -Force) -FullName $NewLocalAdmin -Description "Created by AllMyIT"
        Write-Verbose -Message "$NewLocalAdmin local user created"
    }
    if (!(Test-GroupMember -User $NewLocalAdmin)) {
        Add-LocalGroupMember -Group "Administrateurs" -Member $NewLocalAdmin
        Write-Verbose -Message "$NewLocalAdmin added to the local administrator group"
    }
    else {
        Write-Verbose -Message "$NewLocalAdmin is already in administrator group"
    }
}

# Autorun with config file
function Restart-Service {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String]$ServiceName
    )

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

# Autorun with config file
function Set-ConfigMode {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [bool]$IsEnabled
    )

    if ($IsEnabled -eq $true) {
        netsh advfirewall set allprofiles state off
        Enable-WSManCredSSP -Role server
    }
}


# Autorun with config file
function Set-Accessibility {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [bool]$IsEnabled
    )

    if ($IsEnabled -eq $true) {
        Enable-PSRemoting -Force
        Install-WinRm -StartService $True
    }

}

function Test-GroupMember {
    param (
        [Parameter(Mandatory = $true)]
        $User,
        [Parameter(Mandatory = $false)]
        $Group = "Administrateurs"
    )
    
    $groupObj = [ADSI]"WinNT://./$Group,group" 
    $membersObj = @($groupObj.psbase.Invoke("Members"))
    $members = ($membersObj | foreach { $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null) })

    If ($members -contains $User) {
        return $true
    }
    Else {
        return $false
    }
}