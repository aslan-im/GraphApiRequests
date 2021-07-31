<#
.SYNOPSIS
    Function to invoke Graph API Request
.DESCRIPTION
    Using this function you can invoke any request to the Graph API both versions
.EXAMPLE
    PS C:\> $Token = Get-GraphToken -AppId 246c7445-eee6-4d60-968d-f83d67183753 -AppSecret ?2mwmHICkx8j -TenantID d1ee13a4-c9d0-4ab0-bff5-c011dfc20717
    PS C:\> Invoke-GraphApiRequest -Token $Token -Resource groups -Method Get
    Example of using Invoke-GraphApiRequest to get the list of Azure AD Groups. In this example first command is required to get the token using app secret.
.EXAMPLE
    PS C:\> $BodyObject = [PSCustomObject]@{
        description = "Self help community for golf"
        displayName = "Golf Assist"
        groupTypes = @(
            "Unified"
        )
        mailEnabled = $true
        mailNickname = "golfassist"
        securityenabled = $false
    }
    PS C:\> $BodyJson = ConvertTo-Json $BodyObject
    PS C:\> $Token = Get-GraphToken -AppId 246c7445-eee6-4d60-968d-f83d67183753 -AppSecret ?2mwmHICkx8j -TenantID d1ee13a4-c9d0-4ab0-bff5-c011dfc20717
    PS C:\> Invoke-GraphApiRequest -Token $Token -Resource groups -Method POST -Body $BodyJson
    Steps in this example:
        1. Creating a PSCustomObject with payload of MailEnalbed Security Group
        2. Converting PSCustomObject to Json
        3. Getting the token using Secret (if you already have a token and it is not expired, this step can be skipped)
        4. Invoking a request to the Graph API for creating a new group with predefined properties   
.INPUTS
    None. You cannot pipe objects to Get-GraphDeviceAuthToke
.OUTPUTS
    Usually it is JSON
.LINK
    Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Invoke-GraphApiRequest.ps1
.LINK 
    Source code of whole project: https://github.com/aslan-im/GraphApiRequests
#>
function Invoke-GraphApiRequest {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [PSCustomObject]
        $Token, 
        
        [Parameter(Mandatory=$True)]
        [string]
        $Resource, 
        
        [Parameter()]
        [string]
        $ApiUrl = 'https://graph.microsoft.com',

        [Parameter(Mandatory=$false)]
        [ValidateSet('beta', 'v1.0')]
        [string]
        $ApiVersion = 'beta',

        [Parameter(Mandatory=$false)]
        [ValidateSet('GET', 'PATCH', 'POST', 'PUT', 'DELETE')]
        [string]
        $Method = 'GET',

        [Parameter(Mandatory=$false)]
        [string]
        $TenantId,

        [Parameter(Mandatory=$false)]
        [string]
        $Body,

        [Parameter(Mandatory=$false)]
        [string]
        $AppID,

        [Parameter(Mandatory=$false)]
        [string]
        $AppSecret
    )

    . $PSScriptRoot\Get-GraphToken.ps1

    if (!$Token -and $AppId -and $AppSecret -and $TenantId) {
        try{
            $Token = Get-GraphToken -TenantID $TenantId -AppId $AppId -AppSecret $AppSecret -ErrorAction Stop
        }
        catch{
            throw $_.Exception
            break
        }
    }
    elseif (!$Token -and !$AppId -and $AppSecret -and $TenantId) {
        throw "There is no AppId parameter specified. Please run commandlet again with -AppId specified."
        break
    }
    elseif (!$Token -and $AppId -and !$AppSecret) {
        throw "There is no AppSecret parameter specified. Please run commandlet again with -AppSecret specified."
        break
    }
    elseif (!$Token -and $AppId -and $AppSecret -and !$TenantId) {
        throw "There is no TenantID parameter specified. Please run commandlet again with -TenantId specified."
        break
    }
    elseif (!$Token -and !$AppId -and !$AppSecret) {
        throw "Token, AppId, AppSecret or TenantID are not specified. Please run commandlet with Token specified or with AppId and AppSecret."
        break
    }

    $Url = "$ApiUrl/$ApiVersion/$($Resource)"

    $Header = @{
        Authorization = "$($Token.token_type) $($Token.access_token)"
    }

    $PostSplat = @{
        ContentType = 'application/json'
        Method = $Method
        Header = $Header
        Uri = $Url
    }

    if ($Body) {
        $PostSplat.Add('Body', $Body)
    }


    try {
        $ResultResponse = Invoke-RestMethod @PostSplat -ErrorAction Stop
        $Result = $ResultResponse
        $ResultNextLink = $ResultResponse."@odata.nextLink"
        $page = $null

        if ($ResultNextLink) {

            while ($null -ne $ResultNextLink){

                $PostSplat = @{
                    ContentType = 'application/json'
                    Method = $Method
                    Header = $Header
                    Uri = $ResultNextLink
                }

                $ResultResponse = Invoke-RestMethod @PostSplat -ErrorAction Stop
                $ResultNextLink = $ResultResponse."@odata.nextLink"
                $Result += $ResultResponse
                $page += 1
                Write-Output "Collecting data"
                Write-Output "Processing page number $page"
            }

        }
        return $Result
    } 
    catch {
        throw  $_.Exception
        break
    }
}