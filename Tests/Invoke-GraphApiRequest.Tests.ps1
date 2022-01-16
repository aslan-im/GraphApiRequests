BeforeAll{
    . $PSScriptRoot\..\Source\Public\Invoke-GraphApiRequest.ps1
}

Describe "Invoke-GraphApiRequest" {
    BeforeAll{
        $ResponseObject = [PSCustomObject]@{
            id = "2bc7f109-afbc-4442-96cf-5b03daa0862b"
            createdDateTime = "2021-04-22T07:06:52Z"
            createdByAppId = "f1966e8e-edb6-4149-9278-fa316cc0522a"
            organizationId = "9ba36efb-0822-4de0-b3b0-52b1fbbd0d3e"
            displayName = "Devices_Dyn"
            mailEnabled = "False"
            renewedDateTime = "2021-04-22T07:06:52Z"
            securityEnabled = "True"
        }

        $ResponseJson = ConvertTo-Json $ResponseObject

        $Token = [PSCustomObject]@{
            token_type = "Bearer"
            expires_in = '3599'
            ext_expires_in = '3599'
            access_token = 'NZW1iZXIuUmVhZC5BbGwiLCJDYWxlbmRhcnMuU'
        }

        Mock Invoke-RestMethod {
            return $ResponseJson
        }

    }

    Context "Get function with Token" {

        Mock Get-GraphToken {
            return $Token
        }
        
        It "Returns predefined object " {
            Invoke-GraphApiRequest -Token $Token -Resource 'groups' -ErrorAction Stop | Should -be $ResponseJson
        }
        It "Requires mandatory param" {
            ((Get-Command Invoke-GraphApiRequest).Parameters['Resource'].Attributes.Mandatory) | Should -Be $true
        }

    }

    Context "Get Function without Token" {

        It "Returns predefined object" {
            $Splat = @{
                TenantId = $((New-Guid).Guid)
                AppId = $((New-Guid).Guid)
                AppSecret = 'SuperSecurePassword'
                Resource = "groups"
                ErrorAction = "Stop"
            }
            Invoke-GraphApiRequest @Splat | Should -be $ResponseJson
        }

        It "Throw because of TenantID" {
            $Splat = @{
                AppId = $((New-Guid).Guid)
                AppSecret = 'SuperSecurePassword'
                Resource = "groups"
                ErrorAction = "Stop"
            }
            {Invoke-GraphApiRequest @Splat} | Should -throw "There is no TenantID*"
        }

        it "Throw because of AppId"{
            $Splat = @{
                TenantId = $((New-Guid).Guid)
                AppSecret = 'SuperSecurePassword'
                Resource = "groups"
                ErrorAction = "Stop"
            }
            {Invoke-GraphApiRequest @Splat} | Should -throw "There is no AppId*"
        }

        It "Throw because of AppSecret" {
            $Splat = @{
                TenantId = $((New-Guid).Guid)
                AppId = $((New-Guid).Guid)
                Resource = "groups"
                ErrorAction = "Stop"
            }
            {Invoke-GraphApiRequest @Splat} | Should -throw "There is no AppSecret*"
        }
    }
}