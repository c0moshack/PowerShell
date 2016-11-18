# ----------------------------------------------------------------------------- 
# Script: Set-HomeDrivePermissions.ps1
# Author: Paul Brown
# Date: 11/17/2016 14:08:06 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Set-HomeDrivePermissions {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Set-HomeDrivePermissions.ps1
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 11/17/2016 14:08:06 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[array]$Path,

        [Parameter(
        Mandatory=$true,
        Position=1)]
        [string]$Domain,

        [Parameter(
        Mandatory=$false,
        Position=2)]
        [switch]$Fix
	)
	
    If ($VerbosePreference) {
        Write-Verbose "Verbose output is enabled"
    }

    $directories = $(Get-ChildItem $Path | Where {$_.psIsContainer -eq $true})

    Foreach ($dir in $directories) {
        Try {
            $user = $(Get-ADUser $($dir.Name))
            $currentACL = Get-ACL $($dir.FullName)
            Write-Host $($dir.Name)
        } Catch {
            Write-Host "$($dir.Name) (Does not exist in AD)" -BackgroundColor DarkYellow
        }
    }

    
    If ($Fix) {
        Write-Warning "The -Fix option was given, directory ACLs will be modified."
        Try {
            $Proceed = Read-Host "Do you wish to proceed? (y|n)" 
            If ($Proceed.ToLower() -ne "y") {
                Throw "Script execution aborted by user."
            }
        } Catch {
            Write-Host $_.Exception.Message -BackgroundColor Red -ForegroundColor Yellow
            break
        }
    }

 

}