Function Get-MyProfile {
	$wkprofile = "\\ngwiwk-disc4-47\c$\Users\paul.brown.sa\Documents\WindowsPowerShell"
	Copy-Item -Path $wkprofile -Destination "C:\Users\paul.brown.sa\Documents\" -Container -Recurse -Force
	Copy-Item -Path "\\ngwiwk-disc4-47\c$\Users\paul.brown.sa\Documents\WindowsPowerShell\profile.ps1" -Destination C:\Users\paul.brown.sa\Documents\WindowsPowerShell\profile.ps1 -Force
}