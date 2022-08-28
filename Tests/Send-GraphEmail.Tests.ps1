BeforeAll{
    . $PSScriptRoot\..\source\public\Send-GraphEmail.ps1
    . $PSScriptRoot\..\source\private\New-GraphEmailObject.ps1
}

Describe "Send-GraphEmail"{
    BeforeAll{
        Mock Invoke-GraphApiRequest {
            return $true
        }

        $Token = @{
            token_type = "Bearer"
            expires_in = 3599
            ext_expires_in = 3599
            access_token = "W15YUUiLCJhbGciOiJSUzI1NiIsIng1dCI6Ik1yNS1BVWl"
        }
    }
    it "Returns error no recipients"{
        #No recipients
        $FunctionSplat = @{
            SenderUpn = 'Test.Sender@mail.com'
            MailSubject = 'Some test subject'
            MessageBody = 'It is the mail body'
            ErrorAction = "STOP"
            Token = $Token
        }
        {Send-GraphEmail @FunctionSplat} | Should -Throw -ExpectedMessage "There are no recipients. Function can't be invoked"
    }

    it "Returns Sender is mandatory"{
        (Get-Command Send-GraphEmail).Parameters['SenderUPN'].Attributes.Mandatory | Should -be $True
    }

    it "Returns true. Array recipients" {
        $FunctionSplat = @{
            SenderUpn = 'Test.Sender@mail.com'
            Recipients = @("email1@mail.com", "email2@mail.com")
            MailSubject = 'Some test subject'
            MessageBody = 'It is the mail body'
            ErrorAction = "STOP"
            Token = $Token
        }
        Send-GraphEmail @FunctionSplat | Should -be $True
    }

    it "Returns throw. Sender is string"{
        $FunctionSplat = @{
            SenderUpn = 'Test.Sendermail.com' #Error
            Recipients = @("email1@mail.com", "email2@mail.com")
            MailSubject = 'Some test subject'
            MessageBody = 'It is the mail body'
            ErrorAction = "STOP"
            Token = $Token
        }
        {Send-GraphEmail @FunctionSplat} | Should -Throw -ExpectedMessage "Cannot process argument transformation on parameter 'SenderUPN'*"
    }
    
    it "Returns throw. Recipients is string array"{
        $FunctionSplat = @{
            SenderUpn = 'Test.Sender@mail.com' 
            Recipients = @("email1mail.com", "email2mail.com") #Error
            MailSubject = 'Some test subject'
            MessageBody = 'It is the mail body'
            ErrorAction = "STOP"
            Token = $Token
        }
        {Send-GraphEmail @FunctionSplat} | Should -Throw -ExpectedMessage "Cannot process argument transformation on parameter 'Recipients'*"
    }
    Context "Testing attachments" {
        BeforeAll{
            $AttachmentPath1 = "$TestDrive\file1.txt"
            $AttachmentPath2 = "$TestDrive\file2.docx"
            $AttachmentPath3 = "$TestDrive\file3.pdf"
            $Attachments = @(
                $AttachmentPath1, $AttachmentPath2, $AttachmentPath3
            )
            foreach ($Attachment in $Attachments) {
                New-Item -Path $Attachment -ItemType File
            }
        }
        
        it "Returns true. Has 3 attachments"{
            $FunctionSplat = @{
                SenderUpn = 'Test.Sender@mail.com'
                Recipients = @("email1@mail.com", "email2@mail.com")
                MailSubject = 'Some test subject'
                MessageBody = 'It is the mail body'
                AttachmentPaths = $Attachments
                ErrorAction = "STOP"
                Token = $Token
            }
            Send-GraphEmail @FunctionSplat | Should -be $True
        }

        it "Returns true. Has 1 attachment"{
            $FunctionSplat = @{
                SenderUpn = 'Test.Sender@mail.com'
                Recipients = @("email1@mail.com", "email2@mail.com")
                MailSubject = 'Some test subject'
                MessageBody = 'It is the mail body'
                AttachmentPaths = $AttachmentPath1
                ErrorAction = "STOP"
                Token = $Token
            }
            Send-GraphEmail @FunctionSplat | Should -be $True
        }

        it "Returns throw. There is 1 attachment and it doesn't exist"{
            $AttachmentPath4 = "C:\nonexistingfile.txt"
            $FunctionSplat = @{
                SenderUpn = 'Test.Sender@mail.com'
                Recipients = @("email1@mail.com", "email2@mail.com")
                MailSubject = 'Some test subject'
                MessageBody = 'It is the mail body'
                AttachmentPaths = $AttachmentPath4
                ErrorAction = "STOP"
                Token = $Token
            }
            {Send-GraphEmail @FunctionSplat} |  Should -Throw -ExpectedMessage "Attachment with path $AttachmentPath4 hasn't been found*"
        }

        it "Returns throw. There are more than 1 attachments and they do not exist"{
            $AttachmentPath4 = "C:\nonexistingfile.txt"
            $AttachmentPath5 = "C:\nonexistingfile.txt2"
            $Attachments = @($AttachmentPath4,  $AttachmentPath5)
            $FunctionSplat = @{
                SenderUpn = 'Test.Sender@mail.com'
                Recipients = @("email1@mail.com", "email2@mail.com")
                MailSubject = 'Some test subject'
                MessageBody = 'It is the mail body'
                AttachmentPaths = $Attachments
                ErrorAction = "STOP"
                Token = $Token
            }
            {Send-GraphEmail @FunctionSplat} |  Should -Throw -ExpectedMessage "Attachment with path $AttachmentPath4 hasn't been found*"
        }
    }
    
}