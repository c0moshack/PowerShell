Function Install-CiscoVPNClient {
	New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer -Name SecureRepairPolicy -Value 2
	New-Item HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer\SecureRepairWhitelist -Value '{B0BF7057-6869-4E4B-920C-EA2A58DA07F0}'
	
	$path = "$env:windir\Temp\Cisco VPN Client"
	$installString = @('/i', "$path\vpnclient_setup.msi", "/qb", "/l*vx", "$path\ciscovpn.log", "REBOOT=ReallySuppress")
	# Waste some time
	Test-Connection -ComputerName $env:COMPUTERNAME -Count 5 | Out-Null
	# Copy files and install
	Copy-Item -Path "\\NGWIA7-DISC4-20\e\MDTShare\Applications\Cisco VPN Client" -Destination "C:\Windows\Temp\" -Recurse -ErrorAction SilentlyContinue
	& 'msiexec.exe' $installString
	Copy-Item -Path "\\NGWIA7-DISC4-20\e\MDTShare\Applications\Cisco VPN Client\WIARNG CAC VPN.pcf" -Destination "$env:ProgramFiles\Cisco Systems\VPN Client\" -ErrorAction SilentlyContinue
}

Install-CiscoVPNClient
