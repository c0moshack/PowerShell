$frmMain = New-Object System.Windows.Forms.Form
$frmMain.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
$frmMain.Size = New-Object System.Drawing.Size(600, 600)

$this = New-Object System.Windows.Forms.TextBox
$this.Multiline = $true
$this.Scrollbars = "Vertical"
$this.Location = New-Object System.Drawing.Point(10,5)
$this.Size = New-Object System.Drawing.Size(500, 500)
$frmMain.Controls.Add($this)

function Main{
     [System.Windows.Forms.Application]::EnableVisualStyles()
     [System.Windows.Forms.Application]::Run($frmMain)
}

#endregion

#endregion

#region Event Handlers

$this.Add_GotFocus({
     $this.Text = Get-HotFix 
	 $this.Text += "`n" + "asdef"
})

Main 