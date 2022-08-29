---
external help file: GraphApiRequests-help.xml
Module Name: GraphApiRequests
online version:
schema: 2.0.0
---

# Get-GraphToken

## SYNOPSIS
Function for getting token using client secret

## SYNTAX

```
Get-GraphToken [-AppId] <String> [-AppSecret] <String> [-TenantID] <String> [<CommonParameters>]
```

## DESCRIPTION
For using this function you need to have a generated AppSecret (Client secret) in registered application in Azure AD

## EXAMPLES

### EXAMPLE 1
```
Get-GraphToken -AppId '246c7445-eee6-4d60-968d-f83d67183753' -AppSecret '6R[O)5D8sHZ^pt"3' -TenantId 'd1ee13a4-c9d0-4ab0-bff5-c011dfc20717'
Example of getting the token
```

## PARAMETERS

### -AppId
{{ Fill AppId Description }}

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

### -AppSecret
{{ Fill AppSecret Description }}

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

### -TenantID
{{ Fill TenantID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None. You cannot pipe objects to Get-GraphDeviceAuthToke
## OUTPUTS

### Returns an array with token
## NOTES

## RELATED LINKS

[Source code of this function: https://github.com/aslan-im/GraphApiRequests/blob/main/Functions/Public/Get-GraphToken.ps1]()

[Source code of whole project: https://github.com/aslan-im/GraphApiRequests]()

