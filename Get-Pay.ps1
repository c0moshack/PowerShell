# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 03/28/2016 07:58:36 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-Pay {
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
	    	LASTEDIT: 03/28/2016 07:58:36 
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
		[array]$Location
	)
	$url = "https://www.opm.gov/policy-data-oversight/pay-leave/salaries-wages/salary-tables/xml/2016/GS.xml"
	$basepay = Invoke-WebRequest $url
	[xml]$basepay = $basepay.Content -replace 'ï»¿',""
	
	$basepaytable = @()
	Foreach ($item in $basepay.PayTable.Grades.Grade) {
		$grade = @{}
		$steps = $item.Steps
		$grade.Value = $($item.Value)
		$grade.	
	}
	#return $basepay
} 