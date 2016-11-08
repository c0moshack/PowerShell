#######################################################################################################################
# File:             J6LoanManagement.psm1                                                                             #
# Author:           paul.j.brown                                                                                      #
# Publisher:        US Army                                                                                           #
# Copyright:        © 2015 US Army. All rights reserved.                                                              #
# Usage:            To load this module in your Script Editor:                                                        #
#                   1. Open the Script Editor.                                                                        #
#                   2. Select "PowerShell Libraries" from the File menu.                                              #
#                   3. Check the J6LoanManagement module.                                                             #
#                   4. Click on OK to close the "PowerShell Libraries" dialog.                                        #
#                   Alternatively you can load the module from the embedded console by invoking this:                 #
#                       Import-Module -Name System.Object[]                                                           #
#                   Please provide feedback on the PowerGUI Forums.                                                   #
#######################################################################################################################

Function Get-RemoteRegistryValue {
	[cmdletbinding()]
	Param(
		[Parameter(Mandatory=$true)]
		[string]$Hive,
		[Parameter(Mandatory=$true)]
		[string]$ComputerName,
		[Parameter(Mandatory=$true)]
		[string]$Path,
		[Parameter(Mandatory=$true)]
		[string]$Key
	)
	Try {
		$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
		$sub = $regHive.OpenSubKey($Path)
		$value = $sub.GetValue($Key)
	} Catch {
	}
	
	return $value
} # End get registry value

Function Get-J6Loaners {
	<# 
   	.Synopsis 
    	Query all loan laptops from NGWINB-LOAN-01 - NGWINB-LOAN-60 for their 
		status and power settings.
   	.Example 
		 Display the data in the PowerShell Window
    	Get-J6Loaners 
	.Example
		 Export the data to a .csv file
		Get-J6Loaners | Export-Csv
	.Example
		 Display data in a window for quick reference
		Get-J6Loaners | Out-GridView
   	.Notes 
    	NAME: J6LoanManagement.psm1 
    	AUTHOR: paul.brown.sa 
    	LASTEDIT: 12/08/2015 11:00:49 
    	KEYWORDS:  
	#Requires -Version 2.0 
	#> 

	[cmdletbinding()]
	Param()
	
	Write-Verbose "Script Started"
	$count = 1..60
	$computers = @()
	ForEach ($one in $count) {
		$one = "NGWINB-LOAN-$($one.ToString("00"))"
		Write-Verbose "[$one]: Processing"
		$computerprop = @{}
		$computerprop.Name = $one
		Try {
			$attributes = $null
			$attributes = Get-ADComputer -Identity $one -Properties * -ErrorAction SilentlyContinue
			Write-Verbose "[$one]: Getting AD information"
		} Catch {
		
		}
		If ($attributes) {
			$computerprop.IP = $attributes.IPv4Address
			$computerprop.LastLogon = $attributes.lastLogonDate
			$computerprop.OU = $attributes.DistinguishedName
		} Else {
			$computerprop.IP = $null
			$computerprop.LastLogon = $null
			$computerprop.OU = $null
		}
		
		If ($(Test-Connection -ComputerName "$one" -Count 1 -BufferSize 16 -Quiet)) {
			$computerprop.Serial = $(Get-WmiObject -Class Win32_BIOS -ComputerName $one -ErrorAction SilentlyContinue).SerialNumber
			$computerprop.PowerSetting = Get-RemoteRegistryValue -ComputerName $one -Hive "LocalMachine" -Path "SOFTWARE\Policies\Microsoft\Power\PowerSettings\5CA83367-6E45-459F-A27B-476B1D01C936" -Key "ACSettingIndex"
			$computerprop.Status = "Online"
			Write-Verbose "[$one]: Collecting online data"
		} Else {
			$Computerprop.Serial = $null
			$computerprop.PowerSetting = $null
			$computerprop.Status = "Offline"
			Write-Verbose "[$one]: Offline"
		}
		$computer = New-Object -TypeName PSObject -Property $computerprop
		$computers += $computer
		Write-Verbose "[$one]: Added to collection"
	}
	Write-Verbose "Script Complete" 
	return $computers
}

Function Set-LidAction {
	<# 
   	.Synopsis 
    	Set the lid action to "Do Nothing" for a specific computer. Multiple 
		names can be piped to the cmdlet.
   	.Example 
    	Set-LidAction -Computer <name>
   	.Notes 
    	NAME: J6LoanManagement.psm1 
    	AUTHOR: paul.brown.sa 
    	LASTEDIT: 12/08/2015 11:04:09 
    	KEYWORDS: 
	#Requires -Version 2.0 
	#> 

	Param(
		[Parameter(Mandatory=$true,
		 Position=0,
		 ValueFromPipeline=$true,
	   	 ValueFromPipelineByPropertyName=$true)]
		[string]$ComputerName
	)
	Try {
		If ($(Test-Connection -ComputerName $ComputerName -Count 1 -BufferSize 16 -Quiet)) {
			$Hive = "LocalMachine"
			#$ComputerName = "NGWINB-LOAN-11"
			$Path = "SOFTWARE\Policies\Microsoft\Power\PowerSettings\5CA83367-6E45-459F-A27B-476B1D01C936"
			$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$sub = $regHive.OpenSubKey($Path, $true)
				
			$regHive.CreateSubKey("$Path\ACSettingsIndex") | Out-Null
			$newsub = $regHive.OpenSubKey($Path, $true)
			$newsub.SetValue("ACSettingIndex", 0)
			$output = @{}
			$output.ComputerName = $ComputerName
			$output.Key = "$newsub\ACSettingIndex"
			$output.Value = $newsub.GetValue("ACSettingIndex")
			$object = New-Object -TypeName PSObject -Property $output
		}
	} Catch {
	}
	$object
}
