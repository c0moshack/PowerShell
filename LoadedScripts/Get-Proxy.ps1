# ----------------------------------------------------------------------------- 
# Script: Get-Proxy
# Author: Paul Brown
# Date: 03/29/2016 07:10:52 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-Proxy {
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
	    	LASTEDIT: 03/29/2016 07:10:52 
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
		[array]$Proxy,
		
		[switch]$Toggle
	)
	
	#Pre-difined proxies
	$proxies = "55.94.254.192:8080","55.94.254.200:8080"
	
	$proxyenable = $(Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable).ProxyEnable

	

	If ($proxyenable -eq 0) {
		$proxystatus = "Off"
		If ($Toggle) {
			Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 1
		}
	} ElseIf ($proxyenable -eq 1) {
		$proxystatus = "On"
		If ($Toggle) {
			Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value 0
		}

	}
	
	return Write-Output "Proxy $proxystatus"
} 