# ----------------------------------------------------------------------------- 
# Script: Get-MDTLog.ps1
# Author: Paul Brown
# Date: 01/20/2016 13:58:36 
# Keywords: MDT, BDD.log
# comments: This script will parse MDT logs. It can be extremly useful when
# "SLShare=<PATH>" is defined in the customsettings.ini file. 
# 
# -----------------------------------------------------------------------------

 Function Get-MDTLog {
	[cmdletbinding()]
	Param(
		[Parameter(
		 Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[array]$Path
	)
	
	<# 
   	.Synopsis 
    	This script will parse MDT logs. It can be extremly useful when
		"SLShare=<PATH>" is defined in the customsettings.ini file. Any log
		files created as a result of the deployment should be able to be parsed
		with this script.
   	.Example 
    	Get-MDTLog -Path "%WINDIR%\TEMP\DeploymentLogs"

   	.Notes 
    	NAME: Get-BDDLog.ps1 
    	AUTHOR: Paul Brown
    	LASTEDIT: 01/20/2016 14:24:39 
    	KEYWORDS: 
   	.Link 
    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#> 
	
	$bddlog = Get-Content $Path
	$entries = $($bddlog -split "`r`n")
	$log = @()
	Foreach ($entry in $entries) {
		If ($entry -match '(<!\[LOG\[(.+)\]LOG\]!>)(<(.+)>)') {
			$event = $Matches[2]
			$data = $($Matches[4]) -split '\s'
			$info = @{}
			$info.Event=$event
			
			$Time = $(If ( $data[0] -Match '(?:")(.+)(?:")') {$Matches[1]}) -split ":"
			$hour = $($Time[0])
			$minute = $($Time[1])
			$second = $($($Time[2]) -split "\+")[0]
			$info.Date=$(Get-date -Date $(If ( $data[1] -Match '(?:")(.+)(?:")') {$Matches[1]}) -Hour $hour -Minute $minute -Second $second -Format "MM-dd-yyyy HH:mm:ss")
			$info.Component=$(If ( $data[2] -Match '(?:")(.+)(?:")') {$Matches[1]})
			$info.Context=$(If ( $data[3] -Match '(?:")(.+)(?:")') {$Matches[1]})
			$info.Type=$(If ( $data[4] -Match '(?:")(.+)(?:")') {$Matches[1]})
			$info.Thread=$(If ( $data[5] -Match '(?:")(.+)(?:")') {$Matches[1]})
			$info.File=$(If ( $data[6] -Match '(?:")(.+)(?:")') {$Matches[1]})
			$object = New-Object –TypeName PSObject –Prop $info
			$log += $object
		}
	}
	return $log
}
