Remove-Module WinPE_Builder_x86
Import-Module "D:\Documents\J6\Programming\Powershell\WinPE_Builder_x86.psm1"
WinPE-Cleanup
WinPE-1MakePEDirectory
WinPE-2Mount
WinPE-3AddPAckages
WinPE-4AddFiles
WinPe-5AddDrivers
WinPE-6UnMount
WinPE-7MakeISO