$computer = "NGWINB-SAF-05"

$regHive1 = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $comp)
$sub1 = $regHive1.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings")
"LM`: " + $sub1.GetValue("ProxyEnable")

$regHive = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('CurrentUser', $comp)
$sub = $regHive.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings")
"CU`: " + $sub.GetValue("ProxyEnable")