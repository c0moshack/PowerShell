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
