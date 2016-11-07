function Invoke-GPUpdate()
{
    param($ComputerName = "")
    $targetOSInfo = Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem -ErrorAction SilentlyContinue
    
    If ($targetOSInfo -eq $null)
    {
        Write-Host -BackgroundColor Black -ForegroundColor Red "Unable to connect to $ComputerName"
    }
    Else
    {
        If ($targetOSInfo.version -ge 5.1)
        {
            Invoke-WmiMethod -ComputerName $ComputerName -Path win32_process -Name create -ArgumentList "gpupdate /target:Computer /force /wait:0" Out-Null
        }
        Else
        {
            Invoke-WmiMethod -ComputerName $ComputerName -Path win32_process -Name create –ArgumentList “secedit /refreshpolicy machine_policy /enforce“ Out-Null
        }
    }
}