Import-Module ActiveDirectory

Add-Type -AssemblyName System.Windows.Forms
$form = New-Object Windows.Forms.Form
$form.size = New-Object Drawing.Size @(200,100)
$form.StartPosition = "CenterScreen"

$txtbx = New-Object System.Windows.Forms.Textbox
$txtbx.Text = "Enter Computer Name"

$btn = New-Object System.Windows.Forms.Button
$btn.add_click({$txtbx.Text|Out-Host})
$btn.Text = "Click Me"

$form.Controls.Add($txtbx)
$form.Controls.Add($btn)

$drc = $form.ShowDialog()

Import-Module ActiveDirectory
$UserName = "paul.j.brown"
# See if the user exists
$CheckUser = Get-ADUser -Server NGWIA101 -ldapFilter "(SamAccountName=$UserName)"
#
#If user exists, exit!
if ($CheckUser -ne $Null)
{
  write "User $UserName already exists! Exiting..."
  write ""
  exit 
}
#


#Launch DameWare
$comp = "NGWIA7-DISC4-20"
$args = '-c -m:'+$comp+' -h -a:1'
[Diagnostics.Process]::Start('C:\program files\DameWare\DameWare Mini Remote Control 7.5\DWRCC.exe ',$args)
