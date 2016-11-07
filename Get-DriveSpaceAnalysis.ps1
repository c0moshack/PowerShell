# ----------------------------------------------------------------------------- 
# Script: Get-DirectorySize
# Author: Paul Brown
# Date: 03/31/2016 09:07:23 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-Get-DirectorySize {
	<# 
	    .Synopsis 
	   		Retrieves the size of the given directory or directories
	   	.Example 
	    	Get-DirectorySize -Path "C:\Windows" -Scope "Directory"
		.Example 
	    	Get-DirectorySize -Path "C:\Windows" -Scope "SubFolders"
		.Example 
	    	Get-DirectorySize -Path "C:\Windows" -Scope "Subtree"
	    .Notes 
	    	NAME: Get-DirectorySize
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
		[array]$Path,
		
		[Parameter(
		Mandatory=$true)]
		[ValidateSet("Directory","SubFolders","SubTree")]
		[string]$Scope
	)
	
	switch ($Scope) {
		"Directory" {$Folders = Get-Item $Path}
		"SubFolders" {$Folders = Get-ChildItem $Path -Directory}
		"SubTree" {$Folders = Get-ChildItem -Recurse $Path -Directory}
	}
	$foldercollection = @()
	Foreach ($folder in $Folders) {
		$prop = @{}
		$size = $(Get-ChildItem $($folder.FullName) -recurse | Measure-Object -property length -sum -ErrorAction SilentlyContinue) 
		$prop.Name = $($folder.FullName)
		$prop.SizeMB = "{0:N2}" -f ($size.sum / 1MB)
		$prop.SizeGB = "{0:N2}" -f ($size.sum / 1GB)
		$prop.SubFolders = $(Get-ChildItem $($folder.FullName)  -Recurse -Directory).count
		$object = New-Object -TypeName PsObject -Property $prop
		$foldercollection += $object
	}
	
	return $foldercollection
} 