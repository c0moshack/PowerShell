﻿# ----------------------------------------------------------------------------- 
# Script: Set-RegistryKey
# Author: Paul Brown
# Date: 03/29/2016 10:33:32 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Set-RegistryKey {
	<# 
	    .Synopsis 
	   		Edits the value of a given registry key 
	   	.Example 
	    	Set-RegistryKey -Hive "LocalMachine" -Path "SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Value "1"
        .Example
            Set-RegistryKey -ComputerName "<computername>" -Hive "LocalMachine" -Path "SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "AutoShareServer" -Value "1"
	    .Parameter  
	    	Hive - The hive where the registry key is located
        .Parameter
            Path - Path to the registry item not including the item name
        .Parameter
            Name - Name of the item that you want to edit the value for
        .Parameter
            Value - Value of the registry key
	    .Notes 
	    	NAME: Untitled 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 03/29/2016 10:33:32 
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
		[array]$ComputerName = $Env:COMPUTERNAME,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[string] $Hive,
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string] $Path,
		
		[Parameter(
		Mandatory=$false,
		Position=3)]
		[string] $Name,
		
		[Parameter(
		Mandatory=$false,
		Position=4)]
		[string] $Value,
		
		[switch]$Set
	)

	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
	$subkey = $reg.OpenSubKey($Path, $true)
	$keyvalue = $subkey.GetValue($Name)
	
	If ($Set) {
		$subkey.SetValue($Name, $Value)
		$keyvalue = $subkey.GetValue($Name)
	}
	
	
	return "$subkey\$Name $keyvalue"
}
