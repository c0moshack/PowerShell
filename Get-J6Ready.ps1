# ----------------------------------------------------------------------------- 
# Script: Get-J6Ready.ps1
# Author: paul.brown.sa 
# Date: 11/10/2015 08:51:03 
# Keywords: 
# comments: 
#	ToDo: 
#		- Proxy 55.94.254.200, 55.94.254.
#		- Check TPM
#		- gupdate
#		- Write data to AD
# 	
# 
# -----------------------------------------------------------------------------

#Set-ExecutionPolicy -ExecutionPolicy Bypass
New-PSDrive -Name "Imaging" -PSProvider FileSystem -Root '\\NGWIA7-DISC4-20\Scripts' | Out-Null
Import-Module 'Imaging:\PSWindowsUpdate\PSWindowsUpdate.psm1' | Out-Null
#Import-Module 'Imaging:\ActiveDirectory' | Out-Null
#Import-Module 'Imaging:\TrustedPlatformModule' | Out-Null

###############################################################################
# DO NOT EDIT Above this block
# Author: Dan Stolts - dstolts&&microsoft.com - http://ITProGuru.com 
###############################################################################
function Logit ([string]$TopicName = $env:COMPUTERNAME,  
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
      
     write-host (Get-Date) -ForegroundColor Cyan -NoNewline 
     write-host " - [" -ForegroundColor White -NoNewline 
     write-host $TopicName -ForegroundColor Yellow -NoNewline 
     write-Host "]:: " -ForegroundColor White -NoNewline 
     Write-host $($message) -ForegroundColor $ForeGroundColor 
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
###############################################################################
###############################################################################
# PUT ALL OTHER FUNCTIONS BELOW THIS BLOCK                                    #
# Author: Dan Stolts - dstolts&&microsoft.com - http://ITProGuru.com          #
###############################################################################
###############################################################################

###############################################################################
#  Functions
###############################################################################
#Get program path in case 64bit build
Function Get-J6PFPath {
	If (${env:ProgramFiles(x86)}) {
		$path = ${env:ProgramFiles(x86)}
	} Else {
		$path = $env:ProgramFiles
	}
	
	return $path
}
# Get thumbprint for certificate
Function Get-J6Certs {
	$exportcerts = @()
	$certs = cscript //nologo "$(Get-J6PFPath)\Microsoft Office\Office15\OSPP.VBS" /dtokcerts
	$certs = $certs | Where-Object {$_ -like "Thumbprint*"}
	Foreach ($cert in $certs) {
		$temp = $($cert).Split(":")[1]
		$exportcerts += $temp.Trim()
	}
	return $exportcerts
}
# Check to see if Office is already licensed
Function Get-J6OfficeLicenseStatus {
	$status = $(cscript "$(Get-J6PFPath)\Microsoft Office\Office15\OSPP.VBS" /dstatus)
	IF ($($status -match "LICENSED") -or $($status -match "Product activation successful")) {
		logit -message "Microsoft Office Proffessional Plus 2013 -- $($status -match `"LICENSE STATUS`")" -ForeGroundColor Gray
		return $true
	} Else {
		logit -message "Microsoft Office Proffessional Plus 2013 -- $($status -match `"LICENSE STATUS`")" -ForeGroundColor Yellow
		return $false
	}
}
Function Speak-Text {
	Param(
		[Parameter(Mandatory=$true)]
		[String]$Text
	)
	
    $Voice = new-object -com "SAPI.SpVoice" -strict
    $Voice.Rate = 0                # Valid Range: -10 to 10, slowest to fastest, 0 default.
    $Voice.Volume = 100
	$Voice.Speak($Text) | out-null  # Piped to null to suppress text output.
}
Function Set-SpeakerVolume { 
	Param (
		[switch]$min,
		[switch]$max
	)

 	$wshShell = new-object -com wscript.shell
	If ($min)
		{1..50 | % {$wshShell.SendKeys([char]174)}}
	ElseIf ($max)
		{1..50 | % {$wshShell.SendKeys([char]175)} }
	Else
		{$wshShell.SendKeys([char]173)} 
}
###############################################################################
# Get user input here so the script can proceed without interuptions
###############################################################################
$answer = Read-Host "Would you like to install Windows Updates?" 
$pin = Read-Host "Enter PIN for Office activation" -AsSecureString
$thumbprints = Get-J6Certs
#CLS
###############################################################################
# End user input block ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
###############################################################################
#Ensure sound is up
Set-SpeakerVolume -max
###############################################################################
#  Product Activation
###############################################################################
$activationStatus = Invoke-Expression "slmgr.vbs /dlv"
If ($activationStatus -notcontains "License Status: Licensed") {
	# Activate Windows
	logit -message "Activating Windows"
	Invoke-Expression "slmgr.vbs /ato" | Out-Null
	$activationStatus = Invoke-Expression "slmgr.vbs /dlv" 
	logit -message "Windows Activated"
} Else {
	logit -message "Windows already activated" -ForeGroundColor Gray
}
# Print the license details 
logit -message $($activationStatus | Where-Object {$_ -match "Trusted time:"}) -ForeGroundColor Gray

# Activate Microsoft Office Professional Plus 2013
If ($(Test-Path "$(Get-J6PFPath)\Microsoft Office\Office15" -ErrorAction SilentlyContinue)) {
	IF ($(Get-J6OfficeLicenseStatus) -eq $false) {
		logit -message "Activating Microsoft Office 2013..." 
		#Foreach ($thumbprint in $thumbprints) {
			#Write-Host "cscript //nologo $(Get-J6PFPath)\Microsoft Office\Office15\OSPP.VBS /tokact`:$($thumbprints[0])`:$pin"
			cscript //nologo "$(Get-J6PFPath)\Microsoft Office\Office15\OSPP.VBS" /tokact`:$($thumbprints[0])`:$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pin))) #| Out-Null
			If (Get-J6OfficeLicenseStatus) {	
				logit -message "Microsoft Office 2013 activated."
		#		break
			} Else {
				logit -message "Microsoft Office 2013 activation failed" -ForeGroundColor Red
			}
		#}
	} Else {
		logit -message "Microsoft Office 2013 is already activated." -ForeGroundColor Gray
		
	}
} Else {
	logit -message	"Microsoft Office 2013 was not found at $path\Microsoft Office\Office15" -ForeGroundColor Red
}

Speak-Text "You may now remove your Common Access Card. Script execution will continue."
###############################################################################
# GPUPDATE 
###############################################################################
#$gpupdate = gpupdate /force | Out-Null
#logit -message "Group Policy Updated"

	
###############################################################################
# Update attributes in AD 
###############################################################################
#Try {
#	$serial = $(Get-WmiObject Win32_BIOS).SerialNumber
#	Set-ADComputer -Replace @{"serialNumber"=$serial}
#	If (Get-Item HKLM:\SOFTWARE\AGMProgram\NGWIVersion) {
#		$ngwi = Get-Item HKLM:\SOFTWARE\AGMProgram\NGWIVersion
#	} Else {
#		$ngwi = "Not Set"
#	}
#	Set-ADComputer -Replace @{"serialNumber"=$serial}
#	Set-ADComputer -Replace @{"versionNumber"=$ngwi}
#	logit -message "Active Directory attributes updated"
#} Catch {
#	logit -message "Active Directory attributes not updated" -ForeGroundColor Red
#}

###############################################################################
# Ensure that the proper registry keys are set
###############################################################################

#Enable administrative shares
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
$Names = "AutoShareServer", "AutoShareWks"
$value = "1"

Foreach ($Name in $Names) {
	IF(-not $(Get-ItemProperty -Path $registryPath -Name "AutoShareServer" -ErrorAction SilentlyContinue)) {
		logit -message "Enabling admin shares..."
		New-Item -Path $registryPath -Force | Out-Null
	    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
		logit -message "Admin shares enabled."
	} ELSE {
	    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
	}
}
	
# Set/Verify portal is set to Start Page
$ngwihomepage = 'https://ngwi-guard.ng.ds.army.mil/Pages/default.aspx'
$iehomepagepath = 'HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main\'
$iehomepagename = 'Start Page'
If ($(Get-ItemProperty -Path $iehomepagepath -Name $iehomepagename -ErrorAction SilentlyContinue).$iehomepagename -ne $ngwihomepage) {
	logit -message "Setting Start Page to Portal address..."
	Set-ItemProperty -Path $iehomepagepath -Name $iehomepagename -Value $ngwihomepage
	logit -message "IE home page set to $ngwihomepage."
} Else {
	logit -message "IE home page already set to $ngwihomepage." -ForeGroundColor Gray
}

# Reset legal notice
If (-not $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -ErrorAction SilentlyContinue)) {
	# Create the Key
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" -Force  | Out-Null
	# Add the Value
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" `
	-Value 'US DEPARTMENT OF DEFENSE WARNING STATEMENT' | Out-Null
}

If (-not $(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -ErrorAction SilentlyContinue)) {
	# Create the Key
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" -Force  | Out-Null
	# Add the Value
	New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticetext" `
	-Value 'You are accessing a U.S. Government (USG) Information System (IS) that is
	provided for USG-authorized use only.  By using this IS (which includes any
	device attached to this IS), you consent to the following conditions:
	-The USG routinely intercepts and monitors communications on this IS for
	purposes including, but not limited to, penetration testing, COMSEC monitoring,
	network operations and defense, personnel misconduct (PM), law enforcement
	(LE), and counterintelligence (CI) investigations.
	-At any time, the USG may inspect and seize data stored on this IS.
	-Communications using, or data stored on, this IS are not private, are subject to
	routine monitoring, interception, and search, and may be disclosed or used for
	any USG-authorized purpose.
	-This IS includes security measures (e.g., authentication and access controls) to
	protect USG interests--not for your personal benefit or privacy.
	-Notwithstanding the above, using this IS does not constitute consent to PM, LE
	or CI investigative searching or monitoring of the content of privileged
	communications, or work product, related to personal representation or services
	by attorneys, psychotherapists, or clergy, and their assistants. Such
	communications and work product are private and confidential. See User
	Agreement for details.' | Out-Null
}

###############################################################################
# Get TPM Status	
###############################################################################
#$tpmStatus = Get-TPM
#If ($($tpmStatus.TpmReady) -eq "TPM True") {
#	logit -message "TPM ready!" -ForeGroundColor Green
#} Else {
#	logit -message "TPM not ready" -ForeGroundColor Red
#}

###############################################################################
# Windows Updates
###############################################################################

If ($answer -eq "yes" -or $answer -eq "y") {
	# Install Windows Updates
	logit -message "Installing Windows updates.."
	Get-WUInstall -AcceptAll -NotCategory "Language packs" -IgnoreReboot | Out-Null
	logit -message "Windows updates complete."
} Else {
	logit -message "Windows updates were not installed." -ForeGroundColor red
}

###############################################################################
#  End Script
###############################################################################
logit -message "SCRIPT EXECUTION COMPLETE"
Speak-Text "script execution complete"