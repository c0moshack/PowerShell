$url = "http://hypem.com/download/1/"
$webresults = Invoke-WebRequest $url

If ($($webresults -match "<h1>Index of.+<\/h1>") -and $($webresults -match "Name") -and $($webresults -match "Last modified")) {
    $true
}

$webresults -match "<h1>Index\sof\s(.+)<\/h1>"

$startdirectory = $matches[1]

Foreach ($link in $webresults.Links) {
    $linkprop = @{}
    
	$linkprop.Name = "$($link.innerText.TrimEnd('/'))"
    $linkprop.URL = "$url$($link.href)"
    
	$linkobject = New-Object -TypeName psobject -Property $linkprop
    $linkobject
}

