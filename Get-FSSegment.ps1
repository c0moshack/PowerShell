# ----------------------------------------------------------------------------- 
# Script: Untitled3.ps1
# Author: Paul Brown
# Date: 06/28/2017 08:44:16 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-FSSegments {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled3.ps1 
	    	AUTHOR: paul.j.brown 
	    	LASTEDIT: 06/28/2017 08:44:16 
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
		[string]$Path
	)
    begin {
        $xmldata = [XML](Get-Content $Path)
        $data = @()
    }
	

    process {
        $mainGroup = $xmldata.SelectNodes("//*[@SEGMENT_ID]")
        
        Foreach ($group in $mainGroup) {
            If ($group.RANGES) {

                $props = @{}
                $props.Name = $group.attributes['NAME'].value
                If ($group.RANGES.Attributes.Count -gt 1) {
                    $ranges = $group.RANGES
                    Foreach ($r in $ranges) {
                        $props.RangeStart = $r.RANGE.split("-")[0]
                        $props.RangeEnd = $r.RANGE.split("-")[1]
                        $to = New-Object -TypeName psobject -Property $props
                        $data += $to
                    }
                } Else {
                    $props.RangeStart = $group.RANGES.RANGE.Split("-")[0]
                    $props.RangeEnd = $group.RANGES.RANGE.Split("-")[1]
                    $to = New-Object -TypeName psobject -Property $props
                    $data += $to
                }
            }
        }
    }
    

    end {
        return $data
    }
    

}

Get-FSSegments -Path "Z:\ForeScout\SEGMENTS_IN SCOPE_20170627.xml" | Sort Range | Export-Csv -NoTypeInformation "Z:\ForeScout\Segments_20170628.csv"