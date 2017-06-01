$ADComputerAssets = Get-ADComputer -Filter * -Property * -searchbase "OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil" | Select Name,Description,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion,IPV4Address
$operatingSystems = $ADComputerAssests.OperatingSystem | Select-Object -Unique
$operatingSystems += $null

$inventory = @()
Foreach ($os in $operatingSystems) {
    $props = @{}
    $props.OS = $os
    $props.Number = ($ADComputerAssests  | Where-Object {$_.OperatingSystem -eq $os}).Count

    If ($props.OS -eq $null) {
        $props.OS = "NULL"
    }

    If ($props.Number -eq $null) {
        $props.Number = 1
    }

    $tobj = New-Object -TypeName psobject -Property $props

    $inventory += $tobj
}

$inventory
