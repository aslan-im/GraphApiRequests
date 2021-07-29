BeforeAll{
    . $PSScriptRoot\..\Functions\Public\Get-GraphDeviceAuthToken.ps1
    . $PSScriptRoot\..\Functions\Private\Get-GraphDeviceAuthCode.ps1
    . $PSScriptRoot\..\Functions\Private\New-GraphAuthFormWindow.ps1
}
Describe "Get-GraphDeviceAuthToken" {
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

        Mock Get-GraphDeviceAuthCode{
            return $DeviceCodeObject
        }

        Mock New-GraphAuthFormWindow{
            return
        }

        Mock Invoke-RestMethod {
            return $TokenObject 
        }

        Mock Write-Output{
            return
        }

        $TokenRequestSplat = @{
            AppId = $((New-Guid).Guid)
            TenantName = 'contoso'
        }
        
    }
    It "It returns token" {
        Get-GraphDeviceAuthToken @TokenRequestSplat | Should -be $TokenObject
    }
    
}