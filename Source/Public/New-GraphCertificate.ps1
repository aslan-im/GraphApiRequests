function New-GraphCertificate {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $TenantName,

        [Parameter(Mandatory=$false)]
        [string]
        $StoreLocation = 'Cert:\CurrentUser\My',

        [Parameter(Mandatory=$false)]
        [ValidateScript({
            ($_ -gt (Get-Date -Hour 0 -Minute 0 -Second 0).AddHours(23))
        })]
        [datetime]
        $ExpirationDate = (Get-Date).AddYears(1),

        [Parameter(Mandatory=$false)]
        [string]
        $FriendlyName = "GraphCert"
    )
    
    $CreateCert = @{
        FriendlyName = $FriendlyName
        DnsName = $TenantName
        CertStoreLocation = $StoreLocation
        NotAfter = $ExpirationDate
        KeyExportPolicy = "Exportable"
        KeySpec = "Signature"
        Provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        HashAlgorithm = "SHA256"
    }
   
    $Certificate = New-SelfSignedCertificate @CreateCert

    $CertificatePath = Join-Path -Path $StoreLocation -ChildPath $Certificate.Thumbprint

    $ExportPathCheck = "C:\Temp"
    If (!(Test-Path -Path $ExportPathCheck)){
        New-Item -ItemType Folder -Path $ExportPathCheck
    }
    
    $CerOutPath = "C:\Temp\$FriendlyName.cer"
    Export-Certificate -Cert $CertificatePath -FilePath $CerOutPath | Out-Null
}