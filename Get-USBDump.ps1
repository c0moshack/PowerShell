# ----------------------------------------------------------------------------- 
# Script: Get-USBDump.ps1
# Author: Paul Brown
# Date: 11/09/2015 10:47:03 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------
###############################################################################
#  Utility functions
###############################################################################
Function Speak-Text {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$Text
	)
	
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = 0                # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Volume = 100
	$Voice.Voice = $($Voice.GetVoices())[1]
	$Voice.Speak($Text) | out-null  # Piped to null to suppress text output.
}
#---------------------------------------------------------#
# External Device / USB Usage
#---------------------------------------------------------#

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Key Identification
Description:
Track USB devices plugged into a machine.
Location:
• SYSTEM\CurrentControlSet\Enum\USBSTOR
• SYSTEM\CurrentControlSet\Enum\USB
Interpretation:
• Identify vendor, product, and version of a USB
device plugged into a machine
• Identify a unique USB device plugged into the
machine
• Determine the time a device was plugged
into the machine
• Devices that do not have a unique serial
number will have an “&” in the second
character of the serial number.
#>
Function Get-USBRegistryEntries {
	[cmdletbinding()]
		Param(
			[Parameter(
			Mandatory=$false,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[array]$ComputerName = $env:COMPUTERNAME
		)
		
	
	$usb = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)
	$usbsub = $usb.OpenSubKey("SYSTEM\CurrentControlSet\Enum\USB\")
	$regKeys =  [System.Collections.ArrayList]@()
	Write-Host "Fetching keys from USB..."
	If ($usbsub) {
		Foreach ($item in $usbsub.GetSubKeyNames()) {
			Foreach ($key in $($usbsub.OpenSubKey($item)).GetSubKeyNames()) {
				$tmp = $($usbsub.OpenSubKey($item)).OpenSubKey($key)
				If ($tmp) {
					Try {
						$tmpObject = New-Object -TypeName PSObject -Property ($properties = @{'FriendlyName'=$tmp.GetValue("FriendlyName");'Description'=$tmp.GetValue("DeviceDesc").Split(";")[1];'HardwareID'=$tmp.GetValue("HardwareID");'Manufacturer'=$tmp.GetValue("Mfg").Split(";")[1];'Location'=$tmp.GetValue("LocationInformation");'Serial'=$key;'Class GUID'=$tmp.GetValue("ClassGUID");'Connected'="";'Drive'=""}) 
					} Catch [System.Management.Automation.RuntimeException] {
						
					}
					$regKeys += $tmpObject
				}
			}
		}

	} else {
			Write-Warning "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USB\ does not exist"
	}
			
	$usb = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)
	$usbsub = $usb.OpenSubKey("SYSTEM\CurrentControlSet\Enum\USBSTOR\")
	#$regKeys =  [System.Collections.ArrayList]@()
	Write-Host "Fetching keys from USBSTOR..."
	If ($usbsub) {
		Foreach ($item in $usbsub.GetSubKeyNames()) {
			Foreach ($key in $($usbsub.OpenSubKey($item)).GetSubKeyNames()) {
				$tmp = $($usbsub.OpenSubKey($item)).OpenSubKey($key)
				If ($tmp) {
					Try {
						$tmpObject = New-Object -TypeName PSObject -Property ($properties = @{'FriendlyName'=$tmp.GetValue("FriendlyName");'Description'=$tmp.GetValue("DeviceDesc").Split(";")[1];'HardwareID'=$tmp.GetValue("HardwareID");'Manufacturer'=$tmp.GetValue("Mfg").Split(";")[1];'Location'=$tmp.GetValue("LocationInformation");'Serial'=$key;'Class GUID'=$tmp.GetValue("ClassGUID");'Connected'="";'Drive'=""}) 
					} Catch [System.Management.Automation.RuntimeException] {
						
					}
					$regKeys += $tmpObject
				}
			}
		}

	} else {
			Write-Warning "Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Enum\USBSTOR\ does not exist"
	}
	If ($Speak) {Speak-Text "Registry enumeration complete"}
	#$regKeys | Select-Object Serial, Description, Manufacturer
	return $regKeys #| Select-Object Description,Serial,"Class GUID" | Format-Table -AutoSize
}

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# First/Last Time
Description:
Determine temporal usage of specific USB devices
connected to a Windows Machine.
Location: First Time
• Plug and Play Log Files
XP C:\Windows\setupapi.log
Win7/8 C:\Windows\inf\setupapi.dev.log
Interpretation:
• Search for Device Serial Number
• Log File times are set to local time zone
Location: First, Last, and Removal Times (Win7/8 Only)
System Hive \CurrentControlSet\Enum\USBSTOR\Ven_
Prod_Version\USB
iSerial #\Properties\{83da6326-97a6-4088-9453-
a1923f573b29}\####
0064 = First Install (Win7/8)
0066 = Last Connected (Win8 only)
0067 = Last Removal (Win 8 only)
#>

#HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}
#HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}\BaseContainers
#HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}\BaseContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}
#HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}
#HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}\BaseContainers
#HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}\BaseContainers\{c2a9b426-de33-5866-b150-9e01e7b24ae3}

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# User
Description:
Find User that used the Unique USB
Device.
Location:
• Look for GUID from
SYSTEM\MountedDevices
• NTUSER.DAT\Software\Microsoft\
Windows\CurrentVersion\Explorer\
MountPoints2
Interpretation:
This GUID will be used next to identify
the user that plugged in the device.
The last write time of this key also
corresponds to the last time the device
was plugged into the machine by that
user. The number will be referenced in
the user’s personal mountpoints key in
the NTUSER.DAT Hive.
#>
#-----HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
Function Get-USBMountedDevices {
	[cmdletbinding()]
		Param(
			[Parameter(
			Mandatory=$false,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[array]$ComputerName = $env:COMPUTERNAME
		)
	$data = @() 
	$hive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine", $ComputerName)
	$key = $hive.OpenSubKey("SYSTEM\MountedDevices")
	$values = $key.GetValueNames() | Where-Object {$_ -match "\Dos"}
	            
	foreach ($item in $values) {                   
	 	$bin = $key.GetValue($item)         
	             
	 	$decoded = @()
		$asciirange = 32..126
		foreach ($dec in $bin) {
			If ($asciirange -like $dec) {
				$decoded += [char]$dec
				}
	 	}            
	    $data = New-Object -TypeName PSObject
		$data.PSObject.TypeNames.Add('USB.MountedDevice') 
		Add-Member -InputObject $data -MemberType NoteProperty -Name "Device" -Value $item
		Add-Member -InputObject $data -MemberType NoteProperty -Name "BinaryValue" -Value $bin
		Add-Member -InputObject $data -MemberType NoteProperty -Name "DecodedValue" -Value $($decoded -join "")
		If ($data.DecodedValue -match '\S+&Ven_(\S+)&Prod_(\S+)&Rev_(\S+)#(\S+)#{(\S+)}') {
	    	Add-Member -InputObject $data -MemberType NoteProperty -Name "Manufacturer" -Value $Matches[1]
			Add-Member -InputObject $data -MemberType NoteProperty -Name "Description" -Value $Matches[2]
			Add-Member -InputObject $data -MemberType NoteProperty -Name "Serial" -Value $Matches[4]
		}
	}            
	If ($Speak) {Speak-Text "Mounted device enumeration complete"}
	return $data #| Format-Table  Device, DecodedValue  -AutoSize
}

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Volume Serial Number
Description:
Discover the Volume Serial Number of the Filesystem
Partition on the USB (NOTE: This is not the USB Unique
Serial Number, that is hardcoded into the device firmware.)
Location:
• SOFTWARE\Microsoft\WindowsNT\CurrentVersion\
ENDMgmt
• Use Volume Name and USB Unique Serial Number to find
• Last integer number in line
• Convert Decimal Serial Number into Hex Serial Number
Interpretation:
• Knowing both the Volume Serial Number and the Volume
Name you can correlate the data across SHORTCUT File
(LNK) analysis and the RECENTDOCs key.
• The Shortcut File (LNK) contains the Volume Serial Number
and Name
• RecentDocs Registry Key, in most cases, will contain the
volume name when the USB device is opened via Explorer
#>

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Drive Letter & Volume Name
Description:
Discover the last drive letter of the USB Device when it was plugged into
the machine.
Location:
XP
• Find ParentIdPrefix
- SYSTEM\CurrentControlSet\Enum\USBSTOR
• Using ParentIdPrefix Discover Last Mount Point
- SYSTEM\MountedDevices
Win7/8
• SOFTWARE\Microsoft\Windows Portable Devices\Devices
• SYSTEM\MountedDevices
- Examine Drive Letter’s looking at Value Data Looking for Serial
Number
Interpretation:
Identify the USB device that was last mapped to a specific drive letter. This
technique will only work for the last drive mapped. It does not contain
historical records of every drive letter mapped to a removable drive.
#>

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Shortcut (LNK) Files
Description:
Shortcut files automatically created by Windows
• Recent Items
• Open local and remote data files and documents will generate a
shortcut file (.lnk)
Location:
XP
• %USERPROFILE%\Recent
Win7/8
• %USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent
• %USERPROFILE%\AppData\Roaming\Microsoft\Office\Recent
Interpretation:
• Date/Time file of that name was first opened
- Creation Date of Shortcut (LNK) File
• Date/Time file of that name was last opened
- Last Modification Date of Shortcut (LNK) File
• LNKTarget File (Internal LNK File Information) Data:
- Modified, Access, and Creation times of the target file
- Volume Information (Name, Type, Serial Number)
- Network Share information
- Original Location
- Name of System
#>

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# PnP Events
Description:
When a Plug and Play driver install is attempted,
the service will log an ID 20001 event and
provide a Status within the event. It is important
to note that this event will trigger for any Plug
and Play-capable device, including but not limited
to USB, Firewire, and PCMCIA devices.
Location: System Log File
Win7/8
%system root%\System32\winevt\logs\
System.evtx
Interpretation:
• Event ID: 20001 – Plug and Play driver install
attempted
• Event ID 20001
• Timestamp
• Device information
• Device serial number
• Status (0 = no errors)
#>

<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# WMI Data
#>
Function Get-USBWMIData {
	[cmdletbinding()]
		Param(
			[Parameter(
			Mandatory=$false,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[array]$ComputerName = $env:COMPUTERNAME
		)
	Write-Host "Fetching USB entries from WMI..."
	$usbQuery = Get-WmiObject -Class Win32_USBControllerDevice -ComputerName $ComputerName
	        $usbData = @()
			$usbreturn = @()
	        # Iterate through each USB path and get the object
	        Foreach ($usbDevice in $usbQuery) {
	            $usbData += [wmi]($usbDevice.Dependent)
				#Write-Verbose $usbData
	            }
			Foreach ($usb in $usbData){
				$usbobj = @{}
				$usbobj.Description	= $($usb.Caption)
				$usbobj.Serial = $($($($usb.DeviceID).Split("\"))[2])
				$usbobj.Location = ""
				$usbobj.HardwareID = $($($usb.HardwareID[1]))
				$usbobj.ClassGUID = $($usb.ClassGuid)
				$usbobj.Manufacturer = $($usb.Manufacturer)
				$usbobj.Connected = $($($usb.Scope).IsConnected)
				$usbobj.Drive = ""
				$usbobj.Installed = ""
				$usbobj.FriendlyName = ""
				
				$usbout = New-Object -TypeName PSObject -Property $usbobj
				$usbreturn += $usbout
			}
	If ($Speak) {Speak-Text "WMI enumeration complete"}
	return $usbreturn
}

Function Get-USBDump {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$ComputerName = $env:COMPUTERNAME,
		
		[switch]$Speak
	)
	<# 
   	.SYNOPSIS 
    	Gathers information about USB devices from various location and 
		aggregates the data.
   	.EXAMPLE
    	Get-USBDump | Out-GridView
	.EXAMPLE	
		Get-USBDUMP | Export-CSV
   	.NOTES 
    	NAME:  Get-USBDump.ps1
    	AUTHOR: paul.brown.sa 
    	LASTEDIT: 11/09/2015 10:43:39 
    	KEYWORDS: 
   	.LINK
    	Http://c0moshack.com 
	#Requires -Version 2.0 
	#> 
	Write-Host "Beginning dump of USB devices..."
	$compilation = @()

	$regdata = Get-USBRegistryEntries -ComputerName $ComputerName
	Write-Progress -Activity "Getting Registry Data" -Completed -Status "Complete"
	$wmidata = Get-USBWMIData -ComputerName $ComputerName
	Write-Progress -Activity "Getting WMI Data" -Completed "Complete"
	$mountdata = Get-USBMountedDevices -ComputerName $ComputerName
	Write-Progress -Activity "Getting Mounted Devices" -Completed "Complete"
	
	$exclusions = @("USB Root Hub","USB Root Hub (xHCI)","USB Input Device","USB Composite Device","USB Audio Device","Generic USB Hub")
	Foreach ($exclusion in $exclusions) {
		$regdata = $regdata | Where-Object {$_.Description -ne $exclusion}
		$wmidata = $wmidata | Where-Object {$_.Description -ne $exclusion}
	}
	
	ForEach ($wmi in $wmidata) {
		$compilation += $wmi
	}

	# Fill in the blanks
	ForEach ($reg in $regdata) {
		If (-not $($compilation -match $reg.Serial)) {
			$compilation += $reg
		}
	}
	$eventlog = Get-EventLog -LogName System -ComputerName $ComputerName
	ForEach ($comp in $compilation) {
	$comp.PsObject.TypeNames.Add('USB.Device')
	$serial = $comp.Serial
	$i++
		If (-not $($comp.Location)) {
			$comp.Location = $($regdata | Where-Object { $_.Serial -like $comp.Serial }).Location
		}
		If ($mountdata -match $($comp.Serial)) {
			$comp.Drive = $($mountdata | Where-Object { $_.DecodedValue -match $($comp.Serial) }).Device
			If (-not $comp.Manufacturer) {
				$comp.Manufacturer = $($mountdata | Where-Object { $_.DecodedValue -match $($comp.Serial) }).Manufacturer
			}
			If (-not $comp.Description) {
				$comp.Description = $($mountdata | Where-Object { $_.DecodedValue -match $($comp.Serial) }).Description
			}
		}
		Try {
			$comp.Installed = $($eventlog | Where-Object {$($_.InstanceID -like "20001") -and $($_.Message -match $($comp.Serial))} | Select -Last 1).TimeWritten
		} Catch {
		}
		
		Write-Progress -Activity "Processing USB Data..." -Status "Percent completed:" -PercentComplete (($i / $compilation.Count) * 100)
	}	
	
	Write-Host "USB dump completed."
	If ($Speak) {Speak-Text "Device enumeration complete"}
	
	return $compilation
}
