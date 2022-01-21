BeforeAll{
    . $PSScriptRoot\..\Source\Public\New-GraphCertificate.ps1
}

Describe New-GraphCertificate{
    BeforeAll{
        $TenantName = "contoso.onmicrosoft.com"
        $StoreLocation = "$TestDrive"
        $ExpirationDate = (Get-Date).AddYears(1)
        $FriendlyName = "FakeCertificate"
        # New-Item -Path $StoreLocation -Name "$FriendlyName.txt" -ItemType "File"

        Mock New-SelfSignedCertificate {
            return New-Guid
        }

        Mock Export-Certificate {
        }

        Mock Test-Path {
            return $true
        }
    }

    It "Creates fake certificate"{
        $Splat = @{
            TenantName = $TenantName
            StoreLocation = $StoreLocation
            ExpirationDate = $ExpirationDate
            FriendlyName = $FriendlyName
        }
        New-GraphCertificate @Splat | Should -be $null
    }

    it "Throws because of ExpirationDate" {
        $Splat = @{
            TenantName = $TenantName
            StoreLocation = $StoreLocation
            ExpirationDate = "Not a date"
            FriendlyName = $FriendlyName
        }
        {New-GraphCertificate @Splat} | Should -throw "Cannot process argument transformation on parameter 'ExpirationDate'*"
    }

    it "Tenant name is mandatory"{
        (Get-Command New-GraphCertificate).Parameters['TenantName'].Attributes.Mandatory | Should -Be $true
    }
}