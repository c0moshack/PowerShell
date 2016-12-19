#EXAMPLE 1
$object = New-Object –TypeName PSObject
$object | Add-Member –MemberType NoteProperty –Name Name –Value $item
$object | Add-Member –MemberType NoteProperty –Name Version –Value "NOT FOUND"
$object | Add-Member –MemberType NoteProperty –Name Vendor –Value "N/A"
Write-Output $object

#EXAMPLE 2
$object = New-Object -TypeName PSObject -Property ($properties = @{'Application'=$app;'Required Version'=$($AGMSoftware.$app);'Installed Version'=$($($Installed | Where-Object {$_.Name -match $app}).Version);'Status'="Current"})

#EXAMPLE 3
$info = @{}
$info.OSBuild=$os.BuildNumber
$info.OSVersion=$os.version
$info.BIOSSerial=$bios.SerialNumber
$object = New-Object –TypeName PSObject –Prop $info
Write-Output $object