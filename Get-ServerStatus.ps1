# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 03/24/2016 08:48:22 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-ServerStatus {
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
	    	LASTEDIT: 03/24/2016 08:48:22 
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
		[array]$ComputerName,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[string]$ExcelFile = "D:\_UNSORTED\Master Server List.xlsx",
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Worksheet = "Current Server List",
		
		[switch]$ListWorkSheets
		
	)
	If ($ExcelFile) {
		$excel = New-Object -ComObject 'Excel.Application'
		$excelDoc = $excel.Workbooks.Open($ExcelFile)
			
		If ($ListWorkSheets) {
			$sheets = $($excelDoc.Sheets).Name
			return $sheets
		}
		
		If ($Worksheet) {
			$sheet = $excelDoc.Sheets.Item($Worksheet)
			$columns = $sheet.Columns
			$rows = $sheet.Rows
			$header = $rows.Item(1).Formula | Where-Object {$_ -ne ""}
		}
		
	}	
} 
Get-ServerStatus