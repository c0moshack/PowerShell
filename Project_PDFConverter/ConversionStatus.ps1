While ($true) {
    $users = Get-ChildItem "\\ng\ngwi\public\PDF_Conversion"
    #$users = Get-ChildItem "C:\PowerShellScripts\PDF_Conversion_Test"
    Foreach ($user in $users) {
        $files = Get-ChildItem $user.FullName -Include @("*.xfd","*.xfdl") -Recurse
        $results = @()
        Foreach ($file in $files) {
            $props = @{}
            $props.XFDL = $(Test-Path $file.FullName)
            $props.PDF =  $(Test-Path $("$($file.DirectoryName)\$($file.BaseName).pdf"))
			$props.TXT = $(Test-Path $("$($file.DirectoryName)\$($file.BaseName).txt"))
            $object = New-Object -TypeName psobject -Property $props
        
            $results += $object               
        }
        If ($($results.PDF -contains $false) -and $($results.txt -notcontains $true)) {
            Write-Host "[Incomplete]::Conversion not complete for $user@mail.mil" -ForegroundColor Yellow
        } ElseIf ($results.XFDL -eq $null) {
            Write-Host "[Empty Directory]::There are no results for $user@mail.mil"        
        } Else {
            $mailprops = @{
                SmtpServer = "NGWIC7-DISC4-01"
                To = "$user@mail.mil"
                From = "NGWI_PDF_Converter@mail.mil"
                Subject = "XFDL to PDF Conversion Complete"
                Body = "
Your documents have been converted.

Some documents may contain PII please retrieve them as soon as possible and delete your folder.

`n$(Get-ChildItem $user.FullName -Recurse | %{"$($_.FullName) `n"})


Thank you."
            }
            Send-MailMessage @mailprops
            Write-Host "[Sent]::Message sent to $user@mail.mil"
        }
    }
    sleep 3600
}
