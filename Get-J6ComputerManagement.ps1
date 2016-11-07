
# Constructor
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

# Form settings
$frmMain = New-Object System.Windows.Forms.Form
$frmMain.Text = "J6 Computer Managemnt"
$frmMain.Size = New-Object System.Drawing.Size(1000, 650)

# Add the button to initiate the search
$btnGetObjects = New-Object System.Windows.Forms.Button
$btnGetObjects.Size = New-Object System.Drawing.Size(50,25)
$btnGetObjects.Location = New-Object System.Drawing.Point(10,5)
$btnGetObjects.Text = "Get"

# Add the output text box
$tbxthis = New-Object System.Windows.Forms.TextBox
$tbxthis.Multiline = $true
$tbxthis.Scrollbars = "Vertical"
$tbxthis.Location = New-Object System.Drawing.Point(10,32)
$tbxthis.Size = New-Object System.Drawing.Size(950, 550)

# Set status lable
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready"
$lblStatus.Size = New-Object System.Drawing.Size(50,25)
$lblStatus.Location = New-Object System.Drawing.Point(100,10)

# Add the controls to the form
$frmMain.Controls.Add($tbxthis)
$frmMain.Controls.Add($btnGetObjects)
$frmMain.Controls.Add($lblStatus)

################################################################################
# Custom Functions
################################################################################
Function Get-J6ComputerManagement {
	Param([Parameter(Mandatory=$True)]
	    [string]$ComputerName)
	
	$objects = @()
		
	# Define the OU to be searched instead of searching the whole forest.
	$domain = $(Get-ADDomain ).DistinguishedName
	$state = "NGWI"
	$stateou = "OU=$state,OU=States," 
	$searchOU = $stateou + $domain

	$found = $(Get-ADComputer -Filter "Name -like `"$ComputerName`"" -SearchBase $searchOU -SearchScope Subtree -Properties *)
	
	Foreach ($pc in $found) {
		$results = @{}
		$results.Name = $pc.Name
		$results.Created = $pc.whenCreated
		$results.Changed = $pc.whenChanged
		$dn = $($pc.DistinguishedName).Split(",")
		$results.OU = $dn[1] + $dn[2] + $dn[3]
		$object = New-Object -TypeName PSObject -Property $results
		$objects += $object
	}
		
	return $objects
}
################################################################################

# Main Loop
function Main{
     [System.Windows.Forms.Application]::EnableVisualStyles()
     [System.Windows.Forms.Application]::Run($frmMain)
}

# Form Functions
$btnGetObjects.Add_Click({
	$lblStatus.Text = " Searching... `r`n"
	Foreach ($entry in $(Get-J6ComputerManagement -ComputerName "NGWINB-X9GA0-*")) {
		$tbxthis.Text += "$($entry.Name) $($entry.Created) $($entry.Changed) $($entry.OU) `r`n"
	}
	$lblStatus.Text += " Finished `r`n"
	})
	

	
# Launch the program
Main