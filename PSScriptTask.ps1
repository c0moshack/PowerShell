#Variables to store the username and password for the alternate account            
$AccountName = "sp-dev-farm";            
$AccountPass = "NotMyPswd";            

#Convert the plain text password to a SecureString, required to create the PSCredential object
$AccountPassAsSecureString = $AccountPass | ConvertTo-SecureString -Force -AsPlainText            

#Create the PSCredential object using the alternate users username and password            
#Note that the Domain name has been prepended to the username, using the $env:userdomain variable, which represents the current domain.            
$credential = New-Object System.Management.Automation.PsCredential("$env:userdomain\$SPFarmAccountName",$AccountPassAsSecureString)              

#Create a new PowerShell session in the security context of the alternate user, using the PSCredential object we just created            
$PSSvcAccSession = New-PSSession -Credential $credential;            

#Write some text to the PowerShell Window, that prints the username from the current context 
Write-Host "Elevating priveleges and running scripts as, $env:userdomain\$env:username" -f magenta            

#Pass the PSSession object to Invoke-Command, and write some text to the PowerShell Window, that prints the username from the current context of the PSSession object (which will be the security context of the alternate user)            
Invoke-Command -Session $PSSvcAccSession -Script {
scriptfolder = "C:\PowerShellScripts";
	Foreach ($script in $scriptfolder) {
	. $($script.FullName)
	}
}            

#Write some more text to the PowerShell Window, that shoes the security context has returned to the original user            
Write-Host "Script exectution complete...Exiting," -f magenta