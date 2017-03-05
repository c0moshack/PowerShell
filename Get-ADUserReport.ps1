# ----------------------------------------------------------------------------- 
# Script: Get-ADUserReport.ps1
# Author: Paul Brown
# Date: 03/04/2017 10:28:06 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-ADUserReport {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-ADUserReport.ps1
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 03/04/2017 10:28:06 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SearchBase = $(Get-ADDomain).UsersContainer
	)
    begin {
	    
        $users = Get-ADUser -SearchBase $SearchBase -Filter * -Properties *
        $ADUsers = @()

    }
    process {
    
        Foreach ($user in $users) {
            $props = @{}
            $props.First = $user.GivenName
            $props.Middle = $user.Initials
            $props.Last = $user.Surname
            $props.UserName = $user.SamAccountName
            $props.Email = $user.mail
            $props.Expires = $user.AccountExpirationDate
            $props.Unit = ($user.DistinguishedName -replace "CN=","" -replace "\\","" -split ",OU=")[1]
            
            $to = New-Object -TypeName psobject -Property $props
            $ADUsers += $to
        }
    
    }
    
    end {
    
        return $ADUsers
    
    }
    

}

Get-ADUserReport -SearchBase "OU=Users,OU=32bct,DC=army,DC=smil,DC=mil" | Export-Csv -NoTypeInformation "C:\Users\paul.brown.sa\Desktop\ADReport_$(Get-Date -Format "MMddyyyy_HHmm").csv"