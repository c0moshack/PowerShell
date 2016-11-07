Function Uninstall-Hotfix {
	Start-Transaction "$env:USERPROFILE\Desktop\Run-Cisco-Uninstall-Hotifx.ps1.log"
	$kbs = "KB2918614","KB3072630","KB3008627"
	$computername = $env:COMPUTERNAME

	#Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer -Name NoUACforHashMissing -Value 1
	#Write-Host "Registry Key: NoUACforHashMissing Set to: $($(Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer).NoUACforHashMissing)"
	Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer -Name EnableUserControl -Value 1
	Write-Host "Registry Key: EnableUserControl Set to: $($(Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer).EnableUserControl)"
	
	Foreach ($kb in $kbs) {
		If ($(Get-HotFix "$kb" -ErrorAction SilentlyContinue)) {
		    $kb = $kb.Replace("KB","")
		    #Write-Host "Found the hotfix KB" + $kb
		    Write-Host "Uninstalling the hotfix $kb"
		    $UninstallString = "cmd.exe /c wusa.exe /uninstall /KB:$kb /quiet /norestart"
		    ([WMICLASS]"\\$computername\ROOT\CIMV2:win32_process").Create($UninstallString) | out-null            

		    while (@(Get-Process wusa -computername $computername -ErrorAction SilentlyContinue).Count -ne 0) {
		        Start-Sleep 5
		        Write-Host "Waiting for update removal to finish ..."
		    }
			Start-Sleep 20
			If ($(Get-HotFix "$kb" -ErrorAction SilentlyContinue)) {
				Write-Host "Hotfix not removed!"	-ForegroundColor Red
			} Else {
				Write-Host "Completed the uninstallation of $kb" -ForegroundColor Green
			}
		} else {            
			Write-Host "Given hotfix($kb) not found"
		}
	}
	Set-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer -Name EnableUserControl -Value 0
	Write-Host "Registry Key: EnableUserControl Set to: $($(Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\Installer).EnableUserControl)"
	Stop-Transcript
	return "0"
}

Uninstall-Hotfix