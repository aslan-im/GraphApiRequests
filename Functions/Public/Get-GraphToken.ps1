Function Get-GraphToken {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $AppId, 
        
        [Parameter(Mandatory=$true)]
        [string]
        $AppSecret, 
        
        [Parameter(Mandatory=$true)]
        [string]        
        $TenantID
    )
    
    $AuthUrl = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"
    $Scope = "https://graph.microsoft.com/.default"

    $Body = @{
        client_id = $AppId
        client_secret = $AppSecret
        scope = $Scope
        grant_type = 'client_credentials'

    }

    $PostSplat = @{
        ContentType = 'application/x-www-form-urlencoded'
        Method = 'POST'
        Body = $Body
        Uri = $AuthUrl
        ErrorAction = "Stop"

    }
    
    try {
        Invoke-RestMethod @PostSplat
    }
    catch {
        throw "Exception was caught: $($_.Exception.Message)" 
        break
    }


}