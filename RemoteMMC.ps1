
$tool="mmc.exe"
$userName=$env:username
$machineName=Read-Host("Enter the machine name: ")
$cmdLine="C:\Users\$userName\Desktop\RemoteManagement.msc /a /computer=$machineName"


Write-Host "$tool $cmdLine$machineName"
invoke-expression "$tool $cmdLine" | out-null


