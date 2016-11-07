# ----------------------------------------------------------------------------- 
# Script: Export-PDF
# Author: Paul Brown
# Date: 04/25/2016 08:30:20 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Export-PDF {
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
	    	LASTEDIT: 04/25/2016 08:30:20 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$Path,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[string]$Extension,
		
		[switch]$Recurse
		
	)
	$wildcardext = "*.$Extension"
	
	If ($Recurse) {
		$switches = @{
			Path = $Path
			Recurse = $true
			Filter = $wildcardext
		}
	} Else {
		$switches = @{
			Path = $Path
			Filter = $wildcardext
		}
	}
	
	
	
	$outPath = $Path
	$originalkeyvalue = $null
		
	# Get default printer so it can be reset later
	$defaultPrinter = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Default -eq $true}
	$AdobPDFPrinter = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Name -eq "Adobe PDF"}
	$AdobPDFPrinter.SetDefaultPrinter() | Out-Null
	
	#Get SID for setting Adobe PDF Output folder in registry
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
	$sid = ([System.DirectoryServices.AccountManagement.UserPrincipal]::Current).SID.Value  

	# Set Adobe PDF  Output Folder
	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("USERS", $Env:COMPUTERNAME)
	$subkey = $reg.OpenSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder", $true)
	If ($subkey) {
		$originalkeyvalue = $subkey.GetValue("2")
		$subkey.SetValue("",'2', [Microsoft.Win32.RegistryValueKind]::DWORD) | Out-Null
		$subkey.SetValue("2", $outPath, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
		$keyvalue = $subkey.GetValue("2")
	} Else {
		$reg.CreateSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder") | Out-Null
		$subkey = $reg.OpenSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder", $true) | Out-Null
		$subkey.SetValue("",'2', [Microsoft.Win32.RegistryValueKind]::DWORD) | Out-Null
		$subkey.SetValue("2", $outPath, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
		$keyvalue = $subkey.GetValue("2")
	}
	Try {
		$outbox.AppendText("[StartConversion::$(Get-Date -Format 'HH:MM:ss MM/dd/yy') `n")
		#Write-Output "[StartConversion::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')" 
		Write-Output "[StartConversion::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')" | Out-File -Append $("$Path\ConversionLog.txt")
		$files = Get-ChildItem @switches
		foreach ($file in $files) {
			$pdfname = "$($file.Directory)\$($file.Basename).pdf"
			If (!(Test-Path $pdfname)) {
				$subkey.SetValue("2", $file.DirectoryName, [Microsoft.Win32.RegistryValueKind]::STRING)
				$shell = New-Object -ComObject shell.application
				$namespace = $shell.NameSpace($file.DirectoryName).parsename($file)
				$namespace.InvokeVerb('Print') 
				$outbox.AppendText("[Printed]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName) `n")
				#Write-Output "[Printed]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName)" 
				Write-Output "[Printed]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName)" | Out-File -Append $("$Path\ConversionLog.txt")
			} Else {
				$outbox.AppendText( "[Exists]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName) `n")
				#Write-Output "[Exists]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName)"
				Write-Output "[Exists]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')::$($file.FullName)" | Out-File -Append $("$Path\ConversionLog.txt")
			}
			
			While (!(Test-Path $pdfname)) {
			}
		}
		$outbox.AppendText("[Stop Conversion]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy') `n")
		#Write-Output "[Stop Conversion]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')" 
		Write-Output "[Stop Conversion]::$(Get-Date -Format 'HH:MM:ss MM/dd/yy')" | Out-File -Append $("$Path\ConversionLog.txt")
	} Catch {
		$outbox.AppendText("$($_.Exception.Message) `n")
		Write-Output $_.Exception.Message
		Write-Output $_.Exception.Message |  Out-File -Append $("$Path\ConversionErrorLog.txt")
	}
	
	$defaultPrinter.SetDefaultPrinter() | Out-Null
	If ($originalkeyvalue -ne $null) {
		$subkey.SetValue("2", $originalkeyvalue, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
	}
} 
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")  | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
$script:canceled = $false

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Adobe PDF Converter"
$objForm.Size = New-Object System.Drawing.Size(500,550) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objTextBox.Text;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})
	
#Region
$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(460,20) 
$objLabel.Text = "Enter path to source directory"
$objForm.Controls.Add($objLabel) 	
	
$objTextBox = New-Object System.Windows.Forms.TextBox 
$objTextBox.Text = "<Enter full path>"
$objTextBox.Location = New-Object System.Drawing.Size(10,40) 
$objTextBox.Size = New-Object System.Drawing.Size(385,20) 
$objForm.Controls.Add($objTextBox) 
$objTextBox.add_Leave({$objLabel3.Text = "Log: $($objTextBox.Text)\ConversionLog.txt"})

$objButton = New-Object System.Windows.Forms.Button
$objButton.Text = "Browse"
$objButton.Location = New-Object System.Drawing.Size(395,40)
$objButton.Size = New-Object System.Drawing.Size(75,20)
$objForm.Controls.Add($objButton)
$objButton.add_Click({
	$FileBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
 	[void]$FileBrowser.ShowDialog()
	$objTextBox.Text = $($FileBrowser.SelectedPath)
})
#EndRegion

#Region
$objLabel2 = New-Object System.Windows.Forms.Label
$objLabel2.Location = New-Object System.Drawing.Size(10,70) 
$objLabel2.Size = New-Object System.Drawing.Size(230,20) 
$objLabel2.Text = "Process all sub-directories?"
$objForm.Controls.Add($objLabel2) 

$objCombo = New-Object System.Windows.Forms.ComboBox
$objCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$objCombo.Location = New-Object System.Drawing.Size(10,90)
$objCombo.Size = New-Object System.Drawing.Size(230,20) 
$objCombo.Items.Add("Yes") | Out-Null
$objCombo.Items.Add("No") | Out-Null
$objCombo.SelectedItem = "No"
$objForm.Controls.Add($objCombo)
#EndRegion

#Region
$objLabel4 = New-Object System.Windows.Forms.Label
$objLabel4.Location = New-Object System.Drawing.Size(250,70) 
$objLabel4.Size = New-Object System.Drawing.Size(220,20) 
$objLabel4.Text = "Extension (ie: xfdl,doc,txt)"
$objForm.Controls.Add($objLabel4) 	
	
$objTextBox2 = New-Object System.Windows.Forms.TextBox 
$objTextBox2.Location = New-Object System.Drawing.Size(250,90) 
$objTextBox2.Size = New-Object System.Drawing.Size(220,20) 
$objTextBox2.Text = "xfdl"
$objForm.Controls.Add($objTextBox2) 
#EndRegion

#Region
$objLabel3 = New-Object System.Windows.Forms.Label
$objLabel3.Location = New-Object System.Drawing.Size(10,120) 
$objLabel3.Size = New-Object System.Drawing.Size(280,20) 
$objLabel3.ForeColor = "Red"
$objLabel3.Text = "Log Path: <SourcePath>\ConversionLog.txt"
$objForm.Controls.Add($objLabel3) 
#EndRegion 

#Region
$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(175,150)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({
	If ($script:canceled -ne $true) {
		If ($objCombo.SelectedItem -eq "Yes") {
			$Recurse = $true
		} ElseIf ( $objCombo.SelectedItem -eq "No") {
			$Recurse = $false
		}

		$formswitches = @{
			Path = $($objTextBox.Text)
			Recurse = $Recurse
			Extension = $($objTextBox2.Text)
		}
		Export-PDF @formswitches
	}
})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(250,150)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Close"
$CancelButton.Add_Click({$script:canceled = $true;$objForm.Close()})
$objForm.Controls.Add($CancelButton)
#EndRegion

#Region
$outbox = New-Object System.Windows.Forms.TextBox
$outbox.Location = New-Object System.Drawing.Size(10,200)
$outbox.Size = New-Object System.Drawing.Size(465,300)
$outbox.Multiline = $true
$outbox.ScrollBars = "Vertical"
$outbox.Text = " 
Before running the conversion, please do the following:`n

1. Click `"Start`"
2. Click `"Devices and Printers`"
3. Right click on `"Adobe PDF`"
4. Click `"Printing preferences`"
5. Uncheck `"View Adobe PDF Results`"
6. Uncheck `"Ask to replace existing PDF file`"
7. Click `"OK`"

--WARNING--

Failure to uncheck the settings as directed above will cause `n
you to be prompted for each file that is converted.

--WARNING--
"
$objForm.Controls.Add($outbox)
#EndRegion

$objForm.Topmost = $True
$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

