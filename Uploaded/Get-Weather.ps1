# ----------------------------------------------------------------------------- 
# Script: Get-Weather.ps1
# Author: Paul Brown
# Date: 01/26/2016 13:11:13 
# Keywords: nws, weather
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-Weather {
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		ParameterSetName="lookup")]
		[array]$State,
		
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true,
		ParameterSetName="getweather")]
		[array]$StationID
	)
	
	<# 
	.Synopsis 
		Allows the user to get the station IDs for all weather stations in a 
		state. The ID can then be used to obtain the current weather observation
	.Example 
		Get-Weather -State <two letter state abbreviation>
	.Example
		Get-Weather -StationID <ID>
	.Example
		Pull the weather from all stations in the state
		Get-Weather -State "XX" | %{Get-Weather -StationID $_.StationID} | Out-GridView
	.Notes 
		NAME: Get-Weather.ps1 
		AUTHOR: Paul Brown
		LASTEDIT: 01/26/2016 13:11:13
		KEYWORDS: 
	.Link 
		https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#> 
	
	switch ($psCmdlet.ParameterSetName) {
		"lookup" {		
		
			$NWSURL = "http://w1.weather.gov/xml/current_obs/seek.php?state=" + $State.tolower() + "&Find=Find#XML"
			Try {
				$response = Invoke-WebRequest $NWSURL 
			} Catch {
			}
			
			$XMLLinks = $($response.Links)
			$urls = @()
			Foreach ($link in $XMLLinks) {
				$properties = @{}
				$name = $link.outerText
				# <A href="display.php?stid=KATW">Appleton-Outagamie</A>
				If ($($link.outerHTML -match '<A href="display\.php\?stid=([A-Z]{4})">(.+)<\/A>'))
				{
					$link.outerHTML -match '<A href="display\.php\?stid=([A-Z]{4})">(.+)<\/A>' | Out-Null
					$properties.StationID = $Matches[1]
					$properties.Name = $Matches[2]
					#$properties.Link = "http://w1.weather.gov/xml/current_obs/" + $properties.StationID + ".xml"
					$object = New-Object -TypeName PSObject -Property $properties
					$object.PSObject.TypeNames.Add('Weather.Station')
					$urls += $object
				}
			
			}
			
			return $urls
		}
		"getweather" {
		$results = @()
		Foreach ($sid in $StationID) {
			$stationurl = "http://w1.weather.gov/xml/current_obs/" + $sid.toupper() + ".xml"
			
			Try {
					$data = @{}
					$response = $(Invoke-RestMethod $stationurl).current_observation
					$data.Temp = $response.temp_f
					$data.WindChill = $response.windchill_f
					$data.Dewpoint = $response.dewpoint_f
					$data.Latitude = $response.latitude
					$data.Longitude = $response.longitude
					$data.Location = $response.location
					$data.WindDegrees = $response.wind_degrees
					$data.Wind = $response.wind_string
					$data.Pressure = $response.pressure_mb
					$data.Visibility = $response.visibility_mi
					$data.RelHumidity = $response.relative_humidity
					$data.Weather = $response.weather
					$data.Time = $response.observation_time
					
					$object = New-Object -TypeName PSObject -Property $data
					$object.PSObject.TypeNames.Add('Weather.Forecast')
					#$response = Invoke-WebRequest $stationurl 
				
					$results += $object
				} Catch {
				}
		}
		return $results
		}
	}
}

	


