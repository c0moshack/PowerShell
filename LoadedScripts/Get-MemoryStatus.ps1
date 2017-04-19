# ----------------------------------------------------------------------------- 
# Script: Get-MemoryStatus.ps1
# Author: Paul Brown
# Date: 04/06/2016 10:51:43 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-MemoryStatus {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-MemoryStatus.ps1 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/06/2016 10:51:43 
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
		[string]$ComputerName
	)
	
	$os = Get-WmiObject win32_OperatingSystem -ComputerName $ComputerName 

	"Total Physical Memory: {0:N2} MB" -f ($os.totalvisiblememorysize / 1KB)
	"Free Physical Memory : {0:N2} MB" -f ($os.freephysicalmemory / 1KB)
	"Total Virtual Memory : {0:N2} MB" -f ($os.totalvirtualmemorysize / 1KB)
	"Free Virtual Memory  : {0:N2} MB" -f ($os.freevirtualmemory / 1KB)


} 