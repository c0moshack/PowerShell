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

# Get thumbprint for certificate
Function Get-J6Certs {
	$exportcerts = @()
	$certs = cscript //nologo "c:\Windows\System32\slmgr.vbs" /ltc
	$certs = $certs | Where-Object {$_ -like "Thumbprint*"}
	Foreach ($cert in $certs) {
		$temp = $($cert).Split(":")[1]
		$exportcerts += $temp.Trim()
	}
	return $exportcerts
}

###############################################################################
#  Product Activation
###############################################################################
$activationStatus = Invoke-Expression "c:\Windows\System32\slmgr.vbs /dlv"
If ($activationStatus -notcontains "License Status: Licensed") {
	# Activate Windows
	Write-Output "Activating Windows"
	$pin = Read-Host "Enter PIN for certificate activation" -AsSecureString
	$thumbprints = Get-J6Certs
	cscript //nologo "c:\Windows\System32\slmgr.vbs" /fta`:$($thumbprints[0])`:$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pin)))
	$activationStatus = Invoke-Expression "c:\Windows\System32\slmgr.vbs /dlv" 
	Write-Output "Windows Activated"
} Else {
	Write-Output "Windows already activated" 
}
# Print the license details 
Write-Output $($activationStatus | Where-Object {$_ -match "Trusted time:"})