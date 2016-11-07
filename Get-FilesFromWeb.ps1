$url = "http://meritbadge.org/wiki/index.php/Merit_Badge_Worksheets"
$Path = "C:\Users\paul.j.brown\Desktop\BoyScoutWorksheets"
$results = Invoke-WebRequest $url
$links = $results.Links
$urls = @()
Foreach ($item in $links) {
	If ($($item.href -match 'http\:.+\.pdf')) {
		$urls += $Matches[0]
	}
}
	
Foreach ($u in $urls ) {
	Write-Host "Downloading: $u" -NoNewline
	$filename = $(Split-Path $u -Leaf)
	$location = "$Path\$filename"
	If (-not $(Test-Path $location)) {
		Try {
		Invoke-WebRequest $u -OutFile $location -ErrorAction SilentlyContinue | Out-Null
		} Catch {
		}
		If (Test-Path $location) {
			Write-Host " Success" -ForegroundColor Green
		} Else {
			Write-Host " Failed" -ForegroundColor Red
		}
	} Else {
		Write-Host " Exists" -ForegroundColor Yellow
	}
}