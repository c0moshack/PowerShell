# ----------------------------------------------------------------------------- 
# Script: Untitled1.ps1
# Author: Paul Brown
# Date: 03/30/2018 08:20:47 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Elastic-ReIndex {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled1.ps1 
	    	AUTHOR: paul.j.brown 
	    	LASTEDIT: 03/30/2018 08:20:47 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    [OutputType([psobject])]
    
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$IndexPattern,

        [Parameter(
		Mandatory=$true,
		Position=1)]
		[string]$Username,

        [Parameter(
		Mandatory=$true,
		Position=2)]
		[string]$Password

	)
    begin {
        # Encode the credentials to Base64 and setup headers
        $base64creds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($("$($Username):$($Password)")))

        $headers = @{ Authorization = "Basic $base64creds" }

        # Retreive the list of indices
        $response = Invoke-RestMethod -Method GET -UseBasicParsing -Headers $headers -Uri "https://ngwib6-disc4-50.ng.ds.army.mil:9200/_cat/indices/$IndexPattern"
        $responselines = ($response -split "\n")

        $indices = @()
        Foreach ( $index in $responselines ) {
            $index = ($index -split "\s+")
            If ( $index ) {
                $indexprops = [pscustomobject]@{
                    health = $index[0]
                    status = $index[1]
                    index = $index[2]
                    uuid = $index[3]
                    pri = $index[4]
                    rep = $index[5]
                    docs_count = $index[6]
                    docs_deleted = $index[7]
                    store_size = $index[8]
                    pri_store_size = $index[9]

                }

                $indices += $indexprops
            }
        }
    }
	

    process {
        
        ($indices | Where-object { $_.index -notmatch ".*_1" -and $($_.index) -notmatch ".*-$(Get-Date -Format 'yyyy.MM.dd')"}).index
        $proceed = Read-Host "Proceed? (y/n):"

        If ( $proceed.ToLower() -eq "y") {
            Foreach ( $index in $($indices | Where-object { $_.index -notmatch ".*_1" }) ) {
                If ( $($index.index) -notmatch ".*-$(Get-Date -Format 'yyyy.MM.dd')" ) {
                    $reindexjson = "{ `"source`": { `"index`": `"$($index.index)`" }, `"dest`": { `"index`": `"$($index.index)_1`" } }"
                    $response = Invoke-RestMethod -Method POST -UseBasicParsing -ContentType "application/json" -Headers $headers -Uri "https://ngwib6-disc4-50.ng.ds.army.mil:9200/_reindex" -Body $reindexjson
                    Write-Host "Reindexed: $($index.index) \n Status: $response"
            
                    $deleteresponse = Invoke-RestMethod -Method DELETE -UseBasicParsing -ContentType "application/json" -Headers $headers -Uri "https://ngwib6-disc4-50.ng.ds.army.mil:9200/$($index.index)"
                    Write-Host "Deleted: $($index.index) \n Status: $deleteresponse" -ForegroundColor Gray
                }
            }    
        } Else {
            Write-Host "User Aborted"
        }
    }
    

    end {
        #return $reindexjson
    }
    

}

Elastic-ReIndex -IndexPattern "metricbeat-*" -Username "elastic" -Password 'Pa$$Word1234567'