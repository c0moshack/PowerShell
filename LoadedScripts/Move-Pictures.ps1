Function Move-Pictures {
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
	
	#$file = Get-Item "C:\Users\paul.j.brown\Pictures\IMG_8466.JPG"
	$dt = $(Get-Metadata $file).'Date Taken'

	$basedir = "C:\Users\paul.j.brown\Pictures\"
	$location ="$($dt.Year)\$($($dt.Month).ToString(`"00`"))\$($dt.Day)\"
	$Destination = $basedir + $location

	if(!(Test-Path $Destination))
	{
	    New-Item -Path $Destination -ItemType Directory -Force | Out-Null
	}

	$newdest = "$Destination$($file.name)"

	Move-Item $file $newdest -Force
}