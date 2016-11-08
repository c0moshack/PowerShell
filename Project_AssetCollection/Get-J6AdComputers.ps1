# Set searchbase parameters here to use globally.
#$root = $(Get-ADDomain).DistinguishedName
#$state = "NGWI"
#$searchbase = "OU=J6-DISC4,OU=Computers,OU=$state,OU=States,$root"
#$searchbase = "OU=$state,OU=States,$root"
	
Function Get-J6AdComputers {
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true,
		 Position=1,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[String]$SearchBase
	)
	
	#Write-Host "Getting computers from $searchbase"
	logit -TopicName 'Get-J6AdComputers' -message "Getting computers from $searchbase"
	# Base,OneLevel,Subtree
	$computers = Get-ADComputer -SearchBase $SearchBase -SearchScope Subtree -Filter * 
	#Write-Host "$($computers.Count) computer objects aquired"
	logit -TopicName 'Get-J6AdComputers' -message "$($computers.Count) computer objects aquired"
	return $computers
}

Function Get-J6ComputersOnlineStatus {
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true,
		 ValueFromPipeline=$true,
		 Position=0,
		 ParameterSetName='Single')]
		[String]$ComputerName,
		
		[Parameter(Mandatory=$true,
		 ValueFromPipeline=$true,
		 Position=0,
		 ParameterSetName='Multiple')]
		[Array]$ComputerList
	)
	
	Switch ($PSCmdlet.ParameterSetName) {
		'Single' {$Computer = @{'Name'=$ComputerName}}
		'Multiple' {$Computer = $ComputerList}
	}
	
	$adComputers = @()
	
	
	#Write-Host "Checking online status..."
	Foreach ($comp in $Computer) { 
		
		If (Test-Connection -Count 1 -ComputerName $($comp.Name) -BufferSize 16 -Quiet) {
			$online = $true
			#Write-Output "$comp.Name is online"
		} Else {
			$online = $false
			#Write-Warning "$comp.Name is offline"
		}
		
		# Create new custom object to minimize data
		$tempProperties = @{}
		$tempProperties.Name = $($comp.Name)
		#$tempProperties.OU = $($comp.DistinguishedName.Split("OU=Computer"))[0]
		$tempProperties.Online = $online
		$tempObject = New-Object -TypeName PSObject -Property $tempProperties
		
		$adComputers += $tempObject
	}
	return $adComputers
}

Function Get-J6ADComputersAttributes {
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true,
		 ValueFromPipeline=$true,
		 Position=0,
		 ParameterSetName='Single')]
		[String]$ComputerName,
		
		[Parameter(Mandatory=$true,
		 ValueFromPipeline=$true,
		 Position=0,
		 ParameterSetName='Multiple')]
		[Array]$ComputerList
	)
	
	Switch ($PSCmdlet.ParameterSetName) {
		'Single' {$Computer = @{'Name'=$ComputerName}}
		'Multiple' {$Computer = $ComputerList}
	}
	
	$total = $($Computer.Count)
	$x = 1
	
	$objAttribs = @()
	Foreach ($comp in $Computer) {
		$attributes = Get-ADComputer -Identity $comp.Name -Properties * -ErrorAction SilentlyContinue
		Try {
			$tempProperties = @{}
			# These values are retrieved from Active Directory
			$tempProperties.Name = $attributes.Name
			$tempProperties.OU = $attributes.DistinguishedName
			$tempProperties.Online = $(Get-J6ComputersOnlineStatus -ComputerName $comp.Name | Where-Object {$_.Name -match $($attributes.Name)}).Online
			$tempProperties.OS = $attributes.OperatingSystem
			$tempProperties.Created = $attributes.whenCreated
			$tempProperties.Modified = $attributes.whenChanged
			$tempProperties.IP = $attributes.IPv4Address
			$tempProperties.LastLogon = $attributes.lastLogonDate
			$tempProperties.Enabled = $attributes.Enabled
			$tempProperties.Deleted = $attributes.isDeleted
			$tempProperties.Location = $attributes.Location
			$tempProperties.Description = $attributes.Description
			If ($attributes.serialNumber) {
				$tempProperties.Serial = $attributes.serialNumber[0]
			} Else {
				$tempProperties.Serial = $null
			}			
			$tempObject = New-Object -TypeName PSObject -Property $tempProperties
			
			$objAttribs += $tempObject
			
			#Write-Host "$($tempObject.Name) `thas been processed [$x`/$total]"
			logit -TopicName 'Get-J6ADComputersAttributes' -message "$($tempObject.Name) `thas been processed [$x`/$total]"
			
		} Catch [System.Management.Automation.RuntimeException] {
			# Dont do anything to prevent the error output if a variable is empty.
		}
		$x += 1
	}
	Write-Host "All computer objects in $searchbase have been processed"
	return $objAttribs
}