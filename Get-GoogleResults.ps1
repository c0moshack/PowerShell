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
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$Keywords,

        [Parameter(
		Mandatory=$false)]
		[string]$allinanchor,

        [Parameter(
		Mandatory=$false)]
		[string]$allintext
	)

    #Web Search	allinanchor:, allintext:, allintitle:, allinurl:, cache:, define:, filetype:, id:, inanchor:, info:, intext:, intitle:, inurl:, link:, related:, site:
    #Image Search	allintitle:, allinurl:, filetype:, inurl:, intitle:, site:
    #Groups	allintext:, allintitle:, author:, group:, insubject:, intext:, intitle:
    #Directory	allintext:, allintitle:, allinurl:, ext:, filetype:, intext:, intitle:, inurl:
    #ews	allintext:, allintitle:, allinurl:, intext:, intitle:, inurl:, location:, source:
    #roduct Search	allintext:, allintitle:

    $gsearch = "https://www.google.com/?q=intitle%3Aindex.of"
	

}