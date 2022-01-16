BeforeAll{
    . $PSScriptRoot\..\Source\Private\Get-GraphDeviceAuthCode.ps1
}
Describe "Get-GraphDeviceAuthCode" {
    BeforeAll{
        $ResponseObject = [PSCustomObject]@{
            user_code = "DBL79WLXV"
            device_code = "bO5w0NEMG78cK90"
            verification_url = "https://microsoft.com/devicelogin"
            expires_in = 900
            interval = 5
            message = "To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code DBL79WLXV to authenticate."
        }
    }
    
    It "Returns predefined object" {

        Mock Invoke-RestMethod {
            return $ResponseObject
        }

        $Splat = @{
            TenantName = $((New-Guid).Guid)
            AppId = $((New-Guid).Guid)
        }

        Get-GraphDeviceAuthCode @Splat | Should -be $ResponseObject
    }
}