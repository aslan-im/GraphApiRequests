function Get-DeviceAuthCode {
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
    
    $AuthUrl = "https://login.microsoftonline.com/$TenantUrl"

    $PostSPlat = @{
        method = 'POST'
        uri = "$AuthUrl/oauth2/devicecode"
        ErrorAction = "STOP"
        body = @{
            resource = $ApiUrl
            client_id = $AppId
        }
    }
    
    try {
        Invoke-RestMethod @PostSPlat
    }
    catch [System.Net.WebException]{
        throw $_.Exception
    }
    
}