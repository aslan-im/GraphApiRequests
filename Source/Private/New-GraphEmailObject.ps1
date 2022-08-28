function New-GraphEmailObject {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [mailaddress]
        $SenderUPN,

        [Parameter(Mandatory=$false)]
        [mailaddress[]]
        $Recipients,

        [Parameter(Mandatory=$false)]
        [mailaddress[]]
        $CopyRecipients,
        
        [Parameter(Mandatory=$false)]
        [mailaddress[]]
        $HidenRecipients,

        [Parameter(Mandatory=$true)]
        [string]
        $MailSubject,

        [Parameter(Mandatory=$true)]
        [string]
        $MessageBody,

        [Parameter(Mandatory=$false)]
        [string[]]
        $AttachmentPaths,

        [Parameter(Mandatory=$false)]
        [string]
        $MessageBodyContentType = "Text"
    )
    
    Write-Verbose "Creating main MessageObject"
    $MessageCustomObject = [ordered]@{
        message = @{
            subject = $MailSubject
            body = @{
                contentType = $MessageBodyContentType
                content = $MessageBody
            }
        }
    }

    Write-Verbose "Checking if recipients exist and theirs count"
    if ($Recipients.Count -eq 1) {
        Write-Verbose "There is only 1 recipient"
        $Recipient = $Recipients[0].Address
        $ToRecipients = @{address = $Recipient}
        Write-Verbose "Adding recipient $Recipient to the MessageObject"
        $MessageCustomObject.message += [ordered]@{
            toRecipients = @(
                @{
                    emailAddress = $ToRecipients
                }
            )
        }
    }
    elseif ($Recipients.Count -gt 1) {
        Write-Verbose "There are more than 1 recipients. Count: $($Recipients.Count)"
        $AddressesTable = @()
        foreach($Recipient in $Recipients){
            Write-Verbose "Adding $Recipient to recipient list"
            $AddressesTable += @{
                emailAddress = @{address = $Recipient.Address}
            }
        }
        Write-Verbose "Adding recipient list to MessageObject"
        $MessageCustomObject.message += [ordered]@{
            toRecipients = $AddressesTable
        }
    }
    
    Write-Verbose "Checking CopyRecipients"
    if($CopyRecipients.count -eq 1){
        $CopyRecipient = $CopyRecipients[0].Address
        Write-Verbose "There is 1 CopyRecipient: $CopyRecipient"
        $ccRecipients = @{address = $CopyRecipient}
        Write-Verbose "Adding recipient $CopyRecipient to the MessageObject"
        $MessageCustomObject.Message += [ordered]@{
            ccRecipients = @(
                @{
                    emailAddress = $ccRecipients
                }
            )
        }
    }
    elseif ($CopyRecipients.Count -gt 1) {
        Write-Verbose "There are more than 1 CopyRecipients. ccRecipients count: $($CopyRecipients.Count)"
        $CopyAddressesTable = @()
        foreach ($CopyRecipient in $CopyRecipients){
            Write-Verbose "Adding $CopyRecipient to  copy recipients list"
            $CopyAddressesTable += @{
                emailAddress = @{address = $CopyRecipient.Address}
            }
        }
        Write-Verbose "Adding ccRecipients list to MessageObject"
        $MessageCustomObject.Message += [ordered]@{
            ccRecipients = $CopyAddressesTable
        }
    }

    Write-Verbose "Checking HidenRecipients and count"
    if($HidenRecipients.count -eq 1){
        $HidenRecipient = $HidenRecipients[0].Address
        Write-Verbose "There is only 1 hiden recipient: $HidenRecipient"
        $bccRecipients = @{address = $HidenRecipient}
        Write-Verbose "Adding $HidenRecipient to the MessageObject"
        $MessageCustomObject.Message += [ordered]@{
            bccRecipients = @(
                @{
                    emailAddress = $bccRecipients
                }
            )
        }
    }
    elseif ($HidenRecipients.Count -gt 1) {
        Write-Verbose "There are more than one hidenRecipients. HidenRecipients count: $($HidenRecipient.Count)"
        $HidenAddressesTable = @()
        foreach ($HidenRecipient in $HidenRecipients){
            Write-Verbose "Adding HidenRecipient $HidenRecipient to the list"
            $HidenAddressesTable += @{
                emailAddress = @{address = $HidenRecipient.Address}
            }
        }
        Write-Verbose "Adding hidden recipients list to the MessageObject"
        $MessageCustomObject.Message += [ordered]@{
            bccRecipients = $HidenAddressesTable
        }
    }

    Write-Verbose "Checking attachments and count"
    if ($AttachmentPaths) {
        if ($AttachmentPaths.count -eq 1) {
            Write-Verbose "There is only 1 attachment: $AttachmentPaths"
            $isAttachmentValid = Test-Path $AttachmentPaths
            if ($isAttachmentValid) {
                Write-Verbose "Attachment $AttachmentPaths successfully checked."
                $AttachmentName = ((Get-Item -Path $AttachmentPaths).name)
                $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($AttachmentPaths))
                $MessageCustomObject.Message.attachments += @(
                    @{
                        '@odata.type' = "#microsoft.graph.fileAttachment"
                        name = $AttachmentName
                        contentType = 'text/plain'
                        contentBytes = $Base64String
                    }
                )
            }
            else{
                throw "Provided attachment path is invalid"
                break
            }
        }
        elseif ($AttachmentPaths.count -gt 1) {
            Write-Verbose "There are more than 1 attachments. Count: $($AttachmentPaths.count)"
            $AttachmentsObjectLists = @()
            foreach ($Attachment in $AttachmentPaths) {
                Write-Verbose "Checking the file $Attachment"
                $isAttachmentValid = Test-Path $Attachment
                if ($isAttachmentValid) {
                    Write-Verbose "File $Attachment is reachable"
                    $AttachmentName = ((Get-Item -Path $Attachment).name)
                    $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($Attachment))
                    Write-Verbose "Adding $AttachmentName to the list"
                    $AttachmentsObjectLists += @{
                        '@odata.type' = "#microsoft.graph.fileAttachment"
                        name = $AttachmentName
                        contentType = 'text/plain'
                        contentBytes = $Base64String
                    }                   
                }
                else{
                    throw "Attachment with path $Attachment hasn't been found! Please check the path."
                    break
                }
            }
            if($AttachmentsObjectLists.count -gt 1)  {
                Write-Verbose "Adding prepared list to the MailObject"
                $MessageCustomObject.Message += [ordered]@{
                    attachments = $AttachmentsObjectLists
                }
            }
        }
    }

    return $MessageCustomObject
}