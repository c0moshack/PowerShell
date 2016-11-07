Function Get-Coordinates {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-Coordinates.ps1 
	    	AUTHOR: Paul Brown
	    	LASTEDIT: 04/12/2016 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$Address,
		
		[Parameter(
		Mandatory=$true,
		Position=1)]
		[string]$Key,
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$APIURL = "https://maps.googleapis.com/maps/api/geocode/json?address=$Address&key=$Key"
	)
	
	$request = Invoke-RestMethod $APIURL
	$lat = $($request.results.geometry.location.lat)
	$lon = $($request.results.geometry.location.lng)
	$coordinates = New-Object -TypeName PSObject -Property @{"Latitude"=$lat; "Longitude"=$lon}
	return $coordinates
}
