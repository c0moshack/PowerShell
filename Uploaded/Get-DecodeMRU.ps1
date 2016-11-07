# ----------------------------------------------------------------------------- 
# Script: Get-DecodeMRU.ps1
# Author: Paul Brown
# Date: 12/17/2015 13:28:15 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------
 Function Get-DecodeMRU {
	<# 
   	.Synopsis 
    	Decode MRU entries for analysis
	.Description
		Iterate through each child item in an MRU key and decode each binary 
		value. The script outputs the path, binary value and decoded value. The 
		path can be passed as "[Registry]::HKEY_Local_Machine\" or "HKLM:"
   	.Example 
    	Get-DecodeMRU -MRU "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU"
   	.Parameter  
    	MRU - The parent key to the MRUs to be decoded. For some keys the * can 
		be used to enumerate all keys.
   	.Notes 
    	NAME: Get-DecodeMRU.ps1 
    	AUTHOR: Paul Brown
    	LASTEDIT: 12/17/2015 13:25:52 
    	KEYWORDS: 
   	.Link 
    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#> 
	Param(
	[Parameter(
		 Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[string]$MRU
	)
	Try {
		$items = Get-Item -Path $MRU | select -ExpandProperty Property        
		$data = @()
		foreach ($item in $items) {           
				$name = $item          
				$valuekind = $($(Get-Item $MRU).GetValueKind("$name"))
			 	$bin = (Get-ItemProperty -Path $MRU -Name $name -ErrorAction SilentlyContinue)."$name"            
			 	If ($valuekind -eq "BINARY") {
					$decoded = @()
					$asciirange = 32..126
					foreach ($dec in $bin) {
						If ($asciirange -like $dec) {
							$decoded += [char]$dec
							}
				 	}            
			    }
			 	$data += New-Object -TypeName psobject -Property @{'Path'="$MRU\$name";'BinaryValue'=$bin;'DecodedValue'=$($decoded -join "");'Type'=$valuekind}            
			             
			}
	} Catch {
	}
	return $data
}
