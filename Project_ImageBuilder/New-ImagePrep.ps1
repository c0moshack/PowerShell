# ----------------------------------------------------------------------------- 
# Script: New-ImagePrep.ps1
# Author: Paul Brown
# Date: 01/28/2016 07:31:21 
# Keywords: 
# comments: 
# To Do: 
#	- Correct NGWI Version when inserting into registry
# -----------------------------------------------------------------------------

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

Function Get-JulianDate {
<#
	.SYNOPSIS
		Calculate the julian date

	.DESCRIPTION
		Get-JulianDate allows you calculate the current or past julian date.
		
	.EXAMPLE
		Get-JulianDate -Date "mm/dd/yy"
	
	.EXAMPLE
		Get-JulianDate -Date $(Get-Date)
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
   		[DateTime]$Date = $(Get-Date)
	)
	
	# Do the math for the given year, not just the current year
	$yy = $Date.Year
	# Add 1 to get the correct output
	$offset = $(Get-Date 1/1/$yy).AddDays(-1)
	# Calculate the span
	$jday = $Date - $offset
		
	return $($jday.Days).ToString("000")
}


Function New-ImagePrep {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$ngwiversion 
	)
	
	# Get the TS variables
	$tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment
	$ScriptRoot = $tsenv.Value("ScriptRoot")
	$ngwiversion = $tsenv.Value("NGWI")
	
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: New-ImagePrep.ps1 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 01/28/2016 07:31:21 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#> 
	
	
	# Load the necessary drives and modules
#	New-PSDrive -Name "Apps" -PSProvider Filesystem -Root '\\NGWIA7-DISC4-14\disc4_j6$\Managed Applications' | Out-Null
#	Logit -TopicName "PSDrive" -Message "Loaded::Apps"
#	New-PSDrive -Name "Source" -PSProvider Filesystem -Root '\\ngwib7-disc4-04\SCCM_Source'	| Out-Null
#	Logit -TopicName "PSDrive" -Message "Loaded::Source"
#	New-PSDrive -Name "Imaging" -PSProvider FileSystem -Root '\\NGWIA7-DISC4-20\Scripts' | Out-Null
#	Logit -TopicName "PSDrive" -Message "Loaded::Scripts"
	
		# Load the custom scripts
#	$scriptPath = "$ScriptRoot\CustomScripts\ImageBuilder"
#	$scriptfiles = Get-ChildItem $scriptpath | Where-Object {$_.Extension -like "*.ps1"} | Where-Object {$_.Name -notmatch "New-ImagePrep"}
#	Foreach ($file in $scriptfiles) {
#		. $file.FullName
#		Logit -TopicName "Loading Scripts" -Message "Loaded::$($file.FullName)"
#	}

#	Import-Module 'Imaging:\PSWindowsUpdate\PSWindowsUpdate.psm1' | Out-Null
#	Logit -TopicName "Import Module" -Message "Loaded::PSWindowsUpdate.psm1"
#	Import-Module 'TrustedPlatformModule' | Out-Null
#	Logit -TopicName "Import Module" -Message "Loaded::TrustedPlatformModule"

	############################################################################
	#  Software / Locations	 				@{'Name'='';'Path'='';'Version'=''}
	############################################################################
	#User Software
	$usersoftware = @(
		@{'Name'='Java';'Path'='';'Version'=''}
		@{'Name'='Adobe Pro';'Path'='';'Version'=''}
		@{'Name'='Adobe Flash';'Path'='';'Version'=''}
		@{'Name'='MS Office';'Path'='';'Version'=''}
		@{'Name'='NetBanner';'Path'='';'Version'=''}
		@{'Name'='EMET';'Path'='';'Version'=''}
		@{'Name'='Active Client';'Path'='';'Version'=''}
		@{'Name'='MS Outlook Add-In';'Path'='';'Version'=''}
		@{'Name'='Tumbleweed';'Path'='';'Version'=''}
		@{'Name'='IBM Lotus Forms';'Path'='';'Version'=''}
		@{'Name'='DB Sign';'Path'='';'Version'=''}
		@{'Name'='Silverlight';'Path'='';'Version'=''}
		@{'Name'='McAfee';'Path'='';'Version'=''}
		@{'Name'='Cisco VPN Client';'Path'='';'Version'=''}
		@{'Name'='Connection Monitor';'Path'='';'Version'=''}
		@{'Name'='dotNet 4';'Path'='';'Version'=''}
		@{'Name'='Netcom Logon Banner';'Path'='';'Version'=''}
		@{'Name'='Netcom Logoff Banner';'Path'='';'Version'=''}
	)
	# Admin Software
	$adminsoftware = @(
		@{'Name'='dameware';'Path'='';'Version'=''}
		@{'Name'='admintools';'Path'='';'Version'=''}
		
	)
	############################################################################
	#  Registy Keys
	############################################################################
	$registrykeys = @(
		@{'Name'='AutoShareWks';'Path'='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters';'Value'='1'}
		@{'Name'='AutoShareServer';'Path'='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters';'Value'='1'}
		@{'Name'='Start Page';'Path'='HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main\';'Value'='https://ngwi-guard.ng.ds.army.mil/Pages/default.aspx'}
		@{'Name'='legalnoticecaption';'Path'='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';'Value'='US DEPARTMENT OF DEFENSE WARNING STATEMENT'}
		@{'Name'='legalnoticetext';'Path'='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System';'Value'='
			You are accessing a U.S. Government (USG) Information System (IS) that is
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
			Agreement for details.'}
		@{'Name'='NGWIImageVersion';'Path'='HKLM:\SOFTWARE\AGMProgram\Build';'Value'=$ngwiversion}
		@{'Name'='EnableNegotiate';'Path'='HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings';'Value'='0'}
		@{'Name'='VPNExceptionsList';'Path'='HKLM:\SOFTWARE\Policies\Microsoft\ConnectionMonitor';'Value'='Cisco Systems VPN Adapter'}
		@{'Name'='VPNExceptionsList64';'Path'='HKLM:\SOFTWARE\Policies\Microsoft\ConnectionMonitor';'Value'='Cisco Systems VPN Adapter for 64-bit Windows'}
		@{'Name'='EnableJavaUpdate';'Path'='HKLM:\SOFTWARE\JavaSoft\Java Update\Policy';'Value'='0'}
	)
	############################################################################
	#  Convert Software and Registry information into an object for manipulation
	############################################################################
	# User Software Object
	$usersoftwareobject = @()
	Foreach ($item in $usersoftware) {
		$item = New-Object -TypeName PSObject -Property $item
		$usersoftwareobject += $item
	}
	# Admin Software Object
	$adminsoftwareobject = @()
	Foreach ($item in $adminsoftware) {
		$item = New-Object -TypeName PSObject -Property $item
		$adminsoftwareobject += $item
	}
	# Registry Object
	$registryobject = @()
	Foreach ($item in $registrykeys) {
		$item = New-Object -TypeName PSObject -Property $item
		$registryobject += $item
	}
	############################################################################
	#  Begin Preparation
	############################################################################
	#Run Windows Updates first
	# Install Windows Updates
#	logit -message "Installing Windows updates.."
	#Get-WUInstall -AcceptAll -NotCategory "Language packs" -IgnoreReboot | Out-Null
#	logit -message "Windows updates complete."
	
	############################################################################
	# Ensure that the proper registry keys are set
	############################################################################
	Foreach ($item in $registryobject) {
		Try {
			# If registry key does not exist create it
			If(-not $(Get-ItemProperty -Path $item.Path -Name $item.Name -ErrorAction SilentlyContinue)) {
				New-Item -Path $item.Path -Force | Out-Null
			    New-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Force | Out-Null
				#logit -TopicName 'Registy' -message "Added $($item.Path)\$($item.Name) with value $($item.Value)"
			} ELSE {
			    New-ItemProperty -Path $item.Path -Name $item.Name -Value $item.Value -Force | Out-Null
				#logit -TopicName 'Registy' -message "Updated $($item.Path)\$($item.Name) with value $($item.Value)"
			}
		} Catch{
			Write-Error $_.Exception.Message
		}
	} 
	############################################################################
	# Install User Software
	############################################################################
	
	############################################################################
	# Install Admin Software
	############################################################################
	
	############################################################################
	# Get TPM Status	
	############################################################################
#	$tpmStatus = Get-TPM
#	If ($($tpmStatus.TpmReady) -eq "TPM True") {
#		logit -message "TPM ready!" -ForeGroundColor Green
#	} Else {
#		logit -message "TPM not ready" -ForeGroundColor Red
#	}
		
} # End New-ImagePrep

New-ImagePrep