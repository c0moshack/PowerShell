# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 04/19/2016 08:09:41 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-CurrentServerConfig {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Untitled 
	    	AUTHOR: paul.brown.sa 
	    	LASTEDIT: 04/19/2016 08:09:40 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param(
		[Parameter(
		Mandatory=$false,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SourceServer,
		
		[Parameter(
		Mandatory=$false,
		Position=1,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$DestinationServer,
		
		[Parameter(
		Mandatory=$false,
		Position=2)]
		[string]$Path
	)
	If ($(Get-Item $Path) -isnot [System.IO.DirectoryInfo]) {
		Write-Error "Enter the path to a directory, not a file!"
		End
	} 
	
	$confpath = $Path.TrimEnd("\","/") + "\$DestinationServer\$DestinationServer.ps1" 
	$mofpath = $Path.TrimEnd("\","/") + "\$DestinationServer"
	If (-not $(Test-Path $mofpath)) {	
		New-Item -ItemType Directory -Path $Path -Name $DestinationServer
	}
	
	Try {
		$roles = $(Invoke-Command -ComputerName $SourceServer -ScriptBlock {Import-Module ServerManager; Get-WindowsFeature | Select * | Where-Object {$_.Installed -eq $true}})
	} Catch {
		Write-Host $_.Exception.Message
	}
	
	# Add header to configuration script
	$header = @" 
configuration ServerMigration 
{
    Node $DestinationServer
    {
"@
	
	Out-File -InputObject $header -FilePath $confpath
	
	# Add roles from existing server to configuration script
	Foreach ($role in $roles) {
		$Name = $($role.Name) -replace "-"," "
		
		$roleblock = @" 
		WindowsFeature `'$Name`'
	    {
	        Name = `'$($role.Name)`'
			Ensure = "Present"
	    }
"@
		
		Out-File -InputObject $roleblock -FilePath $confpath -Append
	}
	
	# Add footer to configuration script
	$footer = @" 
    }
}
"@
	
	Out-File -InputObject $footer -FilePath $confpath -Append
	
	#Generat the MOF file
	If (Test-Path $confpath) {
		. $confpath
		ServerMigration -OutputPath $mofpath
	}
} 