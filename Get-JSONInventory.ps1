$subOperatingSystem = @()
$subOperatingSystem += [pscustomobject]@{
    'name' = $env:COMPUTERNAME;
    'domain' = $env:USERDOMAIN;
    'architecture' = $env:PROCESSOR_ARCHITECTURE
    'serial' = (Get-WmiObject -Class Win32_Bios).SerialNumber
}



$systems = [pscustomobject]@{
    'systems' = $subOperatingSystem
}

$systems | ConvertTo-Json