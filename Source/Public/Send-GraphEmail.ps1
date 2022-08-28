function Send-GraphEmail {
    <#
    .SYNOPSIS
        Function to send email through Graph API
    .DESCRIPTION
        Function requires Mail.Send Application permissions. 
    .NOTES
        This function can send emails with To, CC, BCC and Attachments
    .EXAMPLE
        Send-GraphEmail -SenderUPN 'John.Smith@contoso.com' -Recipients @('Maria.Magdalena@contoso.com', 'Thomas.Anderson@contoso.com') -Token $Token
    #>
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
        $MessageBodyContentType = "Text",

        [Parameter(Mandatory=$true)]
        [PSCustomObject]
        $Token
    )

    begin {
        #requires -module GraphApiRequests
        Import-module GraphApiRequests

        . $PSScriptRoot\..\private\New-GraphEmailObject.ps1
    }
    
    process {
        Write-Verbose "Checking if recipients defined"
        if(!$Recipients -and !$CopyRecipients -and !$HidenRecipients){
            Write-Verbose "There are no recipients"
            throw "There are no recipients. Function can't be invoked"
            break
        }

        $MailObjectSplat = @{
            SenderUPN = $SenderUPN
            MailSubject = $MailSubject
            MessageBody = $MessageBody
            MessageBodyContentType = $MessageBodyContentType
            ErrorAction = "STOP"
        }

        if ($Recipients){
            $MailObjectSplat.Add('Recipients', $Recipients)
        }

        if ($CopyRecipients){
            $MailObjectSplat.Add("CopyRecipients", $CopyRecipients)
        }

        if ($HidenRecipients){
            $MailObjectSplat.Add("HidenRecipients", $HidenRecipients)
        }
        
        if($AttachmentPaths){
            foreach($Attacment in $AttachmentPaths){
                $IsPathValid = Test-Path -Path $Attacment
                if (!$IsPathValid) {
                    throw "Attachment with path $Attacment hasn't been found! Please check the path."
                    break
                }
            }
            $MailObjectSplat.Add("AttachmentPaths", $AttachmentPaths)
        }

        try {
            $MailObjectSplat = New-GraphEmailObject @MailObjectSplat
        }
        catch {
            Write-Verbose $_.Exception
            break
        }
        

        $RequestURI = "users/$SenderUPN/sendMail"
        $RequestPayLoad = $MailObjectSplat | ConvertTo-Json -Depth 6

        Write-Verbose "URI for graph request: $RequestURI"
        Write-Verbose "Message Payload: `n$RequestPayLoad"

        $RequestSplat = @{
            Token    = $Token
            Resource = $RequestURI
            Method   = "POST" 
            Body     = $RequestPayLoad
            ErrorAction = "STOP"
        }
        Invoke-GraphApiRequest @RequestSplat
    }
    
}