# -----------------------------------------------------------------------------
# Script: ShowUSBDevices.ps1
# Author: Paul J. Brown WIARNG WO1
# Date: 05/05/2015
# Keywords: 
# comments: 
#
# -----------------------------------------------------------------------------

Function Get-USBDevices{
<#
.DESCRIPTION
    Create a detailed report of all USB devices connected to the system

.EXAMPLE
    Query a single host
    ./Get-USBDevices.ps1 -Extension "csv" -ComputerName "<hostname>"

.EXAMPLE
     Query a multiple hosts
    ./Get-USBDevices.ps1 -Extension "csv" -ComputerName "<C:\path\filename.txt>"

.EXAMPLE
     Query all hosts found in Active Directory
    ./Get-USBDevices.ps1 -Extension "csv" -ComputerName "ad"

#>

Param(
    [Parameter(Mandatory=$True)]
    [string]$Extension,

    [Parameter(Mandatory=$True)]
    [string]$ComputerName
    )

If (!(Test-Path "$env:USERPROFILE\Desktop\USB_SCAN_REPORTS")) {
    New-Item -ItemType "directory" -Name "USB_SCAN_REPORTS" -Path "$env:USERPROFILE\Desktop"
    }

# Check if path is set
If ($Extension.Length -lt 1) {
    $Extension = "txt"
    }

# Check if target is set
If ($ComputerName.Length -lt 1) {
        $ComputerName = 'localhost'
    } elseIf ($ComputerName.ToLower() -eq "ad") {
        Import-Module ActiveDirectory
        $ComputerName = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
    } elseIf (Test-Path $ComputerName) {
        $ComputerName = Get-Content $ComputerName
    }
    
foreach ($uhost in $ComputerName) {
        
        # Query the system for all USB devices
        #Write-Host "Querying $uhost"
        
        $usbQuery = Get-WmiObject -Class Win32_USBControllerDevice -ComputerName $uhost
        $usbData = @()
        
        # Iterate through each USB path and get the object
        foreach ($usbDevice in $usbQuery) {
            $usbData += [wmi]($usbDevice.Dependent)
			#Write-Verbose $usbData
            }
            
                   
        #Get eventlog data
        # Uncomment the lines below to activate this portion
        
        Write-Host "Getting USB events from $uhost"
        Get-EventLog System -ComputerName $uhost | Where-Object {$_.InstanceID -like "2000*"} | Format-Table -Property * -AutoSize | Out-String -Width 4096 | Out-File "$env:USERPROFILE\Desktop\USB_SCAN_REPORTS\$uhost-USBEventlog.txt"
        
        # Set report name
            $usbReport = "$env:USERPROFILE\Desktop\USB_SCAN_REPORTS\$uhost-USBDevices.$Extension"
            
        # Output the correct report type
        Switch ($Extension) {
            "txt" {
                # Output formatted text file
                $usbData | Sort-Object Manufacturer,Name,DeviceID | Format-Table -GroupBy Manufacturer Name,Service,DeviceID | Out-File $usbReport
                }
            "csv" {
                # Output csv file
                $usbData | Select-Object Manufacturer,Name,DeviceID | ConvertTo-Csv -NoTypeInformation | Out-File $usbReport
                }
            }
            
        Write-Host "Processing complete for $uhost"

        }
}        
