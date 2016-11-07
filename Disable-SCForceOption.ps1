# ----------------------------------------------------------------------------- 
# Script: Set-RegistryKey
# Author: Paul Brown
# Date: 03/29/2016 10:33:32 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Set-RegistryKey {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 03/29/2016 10:33:32 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$ComputerName = $Env:COMPUTERNAME,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[string] $Hive,
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string] $Path,
		
		[Parameter(
		Mandatory=$false,
		Position=3)]
		[string] $Name,
		
		[Parameter(
		Mandatory=$false,
		Position=4)]
		[string] $Value,
		
		[switch]$Set
	)

	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($Hive, $ComputerName)
	$subkey = $reg.OpenSubKey($Path,$true)
	$keyvalue = $subkey.GetValue($Name)
	
	If ($Set) {
		$subkey.SetValue($Name, $Value)
		$keyvalue = $subkey.GetValue($Name)
	}
	
	
	return "$keyvalue"
}

[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$script:canceled = $false
$script:stopped = $false

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Disable Smart Card Login Enforcement"
$objForm.Size = New-Object System.Drawing.Size(500,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$OKButton.PerformClick()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
	
#Region
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(460,20) 
$objLabel.Text = "Enter the computers name or IP"
$objForm.Controls.Add($objLabel) 	
	
$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Text = "<Enter Computer Name>"
$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
$objTextBox.Size = New-Object System.Drawing.Size(385,20) 
$objForm.Controls.Add($objTextBox) 
#EndRegion

#Region
$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Size(10,80) 
$objLabel3.Size = New-Object System.Drawing.Size(280,20) 
$objLabel3.ForeColor = "Red"
$objLabel3.Text = "Waiting"
$objForm.Controls.Add($objLabel3) 
#EndRegion 

#Region
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(100,100)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "Start"
$OKButton.Add_Click({
	If ($script:canceled -ne $true) {
		#While ($script:stopped -ne $true) {		
			$objLabel3.Text = "Running"
			If ($(Set-RegistryKey -ComputerName $($objTextBox.Text) -Hive "LocalMachine" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "SCForceOption") -eq 1) {
				Set-RegistryKey -ComputerName $($objTextBox.Text) -Hive "LocalMachine" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "SCForceOption" -Value "0" -Set
				
				$newvalue = $(Set-RegistryKey -ComputerName $($objTextBox.Text) -Hive "LocalMachine" -Path "SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "SCForceOption")
				$objLabel3.Text = "SCForceOption was set to $($newvalue)"
			} Else {
				$objLabel3.Text = "SCForceOption not changed"
			}
		#}
	}
})
$objForm.Controls.Add($OKButton)

#$StopButton = New-Object System.Windows.Forms.Button
#$StopButton.Location = New-Object System.Drawing.Size(175,100)
#$StopButton.Size = New-Object System.Drawing.Size(75,23)
#$StopButton.Text = "Stop"
#$StopButton.Add_Click({$script:stopped = $true;$objLabel3.Text="Stopped"})
#$objForm.Controls.Add($StopButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(250,100)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Close"
$CancelButton.Add_Click({$script:canceled = $true;$objForm.Close()})
$objForm.Controls.Add($CancelButton)
#EndRegion

$objForm.Topmost = $True
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()


