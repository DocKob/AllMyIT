function Test-DNS {
    param([string]$Destination, [string]$Port)
    $Socket = New-Object Net.Sockets.TcpClient
    $IAsyncResult = [IAsyncResult] $Socket.BeginConnect($Destination, $Port, $null, $null)
    $success = $IAsyncResult.AsyncWaitHandle.WaitOne(500, $true)   ## Adjust the port test time-out in milli-seconds, here is 500ms
    Return $Socket.Connected
    $Socket.close()
}

# Autorun with config file
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
        [hashtable]$Dns
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

<#
    ################ Test TCP Port 53 of DNS Servers #################
    if (Test-DNS $Dns1 '53') { 
        Write-Host -Fore Green "Connection to DNS Server $Dns1 is OK."
        $Dns1_OK = 1;
    }
    else {
        Write-Host "Connection to DNS Server $Dns1 is NOT OK."
        $Dns1_OK = 0;
    }
    if (Test-DNS $Dns2 '53') { 
        Write-Host -Fore Green "Connection to DNS Server $Dns2 is OK."
        $Dns2_OK = 1;
    }
    else {
        Write-Host "Connection to DNS Server $Dns2 is NOT OK."
        $Dns2_OK = 0;
    }
    If ((!$Dns1_OK) -AND (!$Dns2_OK)) {
        Write-Host -Fore Red "Cannot connect to both DNS Server.`nPlease contact your network administrator. Now exists.";
        Exit;
    }
    ############# Swap the primary & secondary DNS Settings if the secondary DNS Server is connected where primary is not #######
    If (!$Dns1_OK -AND $Dns2_OK) {
        $TempDNS = $Dns1
        $Dns1 = $Dns2
        $Dns2 = $TempDNS
    }
    ############# Check DNS Settings for each Network Adapter and Prompt the user to correct if not correct ############
    $Netinfo = Get-WmiObject Win32_NetworkAdapterConfiguration -filter "ipenabled=true"

    $Netinfo | foreach {
        If (!$_.DNSServerSearchOrder) {
            Write-Host -Fore Yellow "Client DNS Settings are empty for $($_.Description) Adapter."
            $Correct_DNS_Settings = Read-Host "Do you want to correct Client DNS Settings(y/n)?"
            while ($Correct_DNS_Settings -ne 'y' -AND $Correct_DNS_Settings -ne 'n') {
                Write-Host "Please only type 'y' or 'n'."
                $Correct_DNS_Settings = Read-Host "Do you want to correct Client DNS Settings(y/n)?"
            }
            If ($Correct_DNS_Settings -eq 'y') {
                $DNS_Change_Result = $_.SetDNSServerSearchOrder($(If ($Dns1 -AND $Dns2) { $Dns1, $Dns2 } elseif ($Dns1) { $Dns1 } else { $Dns2 }))
                If (!$DNS_Change_Result.ReturnValue) {
                    Write-Host -Fore Cyan "DNS Setting of $($_.Description) has been changed to $Dns1 $(if($Dns2){"and $Dns2"})"
                }
                else {
                    Write-Host -Fore Red "Cannot change DNS Setting for $($_.Description). Please make sure you have necessary permission or Run Powershell as Administrator. Now exit."
                    Exit;
                }
            }
        }
        elseif ( $Dns1 -contains $_.DNSServerSearchOrder[0] -AND $Dns2 -contains $_.DNSServerSearchOrder[1]  ) {
            Write-Host "Client DNS Settings of $($_.Description) is correct."
        }
        else {
            Write-Host -Fore Red "Client DNS Settings of $($_.Description) is not correct."
            $Correct_DNS_Settings = Read-Host "Do you want to correct Client DNS Settings(y/n)?"
            while ($Correct_DNS_Settings -ne 'y' -AND $Correct_DNS_Settings -ne 'n') {
                Write-Host "Please only type 'y' or 'n'."
                $Correct_DNS_Settings = Read-Host "Do you want to correct Client DNS Settings(y/n)?"
            }
            If ($Correct_DNS_Settings -eq 'y') {
                $DNS_Change_Result = $_.SetDNSServerSearchOrder($($Dns1, $Dns2))
                If (!$DNS_Change_Result.ReturnValue) {
                    Write-Host -Fore Cyan "DNS Setting of $($_.Description) has been changed to $Dns1 $(if($Dns2){"and $Dns2"})"
                }
                else {
                    Write-Host -Fore Red "Cannot change DNS Setting for $($_.Description). Please make sure you have necessary permission or Run Powershell as Administrator. Now exit."
                    Exit;
                }
            }
        }
    }


#>