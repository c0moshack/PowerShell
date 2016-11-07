$computers = Read-Host "Enter path to computer list"
$directory = [System.IO.Path]::GetDirectoryName($computers)
$filename = [System.IO.Path]::GetFileNameWithoutExtension($computers)
$extension = [System.IO.Path]::GetExtension($computers)
$outfile = "$directory\$filename-RESULTS$extension"

Foreach ($computer in (Get-Content $computers)) {

	IF (-not (Test-Connection -ComputerName $computer -Count 1 -BufferSize 16 -Quiet))
	{
		$computer + " Unreachable" >>  $outfile 
	}
	Elseif ((Get-HotFix -ComputerName $computer -Id "KB2957503")){
		$computer + " Patched" >> $outfile
	} 
	Else {
		$computer + " NOT Patched" >> $outfile
	}
}
