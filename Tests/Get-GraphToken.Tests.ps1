BeforeAll{
    . $PSScriptRoot\..\Source\Public\Get-GraphToken.ps1
}

Describe "Get-GraphToken" {
    BeforeAll{
        $TokenObject = [PSCustomObject]@{
            token_type = "Bearer"
            expires_in = 3599
            ext_expires_in = 3599
            access_token = 'eyJ0eXAiOiJKV1QiLCJu'
        }
        Mock Invoke-RestMethod {
            return $TokenObject
        }
        $ScriptParams = @(
            'TenantID',
            'AppSecret',
            'AppId'
        )
    }
    It "Returns token object" {
        $Splat = @{
            TenantID = $((New-Guid).Guid)
            AppSecret = 'TopSecret'
            AppId = $((New-Guid).Guid)
            ErrorAction = 'STOP'
        }
        Get-GraphToken @Splat | Should -be $TokenObject
    }
    It "All params should be $true" {
        foreach ($Param in $ScriptParams){
            ((Get-Command "Get-GraphToken").Parameters[$Param].Attributes.Mandatory) | Should -Be $true
        }
    }
}