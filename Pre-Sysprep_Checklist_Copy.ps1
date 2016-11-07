
<#############################################
Only edit the variables in the following block
#############################################>


# Location to save report
$HTMLOutput = "C:\Users\paul.j.brown\Documents\J6\Programming\Powershell\Test.htm"
# AGM Software
$AGMSoftware = @{"ActivClient CAC"="6.2";
			"Axway Desktop Validator"="4.11.2.0.0";
			"IBM Forms Viewer"="4.0.0.2";
			"DBSign Web Signer"="3.0";
			"Microsoft Office Professional"="12.0.6612.1000";
			"McAfee VirusScan Enterprise"="8.7.00004";
			"e-Sign Desktop"="6.60.3.1000";
			"Microsoft Visio Viewer"="14.0.6029.1000";
			"Adobe Flash Player"="11.9.900.170";
			"Adobe Acrobat X Pro"="10.1.5";
			"Java"="7.0.510";
# Locally installed Software
			"Cisco Systems VPN Client 5.0.07.0290"="5.0.6";
			"DCO XMPP"="";
			"Roxio Creator Copy"="3.5.0";
			"SCR3xxx Smart Card Reader"="8.45";
			"NETCOM"="";
			"Connection Monitor"=""}

# Admin Software


# Registry values -- All entries must be in an array format of #("Path", "Key", "Value")

    $a = [array]@("HKLM:SOFTWARE\AGMProgram\Build", "NGWIImageVersion", "14.300")
    $b = [array]@("HKLM:SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters", "AutoShareWks", "1")
    $c = [array]@("HKLM:SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters", "AutoShareServer", "1")
    $d = [array]@("HKCU:SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings", "EnableNegotiate", "0")
    $e = [array]@("HKLM:SOFTWARE\Policies\Microsoft\ConnectionMonitor", "VPNExceptionsList", "Cisco Systems VPN Adapter")
    
    #add each key to the array
    $RegKeys = $a, $b, $c, $d, $e
    

<#############################################
Do not edit the variables in the following block
#############################################>

Function FindSoftware
{
	$FoundSoftware =  [System.Collections.ArrayList]@()
	$InstalledSoftware_Win32 = Get-WmiObject -Class {Win32_Product} | Select-Object -Property Name, Version, Vendor 
	$InstalledSoftware_REG = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate 
    
	ForEach ($Item in $AGMSoftware.Keys){
		If ($InstalledSoftware_Win32 -match $Item)
		{	
			$FoundSoftware += $InstalledSoftware_Win32 -match $Item
		}
		ElseIf ($InstalledSoftware_REG -match $Item)
		{
			$FoundSoftware += $InstalledSoftware_REG -match $Item
		}
		Else 
		{	
            # Create the software table
            $table = New-Object System.Data.DataTable "Software"
            $ColName = New-Object System.Data.DataColumn Name,([string])
            $ColVersion = New-Object System.Data.DataColumn Version,([string])
            $ColVendor = New-Object System.Data.DataColumn Vendor,([string])
            $table.columns.add($ColName)
            $table.columns.add($ColVersion)
            $table.columns.add($ColVendor)
            $row = $table.NewRow()
            $row.Name = $Item
            $row.Version = "Not Found"
            $row.Vendor = "N/A"
            $table.Rows.Add($row)
    
			$FoundSoftware += $table
            
		}
	}	
	
	return $FoundSoftware
}

Function CheckRegistry 
{
    $regtable = New-Object System.Data.DataTable "Registry Keys"
    $regColPath = New-Object System.Data.DataColumn Path,([string])
    $regColKey = New-Object System.Data.DataColumn Key,([string])
    $regColValue = New-Object System.Data.DataColumn Value,([string])
    $regtable.columns.add($regColPath)
    $regtable.columns.add($regColKey)
    $regtable.columns.add($regColValue)
    
    ForEach ($rkey in $RegKeys)
    {
        $regrow = $regtable.NewRow()
        $regrow.Path = $rkey[0]
        $regrow.Key = $rkey[1]
        $regrow.Value = $rkey[2]
        $regtable.Rows.Add($regrow)
    }
    
    ForEach ($entry in $regtable)
    {
        $newval = Get-ItemProperty -Path $entry.path -Name $entry.key | Select-Object $entry.key
        $entry.value = $newval.($entry.key)  
    }
    
    return $regtable
}

Function ExportToHTML
{
	#param(
	#	[Parameter( `
    #        Mandatory=$True, `
    #        Valuefrompipeline = $true)]
    #    $input
	#)
    
    
	$a = "<title>Sysprep Check</title>"
	$a = $a + "<style>"
	$a = $a + "BODY{background-color:grey;}"
	$a = $a + "TABLE{border-width: 1px;width: 50em;border-style: solid;border-color: black;border-collapse: collapse;}"
	$a = $a + "TH{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:yellow}"
	$a = $a + "TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:white}"
	$a = $a + "</style>"
    
    #Add Header
    ConvertTo-HTML -Head $a | Out-File $HTMLOutput
    
    $divider0 = "<h3>Machine</h3>" 
    $divider0 | Out-File -Append $HTMLOutput
    
    get-wmiobject -class "Win32_ComputerSystem" -namespace "root\CIMV2" | Select-Object Name, Domain, Manufacturer, Model | ConvertTo-HTML -Fragment | Out-File -Append $HTMLOutput
    get-wmiobject -class "Win32_BIOS" -namespace "root\CIMV2" | Select-Object Name, SerialNumber | ConvertTo-HTML -Fragment | Out-File -Append $HTMLOutput
    
    #Add Section
    $divider1 = "<h3>Software</h3>" 
    $divider1 | Out-File -Append $HTMLOutput
    
    #Add Software table
	FindSoftware | Sort-Object -Property Name | ConvertTo-HTML -Fragment | Out-File -Append $HTMLOutput
    
    #Add Section
    $divider2 = "<h3>Registry Keys</h3>" 
    $divider2 | Out-File -Append $HTMLOutput
    
    #Add Registry Table    
    CheckRegistry | Sort-Object -Property Path | Select-Object Path, Key, Value | Sort-Object -Property Name | ConvertTo-HTML -Fragment | Out-File -Append $HTMLOutput
    
    #Add Section
    $divider3 = "<h3>Favorites</h3>" 
    $divider3 | Out-File -Append $HTMLOutput
    
    Invoke-Item $HTMLOutput
}

Speak-Text "Scan Started"
ExportToHTML
Speak-Text "Scan Complete"