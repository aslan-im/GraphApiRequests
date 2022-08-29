---
external help file: GraphApiRequests-help.xml
Module Name: GraphApiRequests
online version:
schema: 2.0.0
---

# New-GraphCertificate

## SYNOPSIS
Function for generating new self signed Graph API auth certificate

## SYNTAX

```
New-GraphCertificate [-TenantName] <String> [[-StoreLocation] <String>] [[-CertificateOutputPath] <String>]
 [[-ExpirationDate] <DateTime>] [[-FriendlyName] <String>] [<CommonParameters>]
```

## DESCRIPTION
After the creation, certificate can be used for authentication in Graph API

## EXAMPLES

### EXAMPLE 1
```
New-GraphCertificate -TenantName 'Contoso' -StoreLocation 'Cert:\CurrentUser\Computer'
Generate new certificate and save in Cert:\CurrentUser\Computer
```

## PARAMETERS

### -TenantName
{{ Fill TenantName Description }}

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

### -StoreLocation
{{ Fill StoreLocation Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Cert:\CurrentUser\My
Accept pipeline input: False
Accept wildcard characters: False
```

### -CertificateOutputPath
{{ Fill CertificateOutputPath Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExpirationDate
{{ Fill ExpirationDate Description }}

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: (Get-Date).AddYears(1)
Accept pipeline input: False
Accept wildcard characters: False
```

### -FriendlyName
{{ Fill FriendlyName Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: GraphCert
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
For running this function you require to provide TenantName (not an ID).

## RELATED LINKS
