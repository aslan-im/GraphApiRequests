### --- PUBLIC FUNCTIONS --- ###
#Region - Get-GraphCertToken.ps1
Function Get-GraphCertToken {
    <#
    .SYNOPSIS
        Function for generating token from certificate
    .DESCRIPTION
        This function uses the Certificate private part instead of Secret for getting the Token
    .NOTES
        Requires:
            - App ID
            - Tenatn ID
            - Certificate Path
    .EXAMPLE
        Get-GraphCertToken -AppId 5265b837-2695-47c2-bc8a-12d064bab6af -TenantID c00b7c2b-ef1b-43f8-8798-2583cb4605db -CertificatePath Cert:\CurrentUser\Computer\3CF88F457CCCE9817ACDB658226031EA0664032B
        Getting the Token by certificate
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $AppId, 

        [Parameter(Mandatory=$true)]
        [string]        
        $TenantID,
        
        [Parameter(Mandatory=$true)]
        [string]
        $CertificatePath     
    )
    

    $Scope = "https://graph.microsoft.com/.default"

    $Certificate = Get-Item $CertificatePath
    $CertificateBase64Hash = [System.Convert]::ToBase64String($Certificate.GetCertHash())

    $StartDate = (Get-Date "1970-01-01T00:00:00Z" ).ToUniversalTime()
    $JWTExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End (Get-Date).ToUniversalTime().AddMinutes(2)).TotalSeconds
    $JWTExpiration = [math]::Round($JWTExpirationTimeSpan,0)

    $NotBeforeExpirationTimeSpan = (New-TimeSpan -Start $StartDate -End ((Get-Date).ToUniversalTime())).TotalSeconds
    $NotBefore = [math]::Round($NotBeforeExpirationTimeSpan,0)

    $JWTHeader = @{
        alg = "RS256"
        typ = "JWT"
        x5t = $CertificateBase64Hash -replace '\+','-' -replace '/','_' -replace '='
    }

    $JWTPayLoad = @{
        aud = "https://login.microsoftonline.com/$TenantID/oauth2/token"
        exp = $JWTExpiration
        iss = $AppId
        jti = [guid]::NewGuid()
        nbf = $NotBefore
        sub = $AppId
    }

    $JWTHeaderToByte = [System.Text.Encoding]::UTF8.GetBytes(($JWTHeader | ConvertTo-Json))
    $EncodedHeader = [System.Convert]::ToBase64String($JWTHeaderToByte)

    $JWTPayLoadToByte =  [System.Text.Encoding]::UTF8.GetBytes(($JWTPayload | ConvertTo-Json))
    $EncodedPayload = [System.Convert]::ToBase64String($JWTPayLoadToByte)

    $JWT = $EncodedHeader + "." + $EncodedPayload

    $PrivateKey = $Certificate.PrivateKey

    $Signature = Get-SignData -inputObject $PrivateKey -JWT $JWT

    $JWT = $JWT + "." + $Signature

    $Body = @{
        client_id = $AppId
        client_assertion = $JWT
        client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
        scope = $Scope
        grant_type = "client_credentials"

    }

    $Url = "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token"

    $Header = @{
        Authorization = "Bearer $JWT"
    }

    $PostSplat = @{
        ContentType = 'application/x-www-form-urlencoded'
        Method = 'POST'
        Body = $Body
        Uri = $Url
        Headers = $Header
    }

    Invoke-RestMethod @PostSplat
}
Export-ModuleMember -Function Get-GraphCertToken
#EndRegion - Get-GraphCertToken.ps1
#Region - Get-GraphDeviceAuthToken.ps1
function Get-GraphDeviceAuthToken {
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
Export-ModuleMember -Function Get-GraphDeviceAuthToken
#EndRegion - Get-GraphDeviceAuthToken.ps1
#Region - Get-GraphToken.ps1
Function Get-GraphToken {
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
Export-ModuleMember -Function Get-GraphToken
#EndRegion - Get-GraphToken.ps1
#Region - Invoke-GraphApiRequest.ps1
function Invoke-GraphApiRequest {
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
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [PSCustomObject]
        $Token, 
        
        [Parameter(Mandatory=$True)]
        [string]
        $Resource, 

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
        $AppSecret,

        [Parameter(Mandatory=$false)]
        [string]
        $ApiUrl = 'https://graph.microsoft.com'
    )

    

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

    if ($Resource[0] -eq '/') {
        $Resource = $Resource -replace '^.'
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
    
    $Result = @()

    try {
        $ResultResponse = Invoke-RestMethod @PostSplat -ErrorAction Stop

        if([bool]($ResultResponse -match "value")){
            $Result = $ResultResponse.value
        }
        else{
            $Result = $ResultResponse
        }
        

        if([bool]($ResultResponse -match "@odata.nextLink")){
            $ResultNextLink = $ResultResponse."@odata.nextLink"
        }
            
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

                $Result += $ResultResponse.value
            }

        }
        return $Result
    } 
    catch {
        throw  $_.Exception
        break
    }
}
Export-ModuleMember -Function Invoke-GraphApiRequest
#EndRegion - Invoke-GraphApiRequest.ps1
#Region - New-GraphCertificate.ps1
function New-GraphCertificate {
    <#
    .SYNOPSIS
        Function for generating new self signed Graph API auth certificate
    .DESCRIPTION
        After the creation, certificate can be used for authentication in Graph API
    .NOTES
        For running this function you require to provide TenantName (not an ID).
    .EXAMPLE
        New-GraphCertificate -TenantName 'Contoso' -StoreLocation 'Cert:\CurrentUser\Computer'
        Generate new certificate and save in Cert:\CurrentUser\Computer
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $TenantName,

        [Parameter(Mandatory=$false)]
        [string]
        $StoreLocation = 'Cert:\CurrentUser\My',

        [Parameter(Mandatory=$False)]
        [string]
        $CertificateOutputPath = "C:\Temp",

        [Parameter(Mandatory=$false)]
        [DateTime][ValidateScript({$_ -ge (Get-Date)})]
        $ExpirationDate = (Get-Date).AddYears(1),

        [Parameter(Mandatory=$false)]
        [string]
        $FriendlyName = "GraphCert"
    )
    
    $CreateCertSplat = @{
        FriendlyName = $FriendlyName
        DnsName = $TenantName
        CertStoreLocation = $StoreLocation
        NotAfter = $ExpirationDate
        KeyExportPolicy = "Exportable"
        KeySpec = "Signature"
        Provider = "Microsoft Enhanced RSA and AES Cryptographic Provider"
        HashAlgorithm = "SHA256"
        ErrorAction = "Stop"
    }
   
    $Certificate = New-SelfSignedCertificate @CreateCertSplat

    $CertificatePath = Join-Path -Path $StoreLocation -ChildPath $Certificate.Thumbprint

    If (!(Test-Path -Path $CertificateOutputPath)){
        New-Item -ItemType Folder -Path $CertificateOutputPath
    }
    
    $CerOutPath = "$CertificateOutputPath\$FriendlyName.cer"
    Export-Certificate -Cert $CertificatePath -FilePath $CerOutPath
}
Export-ModuleMember -Function New-GraphCertificate
#EndRegion - New-GraphCertificate.ps1
### --- PRIVATE FUNCTIONS --- ###
#Region - Get-GraphDeviceAuthCode.ps1
function Get-GraphDeviceAuthCode {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]
        $ApiUrl = "https://graph.microsoft.com/",

        [Parameter(Mandatory)]
        [string]
        $TenantName,

        [Parameter(Mandatory)]
        [string]
        $AppId
    )
    
    $TenantUrl = "$TenantName.onmicrosoft.com"
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
#EndRegion - Get-GraphDeviceAuthCode.ps1
#Region - Get-SignData.ps1
function Get-SignData {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [System.Security.Cryptography.RSACng]
        $InputObject,

        [Parameter(Mandatory=$false)]
        [string]
        $JWT

    )
    $RSAPadding = [Security.Cryptography.RSASignaturePadding]::Pkcs1
    $HashAlgorithm = [Security.Cryptography.HashAlgorithmName]::SHA256
    
    [Convert]::ToBase64String(
        $InputObject.SignData([System.Text.Encoding]::UTF8.GetBytes($JWT),$HashAlgorithm,$RSAPadding)
    ) -replace '\+','-' -replace '/','_' -replace '='
}
#EndRegion - Get-SignData.ps1
#Region - New-GraphAuthFormWindow.ps1
function New-GraphAuthFormWindow {
    [CmdletBinding()]
    param (     
    )
    Add-Type -AssemblyName System.Windows.Forms
    
    $Form = New-Object -TypeName System.Windows.Forms.Form -Property @{ Width = 440; Height = 640 }
    $Web = New-Object -TypeName System.Windows.Forms.WebBrowser -Property @{ Width = 440; Height = 600; Url = "https://www.microsoft.com/devicelogin" }
    
    $Web.Add_DocumentCompleted($DocComp)
    $Web.DocumentText
    
    $Form.Controls.Add($Web)
    $Form.Add_Shown({ $Form.Activate()})
    $Web.ScriptErrorsSuppressed = $true
    
    $Form.AutoScaleMode = 'Dpi'
    $Form.Text = "Graph API Authentication"
    $Form.ShowIcon = $False
    $Form.AutoSizeMode = 'GrowAndShrink'
    $Form.StartPosition = 'CenterScreen'
    
    $Form.ShowDialog() | Out-Null
}
#EndRegion - New-GraphAuthFormWindow.ps1
