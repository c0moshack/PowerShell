Function Get-RegistryData {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$ComputerName,
		
		[Parameter(
		Mandatory=$true,
		Position=1,
		ValueFromPipeline=$false,
		ValueFromPipelineByPropertyName=$false)]
		[string]$Hive,
		
		[Parameter(
		Mandatory=$true,
		Position=2,
		ValueFromPipeline=$false,
		ValueFromPipelineByPropertyName=$false)]
		[string]$Path,
		
		[Parameter(
		Mandatory=$true,
		Position=3,
		ValueFromPipeline=$false,
		ValueFromPipelineByPropertyName=$false)]
		[string]$Key
	)
	
	<# 
	.Synopsis 
		Get the value of local or network computer registry keys
	.Example 
		Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Key "MRUListEx"
	.Notes 
		NAME: Get-J6RegistryData.ps1 
		AUTHOR: Paul Brown
		LASTEDIT: 01/26/2016 13:11:13
		KEYWORDS: 
	.Link 
		https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#> 
	
	Try {
		$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
		$subkey = $reg.OpenSubKey($Path)
		$keyvalue = $subkey.GetValue($Key)
	} Catch {
		# Just here to suppress errors
	}
	
	return $keyvalue

}