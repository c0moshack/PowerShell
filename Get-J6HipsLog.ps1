# ----------------------------------------------------------------------------- 
# Script: Get-J6HipsLog.ps1
# Author: Paul Brown
# Date: 03/06/2017 08:48:01 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-J6HipsLog {
    <#
    .SYNOPSIS
	    Gathers HIPS log data and saves it to the specified destination.
    .EXAMPLE
        Get-J6HipsLog
    .EXAMPLE
	    Get-J6HipsLog -ComputerName <name> -Destination <path> -Path <HIPS Log Directory>
    .PARAMETER  
	    ComputerName
    .PARAMETER
        Destination
    .PARAMETER
        Path
    .NOTES
	    NAME: Get-J6HipsLog.ps1
	    AUTHOR: paul.brown.sa 
	    LASTEDIT: 03/06/2017 08:48:01 
	    KEYWORDS: 
    .LINK
	    https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
    #Requires -Version 2.0 
    #>


	[CmdletBinding()]
    
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$ComputerName = $env:COMPUTERNAME,

          [Parameter(
        Mandatory=$false,
        Position=1)]
        [string]$Destination = "$env:USERPROFILE\Desktop" ,

        [Parameter(
        Mandatory=$false,
        Position=1)]
        [string]$HIPSLogPath = "\\$ComputerName\C$\ProgramData\McAfee\Host Intrusion Prevention",

        [Parameter(
        Mandatory=$false,
        Position=1)]
        [string]$FirewallLogPath = "\\$ComputerName\C$\Windows\System32\LogFiles\Firewall\domainfirewall.log"

	)

    begin {}
	

    process {
    
        If ( Test-Connection -BufferSize 16 -Count 1 -Quiet -ErrorAction SilentlyContinue $ComputerName ) {
            If ( Test-Path -Path $HIPSLogPath) {
                New-Item -ItemType Directory -Path $Destination -Name "$($ComputerName)_HIPSLog_$(Get-Date -Format 'MMddyyyy-HHmm')"  | Out-Null
                Copy-Item -Path "$HIPSLogPath\*.log" -Destination "$Destination\$($ComputerName)_HIPSLog_$(Get-Date -Format 'MMddyyyy-HHmm')"
                Copy-Item -Path "$FirewallLogPath" -Destination "$Destination\$($ComputerName)_HIPSLog_$(Get-Date -Format 'MMddyyyy-HHmm')"
                #Compress-Archive -Path "$Path\*.log" -DestinationPath $OutFile
            } Else {
                Write-Error " Unable to reach $HIPSLogPath"
            }
        } Else {
            Write-Error "$ComputerName is not online"
        }
    }
    

    end {}
    

}