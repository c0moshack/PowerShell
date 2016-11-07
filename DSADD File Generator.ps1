$prefix = "CPOF-127"
$range = 1..10
$path = "OU=Computers,DC=ng"

Foreach ($n in $range) {
	$format = $n.ToString("00")
	Write-Output "dsadd computer CN=$prefix-$format,$path" | Out-File "$env:USERPROFILE\Desktop\DSADD.bat" -Append
}