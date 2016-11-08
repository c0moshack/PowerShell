# ----------------------------------------------------------------------------- 
# Script: Untitled2.ps1
# Author: Paul Brown
# Date: 11/07/2016 14:48:10 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-GoogleResults {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled2.ps1 
	    	AUTHOR: admin 
	    	LASTEDIT: 11/07/2016 14:48:10 
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
		ValueFromPipeline=$true)]
		[string]$Keywords,

        [Parameter(
		Mandatory=$false)]
		[string]$allinanchor,

        [Parameter(
		Mandatory=$false)]
		[string]$allintext,
        
        [Parameter(
		Mandatory=$false)]
		[string]$allintitle,

        [Parameter(
		Mandatory=$false)]
		[string]$allinurl,

        [Parameter(
		Mandatory=$false)]
		[string]$cache,

        [Parameter(
		Mandatory=$false)]
		[string]$define,

        [Parameter(
		Mandatory=$false)]
		[string]$filetype,

        [Parameter(
		Mandatory=$false)]
		[string]$id,

        [Parameter(
		Mandatory=$false)]
		[string]$inanchor,

        [Parameter(
		Mandatory=$false)]
		[string]$info,

        [Parameter(
		Mandatory=$false)]
		[string]$intext,

        [Parameter(
		Mandatory=$false)]
		[string]$intitle,

        [Parameter(
		Mandatory=$false)]
		[string]$inurl,

        [Parameter(
		Mandatory=$false)]
		[string]$link,

        [Parameter(
		Mandatory=$false)]
		[string]$related,

        [Parameter(
		Mandatory=$false)]
		[string]$site,

        [Parameter(
		Mandatory=$false)]
		[string]$author,

        [Parameter(
		Mandatory=$false)]
		[string]$group,

        [Parameter(
		Mandatory=$false)]
		[string]$insubject,

        [Parameter(
		Mandatory=$false)]
		[string]$ext,

        [Parameter(
		Mandatory=$false)]
		[string]$location,

        [Parameter(
		Mandatory=$false)]
		[string]$source
	)
    $searchstring = ""

    Foreach ($parameter in $MyInvocation.BoundParameters.Keys) {
        If ($parameter -ne "" -or $parameter -ne $null -and $parameter -ne "Keywords") {
            $searchstring += "+$($parameter):$($MyInvocation.BoundParameters.Item($parameter))"
        }
    }
    
    $words = $Keywords.Split(" ")
    Foreach ($word in $words) {
        $searchstring += "+$($word)"
    }

    $gsearch = "https://www.google.com/search?q="
	$query = $gsearch + $($searchstring.Remove(0,1))
    $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Firefox
    $webresults = Invoke-WebRequest $query -UserAgent $userAgent
    $webresults | Out-File "C:\Users\admin\Desktop\webresults.html"

    $searchresults = @()

    Foreach ($result in $webresults.Links) {
        
        $obj = @{}

        If ($result.href -like "http*") {
            $obj.Name = $result.outerText
            $obj.URL = $result.href    

            $tobj = New-Object -TypeName "psObject" -Property $obj

            $searchresults += $tobj
        }
    }

    return $searchresults

}