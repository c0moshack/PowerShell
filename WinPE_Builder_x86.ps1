Import-Module "C:\Users\paul.j.brown\Documents\Git\PowerShell\WinPE_Builder_x86.psm1"
Import-Module DISM

WinPE-Cleanup
WinPE-1MakePEDirectory
WinPE-2Mount
WinPE-3AddPAckages
WinPE-4AddFiles
WinPE-5AddDrivers
WinPE-6UnMount
WinPE-7MakeISO