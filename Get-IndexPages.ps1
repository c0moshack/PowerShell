# ----------------------------------------------------------------------------- 
# Script: Get-IndexPages.ps1
# Author: Paul Brown
# Date: 11/07/2016 14:41:24 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-IndexPages {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-IndexPages.ps1
	    	AUTHOR: admin 
	    	LASTEDIT: 11/07/2016 14:41:24 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[stromg]$url = "http://hypem.com/download/1/"
	)
	
    
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

}