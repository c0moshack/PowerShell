$path = '\\ng\ngwi\public\jfhq'
$url = 'http://google.com'

######## Form Constants ######
$borderstyle = 'Fixed3D'
######## Form Code ###########
$frmMain = New-Object System.Windows.Forms.Form
$frmMain.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Program Files (x86)\United States Army\NETCOM Logoff Banner\AGMSplash.exe")
$frmMain.Size = New-Object System.Drawing.Size(210,400)

$notfy = New-Object System.Windows.Forms.NotifyIcon
$notfy.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("C:\Program Files (x86)\ConfigMgr 2012 Toolkit R2\ClientTools\DeploymentMonitoringTool.exe")
$notfy.Site
$frmMain.Controls.Add($notfy)

$btn2 = New-Object System.Windows.Forms.Button
$btn2.Text = "Refresh"
$btn2.Location = New-Object System.Drawing.Point(100,0)
$btn2.Size = New-Object System.Drawing.Size(100,20)
$btn2.BackColor = 'white'
$frmMain.Controls.Add($btn2)

$btn = New-Object System.Windows.Forms.Label
$btn.Text = "Waiting"
$btn.Location = New-Object System.Drawing.Point(0,0)
$btn.Size = New-Object System.Drawing.Size(100,20)
$frmMain.Controls.Add($btn)

$lbl = New-Object System.Windows.Forms.Label
$lbl.BorderStyle = $borderstyle
$lbl.Location = New-Object System.Drawing.Point(100,20)
$lbl.Size = New-Object System.Drawing.Size(100,20)
$lbl.BackColor = 'white'
$frmMain.Controls.Add($lbl)

$lbl2 = New-Object System.Windows.Forms.Label
$lbl2.BorderStyle = $borderstyle
$lbl2.Text = "DISC4-J6 Share"
$lbl2.Location = New-Object System.Drawing.Point(0,20)
$lbl2.Size = New-Object System.Drawing.Size(100,20)
$lbl2.BackColor = 'darkgray'
$frmMain.Controls.Add($lbl2)

$lbl3 = New-Object System.Windows.Forms.Label
$lbl3.BorderStyle = $borderstyle
$lbl3.Location = New-Object System.Drawing.Point(100,40)
$lbl3.Size = New-Object System.Drawing.Size(100,20)
$lbl3.BackColor = 'white'
$frmMain.Controls.Add($lbl3)

$lbl4 = New-Object System.Windows.Forms.Label
$lbl4.BorderStyle = $borderstyle
$lbl4.Text = "Google"
$lbl4.Location = New-Object System.Drawing.Point(0,40)
$lbl4.Size = New-Object System.Drawing.Size(100,20)
$lbl4.BackColor = 'darkgray'
$frmMain.Controls.Add($lbl4)

function Main{
     [System.Windows.Forms.Application]::EnableVisualStyles()
     [System.Windows.Forms.Application]::Run($frmMain)
}

$btn2.add_Click({
    $btn.Text = "Updating..."
    # File Share Test
    If (Test-Path $path) {

        $lbl.BackColor = 'green'
    } Else {
        $lbl.BackColor = 'red'
    }
    # Google Test
    If (Invoke-WebRequest $url -ErrorAction SilentlyContinue) {

        $lbl3.BackColor = 'green'
    } Else {
        $lbl3.BackColor = 'red'
    }
    $btn.Text = "Waiting..."
})

Main