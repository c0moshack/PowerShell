Function Set-WindwowsStore {
	<# 
   	.Synopsis 
    	Enable or disable the windows store
   	.Example 
    	Set-WindowsStore -Computer <name> -Enable
	.Example 
    	Set-WindowsStore -Computer <name> -Disable	
   	.Notes 
    	NAME: Set-WindowsStore.ps1 
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
		[string]$ComputerName,
		[switch]$Enable,
		[switch]$Disable
	)
	
	If ($Enable) {
		$Value = 0
	} ElseIf ($Disable) {
		$Value = 1
	}

	#Try {
		If ($(Test-Connection -ComputerName $ComputerName -Count 1 -BufferSize 16 -Quiet)) {
			$Hive = "CurrentUser"
			$Path = 'Software\Microsoft\Windows\CurrentVersion\Group Policy Objects\{17313853-9E64-4CCA-A225-6EA426AB5836}Machine\SOFTWARE\Policies\Microsoft\WindowsStore'
			$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$sub = $regHive.OpenSubKey($Path, $true)
			$sub.SetValue("RemoveWindowsStore", $Value)
			
			$output = @{}
			$output.ComputerName = $ComputerName
			$output.Key = "RemoveWindowsStore"
			$output.Value = $sub.GetValue("RemoveWindowsStore")
			$object = New-Object -TypeName PSObject -Property $output
		}
	#} Catch {
	#}
	$object
}
