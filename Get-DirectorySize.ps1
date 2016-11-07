# ----------------------------------------------------------------------------- 
# Script: Get-DirectorySize
# Author: Paul Brown
# Date: 03/31/2016 09:07:23 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-CompleteFileList {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$Path,
		[switch]$Recurse,
		[switch]$Directory
	)
	If ($Recurse) {$switches = @{
		Path = $Path
		Recurse = $true
	}}
	If ($Directory) {$switches = @{
		Path = $Path
		Directory = $true
	}}	
	If ($Recurse -and $Directory) {$switches = @{
		Path = $Path
		Directory = $true
		Recurse = $true
	}}
	
	$goodFiles = @()
	Foreach ($files in Get-ChildItem @switches -ErrorVariable +badFile) {
		$goodFiles += $files.FullName
		If ($badFile) {
			$goodFiles += $badFile.TargetObject
		}
	}
	return $goodFiles
}
	
Function Get-DirectorySize {
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
		[string]$Scope,
		
		[switch]$ShortNames
	)
	
	# Process error where the file is too long
	
	Try {
	switch ($Scope) {
		"Directory" {$Folders = Get-Item $Path}
		"SubFolders" {$Folders = Get-CompleteFileList -Path $Path -Directory}
		"SubTree" {$Folders = Get-CompleteFileList -Path $Path -Recurse -Directory}
	}
	
	$foldercollection = @()
	Foreach ($folder in $Folders) {
		$prop = @{}
		Write-Verbose "Workig on $($folder) "
		$sizes = Get-CompleteFileList $($folder) -Recurse
		$processed = @()
		ForEach ($size in $sizes) {
			
			If ($ShortNames) {
				If ($(Get-Item $size).PSIsContainer -eq $false) {
					$SFSO = New-Object -ComObject Scripting.FileSystemObject
					$item = Get-Item $($SFSO.GetFile($($size)).ShortPath)
				} Else {
					Write-Verbose "Not adding directory $size"
				}
			} Else {
				If ($(Get-Item $size).PSIsContainer -eq $false) {
					$item = Get-Item $($size)
				} Else {
					Write-Verbose "Not adding directory $size"
				}
			}
			
			If ($processed -notcontains $($item.FullName)) {
				Write-Verbose "Adding file $item $($item.Length / 1KB) KB"
				If ($item.Length) {
					$temp += $item.Length
					$processed += $($item.FullName)
				}
			}
		}
		$total = $(Measure-Object -InputObject $temp -sum )
		$prop.Name = $($folder)
		$prop.SizeMB = [double]$("{0:N2}" -f ($total.sum / 1MB))
		$prop.SizeGB = [double]$("{0:N2}" -f ($total.sum / 1GB))
		$prop.SubFolders = $(Get-CompleteFileList $($folder) -Recurse -Directory).count
		$object = New-Object -TypeName PsObject -Property $prop
		If ($($foldercollection.Name) -ne $($prop.Name)) {
			$foldercollection += $object
		}
		
		$total = $null
		$temp = $null
		
		
	}
	} Catch {
			$errors = $_.Exception.Message
			Write-Error $errors	
	}
	return $foldercollection
} 