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