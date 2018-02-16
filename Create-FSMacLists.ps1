# ----------------------------------------------------------------------------- 
# Script: Create-FSMacLists.ps1
# Author: Paul Brown
# Date: 01/17/2018 08:55:56 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Create-FSMacLists {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled1.ps1 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 01/17/2018 08:55:56 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    #[OutputType([psobject])]
    
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$File = "C:\Users\paul.j.brown\Desktop\Device Inventory\FSDeviceInventory.csv",
        
        [Parameter(
		Mandatory=$false,
		Position=1)]
		[string]$OutputDirectory = "C:\Users\paul.j.brown\Desktop\Device Inventory\test"
	)
    begin {
        $inventoryData = Import-Csv $File
        $segments = $inventoryData | Select-Object Segment -Unique
        Foreach ($s in $segments) {
            Try {
            New-Item -ItemType File -Path "C:\Users\paul.j.brown\Desktop\Device Inventory" -Name "Known_Devices_$($s.Segment).txt"
            } Catch {
                Write-Host "Unable to create file. The file either already exists or is not writable."
            }
        }
        $validcounter = 0
        $invalidcounter = 0

        $pattern = '^([0-9a-fA-F]{12})$'
    }
	

    process {
        Foreach ( $item in $inventoryData ) {
            If ( $item.Segment -ne "" -and $item.'MAC Address' -ne "" ) {
                If ( $item.'MAC Address' -match $pattern ) {
                    $($item.'MAC Address').ToUpper() | Out-File -Append -FilePath "C:\Users\paul.j.brown\Desktop\Device Inventory\Known_Devices_$($item.Segment).txt" -Encoding ascii
                    Write-Verbose "MAC $($item.'MAC Address') added to C:\Users\paul.j.brown\Desktop\Device Inventory\Known_Devices_$($item.Segment).txt" 
                    $validcounter++
                } Else {
                    "$($item.'MAC Address'),$($item.'IP Address'),$($item.'OS Fingerprint')" | Out-File -Append -FilePath "C:\Users\paul.j.brown\Desktop\Device Inventory\Invalid_Addresses.txt" -Encoding ascii
                    Write-Verbose "$($item.'MAC Address') is invalid!"
                    $invalidcounter++
                }

                
            }
        }
    }
    

    end {
        
        $v = "{0:N0}" -f $validcounter
        $i = "{0:N0}" -f $invalidcounter

        Write-Host "$v MAC addresses parsed."
        Write-Host "$i Invalid MAC Addresses. Check Invalid_Addresses.txt"
    }
    

}

Create-FSMacLists -Verbose