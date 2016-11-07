# -----------------------------------------------------------------------------
# Script: WinPE_Builder_x86_copy.ps1
# Author: Paul J. Brown WIARNG
# Date: 09/29/2015
# Keywords: 
# comments: 
#
# -----------------------------------------------------------------------------

#Gather directory and build information
$Global:PEFiles = "F:\WinPE_Build_Files"
$Global:PEDirectory = "F:"
$Global:OSArchitecture="x86"
$Global:WimFile="$PEDirectory\PE\winpe_$OSArchitecture\ISO\sources\boot.wim"
$Global:DeploymentKit="C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit"
$OCsPATH="$DeploymentKit\Windows Preinstallation Environment\$OSArchitecture\WinPE_OCs"

Function WinPE-1MakePEDirectory{
 If(!(Test-Path -Path "$PEDirectory\PE\winpe_$OSArchitecture\")) 
 {
  New-Item $PEDirectory\PE\winpe_$OSArchitecture\ISO\sources -type directory -force
  New-Item $PEDirectory\PE\winpe_$OSArchitecture\mount -type directory -force
  copy-item "$DeploymentKit\Windows Preinstallation Environment\$OSArchitecture\en-us\winpe.wim" "$PEDirectory\PE\winpe_$OSArchitecture\ISO\sources\boot.wim"
  copy-item "$DeploymentKit\Windows Preinstallation Environment\$OSArchitecture\Media\*" "$PEDirectory\PE\winpe_$OSArchitecture\ISO\" -recurse
  copy-item "$DeploymentKit\Deployment Tools\$OSArchitecture\Oscdimg\efisys.bin" "$PEDirectory\PE\winpe_$OSArchitecture\"
  copy-item "$DeploymentKit\Deployment Tools\$OSArchitecture\Oscdimg\etfsboot.com" "$PEDirectory\PE\winpe_$OSArchitecture\"
 }
 else 
 {
  remove-item -force "$PEDirectory\PE\winpe_$OSArchitecture" -Recurse
  New-Item $PEDirectory\PE\winpe_$OSArchitecture\ISO\sources -type directory -force
  New-Item $PEDirectory\PE\winpe_$OSArchitecture\mount -type directory -force
  copy-item "$DeploymentKit\Windows Preinstallation Environment\$OSArchitecture\en-us\winpe.wim" "$PEDirectory\PE\winpe_$OSArchitecture\ISO\sources\boot.wim"
  copy-item "$DeploymentKit\Windows Preinstallation Environment\$OSArchitecture\Media\*" "$PEDirectory\PE\winpe_$OSArchitecture\ISO\" -recurse
  copy-item "$DeploymentKit\Deployment Tools\$OSArchitecture\Oscdimg\efisys.bin" "$PEDirectory\PE\winpe_$OSArchitecture\"
  copy-item "$DeploymentKit\Deployment Tools\$OSArchitecture\Oscdimg\etfsboot.com" "$PEDirectory\PE\winpe_$OSArchitecture\"
 }
}

Function WinPE-2Mount{
	Mount-WindowsImage -ImagePath $WimFile -Index 1 -Path "$PEDirectory\PE\winpe_$OSArchitecture\mount"
}

Function WinPE-3AddPAckages{
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-Scripting.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-Scripting_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-WMI.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-WMI_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-MDAC.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-MDAC_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-HTA.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-HTA_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-NetFx.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-NetFx_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-PowerShell.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-PowerShell_en-us.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\WinPE-DismCmdlets.cab
	Add-WindowsPackage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -PackagePath $OCsPATH\en-us\WinPE-DismCmdlets_en-us.cab
}

Function WinPE-4AddFiles{
	#Set permissions for custom background image
	$file = "$PEDirectory\PE\winpe_$OSArchitecture\mount\Windows\System32\winpe.jpg"
	$acl = Get-Acl $file
	Invoke-Expression "C:\Windows\System32\takeown.exe /F $file /A"
	Invoke-Expression "C:\Windows\System32\icacls.exe $file /grant administrators:F"
	#$acl.Owner
	#$acl.AccessToString
	
	Copy-Item "$PEFiles\WinPE3.1_Contents_x86\*" "$PEDirectory\PE\winpe_$OSArchitecture\mount\Windows\System32\" -Recurse
	Copy-Item "$PEFiles\PortableApps\*" "$PEDirectory\PE\winpe_$OSArchitecture\mount\PortableApps\" -Recurse
	Copy-Item "$PEFiles\RocketDock\RocketDock\*" "$PEDirectory\PE\winpe_$OSArchitecture\mount\RocketDock\" -Recurse
}

Function WinPE-5AddDrivers {
	Add-WindowsDriver -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -Driver $PEFiles\Drivers_WinPE\ -Recurse -ForceUnsigned -Verbose
	#Add-WindowsDriver -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -Driver $PEFiles\Drivers_WinPE_Dell\ -Recurse -ForceUnsigned -Verbose
}

Function WinPE-6UnMount{
	Dismount-WindowsImage -Path $PEDirectory\PE\winpe_$OSArchitecture\mount -Save
}

Function WinPE-7MakeISO {
	$option1 = "-n"
	$option2 = "-m" 
	$option3 = "-o" 
	$option4 = "-b$PEDirectory\PE\winpe_$OSArchitecture\etfsboot.com"
	$basedir = "$PEDirectory\PE\winpe_$OSArchitecture\ISO"
	$isofile = "$PEDirectory\PE\winpe_$OSArchitecture.iso"
	$allOptions = @($option1, $option2, $option3, $option4, $basedir, $isofile)

	&"$DeploymentKit\Deployment Tools\$OSArchitecture\Oscdimg\oscdimg.exe" $allOptions 

}

Function WinPE-Unseal {
	Mount-WindowsImage -ImagePath F:\PE\winpe_x86\ISO\sources\boot.wim -Index 1 -Path F:\Mount
	Invoke-Expression "explorer.exe F:\Mount"
}

Function WinPE-Reseal {
	Dismount-WindowsImage -Path F:\Mount -Save
	WinPE-7MakeISO
}

Function WinPE-Cleanup{
    Clear-WindowsCorruptMountPoint
}

#Export-ModuleMember WinPE-1MakePEDirectory,WinPE-2Mount,WinPE-3AddPAckages,WinPE-4AddFiles,WinPe-5AddDrivers,WinPE-6UnMount,WinPE-7MakeISO,WinPE-Cleanup,WinPE-Unseal,WinPE-Reseal

#WinPE-Cleanup
#WinPE-1MakePEDirectory
#WinPE-2Mount
#WinPE-3AddPAckages
#WinPE-4AddFiles
#WinPe-5AddDrivers
#WinPE-6UnMount
#WinPE-Unseal
#WinPE-Reseal