# ----------------------------------------------------------------------------- 
# Script: Get-StorageReport.ps1
# Author: Paul Brown
# Date: 04/03/2016 07:42:57 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-StorageReport {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-StorageReport.ps1 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/03/2016 07:42:56 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$mandatory,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$Path
	)
	
	$appExcel = New-Object -ComObject Excel.Application
	$appExcel.Visible = $true
	$workbook = $appExcel.Workbooks.Add()
	# Populate Sheet one with subfolders one level down
	$sheet1 = $workbook.Sheets.Item("Sheet1")
	$sheet1.Name = "Folders"
	$directories = $(Get-DirectorySize -Path $Path -Scope Directory)
	$fields = $($directories | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}).Name
	Foreach ($field in $fields) {
		$sheet1.Cells.Item(1, $($($fields.IndexOf($field))+1)) = $field
	}
	Foreach ($i in $directories) {
		$sheet1.Cells.Item($($($directories.IndexOf($i))+2), 1) = $($i.Name)
		$sheet1.Cells.Item($($($directories.IndexOf($i))+2), 2) = $($i.SizeGB)
		$sheet1.Cells.Item($($($directories.IndexOf($i))+2), 3) = $($i.SizeMB)
		$sheet1.Cells.Item($($($directories.IndexOf($i))+2), 4) = $($i.SubFolders)
	}
	# Populate Sheet two with all underlying subfolders
	$workbook.Sheets.Add()
	$sheet2 = $workbook.Sheets.Item("Sheet2")
	$sheet2.Name = "SubFolders"
	$directories = $(Get-DirectorySize -Path $Path -Scope SubFolders)
	$fields = $($directories | Get-Member | Where-Object {$_.MemberType -eq "NoteProperty"}).Name
	Foreach ($field in $fields) {
		$sheet2.Cells.Item(1, $($($fields.IndexOf($field))+1)) = $field
	}
	Foreach ($i in $directories) {
		$sheet2.Cells.Item($($($directories.IndexOf($i))+2), 1) = $($i.Name)
		$sheet2.Cells.Item($($($directories.IndexOf($i))+2), 2) = $($i.SizeGB)
		$sheet2.Cells.Item($($($directories.IndexOf($i))+2), 3) = $($i.SizeMB)
		$sheet2.Cells.Item($($($directories.IndexOf($i))+2), 4) = $($i.SubFolders)
	}
} 
