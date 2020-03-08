function Set-RegKey {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Key,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Value,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Type
    )

    $BasePath = "HKLM:\SOFTWARE\HiteaNet\"

    if (!(Test-Path (Join-Path $BasePath "AllMyIT"))) {
        New-Item -Path $BasePath -Name "AllMyIT"
        # New-PSDrive -Name "AllMyCloud" -PSProvider "Registry" -Root "HKLM:\SOFTWARE\AllMyCloud"
    }

    $BasePath = (Join-Path $BasePath "AllMyIT")

    if (Get-ItemProperty -Path $BasePath -Name $Key) {
        Remove-ItemProperty -Path $BasePath -Name $Key -Force
    }
    New-ItemProperty -Path $BasePath -Name $Key -Value $Value -PropertyType $Type

}

function Get-RegKey {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        $Key
    )

    $BasePath = "HKLM:\SOFTWARE\HiteaNet\AllMyIT"

    $RegKey = Get-ItemProperty -Path $BasePath -Name $Key

    return $RegKey.$Key
    
}

function Get-AmiReg {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    $AmiReg = [PSCustomObject]@{ }
    Push-Location
    Set-Location -Path $Path
    Get-Item . |
    Select-Object -ExpandProperty property |
    ForEach-Object {
        $AmiReg | Add-Member -MemberType NoteProperty -Name $_ -Value (Get-ItemProperty -Path . -Name $_).$_
    }
    Pop-Location
    Return $AmiReg
}