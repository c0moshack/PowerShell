Function Get-STIGData {
	<# 
   	.Synopsis 
    	Analyze workstation for the given STIG	
   	.Example 
    	Get-STIGData -File <path to file>
   	.Parameter  
    	STIG - The full path to the .xml file 
   	.Notes 
    	NAME: Get-STIGData.ps1 
    	AUTHOR: Paul Brown
    	LASTEDIT: 12/14/2015 10:23:25 
    	KEYWORDS: 
	#Requires -Version 2.0 
	#> 
	[cmdletbinding()]
	Param(
	[Parameter(
		 Mandatory=$false,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[string]$STIG = "D:\Documents\J6\STIG\Windows 7\U_Windows_7_V1R27_STIG_SCAP_1-1_Benchmark\U_Windows_7_V1R27_STIG_SCAP_1-1_Benchmark-xccdf.xml"
	)	

	If ($STIG) {
		[string]$stigdata = Get-Content $STIG
		[string]$stigdata = $stigdata.Replace('â€œ','"')
		[xml]$stigdata = $stigdata.Replace('â€','"')
	} Else {
		Write-Error "Please provide a valid path to an XML file."
	}
	
	return $stigdata

}

$data = Get-STIGData

Foreach ($id in $data.Benchmark.Profile[0].Select.idref) {
	$group = $data.Benchmark.Group | Where {$_.id -eq $id}
	$value = $data.Benchmark.Value | Where {$_.id -eq $($group.Rule.check.'check-export'.'value-id')}
	Write-Host "---------------------------------------------------------------"
	Write-host $group.title
	Write-Host $group.Rule.fixtext.'#text'
	#$($($($value.value) | Where {$_.selector.'#text' -eq $($value.value)}).selector)
	$out = $value.value
	Write-Host "$($value.value[0]) $($($out | Where-Object {$_.'#text' -eq $value.value[0]}).selector)"
	Write-Host ""
}