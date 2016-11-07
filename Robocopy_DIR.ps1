Function Copy-Profile {
	Param(
  		[Parameter(Mandatory=$True,Position=0)]
   		[string]$Source,
		[Parameter(Mandatory=$True,Position=1)]
   		[string]$Destination,
		[Parameter(Mandatory=$True,Position=2)]
   		[string]$UserName)
		
	$CMD = "C:\Windows\System32\Robocopy.exe"
	$params = "*.* /Z /V /XJ /J /E /PURGE /XA:SHE /MT:32 /R:1 /W:5 /XD AppData /XD MyEFS"`
	
	Start-Process robocopy $Source\$Username $Destination\$UserName $params -Wait -NoNewWindow -PassThru
	#Invoke-Expression "$CMD $Source\$Username $Destination\$UserName $params"
	
	If (Test-Path "$Source\$UserName\AppData\Microsoft\Outlook\*.pst") {
		$pstparams = "*.pst /Z /V /J /XJ /E /MT:32 /R:1 /W:5 "
		Start-Process robocopy $Source\$Username $Destination\$UserName $pstparams -Wait -NoNewWindow -PassThru
		#Invoke-Expression "$CMD $Source$Username\AppData\Microsoft\Outlook  $Destination\$UserName $pstparams"
	}
}