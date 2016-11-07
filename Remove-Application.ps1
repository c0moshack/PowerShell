# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 04/21/2016 14:25:03 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Remove-Application {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/21/2016 14:25:03 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$ComputerName
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[array]$UninstallString
	)
	
	
} 