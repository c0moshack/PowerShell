# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 06/30/2016 08:53:54 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-SoftwareSearch {
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
	    	LASTEDIT: 06/30/2016 08:53:54 
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
		[array]$ComputerName,
		
		[Parameter(
		Mandatory=$true,
		Position=1)]
		[string]$SearchTerm		
	)
	
	$items = @()
	
	ForEach ($name in $ComputerName) {
			
		$online = $(Test-Connection $name -Count 1 -BufferSize 8 -Quiet)
		If ($online -eq $true) {
			Try { 
				$products = Get-WmiObject -Class Win32_Product -ComputerName $name | Select Name,Version
				If ($products -match $SearchTerm) { 
					$present = $products -match $SearchTerm
				} Else { 
					$present = "Not Present" 
				} 
			} Catch { 
				Write-Error "$name is unreachable" 
			}
		} Else {
			$present = "NA"
		}
		
		$computer = @{}
		$computer.Name = $name
		$computer.Online = $online
		$computer.Present = $present
		$computers = New-Object -TypeName PsObject -Property $computer
		$items += $computers
		  
	}
	
	return $items

} 