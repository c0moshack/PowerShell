$Hive = "LocalMachine"
$ComputerName = "NGWINB-DISC4-33"
$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
$subkey = $reg.OpenSubKey("SOFTWARE\AGMProgram\Build")
$ngwival = $subkey.GetValue("NGWIImageVersion")
$agmval = $subkey.GetValue("SecurityUpdateVersion")
Write-Output "NGWI Image Version: $ngwival"
Write-Output "AGM Version: $agmval"
