BeforeAll{
    . $PSScriptRoot\..\source\private\New-GraphEmailObject.ps1
}

Describe "New-GraphEmailObject"{
    Context "One recipient" {
        BeforeAll{
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )
                }
            }
        }

        It "Returns expected objects"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.toRecipients[0].Keys | Should -be $ExpectedObject.message.toRecipients[0].Keys
            $MailObject.message.toRecipients.count | Should -be $ExpectedObject.message.toRecipients.count
            $MailObject.message.toRecipients[0].emailAddress.address | Should -Be $ExpectedObject.message.toRecipients[0].emailAddress.address
        }
    }

    Context "Two and more recipients"{
        BeforeAll{
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "test.address2@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "test.address3@mail.com"
                            }
                        }
                    )
                }
            }
        }

        It "Returns Recipients" {
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = @("test.address@mail.com", "test.address2@mail.com", "test.address3@mail.com")
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.toRecipients.GetType() | Should -Be $ExpectedObject.message.toRecipients.GetType()
            for($i = 0; $i -lt $ExpectedObject.message.toRecipients.count; $i++){
                $MailObject.message.toRecipients[$i].emailAddress.address | Should -Be $ExpectedObject.message.toRecipients[$i].emailAddress.address
            }
        }
    }
    
    Context "1 recipients and 1 ccObject"{
        BeforeAll {
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )
                    ccRecipients = @(
                        @{
                            emailAddress = @{
                                address = "copyRecipient.address@mail.com"
                            }
                        }
                    )
                }
            }
        }

        it "Returns СС address"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                CopyRecipients = "copyRecipient.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.ccRecipients.GetType() | Should -be $ExpectedObject.message.ccRecipients.GetType()
            $MailObject.message.ccRecipients.emailAddress.address | Should -be $ExpectedObject.message.ccRecipients.emailAddress.address
        }
    }

    Context "1 recipients and more than 1 ccObjects"{
        BeforeAll {
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )
                    ccRecipients = @(
                        @{
                            emailAddress = @{
                                address = "copyRecipient.address@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "copyRecipient2.address@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "copyRecipient3.address@mail.com"
                            }
                        }
                    )
                }
            }
        }

        it "Returns СС addresses"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                CopyRecipients = @("copyRecipient.address@mail.com", "copyRecipient2.address@mail.com", "copyRecipient3.address@mail.com")
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.ccRecipients.GetType() | Should -be $ExpectedObject.message.ccRecipients.GetType()
            for($i = 0; $i -lt $ExpectedObject.message.ccRecipients.count; $i++){
                $MailObject.message.ccRecipients[$i].emailAddress.address | Should -Be $ExpectedObject.message.ccRecipients[$i].emailAddress.address
            }
        }
    }

    Context "1 recipients and 1 bccObject"{
        BeforeAll {
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )
                    bccRecipients = @(
                        @{
                            emailAddress = @{
                                address = "hidenCopyRecipient.address@mail.com"
                            }
                        }
                    )
                }
            }
        }

        it "Returns BСС address"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                HidenRecipients = "hidenCopyRecipient.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.bccRecipients.GetType() | Should -be $ExpectedObject.message.bccRecipients.GetType()
            $MailObject.message.bccRecipients.emailAddress.address | Should -be $ExpectedObject.message.bccRecipients.emailAddress.address
        }
    }

    Context "1 recipients and more than 1 bccObjects"{
        BeforeAll {
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )
                    bccRecipients = @(
                        @{
                            emailAddress = @{
                                address = "hidenRecipient.address@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "hidenRecipient2.address@mail.com"
                            }
                        }
                        @{
                            emailAddress = @{
                                address = "hidenRecipient3.address@mail.com"
                            }
                        }
                    )
                }
            }
        }

        it "Returns BСС addresses"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                HidenRecipients = @("hidenRecipient.address@mail.com", "hidenRecipient2.address@mail.com", "hidenRecipient3.address@mail.com")
                MailSubject = "Test subject"
                MessageBody = "Test body"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.bccRecipients.GetType() | Should -be $ExpectedObject.message.bccRecipients.GetType()
            for($i = 0; $i -lt $ExpectedObject.message.bccRecipients.count; $i++){
                $MailObject.message.bccRecipients[$i].emailAddress.address | Should -Be $ExpectedObject.message.bccRecipients[$i].emailAddress.address
            }
        }
    }

    Context "One attachment exists" {
        BeforeAll{
            $AttachmentName = "fakeAttachment.txt"
            $AttachmentPath = "$TestDrive\$AttachmentName"

            New-Item -Path $AttachmentPath -ItemType File
            $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($AttachmentPath))
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )

                    attachments = @(
                        @{
                            "@odata.type" = "#microsoft.graph.fileAttachment"
                            name = $AttachmentName
                            contentType = "text/plain"
                            contentBytes = $Base64String
                        }
                    )
                }
            }
        }
        It "Returns attachment info"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
                AttachmentPaths = $AttachmentPath
                ErrorAction = "STOP"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.attachments.GetType() | Should -be $ExpectedObject.message.attachments.GetType()
            foreach($key in $MailObject.message.attachments[0].keys){
                $MailObject.message.attachments[0].$key | Should -be $ExpectedObject.message.attachments[0].$key
            }
        }
    }
    
    Context "One attachment doesn't exist" {
        BeforeAll{
            $AttachmentName = "fakeAttachment.txt"
            $AttachmentPath = "$TestDrive\$AttachmentName"
            
        }
        It "Throws because of non existing attachment"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
                AttachmentPaths = $AttachmentPath
                ErrorAction = "STOP"
            }

            {New-GraphEmailObject @MailSplat} | Should -throw -ExpectedMessage "Provided attachment path is invalid"
        }
    }

    Context "Three attachments exist" {
        BeforeAll{
            $Base64Strings = @()
            $AttachmentPaths = @()
            $AttachmentNames = @("fakeAttachment.txt","fakeAttachment2.txt", "fakeAttachment3.txt")
            foreach ($Attachment in $AttachmentNames){
                $AttachmentPath = "$TestDrive\$Attachment"
                $AttachmentPaths += $AttachmentPath
                New-Item -Path $AttachmentPath -ItemType File
                $Base64Strings += $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($AttachmentPath))
            }
            
            $ExpectedObject = [ordered]@{
                message = @{
                    subject = "Test subject"

                    body = @{
                        contentType = "Text"
                        content = "Test body"
                    }

                    toRecipients = @(
                        @{
                            emailAddress = @{
                                address = "test.address@mail.com"
                            }
                        }
                    )

                    attachments = @(
                        @{
                            "@odata.type" = "#microsoft.graph.fileAttachment"
                            name = $AttachmentNames[0]
                            contentType = "text/plain"
                            contentBytes = $Base64String[0]
                        }
                        @{
                            "@odata.type" = "#microsoft.graph.fileAttachment"
                            name = $AttachmentNames[1]
                            contentType = "text/plain"
                            contentBytes = $Base64String[1]
                        }
                        @{
                            "@odata.type" = "#microsoft.graph.fileAttachment"
                            name = $AttachmentNames[2]
                            contentType = "text/plain"
                            contentBytes = $Base64String[2]
                        }
                    )
                }
            }
        }
        It "Returns 3 attachments info"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
                AttachmentPaths = $AttachmentPaths
                ErrorAction = "STOP"
            }

            $MailObject = New-GraphEmailObject @MailSplat 
            $MailObject.message.attachments.GetType() | Should -be $ExpectedObject.message.attachments.GetType()
            
            for($i = 0; $i -lt $MailObject.message.attachments.Count; $i++){
                foreach($key in $MailObject.message.attachments[$i]){
                    $MailObject.message.attachments[$i].$key | Should -be $ExpectedObject.message.attachments[$i].$key
                }
            }
        }
    }

    Context "Three attachments, and one doesn't exist" {
        BeforeAll{
            $Base64Strings = @()
            $AttachmentPaths = @()
            $AttachmentNames = @("fakeAttachment.txt","fakeAttachment2.txt")
            foreach ($Attachment in $AttachmentNames){
                $AttachmentPath = "$TestDrive\$Attachment"
                $AttachmentPaths += $AttachmentPath
                New-Item -Path $AttachmentPath -ItemType File
                $Base64Strings += $Base64String = [Convert]::ToBase64String([IO.File]::ReadAllBytes($AttachmentPath))
            }
            $AttachmentPaths += "$TestDrive\NonExistingFile.txt"
        }
        It "Throws because of non existing attachment"{
            $MailSplat = @{
                SenderUpn = "Sender@mail.com"
                Recipients = "test.address@mail.com"
                MailSubject = "Test subject"
                MessageBody = "Test body"
                AttachmentPaths = $AttachmentPaths
                ErrorAction = "STOP"
            }

            {New-GraphEmailObject @MailSplat } | Should -Throw -ExpectedMessage "Attachment with path $("$TestDrive\NonExistingFile.txt") hasn't been found! Please check the path."
            
        }
    }
}