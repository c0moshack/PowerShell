﻿# ----------------------------------------------------------------------------- 
# Script: Get-J6UnitADReport.ps1
# Author: Paul Brown
# Date: 05/24/2017 11:50:08 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-J6UnitADReport {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-J6UnitADReport.ps1 
	    	AUTHOR: paul.j.brown 
	    	LASTEDIT: 05/24/2017 11:50:08 
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
		[string]$UIC
	)
    begin {
        $unitcomputers =@()
        $ADComputerAssets = Get-ADComputer -Filter * -Property * -searchbase "OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil"

    }
	

    process {
    
        $comps = $ADComputerAssets | Where-Object {$_.Name -like "NG*-$UIC*"}
        
        Foreach ( $comp in $comps ) {
            $props = @{}
            $props.Name = $comp.Name
            $props.Modified = $comp.Modified
            $props.CN = $comp.CanonicalName
            $props.ExpirationDate = (Get-Date $comp.Modified).AddDays(45)
            If ( ($props.ExpirationDate) -le (Get-Date) ) {
                $props.Expired = $true
            } Else {
                $props.Expired = $false
            }
            $props.Serial = $comp.serialNumber

            $to = New-Object -TypeName psobject -Property $props

            $unitcomputers += $to
        }
    }
    

    end {
    
        return $unitcomputers

    }
    

}
