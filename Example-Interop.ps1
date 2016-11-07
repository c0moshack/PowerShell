$host.UI.RawUI.WindowTitle = "Launcher"
Start-Process C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

sleep 2

[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("Windows PowerShell")

$nppID = Start-Process "D:\Personal\PortableApps\PortableApps\Notepad++Portable\App\Notepad++\notepad++.exe" -PassThru
$nppID.Id
[Microsoft.VisualBasic.Interaction]::AppActivate($nppID.Id)

[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait(". C:\PowerShellScripts\XFDLConversionScript.ps1")
[System.Windows.Forms.SendKeys]::SendWait("~")
[System.Windows.Forms.SendKeys]::SendWait("C:\PowerShellScripts\PDFWatcher.ps1")
[System.Windows.Forms.SendKeys]::SendWait("~")
[System.Windows.SystemParameters]::