# ----------------------------------------------------------------------------- 
# Script: Get-USBStor.ps1*
# Author: Paul Brown
# Date: 02/08/2017 10:00:10 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-USBStor {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-USBStor.ps1* 
	    	AUTHOR: admin 
	    	LASTEDIT: 02/08/2017 10:00:10 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
    [OutputType([psobject])]

	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		#[array]$<VARIABLE>
	)

    begin {}

    process {}
	
    end {}

}