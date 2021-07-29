function Invoke-GraphApiRequest {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [PSCustomObject]
        $Token, 
        
        [Parameter(Mandatory=$True)]
        [string]
        $Resource = $(Throw '-Resource param is required'), 
        
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