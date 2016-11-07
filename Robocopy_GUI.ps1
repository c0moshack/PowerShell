#region Constructor

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#endregion

#region Post-Constructor Custom Code

#endregion

#region Form Creation

#~~< frmMain >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$frmMain = New-Object System.Windows.Forms.Form
$frmMain.ClientSize = New-Object System.Drawing.Size(278, 138)
$frmMain.Text = "RoboCopy User Profile"
#~~< txtTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$userTextbox = New-Object System.Windows.Forms.TextBox
$userTextbox.Location = New-Object System.Drawing.Point(47, 20)
$userTextbox.Size = New-Object System.Drawing.Size(183, 20)
$userTextbox.TabIndex = 1
$userTextbox.Text = ""
#~~< txtTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$srcTextbox = New-Object System.Windows.Forms.TextBox
$srcTextbox.Location = New-Object System.Drawing.Point(47, 50)
$srcTextbox.Size = New-Object System.Drawing.Size(183, 20)
$srcTextbox.TabIndex = 2
$srcTextbox.Text = ""
#~~< txtTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$destTextbox = New-Object System.Windows.Forms.TextBox
$destTextbox.Location = New-Object System.Drawing.Point(47, 80)
$destTextbox.Size = New-Object System.Drawing.Size(183, 20)
$destTextbox.TabIndex = 3
$destTextbox.Text = ""
#~~< butClickMe >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$butClickMe = New-Object System.Windows.Forms.Button
$butClickMe.Location = New-Object System.Drawing.Point(98, 110)
$butClickMe.Size = New-Object System.Drawing.Size(75, 23)
$butClickMe.TabIndex = 0
$butClickMe.Text = "Click Me"
$butClickMe.UseVisualStyleBackColor = $true
#~~< labelClickMe >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$userLabel1 = New-Object System.Windows.Forms.Label
$userLabel1.Location = New-Object System.Drawing.Point(235, 50)
$userLabel1.Size = New-Object System.Drawing.Size(75, 23)
$userLabel1.Text = "<username>"
$userLabel2 = New-Object System.Windows.Forms.Label
$userLabel2.Location = New-Object System.Drawing.Point(235, 80)
$userLabel2.Size = New-Object System.Drawing.Size(75, 23)
$userLabel2.Text = "<username>"

#~~< Add to Form >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$frmMain.Controls.Add($destTextbox)
$frmMain.Controls.Add($srcTextbox)
$frmMain.Controls.Add($userLabel1)
$frmMain.Controls.Add($userLabel2)
$frmMain.Controls.Add($userTextbox)
$frmMain.Controls.Add($butClickMe)

#endregion

#region Custom Code

#endregion

#region Event Loop

function Main{
     [System.Windows.Forms.Application]::EnableVisualStyles()
     [System.Windows.Forms.Application]::Run($frmMain)
}

#endregion

#endregion

#region Event Handlers

$butClickMe.Add_Click({
     $srcTextbox.Text = "Hello World"
})

$userTextbox.Add_LostFocus({
     $userLabel1.Text = "\" + $userTextbox.Text
	 $userLabel2.Text = "\" + $userTextbox.Text
})

Main #This call must remain below all other event functions

#endregion