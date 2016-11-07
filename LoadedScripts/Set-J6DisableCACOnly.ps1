Function Set-J6DisableCACOnly {
	<# 
   	.Synopsis 
    	Allow logon with username/password 
   	.Example 
    	Set-J6DisableCACOnly -Computer <name>
   	.Notes 
    	NAME: Set-DisableCACOnly.ps1 
    	AUTHOR: paul.brown.sa 
    	LASTEDIT: 12/08/2015 11:04:09 
    	KEYWORDS: 
	#Requires -Version 2.0 
	#> 

	Param(
		[Parameter(Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[string]$ComputerName
	)
	Try {
		If ($(Test-Connection -ComputerName $ComputerName -Count 1 -BufferSize 16 -Quiet)) {
			Write-Host "Connected to machine."
			$Hive = "LocalMachine"
			$Path = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
			$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$sub = $regHive.OpenSubKey($Path, $true)
			$sub.SetValue("SCForceOption", 0)
			Write-Host "SCForceOption disabled"
			$output = @{}
			$output.ComputerName = $ComputerName
			$output.Key = "SCForceOption"
			$output.Value = $sub.GetValue("SCForceOption")
			$object = New-Object -TypeName PSObject -Property $output
		} Else {
			Write-Host "Unable to connecto to machine!"
		}
	} Catch {
		
	}
	$object
}
