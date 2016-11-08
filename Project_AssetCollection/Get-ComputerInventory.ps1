<#   
	================================================================================ 
	========= LogIt.ps1 ======================================= 
	================================================================================ 
	 Name: LogIt 
	 Purpose: Demonstrate how create and work with Log files using PowerShell 
	 Author: Dan Stolts - dstolts&&microsoft.com - http://ITProGuru.com 
	 Syntax/Execution: Copy portion of script you want to use and paste into PowerShell (or ISE)  
	 Description: Shows how to create log files and create function to log information to screen and text file 
	                 Includes ability so set colors and other features 
	 Disclaimer: Use at your own Risk!  See details at http://ITProGuru.com/privacy  
	 Limitations:  
	         * Must Run PowerShell (or ISE)  
	        * UAC may get in the way depending on your settings (See: http://ITProGuru.com/PS-UAC) 
	# video of Script https://channel9.msdn.com/Series/GuruPowerShell 
	# More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts 
	 ================================================================================ 
	#> 
	#$LogFilePath = Get-Location 
	#$LogFileName = "ITProGuru-LogIt.log"  
	#$myLog= "$LogFilePath\$LogFileName" 
	 
	 
	function Logit ([string]$TopicName,  
	 [string]$message,  
	 [string]$ForeGroundColor="Green",  
	 [switch]$LogToFile,  
	 [string]$LogToFileName="PSLog.log") 
	 
	    {# Function for displaying formatted log messages and optionally writing them out to a text log file 
	        #TopicName      : Classification or short subject of message 
	        #message        : Message to log 
	        #ForeGroundColor: Identifies the color of the $message  [default =Green] 
	        #LogToFile      : Boolean Write log to file [default = $false] 
	        #LogToFileName  : File to create if writing to file [default ="PSLog.log"] 
	      
#	     write-host (Get-Date).ToShortTimeString() -ForegroundColor Cyan -NoNewline 
#	     write-host " - [" -ForegroundColor White -NoNewline 
#	     write-host $TopicName -ForegroundColor Yellow -NoNewline 
#	     write-Host "]:: " -ForegroundColor White -NoNewline 
#	     Write-host $($message) -ForegroundColor $ForeGroundColor 
		 
		 Write-Host "$((Get-Date).ToShortTimeString()) - [$TopicName]::$($message)" -ForegroundColor Black
		 
	     If ($LogToFile) { 
	         If ($LogToFileName -Like "PSLog.log") {}  # standard logfile being used; do we want to do anything??? }    
	            If (Test-Path $LogToFileName)  #Test to see if the log file already exists 
	            { 
	                # Log File already exists... We will just append to existing file 
	                Write-Host (Get-Date).ToString() " Opening Log " $LogToFileName -ForegroundColor Green  # REMOVE/REMARK 
	                (Get-Date).ToShortTimeString() + " - [" + $TopicName + "]::" + $message |Out-File $LogToFileName -Append 
	            } 
	            Else   { 
	                # Create the log file   # Need to add some error checking here!!! 
	                Write-Host (Get-Date).ToString() " Creating Log " $LogToFileName -ForegroundColor Green   
	                (Get-Date).ToShortTimeString() + " - [" + $TopicName + "]::" + $message |Out-File $LogToFileName -Append 
	            } 
	        } 
	   } 
	  
	  #Examples:  
	#  logit (HostName) "Write this to screen"  
	#  logit "Subject" "Write to My Log File!" -ForeGroundColor Red -LogToFile -LogToFileName $MyLog 
	#  logit (HostName) "Write to default Log File!" -ForeGroundColor Red -LogToFile 
	 
	 
	# video of Script https://channel9.msdn.com/Series/GuruPowerShell  
	# More scripts from Dan Stolts "ITProGuru" at http://ITProGuru.com/Scripts

	###############################################################################
	#  
	###############################################################################

	# ----------------------------------------------------------------------------- 
	# Script: Add-Objects.ps1
	# Author: paul.brown.sa 
	# Date: 11/19/2015 10:58:32 
	# Keywords: 
	# comments: 
	# 
	# -----------------------------------------------------------------------------

	Function Add-Objects {
		<# 
		.Synopsis 
			Add-Objects allows you to add the Note Properties from one object 
			to another object. The objects both must be passed to the function 
			along with the name of the property to be used as the primary key. 
			Both property names can be passed if the do not match.
		.Example 
			Add-Objects -BaseObject <object> -BaseField <field> -InputObject <object>
		.Example
			Add-Objects -BaseObject <object> -BaseField <field> -InputObject <object> -InField <field>
		.Parameter  BaseObject
			The object to be added to
		.Parameter BaseField 
			The key to compare
		.Parameter InputObject 
			The object to get the new data from
		.Parameter InField
			The key if different than the base object
		.Notes 
			NAME: Add-Objects.ps1 
			AUTHOR: paul.brown.sa 
			LASTEDIT: 11/19/2015 10:58:52 
			KEYWORDS: 
		.Link 
			http://c0moshack.com 
		#Requires -Version 2.0 
		#>
		[cmdletbinding()]
		Param( 
			[Parameter(Mandatory=$true)]
			[PSObject]$BaseObject,
			
			[Parameter(Mandatory=$true)]
			[PSObject]$BaseField,
			
			[Parameter(Mandatory=$false)]
			[PSObject]$InField,
			
			[Parameter(Mandatory=$true)]
			[PSObject]$InputObject
		)
		# If no InField is supplied set it to the basefield 
		If (-not $InField ) {
			$InField = $BaseField 
		}
		
		# Get the list of all object members not including shell variables
		$membertypes = $($InputObject | Get-Member | Where-Object {$_.MemberType -match 'NoteProperty'}) | Select-Object Name
		
		# Add each of the new members to the existing object
		Foreach ($membertype in $membertypes) {
			$type = $membertype.Name
			$BaseObject | Add-Member -MemberType NoteProperty -Name $type  -Value $null -ErrorAction SilentlyContinue
		}

		# Iterate through the new object and add its attributes to the existing object
		Foreach ($object in $InputObject) {
			# Variables to hold the values for validatio and debugging-
			$holding1 = $object.$InField
			$holding2 = $BaseObject.$BaseField
			# Make sure there is a value in the filed being validated
			If ($holding1) {
				$item = $BaseObject | Where-Object {$_.$BaseField -match $holding1}
				# Do not bother processing if there is not a match
				If ($item) {
					# Add the new attributes to the current item
					Foreach ($membertype in $membertypes) {
						# Do not overwrite the attribute  being used as the key
						If (-not $($membertype.Name -eq $BaseField)) {
							Try {
								$item.$($membertype.Name) = $object.$($membertype.Name)
							} Catch {
							}
						}
					}
				}
			}
		}
		
		return $BaseObject
	}

	###############################################################################
	#  
	###############################################################################

	Function Get-DellWarranty {
		[cmdletbinding()]
		Param(
			[Parameter(
			 Mandatory=$true,
			 Position=0,
			 ValueFromPipeline=$true,
		   	 ValueFromPipelineByPropertyName=$true)]
			[array]$ServiceTag,
			[Parameter(
			 Mandatory=$false,
			 Position=1)]
			[string]$EntitlementType = "EXTENDED",
			[Parameter(
			 Mandatory=$false,
			 Position=2)]
			[string]$APIKey = "d676cf6e1e0ceb8fd14e8cb69acd812d"
		)
			
	# 	Possible API keys
	# 	1adecee8a60444738f280aad1cd87d0e
	# 	d676cf6e1e0ceb8fd14e8cb69acd812d
	# 	849e027f476027a394edd656eaef4842
		Try {
			$WarrantyCollection = @()
			Foreach ($Tag in $ServiceTag) {
				$AssetProps = @{}
				$DellURL = "https://api.dell.com/support/v2/assetinfo/warranty/tags.xml?apikey=$APIKey&svctags=$Tag"
				$DellAPIResponse = Invoke-RestMethod $DellURL
				$DellAsset = $DellAPIResponse.GetAssetWarrantyResponse.GetAssetWarrantyResult.Response.DellAsset
				$Warranties = $DellAsset.Warranties.Warranty | Where-Object {$_.EntitlementType -eq $EntitlementType}
				
				$AssetProps.ServiceTag = $DellAsset.ServiceTag
				$AssetProps.CustomerNumber = $DellAsset.CustomerNumber
				$AssetProps.Description = $DellAsset.MachineDescription
				$AssetProps.ShipDate = $DellAsset.ShipDate
				$AssetProps.OrderNumber = $DellAsset.OrderNumber
				$AssetProps.EntitlementType = $Warranties.EntitlementType
				$AssetProps.StartDate = $Warranties.StartDate
				$AssetProps.EndDate = $Warranties.EndDate
				$AssetProps.ServiceLevelDescription = $Warranties.ServiceLevelDescription
				
				$Asset = New-Object -TypeName PSObject -Property $AssetProps
				$WarrantyCollection += $Asset
			}
		} Catch {
			
		}
		Return $WarrantyCollection
	}

	###############################################################################
	#  
	###############################################################################

	Function Get-LoggedOnUser {
		Param(
			[Parameter(Mandatory=$false)]
			[string]$computername = $env:COMPUTERNAME
		) 
	 
		#mjolinor 3/17/10 
		 
		$regexa = '.+Domain="(.+)",Name="(.+)"$' 
		$regexd = '.+LogonId="(\d+)"$' 
		 
		$logontype = @{ 
		"0"="Local System" 
		"2"="Interactive" #(Local logon) 
		"3"="Network" # (Remote logon) 
		"4"="Batch" # (Scheduled task) 
		"5"="Service" # (Service account logon) 
		"7"="Unlock" #(Screen saver) 
		"8"="NetworkCleartext" # (Cleartext network logon) 
		"9"="NewCredentials" #(RunAs using alternate credentials) 
		"10"="RemoteInteractive" #(RDP\TS\RemoteAssistance) 
		"11"="CachedInteractive" #(Local w\cached credentials) 
		} 
		 
		$logon_sessions = @(gwmi win32_logonsession -ComputerName $ComputerName -ErrorAction SilentlyContinue) 
		$logon_users = @(gwmi win32_loggedonuser -ComputerName $ComputerName -ErrorAction SilentlyContinue) 
		 
		$session_user = @{} 
		 
		$logon_users |% { 
		$_.antecedent -match $regexa > $nul 
		$username = $matches[1] + "\" + $matches[2] 
		$_.dependent -match $regexd > $nul 
		$session = $matches[1] 
		$session_user[$session] += $username 
		} 
		 
		 
		$logon_sessions |%{ 
		$starttime = [management.managementdatetimeconverter]::todatetime($_.starttime) 
		 
		$loggedonuser = New-Object -TypeName psobject 
		$loggedonuser | Add-Member -MemberType NoteProperty -Name "Session" -Value $_.logonid 
		$loggedonuser | Add-Member -MemberType NoteProperty -Name "User" -Value $session_user[$_.logonid] 
		$loggedonuser | Add-Member -MemberType NoteProperty -Name "Type" -Value $logontype[$_.logontype.tostring()] 
		$loggedonuser | Add-Member -MemberType NoteProperty -Name "Auth" -Value $_.authenticationpackage 
		$loggedonuser | Add-Member -MemberType NoteProperty -Name "StartTime" -Value $starttime 
		 
		$loggedonuser 
		} 
		 
	}

	###############################################################################
	#  
	###############################################################################

	Function Get-RegistryData {
		[cmdletbinding()]
		Param(
			[Parameter(
			Mandatory=$true,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[array]$ComputerName,
			
			[Parameter(
			Mandatory=$true,
			Position=1,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false)]
			[string]$Hive,
			
			[Parameter(
			Mandatory=$true,
			Position=2,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false)]
			[string]$Path,
			
			[Parameter(
			Mandatory=$true,
			Position=3,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false)]
			[string]$Key
		)
		
		<# 
		.Synopsis 
			Get the value of local or network computer registry keys
		.Example 
			Get-RegistryData -ComputerName $comp.Name -Hive "LocalMachine" -Path "Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs" -Key "MRUListEx"
		.Notes 
			NAME: Get-J6RegistryData.ps1 
			AUTHOR: Paul Brown
			LASTEDIT: 01/26/2016 13:11:13
			KEYWORDS: 
		.Link 
			https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
		#Requires -Version 2.0 
		#> 
		
		Try {
			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
			$subkey = $reg.OpenSubKey($Path)
			$keyvalue = $subkey.GetValue($Key)
		} Catch {
			# Just here to suppress errors
		}
		
		return $keyvalue

	}

	###############################################################################
	#  
	###############################################################################

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

	###############################################################################
	#  
	###############################################################################

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

	###############################################################################
	#  
	###############################################################################


	# Load the function into the session
	Function Get-J6Assets {
		[cmdletbinding()]
		Param(
			[Parameter(
			Mandatory=$true,
			Position=0,
			ValueFromPipeline=$true,
			ValueFromPipelineByPropertyName=$true)]
			[string]$SearchBase,
			
			[Parameter(
			Mandatory=$false,
			Position=1,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false)]
			[string]$CSV,
			
			[Parameter(
			Mandatory=$false,
			Position=2,
			ValueFromPipeline=$false,
			ValueFromPipelineByPropertyName=$false)]
			[string]$CSVKey
		)
	################################################################################
		# Make sure the ActiveDirectory module is loaded
		If (-not $(Get-Module ActiveDirectory)) {
			Import-Module ActiveDirectory
		}

		# Load the custom scripts
		#$collectorroot = $(Split-Path $script:MyInvocation.MyCommand.Path)
		#$collectorfiles = Get-ChildItem $collectorroot | Where-Object {$_.Extension -like "*.ps1"} | Where-Object {$_.Name -notmatch "Get-J6Assets"}
		#Foreach ($file in $collectorfiles) {
		#	. $file.FullName
		#	logit -TopicName "Loading Scripts" -message "Loaded::$($file.FullName)"
		#}
	################################################################################
				
		# Get ActiveDirectory Information
		$computers = Get-J6AdComputers -SearchBase $searchbase
		$adassets = Get-J6ADComputersAttributes -ComputerList $computers 
		$wmidata = Get-J6WMIData -ComputerList $($adassets | Select Name) 
		# Merge AD and WMI data into a single object
		$new = Add-Objects -BaseObject $adassets -BaseField "Name" -InField "Name" -InputObject $wmidata
				
		# Merge data with additonal data from CSV
		$pbuse = Import-Csv $CSV
		$newer = Add-Objects -BaseObject $new -BaseField 'Serial' -InField $CSVKey -InputObject $pbuse 
		
		$warranty = @()
		Foreach ($item in $newer) {
			If ($($item.Serial)) {
				$warranty += Get-DellWarranty -ServiceTag $item.Serial
			} Else {
			
			}
		}
		#$warranty = $newer |  %{Get-DellWarranty -ServiceTag $_.Serial} -ErrorAction SilentlyContinue
		$newest = Add-Objects -BaseObject $newer -BaseField 'Serial' -InField 'ServiceTag' -InputObject $warranty
		
		logit -TopicName "General" -message "Data collection is complete."
		
		return $newest
	} # END Function Get-J6Assets
