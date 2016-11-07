# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }

# Run your code that needs to be elevated here
Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

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
			$Hive = "LocalMachine"
			$Path = "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
			$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$sub = $regHive.OpenSubKey($Path, $true)
			$sub.SetValue("SCForceOption", 0)
			
			$output = @{}
			$output.ComputerName = $ComputerName
			$output.Key = "SCForceOption"
			$output.Value = $sub.GetValue("SCForceOption")
			$object = New-Object -TypeName PSObject -Property $output
		}
	} Catch {
	}
	$object
}
Set-J6DisableCACOnly
