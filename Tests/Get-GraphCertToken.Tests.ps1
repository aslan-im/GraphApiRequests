BeforeAll{
    . $PSScriptRoot\..\Source\Public\Get-GraphCertToken.ps1
}

Describe Get-GraphCertToken {
    BeforeEach{
        $CertificatePath = "$TestDrive\FakeCertificate.cer"
        # New-Item -Path $CertificatePath -ItemType File

        # $CertificateObject = New-Module -AsCustomObject -ScriptBlock {
        #     $PrivateKey = "SomeString"
        #     $CertHash = [System.Byte[]]::CreateInstance([System.Byte],8)
        #     function GetCertHash {
        #         return $CertHash
        #     }

        #     function SignData(){
        #         return 1;
        #     }
        # }

        # Mock Get-Item {
        #     return $CertificateObject
        # }
    
        # Mock Invoke-RestMethod {
        #     return $true
        # }

        
    }
    # Mock Get-SignData {
    #     return "0";
    # }

    # It "Returns true"{
    #     $Splat = @{
    #         AppId = (New-Guid).Guid
    #         TenantID = (New-Guid).Guid
    #         CertificatePath = "fake\path"
    #         ErrorAction = "STOP"
    #     }
    #     Get-GraphCertToken @Splat | Should -be $true
    # }

    It "Returns True. All mandatory params are mandatory"{
        $MandatoryParams = @("AppId", "CertificatePath", "TenantID")
        foreach($Param in $MandatoryParams){
            (Get-Command Get-GraphCertToken).Parameters[$Param].Attributes.Mandatory | Should -Be $true
        }
    }

    
}