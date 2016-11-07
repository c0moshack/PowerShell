
<#############################################
Only edit the variables in the following block
#############################################>

# Location to save report
$HTMLOutput = "$env:USERPROFILE\Desktop\Test.htm"
# AGM Software
$AGMSoftware = @{"ActivClient"="6.2";
			"Axway Desktop Validator"="4.11.2.0.0";
			"IBM Forms Viewer"="4.0.0.2";
			"DBSign Web Signer"="3.0";
			"Microsoft Office Professional"="12.0.6612.1000";
			"McAfee VirusScan Enterprise"="8.7.00004";
			"e-Sign Desktop"="6.60.3.1000";
			"Microsoft Visio Viewer"="14.0.6029.1000";
			"Adobe Flash Player"="11.9.900.170";
			"Adobe Acrobat"="10.1.5";
			"Java 7 Update 79"="7.0.790";
# Locally installed Software
			"Cisco Systems VPN Client 5.0.07.0290"="5.0.6";
			"DCO XMPP"="";
			"Roxio Creator Copy"="3.5.0";
			"SCR3xxx Smart Card Reader"="8.45";
			"NETCOM"="";
			"MBAM"="2.5";
			"Connection Monitor"=""}

# Admin Software

# Registry Keys
$autoServer = $(Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\).AutoShareServer
$autoWks = $(Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters\).AutoShareWks
$NGWIVersion = $(Get-ItemProperty HKLM:\SOFTWARE\AGMProgram\Build\).NGWIImageVersion
	
<#############################################
Do not edit the variables in the following block
#############################################>

Function FindSoftware
{
	$FoundSoftware =  [System.Collections.ArrayList]@()
	$InstalledSoftware_Win32 = Get-WmiObject {Win32_Product} | Select-Object Name, Version, Vendor 
	$InstalledSoftware_REG = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object @{Name='Name'; Expression={$_.DisplayName}}, @{Name='Version'; Expression={$_.DisplayVersion}}, @{Name='Vendor'; Expression={$_.Publisher}}
	
	ForEach ($Item in $AGMSoftware.Keys){
		If ($InstalledSoftware_Win32 -match $Item)
		{	
            #$test = $InstalledSoftware_Win32 -match $Item
			$FoundSoftware += $InstalledSoftware_Win32 -match $Item
		}
		ElseIf ($InstalledSoftware_REG -match $Item)
		{
			$FoundSoftware += $InstalledSoftware_REG -match $Item
		}
		Else 
		{	
            $object = New-Object –TypeName PSObject
			$object | Add-Member –MemberType NoteProperty –Name Name –Value $item
			$object | Add-Member –MemberType NoteProperty –Name Version –Value "N/A"
			$object | Add-Member –MemberType NoteProperty –Name Vendor –Value "N/A"
			            
			$FoundSoftware += $object
		}
	}	
	
	return $FoundSoftware
}

Function Get-J6Software {
	$Installed = FindSoftware
	$output =  [System.Collections.ArrayList]@()
		
	Foreach ($app in $AGMSoftware.Keys) {
		# Create the temporary object and initialize each time
		$object = ""
		IF ($($($Installed | Where-Object {$_.Name -match $app}).Version) -ne "N/A") {
			If ($app -match "Java") {
				If ($($AGMSoftware.$app) -gt $($($Installed | Where-Object {$_.Name -match $app}).Version)) {
					$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -contains $app}).Version);'Status'="Fail"})
				} Else {
					$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -contains $app}).Version);'Status'="Pass"})
				}
			} ElseIf ($Installed.Name -match "$app") {
				If ($($AGMSoftware.$app) -gt $($($Installed | Where-Object {$_.Name -match $app}).Version)) {
					$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -match $app}).Version);'Status'="Fail"})
				} Else {
					$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -match $app}).Version);'Status'="Pass"})
				}
			}
		} Else {$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -match $app}).Version);'Status'="Not Found"})
			
		}
		$output += $object
	}
	
	return $output
}

Function Get-J6RegistryKeys {

	$regKeys =  [System.Collections.ArrayList]@()

	If ($autoServer -eq 1) {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="AutoShareServer";'Value'=$autoServer;'Status'="Pass"})
	} else {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="AutoShareServer";'Value'=$autoServer;'Status'="Fail"})
	}

	If ($autoWks -eq 1) {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="AutoShareWks";'Value'=$autoWks;'Status'="Pass"})
	} else {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="AutoShareWks";'Value'=$autoWks;'Status'="Fail"})
	}
	
	If ($NGWIVersion -ge "15.001") {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="NGWI Image Version";'Value'=$NGWIVersion;'Status'="Pass"})
	} else {
		$regKeys += $object = New-Object -TypeName PSObject -Property ($properties = @{'Registry Key'="NGWI Image Version";'Value'=$NGWIVersion;'Status'="Fail"})
	}

	return $regKeys
}

Function Get-J6TPM {
	$tpm = New-Object -TypeName PSObject -Property ($propertites = @{'TPM Ready'=$(Get-Tpm).TpmReady})
	return $tpm
}
	
Function ExportTo-HTML
{	
	$J6Software = Get-J6Software | Select-Object "Application", "Installed Version", "Required Version", "Status" | Sort-Object "Application" | ConvertTo-Html -Fragment
	$J6RegistryKeys = Get-J6RegistryKeys | Select-Object "Registry Key", "Value", "Status" | Sort-Object "Registry Key" | ConvertTo-Html -Fragment
	
	$a = "<title>Sysprep Check</title>"
	$a = $a + "<style>"
	$a = $a + "BODY{background-color:tan;}"
	$a = $a + "TABLE{width: 1000px; border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
	$a = $a + "TH{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:thistle}"
	$a = $a + "TD{border-width: 1px;padding: 4px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
	$a = $a + "</style>"
		
	$input | ConvertTo-HTML -Head $a -Body "$J6Software $J6RegistryKeys" | Out-File $HTMLOutput
	Invoke-Item $HTMLOutput
}

ExportTo-HTML