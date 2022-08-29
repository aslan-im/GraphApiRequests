---
external help file: GraphApiRequests-help.xml
Module Name: GraphApiRequests
online version:
schema: 2.0.0
---

# Get-GraphDeviceAuthToken

## SYNOPSIS
Function to get a device authentication token.

## SYNTAX

```
Get-GraphDeviceAuthToken [-AppId] <String> [-TenantName] <String> [[-ApiUrl] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function works only if your tenant satisfy the pre-requisites below:
    - Registered Graph API application with required permissions (depends of the requests that you need)
    - Enabled redirection for Mobile and desktop applications.
More details here: https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app#register-a-new-application-using-the-azure-portal
    - Configured redirect URL: https://localhost
    - '"allowPublicClient": true' in application Manifest json

## EXAMPLES

### EXAMPLE 1
```
Get-GraphDeviceAuthToken -TenantName 'contoso' -AppId '246c7445-eee6-4d60-968d-f83d67183753' 
Getting the device auth token for Contoso tenant using application ID registered in Azure AD
```

## PARAMETERS

### -AppId
Фpplication ID registered in Azure AD

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TenantName
You can find your tenant name using Azure AD  portal \> Overview \> Basic information \> Name

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

### -ApiUrl
{{ Fill ApiUrl Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Https://graph.microsoft.com/
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-GraphDeviceAuthToke
## OUTPUTS

### System.Array. Returns the array with token
## NOTES

## RELATED LINKS

[Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Get-GraphDeviceAuthToken.ps1]()

[Source code of whole project: https://github.com/aslan-im/GraphApiRequests]()

