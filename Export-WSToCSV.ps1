Function Export-WSToCSV {
	Param(
  		[Parameter(Mandatory=$True,Position=1)]
   		[string]$XLS,
	
   		[Parameter(Mandatory=$False,Position=2)]
   		[string]$CSV
	)
	
    $E = New-Object -ComObject Excel.Application
    $E.Visible = $false
    $E.DisplayAlerts = $false
    $wb = $E.Workbooks.Open($XLS)
    foreach ($ws in $wb.Worksheets) {
		If ($CSV) {
        	$ws.SaveAs($CSV + $ws.Name + ".csv", 6)
		} Else {
			$ws.SaveAs($XLS + $ws.Name + ".csv", 6)
		}
    }
    $E.Quit()
}
