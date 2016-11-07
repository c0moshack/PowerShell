$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = '\\ng\ngwi\Public\PDF_Conversion'
$watcher.IncludeSubdirectories = $true
$watcher.EnableRaisingEvents = $true
$watcher.Filter = "*.xfd*"


Register-ObjectEvent $watcher "Created" -SourceIdentifier FileCreated -Verbose -Action {
    $Item = Get-Item $Event.SourceEventArgs.FullPath
	Write-Host "[$($Event.SourceEventArgs.ChangeType)]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::Processing directory $($Item.FullName)" -ForegroundColor Green
    If ($($Item.DirectoryName)) {
        
        Export-PDF -Path $($Item.DirectoryName) -Extension @("*.xfdl","*.xfd") -Recurse -Verbose
        
        #Check files and notify user
        If ($($Item.DirectoryName) -ne '\\ng\ngwi\Public\PDF_Conversion') {
            $user = $($($Item.DirectoryName) -split "\\")[6]
            $files = Get-ChildItem "\\ng\ngwi\Public\PDF_Conversion\$user" -Include @("*.xfd","*.xfdl") -Recurse
            Foreach ($file in $files) {
                $check = $false
                If ($(Test-Path $("$($file.DirectoryName)\$($file.BaseName).pdf"))) {
                    $check = $true       
                } ElseIf ($(Test-Path $("$($file.DirectoryName)\$($file.BaseName).txt"))) {
                    $check = $true
                }                              
            }
            If ($check = $true) {
                $documents = $(Get-ChildItem "\\ng\ngwi\Public\PDF_Conversion\$user" -Recurse | %{"$($_.FullName) `n"})
                $mailprops = @{
                    SmtpServer = "NGWIC7-DISC4-01"
                    To = "$user@mail.mil"
                    From = "NGWI_PDF_Converter@mail.mil"
                    Subject = "XFDL to PDF Conversion Complete"
                    Body = "
                    Your documents have been converted. 
                    Please retrieve them as soon as possible and delete your folder as some documents may contain PII.

                    Documents in folder:

                    $documents

                    Thank you."
                }
                Send-MailMessage @mailprops
                Write-Host "[Sent]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::Message sent to $user"
            }
        }
        #End Check fiels and notify user
    }
    #Export-PDF -Path $($Item.DirectoryName) -Extension @("*.xfdl","*.xfd") -Recurse -Verbose
    Write-Host "[Completed]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::Processing for $($Item.DirectoryName)" -ForegroundColor Green
}

#Register-ObjectEvent $watcher "Changed" -SourceIdentifier FileChanged -Verbose -Action {
#    $Item = Get-Item $Event.SourceEventArgs.FullPath
#	Write-Host "[$($Event.SourceEventArgs.ChangeType)]::Processing directory $($Item.DirectoryName)"
#    If ($($Item.DirectoryName)) {
#        Export-PDF -Path $($Item.DirectoryName) -Extension @("*.xfdl","*.xfd") -Recurse -Verbose
#    }
#    Write-Host "Processing for $($Item.DirectoryName) complete."
#}
