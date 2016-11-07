$Path = "\\ng\ngwi\Home\JFHQ\paul.j.brown"
#$Path = "F:\ConversionTest"
$temp1 = 0
$temp2 = 0
$xfdls = $(Get-ChildItem $Path -Recurse -Filter "*.xfdl")
Foreach ($xfdl in $xfdls) {
	$temp1 += $xfdl.Length
}
$xfdlsizeraw = $(Measure-Object -InputObject $temp1 -sum)
$xfdlsize = [double]$("{0:N2}" -f ($xfdlsizeraw.sum / 1MB))

$pdfs = $(Get-ChildItem $Path -Recurse -Filter "*.pdf" | Where-Object {$xfdls.Basename -contains $_.Basename})
Foreach ($pdf in $pdfs) {
	$temp2 += $pdf.Length
}
$pdfsizeraw = $(Measure-Object -InputObject $temp2 -sum)
$pdfsize = [double]$("{0:N2}" -f ($pdfsizeraw.sum / 1MB))

"XFDL Size in MB: $xfdlsize"
"PDF  Size in MB: $pdfsize"
"Percent increase: " + [double]$("{0:N2}" -f $($($pdfsize/$xfdlsize *100)-100))

