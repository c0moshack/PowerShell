Function Get-J6ReCreateComputer {
	Param([Parameter(Mandatory=$True)]
    [string]$ComputerName)
	If (-not (Get-Module -Name "ActiveDirectory")) {
		Import-Module ActiveDirectory
	}
	
	$details = @{}
	
	$computer = Get-ADComputer -Identity $ComputerName -Properties *
	If ($computer) {
		$details.Name = $computer.CN
		$details.Created = $computer.whenCreated.DateTime
		$details.Modified = $computer.whenChanged.DateTime
		$details.LastLogon = $computer.LastLogonDate.DateTime
		$details.OU = $computer.DistinguishedName.Replace("CN=$($computer.Name),","")
		$details.Description = $computer.Description
		$details.Location = $computer.Location
	}

	$object = New-Object –TypeName PSObject –Prop $details
	Write-Output "Found: "
	Write-Output $object
	
	If ($(Read-Host "Would you like to re-add this object?") -eq "y") {
		Get-ADComputer $computername | Remove-ADObject -Recursive -Confirm
		New-ADComputer -Name $ComputerName -SAMAccountName $ComputerName -Path $object.OU -Enabled $true -Description $object.Description -Location $object.Location
		Write-Output "Object recreated"
		Get-ADComputer -Identity $ComputerName
	} Else {
		Write-Output "Object not modified"
	}
}