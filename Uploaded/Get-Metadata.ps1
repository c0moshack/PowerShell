# ----------------------------------------------------------------------------- 
# Script: Get-Metadata.ps1
# Author: Paul Brown
# Date: 12/14/2015 10:23:12 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-Metadata {
 	<# 
   	.Synopsis 
    	Return the metadata for a given file as a powershell object. Values are 
		returned as strings unless they can be interpreted by the Get-Date 
		Cmdlet, then they are converted to system.datetime. All values are 
		checked for Right-to-Left and Left-to-Right characters and replaced.
   	.Example 
    	Get-Metadata -File <path to file>
   	.Parameter  
    	File - The full path to the file 
   	.Notes 
    	NAME: Get-Metadata.ps1 
    	AUTHOR: Paul Brown
    	LASTEDIT: 12/14/2015 10:23:25 
    	KEYWORDS: 
	#Requires -Version 2.0 
	#> 
	[cmdletbinding()]
	Param(
	[Parameter(
		 Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[array]$File
	)	
	$path = Split-Path $File
	$filename = Split-Path $File -Leaf
	$object = New-Object -ComObject Shell.Application
	$space = $object.namespace($path)
	$fileitem = $space.ParseName($filename)

	$metadata = New-Object -TypeName PSObject
	
	For ($a=0; $a -le 266; $a++) {
		$key =$($space.GetDetailsOf($space.Items, $a))
		$value = $($space.GetDetailsOf($fileitem, $a)) 
		# Replace Lef-to-Right and Right-to-Left characters
		$value = $value -replace [char][Int16]'8206', "" 
		$value = $value -replace [char][Int16]'8207', ""
		Try {
			$value = Get-Date $value
		} Catch {
		}
		$hash += @{$key = $value}
		Try {
		$metadata | Add-Member $hash -ErrorAction SilentlyContinue
		} Catch {
		}
		$hash.Clear()
	}
	
	return $metadata
}