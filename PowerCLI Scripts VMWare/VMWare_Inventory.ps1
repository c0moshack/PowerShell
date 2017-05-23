$Excel = New-Object -ComObject "Excel.Application" 
$XLSXDoc = "Path of Excel File.xlsx" 
$SheetName = "Sheet1" 
$Workbook = $Excel.workbooks.open($XLSXDoc) 
$Sheet = $Workbook.Worksheets.Item($SheetName) 
$WriteData = $Excel.WorkSheets.Item($SheetName) 
$RowCount = ($Sheet.usedRange.rows).count 
$Excel.Visible = $true 
$RowCount 
#Connecting to ESX Server  
#Connect-VIServer "Vcenter-ServerName" 
$VirtualMachineNames = Get-VM | Select Name 
$VirtualMachineNames = $VirtualMachineNames.Name 
$VirtualMachineNames = [string[]]$VirtualMachineNames 
$VirtualMachineCount = $VirtualMachineNames.Count -1 
$Row = 2 
For ($J=0; $J -le $VirtualMachineCount; $J++) 
{ 
#$VirtualMachineName = $Sheet.Cells.Item("$Row",1).Text 
#$VirtualMachineName 
$VirtualMachineName = $VirtualMachineNames[$J] 
$VMPowerState = Get-VM $VirtualMachineName | select PowerState 
$VMPowerState = $VmPowerState.PowerState 
$CPUCount = Get-VM $VirtualMachineName | select NumCpu 
$CPUCount = $CPUCount.NumCpu 
$RAMAssigned = Get-VM $VirtualMachineName | select MemoryGB 
$RAMAssigned = $RAMAssigned.MemoryGB 
$VMHost = Get-VM $VirtualMachineName | select Host 
$VMHost = $VMHost.Host 
$VMDataStore = Get-Datastore -VM $VirtualMachineName | select Name 
$VMDataStore = $VMDataStore.Name 
$VMDataStore = [string[]]$VMDataStore 
$vmview = Get-VM $VirtualMachineName | Get-View 
$ProvisionedSpace = (($vmview.Storage.PerDatastoreUsage.Committed+$vmview.Storage.PerDatastoreUsage.Uncommitted)/1024/1024/1024) 
$vmview.Storage.PerDatastoreUsage.Committed.gettype() 
$UsedSpace = ($vmview.Storage.PerDatastoreUsage.Committed/1024/1024/1024) 
$UsedSpace = "{0:N2}" -f ($vmview.Storage.PerDatastoreUsage.Committed/1024/1024/1024) 
$UsedSpace =$UsedSpace.ToString() 
$UsedSpace = $UsedSpace + " GB" 
$ProvisionedSpace = "{0:N2}" -f (($vmview.Storage.PerDatastoreUsage.Committed+$vmview.Storage.PerDatastoreUsage.Uncommitted)/1024/1024/1024) 
$ProvisionedSpace =$ProvisionedSpace.ToString() 
$ProvisionedSpace = $ProvisionedSpace + " GB" 
if ($VMPowerState -eq "PoweredOn") 
{ 
$OSInfo = Get-VMGuest -VM $VirtualMachineName 
$OSName =  $OSInfo.OSFullName 
$OSIPAddress = $OSInfo.IPAddress 
$VMDisks = Get-VMGuest $VirtualMachineName | select Disks 
$VMDisks = $VMDisks.Disks 
$DNSName = Get-VMGuest -VM "$VirtualMachineName" | select HostName 
$DNSName = $DNSName.HostName 
################################################ 
#Calculating Disks Information 
################################################ 
$diskcount = $VMDisks.Count -1 
$DriveInfo = @() 
For ($I=0; $I -le $diskcount; $I++) 
{ 
$DriveUsedSpace = "{0:N2}" -f $VMDisks[$I].FreeSpaceGB + " GB" 
$DriveCapacity = "{0:N2}" -f $VMDisks[$I].CapacityGB + " GB" 
$DrivePath = $VMDisks[$I].Path 
$DriveInfo += $DrivePath + " Used Space Is " + $DriveUsedSpace+" Capacity Is "+$DriveCapacity 
$DriveInfo += "`n" 
} 
#End of HD Calculations 
} 
#Writing Data 
$WriteData.Cells.Item("$Row",1) = "$VirtualMachineName" 
$WriteData.Cells.Item("$Row",2) = "$VMPowerState" 
$WriteData.Cells.Item("$Row",3) = "$CPUCount" 
$WriteData.Cells.Item("$Row",4) = "$RAMAssigned" 
$WriteData.Cells.Item("$Row",5) = "$VMHost" 
$WriteData.Cells.Item("$Row",6) = "$DriveInfo" 
$WriteData.Cells.Item("$Row",9) = "$VMDataStore" 
$WriteData.Cells.Item("$Row",10) = "$ProvisionedSpace" 
$WriteData.Cells.Item("$Row",11) = "$UsedSpace" 
$WriteData.Cells.Item("$Row",12) = "$OSName" 
$WriteData.Cells.Item("$Row",13) = "$OSIPAddress" 
$WriteData.Cells.Item("$Row",14) = "$DNSName" 
$Row = $Row + 1 
} 
$Excel.Visible = $true 