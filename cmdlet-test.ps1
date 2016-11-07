"C# - WMI : " + $(Measure-Command {Get-USBDevices -Location WMI -ComputerName "NGWINB-DISC4-47"}).TotalSeconds
"PS - WMI : " + $(Measure-Command {Get-USBWMIData -ComputerName "NGWINB-DISC4-47"}).TotalSeconds

"C# - MountedDevices : " + $(Measure-Command {Get-USBDevices -Location MOUNTEDDEVICES -ComputerName "NGWINB-DISC4-47"}).TotalSeconds
"PS - MountedDevices : " + $(Measure-Command {Get-USBMountedDevices -ComputerName "NGWINB-DISC4-47"}).TotalSeconds

"C# - Registry : " + $(Measure-Command {Get-USBDevices -Location USBSTOR -ComputerName "NGWINB-DISC4-47"; Get-USBDevices -Location USB -ComputerName "NGWINB-DISC4-47"}).TotalSeconds
"PS - Registry : " + $(Measure-Command {Get-USBRegistryEntries -ComputerName "NGWINB-DISC4-47"}).TotalSeconds


#C# - WMI : 14.8634977
#PS - WMI : 28.2182703
#C# - MountedDevices : 1.1104035
#PS - MountedDevices : 0.7254392
#C# - Registry : 205.0559839
#PS - Registry : 34.8154814