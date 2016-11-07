# Type in a PowerShell script here
$software = Read-Host "Enter the software name or vendor"

$input = "NGWINB-DISC4-31"

$input | ForEach-Object {
	$name = $_
	
	$online = $(Test-Connection $name -Count 1 -BufferSize 8 -Quiet)
	If ($online -eq $true) {
		Try { 
			If ($(Get-WmiObject -Class Win32_Product -ComputerName $name) -match $software) { 
				$present = $Matches
			} Else { 
				$present = "Not Present" 
			} 
		} Catch { 
			Write-Error "$name is unreachable" 
		}
	} Else {
		$present = "NA"
	}
	
	$computer = @{}
	$computer.Name = $name
	$computer.Online = $online
	$computer.Present = $present
	$computers = New-Object -TypeName PsObject -Property $computer
	Write-Output $computers
	  
}