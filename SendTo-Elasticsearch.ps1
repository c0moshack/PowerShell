# ----------------------------------------------------------------------------- 
# Script: SendTo-Elasticsearch.ps1
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
	    	NAME: SendTo-Elasticsearch.ps1 
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
		[string]$CSV = "C:\Users\Paul\Downloads\2016-17_school_reportcard_data.csv",

        [Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Index = "reportcards",

        [Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Out = "C:\Users\Paul\Downloads\2016-17_school_reportcard_data.json",

        [Parameter(
        Mandatory=$false,
        ParameterSetName="Template")]
        [switch]$Template,

        [Parameter(
        Mandatory=$false,
        ParameterSetName="Template")]
        [string]$TemplateName = "reportcards",

        [Parameter(
        Mandatory=$false,
        ParameterSetName="Template")]
        [string]$Shards = 1

	)
    begin {
        $csvdata = Import-Csv $CSV 
        # This line gets the column headers from the csv
        $headers = $csvdata | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty 'Name' 
        #$jsondata = @()
        $i = 1
    }
	
    process {
        If ( !$Template ) {
            Foreach ( $line in $csvdata ) {
                $subindex = @()
                $location = @()
                $node = @()

                # Build the index line for the document
                $indexnumber = $i++
                $subindex = [pscustomobject]@{
                        _index = "$Index-$(Get-Date -Format 'yyyy.MM.dd')";
                        _type = "doc";
                        _id = $indexnumber
                    }
                $indexdoc = [pscustomobject]@{
                    index = $subindex
                    #index = {}
                }
                $indexdoc | ConvertTo-Json -Depth 3 -Compress | Out-File $Out -Append

                # Define the fields and fill in the data for each document
            
                # If the latitude and longitude field are present parse them into the location field
                #if ( $headers -match "*lat*" -or $headers -match "*lon*" ) {
                #    $location = [pscustomobject]@{
                #        "lat" = $line.$($headers -match "*lat*");
                #        "lon" = $line.$($headers -match "*lon*")
                #    }
                #}

                $node = @{}
                # Assing the rest of the fields
                foreach ( $h in $headers ){
                       $node.Add($h, $line.$h)
                       #$h = $line.$h
                }
                        
                $node | ConvertTo-Json -Depth 3 -Compress | Out-File $Out -Append
            
                $jsondata += "$($indexdoc | ConvertTo-Json -Depth 3 -Compress)`r`n$($node | ConvertTo-Json -Depth 3 -Compress)`r`n"
            
            }

            Foreach ( $d in $jsondata ) {
                Try {
                    Invoke-RestMethod -Method Post -Uri "$ESURI/$Index/doc/_bulk" -ContentType 'application/x-ndjson' -Body $jsondata -ErrorAction Stop | Out-Null
                } Catch {
                    $_.Exception.Message
                }
            }
        } Else {
            # Generate Template
                
            $properties = @{}
            # Assing the rest of the fields
            foreach ( $h in $headers ){
                $systemtype = $($csvdata[0].$h).GetType()
                if ($systemtype.Name -eq "Int32") {
                    $stype = "integer"

                } elseif ( $systemtype.Name -eq "string"  ) {
                    $stype = "text"
                } else {
                    $stype = $systemtype.Name
                }

                # determine the item type
                $itemtype = Read-Host "Please enter type of text, keyword, float, or integer for the following data.`nDefault is in brackets.`n`nName: $h`nValue:  '$($csvdata[0].$h)'`n[$stype]"


                $ttype = [pscustomobject]@{
                    type = $itemtype
                }
                $properties.Add($h, $ttype)
            }

            $tproperties = [pscustomobject]@{
                properties = $properties
            }

            $tdoc = [pscustomobject]@{
                doc = $tproperties
            }

            $tshards = [pscustomobject]@{
                number_of_shards = $Shards
            }

            $templatedoc = [pscustomobject]@{
                index_patterns = "[$TemplateName-$(Get-Date -Format 'yyyy.MM.dd')]";
                settings = $tshards;
                mappings = $tdoc
            }

            $templatedoccompressed = $templatedoc | ConvertTo-Json -Depth 10 -Compress
            Try {
                #Invoke-RestMethod -Method Post -Uri "$ESURI/_template/$TemplateName" -ContentType 'application/json' -Body $templatedoccompressed -ErrorAction Stop | Out-Null
                $templatedoc | ConvertTo-Json -Depth 10 -Compress | Out-File "C:\Users\Paul\Downloads\2016-17_school_reportcard_data_template.json"
            } Catch {
                $_.Exception.Message
            }

        }
    }

    end {
        Write-Host "Complete"
    }
    

}

SendTo-Elasticsearch -Template