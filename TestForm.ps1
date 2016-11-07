[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[Void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objForm = New-Object System.Windows.Forms.Form
$objForm.Text = "Data Entry Form"
$objForm.AutoSize = $True
$objForm.AutoSizeMode = "GrowAndShrink"
$objForm.StartPosition = "CenterScreen"

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(10,10)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$objForm.AcceptButton = $OKButton
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(85,10)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$objForm.CancelButton = $CancelButton
$objForm.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,40) 
$label.Size = New-Object System.Drawing.Size(280,20) 
$label.Text = "Please make a selection from the list below:"
$objForm.Controls.Add($label) 

$objListBox = New-Object System.Windows.Forms.ListBox
$objListBox.SelectionMode = "MultiExtended"
$objListBox.Location = New-Object System.Drawing.Size(10,60)
$objListBox.AutoSize = $true
$list = Get-childitem -Path "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Windows Preinstallation Environment\x86\WinPE_OCs\" | Where-Object {$_.Extension -eq ".cab"} | ForEach-Object {[Void] $objListBox.Items.Add($_)}
$objForm.Controls.Add($objListBox)


$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
$result = $objForm.ShowDialog()

If ($result -eq [System.Windows.Forms.DialogResult]::OK)
{	
	$selected = $objListBox.SelectedItems
	Foreach ($select in $selected){
		[Void] [System.Windows.Forms.MessageBox]::Show("$select  `n")
		}
	}