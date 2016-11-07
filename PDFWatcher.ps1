. C:\P
$FileSystemWatcherParams = @{

	Path = '\\ng\ngwi\Home\JFHQ\paul.j.brown'
	EventName = 'Created'
	Recurse =  $True
	NotifyFilter =  'FileName'
	Verbose =  $True
	Action=  {
		$Item  = Get-Item $Event.SourceEventArgs.FullPath
		Write-Host "Found $($Item.FullName)"
		Write-Host "Processing directory $($Item.DirectoryName)"
		Export-PDF -Path $($Item.DirectoryName) -Extension "xfdl"
	}
}

Start-FileSystemWatcher  @FileSystemWatcherParams