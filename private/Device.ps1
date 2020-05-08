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