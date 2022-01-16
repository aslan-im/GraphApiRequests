<#
.SYNOPSIS
    Function for getting token using client secret
.DESCRIPTION
    For using this function you need to have a generated AppSecret (Client secret) in registered application in Azure AD
.EXAMPLE
    PS C:\> Get-GraphToken -AppId '246c7445-eee6-4d60-968d-f83d67183753' -AppSecret '6R[O)5D8sHZ^pt"3' -TenantId 'd1ee13a4-c9d0-4ab0-bff5-c011dfc20717'
    Example of getting the token
.INPUTS
    None. You cannot pipe objects to Get-GraphDeviceAuthToke
.OUTPUTS
    Returns an array with token 
.LINK
    Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Get-GraphToken.ps1
.LINK 
    Source code of whole project: https://github.com/aslan-im/GraphApiRequests
#>
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