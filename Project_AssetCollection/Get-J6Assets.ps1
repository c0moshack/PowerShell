
# Load the function into the session
Function Get-J6Assets {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SearchBase = "OU=Computers,OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil",
		
		[Parameter(
		Mandatory=$false,
		Position=1,
		ValueFromPipeline=$false,
		ValueFromPipelineByPropertyName=$false)]
		[string]$CSV = "D:\Documents\J6\Programming\Powershell\AssetCollection\Files\PBUSE.xls.csv",
		
		[Parameter(
		Mandatory=$false,
		Position=2,
		ValueFromPipeline=$false,
		ValueFromPipelineByPropertyName=$false)]
		[string]$CSVKey = 'SER|DETECT SN|REG|LOT|SYS NO'
	)
################################################################################
	# Make sure the ActiveDirectory module is loaded
	If (-not $(Get-Module ActiveDirectory)) {
		Import-Module ActiveDirectory
	}

	# Load the custom scripts
	$collectorroot = $(Split-Path $script:MyInvocation.MyCommand.Path)
	$collectorfiles = Get-ChildItem $collectorroot | Where-Object {$_.Extension -like "*.ps1"} | Where-Object {$_.Name -notmatch "Get-J6Assets"}
	Foreach ($file in $collectorfiles) {
		. $file.FullName
		logit -TopicName "Loading Scripts" -message "Loaded::$($file.FullName)"
	}
################################################################################
			
	# Get ActiveDirectory Information
	$computers = Get-J6AdComputers -SearchBase $searchbase
	$adassets = Get-J6ADComputersAttributes -ComputerList $computers 
	$wmidata = Get-J6WMIData -ComputerList $($adassets | Select Name) 
	# Merge AD and WMI data into a single object
	$new = Add-Objects -BaseObject $adassets -BaseField "Name" -InField "Name" -InputObject $wmidata
	
	# Merge data with additonal data from CSV
	$pbuse = Import-Csv $CSV
	$newer = Add-Objects -BaseObject $new -BaseField 'Serial' -InField $CSVKey -InputObject $pbuse 
	
	$warranty = @()
	Foreach ($item in $newer) {
		If ($($item.Serial)) {
			$warranty += Get-DellWarranty -ServiceTag $item.Serial
		} Else {
		
		}
	}
	#$warranty = $newer |  %{Get-DellWarranty -ServiceTag $_.Serial} -ErrorAction SilentlyContinue
	$newest = Add-Objects -BaseObject $newer -BaseField 'Serial' -InField 'ServiceTag' -InputObject $warranty
	
	logit -TopicName "General" -message "Data collection is complete."
	
	return $newest
} # END Function Get-J6Assets

Get-J6Assets -SearchBase "OU=USB Exempt,OU=J6-DISC4,OU=Computers,OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil" | Select * #| Export-Csv "D:\Documents\J6\Programming\Powershell\AssetCollection\Files\Inventory_030116.csv" -NoTypeInformation