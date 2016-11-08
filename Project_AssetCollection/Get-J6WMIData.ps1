Function Get-J6WMIData {
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
	
	$computerinfo = @()
	
	Foreach ($comp in $Computer) {
		If (Test-Connection $comp.Name -Count 1 -BufferSize 16 -Quiet) {
			$tempProperties = @{}
			Try {
			$bios = Get-WmiObject -ComputerName $comp.Name -Class Win32_BIOS -ErrorAction SilentlyContinue
			$tempProperties.Manufacturer = $bios.Manufacturer
			$tempProperties.Serial = $bios.SerialNumber
			} Catch {
			#logit ($ComputerName) -message "[BIOS]:::Unable to retreive data"
			}
			$compsys = Get-WmiObject -ComputerName $comp.Name -Class Win32_ComputerSystem -ErrorAction SilentlyContinue
			$tempProperties.Model = $compsys.Model
			$tempProperties.Memory = [math]::truncate($($compsys.TotalPhysicalMemory / 1mb))
			$tempProperties.Name = $comp.Name
			
			#$ossys = Get-WmiObject -ComputerName $comp.Name -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
					
			$tempProperties.AGMSecurityUpdateVersion = Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "SecurityUpdateVersion"
			$tempProperties.AGMVersion = Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "Version"
			$tempProperties.AGMBaselineSecurity = Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "BaselineSecurity"
			$tempProperties.NGWI = Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "SOFTWARE\AGMProgram\Build" -Key "NGWIImageVersion"
			
			$tempProperties.BitLocker = $(Get-WmiObject -Namespace root\CIMV2\Security\MicrosoftVolumeEncryption -Class Win32_EncryptableVolume -ComputerName $comp.Name -ErrorAction SilentlyContinue | Where-Object {$_.DriveLetter -eq "C:"}).ProtectionStatus 
			$tempProperties.LastUser = $(Get-LoggedOnUser -computername $comp.Name | Sort 'StartTime' | Where-Object {$_.Type -match 'Interactive'} | Select 'User' -Last 1 ).User
			
			# Get TPM Data
			$tpmdata = Get-WmiObject -Namespace root\CIMV2\Security\MicrosoftTpm -Class Win32_Tpm -Property * -ComputerName $comp.Name -ErrorAction SilentlyContinue
			$tempProperties.TPMVersion = $tpmdata.PhysicalPresenceVersionInfo
			$tempProperties.TPMEnabled = $tpmdata.IsEnabled_InitialValue
			$tempProperties.TPMActivated = $tpmdata.IsActivated_InitialValue
			
			$tempObject = New-Object -TypeName PSObject -Property $tempProperties
			
			$computerinfo += $tempObject
		} Else {
		
		}
		logit -TopicName 'Get-J6WMIData' -message "$($comp.Name) `thas been processed [$x`/$total]"
		$x += 1
	}
	return $computerinfo
}
