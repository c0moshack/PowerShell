# ----------------------------------------------------------------------------- 
# Script: Untitled2.ps1*
# Author: Paul Brown
# Date: 03/04/2017 15:06:21 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-WebSiteStatus {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled2.ps1* 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 03/04/2017 15:06:21 
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
		[string]$URL
	)
    begin {}
	

    process {
    
        # First we create the request.
        $HTTP_Request = [System.Net.WebRequest]::Create($URL)
        # We then get a response from the site.
        $HTTP_Response = $HTTP_Request.GetResponse()
        # We then get the HTTP code as an integer.
        $HTTP_Status = [int]$HTTP_Response.StatusCode
        If ($HTTP_Status -eq 200) { 
            return $true
        } Else {
            return $false
        }
        # Finally, we clean up the http request by closing it.
        $HTTP_Response.Close()

    }
    

    end {}
    

}