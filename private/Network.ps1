function Set-Network {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$IPAddress,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$PrefixLength,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DefaultGateway,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [array]$Dns
    )

    $NetworkCards = Get-NetAdapter | Where-Object "MediaConnectionState" -Match "Connected" | Select-Object *
    foreach ($Card in $NetworkCards) {
        $Ip = Get-NetIPAddress -InterfaceAlias $Card.InterfaceAlias | Where-Object "AddressFamily" -Match "IPv4" | Select-Object *
        Write-Host "Card Index:" $Card.InterfaceIndex " -- Card Name: " $Card.InterfaceAlias " -- with ip: " $Ip.IPAddress
    }
    if (!($InterfaceIndex = Read-Host "which card do you want to set ? (Card Index or press enter to return)")) {
        return
    }

    if (!($IPAddress) -or !($PrefixLength) -or !($DefaultGateway) -or !($Dns)) {
        return
    }

    New-NetIPAddress -InterfaceIndex $InterfaceIndex -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $DefaultGateway
    Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddress $Dns

}