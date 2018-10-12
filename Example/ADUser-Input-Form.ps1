$frmMain = New-Object System.Windows.Forms.Form
$frmMain.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
$frmMain.Size = New-Object System.Drawing.Size(600, 600)

$csvpath = New-Object System.Windows.Forms.TextBox
$csvpath.Location = New-Object System.Drawing.Point(10,5)
$csvpath.Size = New-Object System.Drawing.Size(400,10)
$frmMain.Controls.Add($csvpath)

$domain = New-Object System.Windows.Forms.TextBox
$domain.Location = New-Object System.Drawing.Point(10,30)
$domain.Size = New-Object System.Drawing.Size(400,10)
$frmMain.Controls.Add($domain)

$this = New-Object System.Windows.Forms.TextBox
$this.Multiline = $true
$this.Scrollbars = "Vertical"
$this.Location = New-Object System.Drawing.Point(10,65)
$this.Size = New-Object System.Drawing.Size(500, 500)
$frmMain.Controls.Add($this)

function Main{
     [System.Windows.Forms.Application]::EnableVisualStyles()
     [System.Windows.Forms.Application]::Run($frmMain)
}

#endregion

#endregion

#region Event Handlers

$domain.Add_Shown({
    $domain.Text = Get-ADDomain
})

$this.Add_GotFocus({
     $this.Text = Get-HotFix 
	 $this.Text += "`n" + "asdef"
})

Main 