$log = Get-MDTLog -Path "\\NGWIA7-DISC4-20\MDTShare\Logs\SN_VMware-\BDD.LOG"
$prop = @()
Foreach ($item in $log.Event) {
	$abc = @{}
	$item   -match 'Property\s(\w+).+=(.+)' | Out-Null
	
	$abc.Name = $Matches[1]
	$abc.Value = $Matches[2]
	$object = New-Object -TypeName PSObject -Property $abc
	
	$prop += $object
	
}

$prop | Select Name,Value | Out-GridView
