<#
.SYNOPSIS
    Function to get a device authentication token.
.DESCRIPTION
    This function works only if your tenant satisfy the pre-requisites below:
        - Registered Graph API application with required permissions (depends of the requests that you need)
        - Enabled redirection for Mobile and desktop applications. More details here: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#register-a-new-application-using-the-azure-portal
        - Configured redirect URL: https://localhost
        - '"allowPublicClient": true' in application Manifest json
.EXAMPLE
    PS C:\> Get-GraphDeviceAuthToken -TenantName 'contoso' -AppId '246c7445-eee6-4d60-968d-f83d67183753' 
    Getting the device auth token for Contoso tenant using application ID registered in Azure AD
.PARAMETER TenantName 
    You can find your tenant name using Azure AD  portal > Overview > Basic information > Name
.PARAMETER AppId
    Фpplication ID registered in Azure AD
.INPUTS
    None. You cannot pipe objects to Get-GraphDeviceAuthToke
.OUTPUTS
    System.Array. Returns the array with token
.LINK
    Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Get-GraphDeviceAuthToken.ps1
.LINK 
    Source code of whole project: https://github.com/aslan-im/GraphApiRequests
#>
function Get-GraphDeviceAuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $AppId,

        [Parameter(Mandatory)]
        [string]
        $TenantName,

        [Parameter(Mandatory=$false)]
        [string]
        $ApiUrl = "https://graph.microsoft.com/"
    )
    . $PSScriptRoot\..\Private\New-GraphAuthFormWindow.ps1
    . $PSScriptRoot\..\Private\Get-GraphDeviceAuthCode.ps1

    $TenantUrl = "$TenantName.onmicrosoft.com"

    $AuthUrl = "https://login.microsoftonline.com/$TenantUrl"

    $CodeRequestSplat = @{
        TenantName = $TenantName
        AppId = $AppId
    }

    $DeviceCodeObject = Get-GraphDeviceAuthCode @CodeRequestSplat
    Write-Output $DeviceCodeObject.message
    $Code = ($DeviceCodeObject.message -split "code " | Select-Object -Last 1) -split " to authenticate."
    Set-Clipboard -Value $Code

    New-GraphAuthFormWindow

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
}