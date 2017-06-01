﻿$ADComputerAssets = Get-ADComputer -Filter * -Property * -searchbase "OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil" | Select Name,Description,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion,IPV4Address
$ADComputerAssets | Export-Csv "C:\Users\paul.j.brown\Desktop\AD_Computer_Report.csv" -NoTypeInformation