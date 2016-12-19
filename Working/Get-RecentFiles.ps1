# ----------------------------------------------------------------------------- 
# Script: Get-RecentFiles.ps1
# Author: Paul Brown
# Date: 03/29/2016 10:33:32 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-RecentFiles {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-RecentFiles.ps1 
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
        [ValidateSet("ClassesRoot","CurrentConfig","CurrentUser","DynData","LocalMachine","PerformanceData","Users")]
		[string] $Hive = "CurrentUser",
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string] $Path = "Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU\*",	

		[Parameter(
		Mandatory=$false,
		Position=3)]
		[string] $Extension
	)
    If ($Extension) {
        $Path.Replace("*",$Extension)
    }

	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
	$subkey = $reg.OpenSubKey($Path)
    $values = $subkey.GetValueNames() | Where-Object {$_ -ne "MRUListEx"}

    Try {      
		$data = @()
		foreach ($value in $values) {           
				$valuekind = $subkey.GetValueKind($value)
			 	$bin = $subkey.GetValue($value)           
			 	If ($valuekind -eq "BINARY") {
					$decoded = @()
					$asciirange = 32..126
					foreach ($dec in $bin) {
						If ($asciirange -like $dec) {
							$decoded += [char]$dec
							}
				 	}            
			    }
			 	$data += New-Object -TypeName psobject -Property @{'Name'="$value";'Value'=$($decoded -join "")}            
			             
			}
	} Catch {
	}

    return $data
}

Get-RecentFiles | fl