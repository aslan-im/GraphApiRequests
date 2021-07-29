BeforeAll{
    . $PSScriptRoot\..\Functions\Public\Get-DeviceAuthToken.ps1
    . $PSScriptRoot\..\Functions\Private\Get-DeviceAuthCode.ps1
    . $PSScriptRoot\..\Functions\Private\New-AuthFormWindow.ps1
}
Describe "Get-DeviceAuthToken" {
    BeforeAll{
        $DeviceCodeObject = [PSCustomObject]@{
            user_code = "DBL79WLXV"
            device_code = "bO5w0NEMG78cK90"
            verification_url = "https://microsoft.com/devicelogin"
            expires_in = 900
            interval = 5
            message = "To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code 
            DBL79WLXV to authenticate."
        }

        $TokenObject = [PSCustomObject]@{
            token_type = "Bearer"
            scope = "User.Read.All"
            expires_in = 3599
            ext_expires_in = 3599
            expires_on = 1627385864
            not_before = 1627381964
            resource = "https://graph.microsoft.com/"
            access_token = "S0MeT0KenVa1ue"
            refresh_token = "S0M3R3FR3SHT0K3N"
            id_token = "T0k3N1D"
        }

        Mock Get-DeviceAuthCode{
            return $DeviceCodeObject
        }

        Mock New-AuthFormWindow{
            return
        }

        Mock Invoke-RestMethod {
            return $TokenObject 
        }

        Mock Write-Output{
            return
        }

        $TokenRequstSplat = @{
            AppId = $((New-Guid).Guid)
            TenantUrl = 'contoso.onmicrosoft.com'
        }
        
    }
    It "It returns token" {
        Get-DeviceAuthToken @TokenRequstSplat | Should -be $TokenObject
    }
    
}