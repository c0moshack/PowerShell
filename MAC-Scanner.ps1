$hosts = @()
$hosts +=  1..154 | %{"192.168.1.$_"}
$pinger = New-Object System.Net.NetworkInformation.Ping
  
$hosts |
  Where-Object { ($pinger.send($_,"100").Status) -eq "Success" } |
  ForEach-Object {
    $IPAddress = $_
    Write-Progress -Activity "Scanning IPs.." -Status "Checking $IPAddress"
    Get-WmiObject Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=TRUE' -Computer $IPAddress  -ErrorAction SilentlyContinue|
    Where-Object { $_.IPAddress -contains $IPAddress } |
    Select-Object @{n='IPAddress';e={ $IPAddress }}, MACAddress, DNSHostName
  }

