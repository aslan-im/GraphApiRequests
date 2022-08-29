---
external help file: GraphApiRequests-help.xml
Module Name: GraphApiRequests
online version:
schema: 2.0.0
---

# Invoke-GraphApiRequest

## SYNOPSIS
Function to invoke Graph API Request

## SYNTAX

```
Invoke-GraphApiRequest [[-Token] <PSObject>] [-Resource] <String> [[-ApiVersion] <String>] [[-Method] <String>]
 [[-TenantId] <String>] [[-Body] <String>] [[-AppID] <String>] [[-AppSecret] <String>] [[-ApiUrl] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Using this function you can invoke any request to the Graph API both versions

## EXAMPLES

### EXAMPLE 1
```
$Token = Get-GraphToken -AppId 246c7445-eee6-4d60-968d-f83d67183753 -AppSecret ?2mwmHICkx8j -TenantID d1ee13a4-c9d0-4ab0-bff5-c011dfc20717
PS C:\> Invoke-GraphApiRequest -Token $Token -Resource groups -Method Get
Example of using Invoke-GraphApiRequest to get the list of Azure AD Groups. In this example first command is required to get the token using app secret.
```

### EXAMPLE 2
```
$BodyObject = [PSCustomObject]@{
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
```

## PARAMETERS

### -Token
{{ Fill Token Description }}

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resource
{{ Fill Resource Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiVersion
{{ Fill ApiVersion Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Beta
Accept pipeline input: False
Accept wildcard characters: False
```

### -Method
{{ Fill Method Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: GET
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantId
{{ Fill TenantId Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Body
{{ Fill Body Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppID
{{ Fill AppID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AppSecret
{{ Fill AppSecret Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiUrl
{{ Fill ApiUrl Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: Https://graph.microsoft.com
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-GraphDeviceAuthToke
## OUTPUTS

### Usually it is JSON
## NOTES

## RELATED LINKS

[Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Invoke-GraphApiRequest.ps1]()

[Source code of whole project: https://github.com/aslan-im/GraphApiRequests]()

