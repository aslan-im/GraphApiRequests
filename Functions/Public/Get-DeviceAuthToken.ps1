function Get-DeviceAuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $ApiUrl = "https://graph.microsoft.com/",

        [Parameter(Mandatory)]
        [string]
        $TenantUrl,

        [Parameter(Mandatory)]
        [string]
        $AppId
    )
    . $PSScriptRoot\..\Private\New-AuthFormWindow.ps1
    . $PSScriptRoot\..\Private\Get-DeviceAuthCode.ps1

    $AuthUrl = "https://login.microsoftonline.com/$TenantUrl"

    $CodeRequestSplat = @{
        TenantUrl = $TenantUrl
        AppId = $AppId
    }

    $DeviceCodeObject = Get-DeviceAuthCode @CodeRequestSplat
    Write-Output $DeviceCodeObject.message
    $Code = ($DeviceCodeObject.message -split "code " | Select-Object -Last 1) -split " to authenticate."
    Set-Clipboard -Value $Code

    New-AuthFormWindow

    $TokenParamsSplat = @{
        Method = "POST"
        URI = "$Authurl/oauth2/token"
        ErrorAction = "Stop"
        body = @{
            grant_type = 'device_code'
            resource = $ApiUrl
            client_id = $AppId
            code = $($DeviceCodeObject.device_code)
        }
    }

    $TokenResponse = $null

    try {
        $TokenResponse = Invoke-RestMethod @TokenParamsSplat
        return $TokenResponse
    }
    catch [System.Net.WebException]{
        if ($null -eq $_.Exception.Response){
    		throw
    	}

        $Result = $_.Exception.Response.GetResponseStream()
    	$Reader = New-Object System.IO.StreamReader($Result)
    	$Reader.BaseStream.Position = 0
    	$ErrorBody = ConvertFrom-Json $Reader.ReadToEnd()

        if ($ErrorBody.Error -ne "authorization_pending"){
    		throw
    	}
    }

    If ($null -eq $TokenResponse){
    	Write-Warning "Not Connected"
    }
    else{
    	Write-Output "Connected has been established"
    }
    
}