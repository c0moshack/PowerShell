# ----------------------------------------------------------------------------- 
# Script: Enable-ClientPSRemoting
# Author: Paul Brown
# Date: 04/12/2016 14:33:31 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Enable-ClientPSRemoting {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Enable-ClientPSRemoting 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/12/2016 14:33:31 
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
		[array]$ComputerName
	)
	# Test connectivity to the computer
	if (Test-Connection -Quiet -Count 2 -ComputerName $ComputerName -ErrorAction SilentlyContinue) {
		$Online = "Yes"}else{$Online = "No"
	}
	if ($Online -eq "No") {
		write-Output "$ComputerName is not online!"
	}
	if ($Online -eq "Yes") {
		# Start Remote Registry Service to allow Get-Process to run
		If ($(Get-Service -ComputerName $ComputerName -Name RemoteRegistry).Status -ne "Running") {
			(Get-Service -ComputerName $ComputerName -Name RemoteRegistry).Start()
		}

		# Check for admin share
		$keys = "AutoShareServer", "AutoShareWks"
		Foreach ($key in $keys) {
			$Hive = "LocalMachine" 
			$Path = "SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" 

			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$subkey = $reg.OpenSubKey($Path)
			$keyvalue = $subkey.GetValue($key)
			
			If ($keyvalue -ne 1) {
				$subkey.SetValue($Name, $Value)
				$keyvalue = $subkey.GetValue($Name)
			}
		}
		Try {
			$params = @(
				"-accepteula",
				"\\$($ComputerName)",
				"-s",
				"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
				"Enable-PSRemoting",
				"-Force"
			)
						
			Start-Process D:\SysinternalsSuite\PsExec.exe $params
			return Write-Output "PSRemoting enabled on $ComputerName"
			
		} Catch {
			Write-Error $_.Exception.Message
		}
	}
} 