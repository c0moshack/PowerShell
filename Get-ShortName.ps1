# ----------------------------------------------------------------------------- 
# Script: Get-ShortName
# Author: Paul Brown
# Date: 03/31/2016 09:07:23 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-ShortName {
	<# 
	    .Synopsis 
	   		Retrieves the short name for a path or file
	   	.Example 
	    	Get-ShortName -Path "C:\Windows"
	    .Notes 
	    	NAME: Get-ShortName
	    	AUTHOR: Paul Brown
	    	LASTEDIT: 03/31/2016 09:07:23 
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
		[array]$Path
	)
	
	$SFSO = New-Object -ComObject Scripting.FileSystemObject
	$short = $SFSO.GetFile(($Path)).ShortPath
	
	return $short
}