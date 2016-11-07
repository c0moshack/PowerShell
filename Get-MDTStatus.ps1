Function Get-MDTStatus {
	If( -not $(Get-PSSnapin -Name Microsoft.BDD.PSSnapIn)) {
		Add-PSSnapin -Name Microsoft.BDD.PSSnapIn
	}
	Restore-MDTPersistentDrive -ErrorAction SilentlyContinue | Out-Null
	#Get-PSDrive -PSProvider Microsoft.BDD.PSSnapIn\MDTProvider
	#Add-PSSnapIn Microsoft.BDD.PSSnapIn
	#New-PSDrive -Name MDTShare -PSProvider MDTProvider -Root \\server\DeploymentShare$
	$data = Get-MDTMonitorData -path DS001: | Select-Object *
	$computers = @()
	Foreach ($device in $data) {
		$object = @{}
		$object.Name = $($device.Name)
		$object.Start = $($device.StartTime)
		$object.End = $($device.EndTime)
		$object.Progress = $($device.PercentComplete)
		$objects = New-Object -TypeName PSObject -Property $object
		$computers += $objects
		}
	return $computers
}

While ($true) {
	CLS
	Write-Host "Deployment Server Status"
	Get-MDTStatus
	Sleep 10
}