$proxyenabled = $(Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name ProxyEnable | Select ProxyEnable).ProxyEnable
$notifyicon = New-Object System.Windows.Forms.NotifyIcon
$notifyicon.Icon = "C:\Users\paul.j.brown\Documents\STIG\Windows 8\metro-ui-dock-icon-set-436-icons-by-dakirby\Metro ICO\Web Browsers\RockMelt.ico"
$notifyicon.Visible = $true
If ($proxyenabled -ne $previousstatus) {
    If ($proxyenabled -eq "0") {
        $notifyicon.ShowBalloonTip(10,"Proxy Status","Proxy: Disabled",[system.windows.forms.ToolTipIcon]"Info")
    } ElseIf ($proxyenabled -eq "1") {
        $notifyicon.Text = "Proxy: Enabled"
        $notifyicon.BalloonTipText = "Proxy: Enabled"
    }
}
$previousstatus = $proxyenabled