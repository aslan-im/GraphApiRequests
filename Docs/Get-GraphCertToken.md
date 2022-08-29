---
external help file: GraphApiRequests-help.xml
Module Name: GraphApiRequests
online version:
schema: 2.0.0
---

# Get-GraphCertToken

## SYNOPSIS
Function for generating token from certificate

## SYNTAX

```
Get-GraphCertToken [-AppId] <String> [-TenantID] <String> [-CertificatePath] <String> [<CommonParameters>]
```

## DESCRIPTION
This function uses the Certificate private part instead of Secret for getting the Token

## EXAMPLES

### EXAMPLE 1
```
Get-GraphCertToken -AppId 5265b837-2695-47c2-bc8a-12d064bab6af -TenantID c00b7c2b-ef1b-43f8-8798-2583cb4605db -CertificatePath Cert:\CurrentUser\Computer\3CF88F457CCCE9817ACDB658226031EA0664032B
Getting the Token by certificate
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

### -TenantID
{{ Fill TenantID Description }}

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

### -CertificatePath
{{ Fill CertificatePath Description }}

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

## OUTPUTS

## NOTES
Requires:
    - App ID
    - Tenatn ID
    - Certificate Path

## RELATED LINKS
