Function Get-Netstat {
	[cmdletbinding()]
	Param()
	$netstatdata = @()
	$net = netstat -nao

	Foreach ($line in $net) {
		If ($($line -match "TCP") -or $($line -match "UDP")) {
			$line = $line -split ' ' | Where-Object {$_ -ne ''}
			If ($($line[0]) -match "TCP") {
				$tempObject = @{}
				$tempObject.Protocol = $line[0]
				$tempObject.LocalAddress = $line[1]
				$tempObject.ForeignAddress = $line[2]
				$tempObject.State = $line[3]
				$tempObject.PID = $line[4]
			} ElseIf ($($line[0]) -match "UDP") {
				$tempObject = @{}
				$tempObject.Protocol = $line[0]
				$tempObject.LocalAddress = $line[1]
				$tempObject.ForeignAddress = $line[2]
				$tempObject.PID = $line[3]
				$tempObject.State = $null
			}
			
			$object = New-Object -TypeName PSObject -Property $tempObject
			$netstatdata += $object
		}
	}
	return $netstatdata
}
