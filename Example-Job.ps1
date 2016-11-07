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
			
			$regjob = Start-Job { 
				$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($args[1], $args[0])
				$subkey = $reg.OpenSubKey($args[2])
				$keyvalue = $subkey.GetValue($args[3])
				Write-Output $keyvalue
			} -ArgumentList $ComputerName, $Hive, $Path, $Key
			
			Wait-Job $regjob -Timeout 10 | Out-Null
			Stop-Job $regjob
			Receive-Job $regjob
			Remove-Job $regjob
		} Catch {
			# Just here to suppress errors
		}
		
		return
}


$computer = "NGWINB-7MCAA-38"
#$computer = "NGWINB-7MCAA-25"
$tempProperties = @{}
If (Test-Connection $computer -Count 1 -BufferSize 16 -Quiet) {
	$tempProperties.ComputerName = $($computer)
	$tempProperties.AGMSecurityUpdateVersion = Get-RegistryData -ComputerName $computer -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "SecurityUpdateVersion"
	$tempProperties.AGMVersion = Get-RegistryData -ComputerName $computer -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "Version"
	$tempProperties.AGMBaselineSecurity = Get-RegistryData -ComputerName $computer -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "BaselineSecurity"
	$tempProperties.NGWI = Get-RegistryData -ComputerName $computer -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "NGWIImageVersion"
} Else {
	$tempProperties.ComputerName = $($computer)
	$tempProperties.AGMSecurityUpdateVersion = ""
	$tempProperties.AGMVersion = ""
	$tempProperties.AGMBaselineSecurity = ""
	$tempProperties.NGWI = "Unreachable"
}
$tempObject = New-Object -TypeName PSObject -Property $tempProperties
			
$tempObject