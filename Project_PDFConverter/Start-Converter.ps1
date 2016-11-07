$host.UI.RawUI.WindowTitle = "PDF Conversion Launcher"
Start-Process C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

sleep 2

[void] [System.Reflection.Assembly]::LoadWithPartialName("'Microsoft.VisualBasic")
[Microsoft.VisualBasic.Interaction]::AppActivate("Windows PowerShell")

[void] [System.Reflection.Assembly]::LoadWithPartialName("'System.Windows.Forms")
[System.Windows.Forms.SendKeys]::SendWait("`$host.UI.RawUI.WindowTitle = `"PDF Converter`"")
[System.Windows.Forms.SendKeys]::SendWait("~")
sleep 1
[System.Windows.Forms.SendKeys]::SendWait(". C:\PowerShellScripts\XFDLConversionScript.ps1")
[System.Windows.Forms.SendKeys]::SendWait("~")
sleep 2
[System.Windows.Forms.SendKeys]::SendWait("C:\PowerShellScripts\PDFWatcher.ps1")
[System.Windows.Forms.SendKeys]::SendWait("~")
sleep 2


While ($true) {
    Copy-Item 'C:\PowerShellScripts\DummyForm.xfdl' '\\ng\ngwi\Public\PDF_Conversion'
    sleep 20
    Remove-Item '\\ng\ngwi\Public\PDF_Conversion\DummyForm.xfdl' -ErrorAction SilentlyContinue
    Remove-Item '\\ng\ngwi\Public\PDF_Conversion\DummyForm.pdf' -ErrorAction SilentlyContinue
    Write-Host "[Trigger]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')"
    $seconds = 300
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity Sleeping -Status Sleeping... -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity Sleeping 
}