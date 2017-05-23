# ----------------------------------------------------------------------------- 
# Script: Get-InstallDate.ps1*
# Author: Paul Brown
# Date: 04/03/2017 08:41:04 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-InstallDate {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-InstallDate.ps1* 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/03/2017 08:41:04 
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
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$ComputerName = $env:COMPUTERNAME
	)
    begin {}
	

    process {
        Try {
            ([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName).InstallDate)
        } Catch {
            Write-Error $_.Exception.Message
        }
    
    }
    

    end {}
    

}

Get-InstallDate
