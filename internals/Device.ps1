# Autorun with config file
function New-Certificate {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [Parameter(Mandatory = $false)]
        $Password,
        [Parameter(Mandatory = $false)]
        $Export = $false,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )
    if ($Wizard) { 
        [string]$Name = Read-Host "Set a name for the certificate"
        switch (Read-Host "do you want to export the certificate ? (Y)es to export or press enter to cancel") {
            "Y" { 
                $Export = $true
                $Password = Read-Host "Set a password for the export"
            }
            Default { $Export = $false }
        }
    }
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
        [Parameter(Mandatory = $false)]
        $NewLocalAdmin,
        [Parameter(Mandatory = $false)]
        $Password,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )
    if ($Wizard) { 
        [string]$NewLocalAdmin = Read-Host "Set a name for the new admin"
        $Password = Read-Host "Set a password for " $NewLocalAdmin
    }
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

# Autorun with config file
function Set-ConfigMode {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $IsEnabled = $false,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        $EnableConfig = Read-Host "Do you want enable config mode ? (Y)es or no dy default"
        if ($EnableConfig -match "Y") {
            $IsEnabled = $true
        }
        else {
            $IsEnabled = $false
        }
    }

    if ($IsEnabled -eq $true) {
        netsh advfirewall set allprofiles state off
        Enable-WSManCredSSP -Role server
    }
    elseif ($IsEnabled -eq $false) {
        netsh advfirewall set allprofiles state on
        Disable-WSManCredSSP -Role Server
    }
}

# Autorun with config file
function Set-Accessibility {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $IsEnabled = $false,
        [Parameter(Mandatory = $false)]
        $Wizard = $false
    )

    if ($Wizard -eq $true) {
        $EnableConfig = Read-Host "Do you want enable PSRemoting, WinRM and Secure RDP mode ? (Y)es or no dy default"
        if ($EnableConfig -match "Y") {
            $IsEnabled = $true
        }
        else {
            $IsEnabled = $false
        }
    }

    if ($IsEnabled -eq $true) {
        Enable-PSRemoting -Force
        Install-WinRm -StartService $True
    }
    elseif ($IsEnabled -eq $false) {
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