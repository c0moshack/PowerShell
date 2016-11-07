# -----------------------------------------------------------------------------
# Script: WinPE_Builder_x86_copy.ps1
# Author: Paul J. Brown WIARNG
# Date: 09/29/2015
# Keywords: 
# comments: 
#
# -----------------------------------------------------------------------------

Function WinPE-1MakePEDirectory{
	Param($OSArchitecture="x86")
 If(!(Test-Path -Path "C:\PE\winpe_$OSArchitecture\")) 
 {
  New-Item c:\PE\winpe_$OSArchitecture\ISO\sources -type directory -force
  New-Item c:\PE\winpe_$OSArchitecture\mount -type directory -force
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\$OSArchitecture\en-us\winpe.wim" "c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim"
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\$OSArchitecture\Media\*" "c:\PE\winpe_$OSArchitecture\ISO\" -recurse
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\$OSArchitecture\Oscdimg\etfsboot.com" "c:\PE\winpe_$OSArchitecture\"
 }
 else 
 {
  remove-item -force "c:\PE\winpe_$OSArchitecture" -Recurse
  New-Item c:\PE\winpe_$OSArchitecture\ISO\sources -type directory -force
  New-Item c:\PE\winpe_$OSArchitecture\mount -type directory -force
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\$OSArchitecture\en-us\winpe.wim" "c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim"
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\$OSArchitecture\Media\*" "c:\PE\winpe_$OSArchitecture\ISO\" -recurse
  copy-item "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\$OSArchitecture\Oscdimg\etfsboot.com" "c:\PE\winpe_$OSArchitecture\"
 }
}

Function WinPE-2Mount{
	Param($OSArchitecture="x86",$WimFile="c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim")
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /Mount-Wim /WimFile:$WimFile /index:1 /MountDir:C:\PE\winpe_$OSArchitecture\mount
}

Function WinPE-3AddPAckages{
	Param($OSArchitecture="x86",$WimFile="c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim")
	$OCsPATH="C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\$OSArchitecture\WinPE_OCs"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-Scripting.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-Scripting_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-WMI.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-WMI_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-MDAC.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-MDAC_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-HTA.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-HTA_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-NetFx.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-NetFx_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-PowerShell.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-PowerShell_en-us.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\WinPE-DismCmdlets.cab"
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /add-package /packagepath:"$OCsPATH\en-us\WinPE-DismCmdlets_en-us.cab"
}

Function WinPE-4AddFiles{
	Param($OSArchitecture="x86")
	Copy-Item "E:\WinPE_Build_Files\WinPE3.1_Contents_x86\*" "C:\PE\winpe_$OSArchitecture\mount\Windows\System32\" -Recurse
	Copy-Item "E:\WinPE_Build_Files\PortableApps\*" "C:\PE\winpe_$OSArchitecture\mount\Program Files\PortableApps\" -Recurse
	Copy-Item "E:\WinPE_Build_Files\winpe.bmp" "C:\PE\winpe_$OSArchitecture\mount\Windows\System32\"
}

Function WinPE-5AddDrivers {
	Param($OSArchitecture="x86")
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /image:C:\PE\winpe_$OSArchitecture\mount /Add-Driver /driver:E:\WinPE_Build_Files\Drivers_WinPE\ /recurse
}

Function WinPE-6UnMount-NoCommit{
	Param($OSArchitecture="x86",$WimFile="c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim")
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /unmount-Wim /MountDir:C:\PE\winpe_$OSArchitecture\mount /discard
}
Function WinPE-6UnMount{
	Param($OSArchitecture="x86",$WimFile="c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim")
	C:\"Program Files (x86)"\"Windows Kits"\8.1\"Assessment and Deployment Kit"\"Deployment Tools"\x86\DISM\dism.exe /unmount-Wim /MountDir:C:\PE\winpe_$OSArchitecture\mount /Commit
}

Function WinPE-7MakeISO {
	Param($OSArchitecture="x86",$WimFile="c:\PE\winpe_$OSArchitecture\ISO\sources\boot.wim")
	$command="C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\$OSArchitecture\Oscdimg\oscdimg.exe"
	&$command  -o -m -n -bc:\PE\winpe_$OSArchitecture\etfsboot.com c:\PE\winpe_$OSArchitecture\ISO c:\PE\winpe_$OSArchitecture\winpe_$OSArchitecture.iso
}

WinPE-1MakePEDirectory
WinPE-2Mount
WinPE-3AddPAckages
WinPE-4AddFiles
#WinPe-5AddDrivers
WinPE-6UnMount
WinPE-7MakeISO