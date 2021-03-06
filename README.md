# GraphApiRequests
[![Build](https://github.com/aslan-im/GraphApiRequests/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/aslan-im/GraphApiRequests/actions/workflows/build.yml)   
Simple Microsoft Graph API requests module
## Overview
 To use this module you need to be familiar with [Microsoft Docs](https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-beta) site where you can find all possible resources for requests.

## Synopsis

GraphAPIRequests supports all type of the requests. You do not need to create the headers, this module will do all the things instead of you! Just select required resource, register the application, get the token and run Invoke-GraphApiRequest.

## Getting Started (Quickstart)

Install the latest module version from PSGallery using:

```PowerShell
PS C:\> Install-Module GraphApiRequests
```

### About the permissions

To start using this module you need to register the Graph API application in your Azure AD following this [instruction](https://docs.microsoft.com/en-us/graph/auth-register-app-v2).

There are two types of the permissions:

* Delegated permissions - possible to use only with user interaction. User needs to authorise in application using his credentials. (Get-GraphDeviceAuthentication)
* Application permissions - requests require this type of permissions can be automated and be used without user interaction (Get-GraphToken)

Depends of the type of permissions you can use two different commandlets for getting a token.

### Get-GraphDeviceAuthentication

There are the pre-requisites for using this type of authorization:

- Redirect URIs should be configured in your application as 'Mobile and desktop applications'
- "https://localhost" should be added as Redirect URI
- Permission assigned to application should be "Delegated"
- Manifest parameter "allowPublicClient" should be set to "true"

#### Usage Example

```PowerShell
PS C:\> $Token = Get-GraphDeviceAuthToken -TenantName 'contoso' -AppId '246c7445-eee6-4d60-968d-f83d67183753'
```

Getting the device auth token for Contoso tenant using application ID registered in Azure AD

### Get-GraphToken

For using this auth method, you need to generate Client Secret (AppSecret) in application Certificates & secrets menu.

#### Usage Example

```PowerShell
PS C:\> $Token = Get-GraphToken -AppId '246c7445-eee6-4d60-968d-f83d67183753' -AppSecret '6R[O)5D8sHZ^pt"3' -TenantId 'd1ee13a4-c9d0-4ab0-bff5-c011dfc20717'
```

Example of getting a token using AppId, AppSecret and TenantId

### Invoking Graph Request

For invoking Graph request you need firstly to get the token using one of the showed examples above.

When you got the token to $Token variable, you can try to get some user info:

```PowerShell
PS C:\> Invoke-GraphApiRequest -Token $Token -Resource 'users/admin@contoso.com' -Method Get
```

Creating a group with predefined properties:

```PowerShell
PS C:\>$BodyObject = [PSCustomObject]@{
        description = "Self help community for golf"
        displayName = "Golf Assist"
        groupTypes = @(
            "Unified"
        )
        mailEnabled = $true
        mailNickname = "golfassist"
        securityenabled = $false
    }
```

```PowerShell
PS C:\> $BodyJson = ConvertTo-Json $BodyObject
```

```PowerShell
PS C:\> Invoke-GraphApiRequest -Token $Token -Resource groups -Method POST -Body $BodyJson
```

About more possible resources you can read in official [Microsoft documentation](https://docs.microsoft.com/en-us/graph/api/overview?view=graph-rest-beta)

## Disclaimer

Author is not responsible for any damage caused to your infrastructure as a result of the module's operation. USE IT ON YOUR OWN RISK!
