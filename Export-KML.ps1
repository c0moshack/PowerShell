$locations = Import-Csv "D:\OSD Distribution Point Plans\Copy of 2016 04.csv"
$outfile = "D:\OSD Distribution Point Plans\Armories.kml"

$header = @" 
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">
<Folder>
	<name>WIARNG Armories</name>
	<open>1</open>
"@
Out-File -Append -FilePath $outfile -InputObject $header
Foreach ($location in $locations) {
	$coords = Get-Coordinates $("$($location.ADDRESS), $($location.LOCATION), WI")
	$place = @" 
	 <Placemark id="$(Get-Random)">
		<name>$($location.UNIT)</name>
		<description></description>
		<Point>
			<coordinates>$($coords.Longitude),$($coords.Latitude),0</coordinates>
		</Point>
	</Placemark>
"@
	Out-File -Append -FilePath $outfile -InputObject $place
}
	
$footer = @" 
</Folder>
</kml>
"@
Out-File -Append -FilePath $outfile -InputObject $footer