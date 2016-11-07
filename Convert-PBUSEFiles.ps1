Function Export-PBUSEToCSV {
	Param(
  		[Parameter(Mandatory=$True,Position=1)]
   		[string]$XLS,
	
   		[Parameter(Mandatory=$False,Position=2)]
   		[string]$CSV = $XLS
	)
	
    $E = New-Object -ComObject Excel.Application
    $E.Visible = $false
    $E.DisplayAlerts = $false
    $wb = $E.Workbooks.Open($XLS)
    foreach ($ws in $wb.Worksheets) {
        $ws.SaveAs($CSV + ".csv", 6)
    }
    $E.Quit()
}

Function Convert-PBUSEFiles {
	$files = Get-ChildItem "\\NGWIA7-DISC4-20\e\Brown\PBUSE Data"
	Foreach ($file in $files) {
		Export-PBUSEToCSV -XLS "$file"
	}
}

Convert-PBUSEFiles