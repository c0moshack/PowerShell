# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 06/23/2016 10:39:05 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-SCCMClientPreCheck {
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
	    	LASTEDIT: 06/23/2016 10:39:05 
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
		[array]$Clients
	)
	
	$data = @()
	$count = $clients.Count
	$c = 1
	Foreach ($client in $Clients) {
		Write-Host "Processing $client [$c/$count]"
		If ($(Test-Connection $($client) -Count 1 -ErrorAction SilentlyContinue)) {
			$props = @{}
			$props.Name = $client
			$props.Active = $(Test-Connection $($client) -Count 1 -ErrorAction SilentlyContinue).StatusCode -like '0'
			$props.DNS = $(Start-WinProcess -Executable "nslookup" -Arguments $($client)).Output -like "*$client.ng.ds.army.mil*"
			$props.AdminShare = Test-Path "`\`\$client`\admin`$" -ErrorAction SilentlyContinue
			$props.LocalAdmin = $(Get-LocalGroup -Computername  $client -Group  Administrators).Members -like "*NGWI SCCM Admins*"
			#$props.OperatingSystem = $(Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue).Caption
			#$props.Manufacturer = $(Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue).Manufacturer
			#$props.Model = $(Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue).Model
			
			$data += $(New-Object psobject -Property $props)
		} Else {
			$props = @{}
			$props.Name = $client
			$props.Active = "NO RESPONSE"
			$props.DNS = ""
			$props.AdminShare = ""
			$props.LocalAdmin = ""
			$props.OperatingSystem = ""
			$props.Manufacturer = ""
			$props.Model = ""
			
			$data += $(New-Object psobject -Property $props)
		}
		
		$c += 1
	}

	return $data
} 

#$clients = Import-Csv "D:\SCCM Reports\Non_Client_20160621.csv"
#Get-SCCMClientPreCheck $($clients.Name) | Out-GridView