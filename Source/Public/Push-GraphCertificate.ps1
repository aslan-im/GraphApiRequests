function Push-GraphCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [System.String]
        $CertificateThumbprint,

        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if( -Not ($_ | Test-Path) ){
                throw "Path doesn't exitst"
            }
            return $true
        })]
        [System.IO.FileInfo]
        $CertStoreLocation,

        [Parameter(Mandatory=$true)]
        [System.Guid]
        $AppId
    )
    
    begin {
        [System.IO.FileInfo]$CertificateFullPath = Join-Path -Path $CertStoreLocation -ChildPath $CertificateThumbprint
    }
    
    process {
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate = Get-Item -Path $CertificateFullPath
        $BitCert = $Certificate.GetRawCertData()
        $CredValue = [System.Convert]::ToBase64String($BitCert)
        

        # $appname=$app.DisplayName
        # $path='Cert:\CurrentUser\My\'
        # $certPassword = Read-Host "Please provide cert password"
        # $CertPassword = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
        # New-SelfSignedCertificate -dnsname $app.DisplayName -notafter $3years -CertStoreLocation Cert:\CurrentUser\My
        # $certificate=Get-ChildItem -Path Cert:\CurrentUser\My\ | Where-Object {$_.Subject -contains 'CN='+$app.DisplayName}
        # $certpath=Join-Path $path $certificate.Thumbprint
        # $expfilepath='.\'+$app.DisplayName+'.pfx'
        # $excerilepath='.\'+$app.DisplayName+'.cer'
        # Export-PfxCertificate -Cert $certpath -Password $certPassword -FilePath $expfilepath
        # Export-Certificate -Cert $certpath -FilePath $excerilepath
        # $certificate.Thumbprint >>Thumbprint.txt
        # $pwd = "IEZ^=Wnersx%`1s*87Jj"
        # $notAfter = $todaydt.AddYears(3)
        # $thumb = (New-SelfSignedCertificate -DnsName "Test-AzureAD111" -CertStoreLocation "cert:\CurrentUser\My"  -KeyExportPolicy Exportable -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -NotAfter $notAfter).Thumbprint
        # $pwd = ConvertTo-SecureString -String $pwd -Force -AsPlainText
        # Export-PfxCertificate -cert "cert:\CurrentUser\my\$thumb" -FilePath 'C:\_work\BAT\git\Project-b\ExpiratingCerts\Test-AzureAD.pfx' -Password $pwd
        # $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate('C:\_work\BAT\git\Project-b\ExpiratingCerts\Test-AzureAD1111.pfx', $pwd)
        # $keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())
        # New-AzureADApplicationKeyCredential -ObjectId 9c762cd7-c3e0-4169-b564-5f67bab099c1 -CustomKeyIdentifier "Test-AzureAD" -Type AsymmetricX509Cert -Usage Verify -Value $keyValue
        # ## Get the certificate file (.CER)
        # $CertificateFilePath = (Resolve-Path ".\\$($appName).cer").Path
        # ## Create a new certificate object
        # $cer = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        # $cer.Import("$($CertificateFilePath)")
        # $bin = $cer.GetRawCertData()
        # $base64Value = [System.Convert]::ToBase64String($bin)
        # $bin = $cer.GetCertHash()
        # $base64Thumbprint = [System.Convert]::ToBase64String($bin)
        # ## Upload and assign the certificate to application in AzureAD
        # $null = New-AzureADApplicationKeyCredential -ObjectId $myApp.ObjectID `
        # -CustomKeyIdentifier $base64Thumbprint `
        # -Type AsymmetricX509Cert -Usage Verify `
        # -Value $base64Value `
        # -StartDate ($cer.NotBefore) `
        # -EndDate ($cer.NotAfter)
    }
    
    end {
        
    }
}
