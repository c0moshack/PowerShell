if(((Get-PowerCLIConfiguration).DefaultVIServerMode) -ne "Multiple") { 
    Set-PowerCLIConfiguration -DefaultVIServerMode Multiple | Out-Null 
}

$x=0
while ($x -eq 0) {
    $vcenterfile = Read-Host "Please enter the vCenters file location"
    if (! (Test-Path $vcenterfile -PathType Leaf)) {
        Write-Host "Invalid file"
        $x = 0
    }
    else {
        $x =1
    }
}
$date = Get-Date -UFormat "%Y%m%d"
$vcenters = Import-Csv $vcenterfile
$password = Read-Host -Prompt "Enter Password" -AsSecureString
$username = "Domain/Service_Account"
$cred = New-Object System.Management.Automation.PSCredential($username,$password)
$vcIPs = @()
foreach ($vcenter in $vcenters) {
$vcIPs += $vcenter.IP
}
# Get the license info from each VC in turn 
Connect-VIServer $vcIPs -Credential $cred
$vSphereLicInfo = @() 
$ServiceInstance = Get-View ServiceInstance 
Foreach ($LicenseMan in Get-View ($ServiceInstance | Select -First 1).Content.LicenseManager) { 
    Foreach ($License in ($LicenseMan | Select -ExpandProperty Licenses)) { 
        $Details = "" |Select VC, Name, Key, Total, Used, ExpirationDate , Information 
        $Details.VC = ([Uri]$LicenseMan.Client.ServiceUrl).Host 
        $Details.Name= $License.Name 
        $Details.Key= $License.LicenseKey 
        $Details.Total= $License.Total 
        $Details.Used= $License.Used 
        $Details.Information= $License.Labels | Select -expand Value 
        $Details.ExpirationDate = $License.Properties | Where { $_.key -eq "expirationDate" } | Select -ExpandProperty Value 
        $vSphereLicInfo += $Details 
    } 
}
$vSphereLicInfo | Export-Csv T:\Reports\$date.vCenterlic.csv
#$vSphereLicInfo | Format-Table -AutoSize
