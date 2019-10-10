function New-Certificate {
    [CmdletBinding(
        SupportsShouldProcess = $true
    )]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Name,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Password,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Export = $false,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        $Wizard = $false
    )

    if ($Wizard) { Write-Verbose -Message "Wizard if on" }
    else {
        $OldCert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.FriendlyName -eq $Name }
        if ($OldCert) {
            Write-Host "Cert Alreday Exist, Return "
            Return
        }
        else {
            $Create_Cert = New-SelfSignedCertificate -Subject "CN=$Name" -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsage KeyEncipherment, DataEncipherment, KeyAgreement -Type DocumentEncryptionCert -FriendlyName $Name
            Write-Host "New Certificate created"
        
            if ($Export -eq $true) {
                if (Test-Path (Join-Path $BaseFolder "export\Cert_Export.pfx")) {
                    Remove-Item (Join-Path $BaseFolder "export\Cert_Export.pfx")
                    Write-Verbose -Message "File alreday exist: removed"
                }
                $cert = Get-ChildItem -Path cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $($Create_Cert.Thumbprint) }
                Export-PfxCertificate -Cert $cert -FilePath (Join-Path $BaseFolder "export\Cert_Export.pfx") -Password (ConvertTo-SecureString -AsPlainText $Password -Force)
                Write-Host "Certificate Exported"
            }
        }
    }


}