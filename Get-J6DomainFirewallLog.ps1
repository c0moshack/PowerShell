# ----------------------------------------------------------------------------- 
# Script: Untitled2.ps1
# Author: Paul Brown
# Date: 03/06/2017 10:01:40 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-J6DomainFirewallLog {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled2.ps1 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 03/06/2017 10:01:40 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$DomainFirewallLog,

        [switch]$ResolveNames
	)

    begin {
    
        $LogOutput = @()

    }
	

    process {
        $logdata = Get-Content $DomainFirewallLog
 
        Foreach ($entry in $logdata) {
            $line = $entry -split " "
            If (($line[4] -ne $null) -and ($line[4] -ne 'protocol')) {
                
                #Fields: date time action protocol src-ip dst-ip src-port dst-port size tcpflags tcpsyn tcpack tcpwin icmptype icmpcode info path

                $props = @{}
                $props.date = $line[0]
                $props.time = $line[1]
                $props.action = $line[2]
                $props.protocol = $line[3]
                $props.srcIP = $line[4]
                $props.dstIP = $line[5]
                $props.srcPORT = $line[6]
                $props.dstPORT = $line[7]
                $props.size = $line[8]
                $props.tcpflags = $line[9]
                $props.tcpsyn = $line[10]
                $props.tcpack = $line[11]
                $props.tcpwin = $line[12]
                $props.icmptype = $line[13]
                $props.icmpcode = $line[14]
                $props.info = $line[15]
                $props.path = $line[16]

                If ($ResolveNames) {
                    $props.srcDNS = Resolve-DnsName $line[4] -ErrorAction SilentlyContinue | Select Name,NameHost
                    $props.dstDNS = Resolve-DnsName $line[5] -ErrorAction SilentlyContinue | Select Name,NameHost
                }

                $to = New-Object -TypeName psobject -Property $props

                $LogOutput += $to

            }
        }

    }
    

    end {
    
        return $LogOutput

    }
    

}