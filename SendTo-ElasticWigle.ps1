# ----------------------------------------------------------------------------- 
# Script: Untitled1.ps1
# Author: Paul Brown
# Date: 02/16/2018 11:30:00 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function SendTo-Elasticsearch {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled1.ps1 
	    	AUTHOR: Paul 
	    	LASTEDIT: 02/16/2018 11:30:00 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    [OutputType([psobject])]
    
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0)]
		[string]$ESURI = "http://192.168.202.130:9200",

        [Parameter(
		Mandatory=$false,
		Position=1)]
		[string]$CSV = 'C:\Users\Paul\Desktop\elasticcsv\wiglenew.csv',

        [Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Index = "wigle",

        [Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Out = "C:\Users\Paul\Desktop\elasticcsv\test.json"

	)
    begin {
        $csvdata = Import-Csv $CSV  
    }
	
    process {
        
        $subindex = @()
        $location = @()
        $i = 1
        Foreach ( $line in $csvdata ) {
            $indexnumber = $i++
            $subindex = [pscustomobject]@{
                    _index = "wigle";
                    _type = "doc";
                    _id = $indexnumber
                }

            $indexdoc = [pscustomobject]@{
                index = $subindex
                #index = {}
            }

            $indexdoc | ConvertTo-Json -Depth 3 -Compress | Out-File $Out -Append

            #set the fields            
            $location = [pscustomobject]@{
                    "lat" = $line.CurrentLatitude;
                    "lon" = $line.CurrentLongitude
                }

            $node = [pscustomobject]@{
                "mac" = $line.MAC;
                "sid" = $line.SSID;
                "authmode" = $line.AuthMode;
                "firstseen" = $line.FirstSeen;
                "channel" = $line.Channel;
                "rssi" = $line.RSSI;
                "location" = $location;
                "altitudemeters" = $line.AltitudeMeters;
                "accuracymeters" = $line.AccuracyMeters;
                "wifitype" = $line.Type
            }

            
            $node | ConvertTo-Json -Depth 3 -Compress | Out-File $Out -Append
            
            $doc = "$($indexdoc | ConvertTo-Json -Depth 3 -Compress)`r`n$($node | ConvertTo-Json -Depth 3 -Compress)`r`n"
            #$doc
            Invoke-RestMethod -Method Post -Uri "$ESURI/$Index/doc/_bulk" -ContentType 'application/x-ndjson' -Body $doc -ErrorAction Stop | Out-Null
        }

        
    }

    end {
        #Try {
            #Invoke-RestMethod -Method Post -Uri "$ESURI/$Index/doc/_bulk" -ContentType 'application/x-ndjson' -Body $(Get-Content $Out) -ErrorAction Stop | Out-Null
        #} Catch {
            #$_.Exception.Message
        #}
        Write-Host "Complete"
    }
    

}

SendTo-Elasticsearch