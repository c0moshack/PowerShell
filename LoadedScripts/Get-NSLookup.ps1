# ----------------------------------------------------------------------------- 
# Script: Untitled
# Author: Paul Brown
# Date: 06/24/2016 08:21:57 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Get-NSLookup{
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
	    	LASTEDIT: 06/24/2016 08:21:57 
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
		[string]$Name
	)
	

	Function Start-WinProcess {
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
		    	LASTEDIT: 06/23/2016 10:27:36 
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
			[string]$Executable,
			
			[Parameter(
			Mandatory=$false,
			Position=1)]
			[string]$Arguments
		)
		
		$pinfo = New-Object System.Diagnostics.ProcessStartInfo
		$pinfo.Filename = $Executable
		$pinfo.RedirectStandardError = $true
		$pinfo.RedirectStandardOutput = $true
		$pinfo.UseShellExecute = $false
		$pinfo.Arguments = $Arguments

		$p = New-Object System.Diagnostics.Process
		$p.StartInfo = $pinfo
		$p.Start() | Out-Null
		$p.WaitForExit()
		
		$output = @{}
		$output.Output = $p.StandardOutput.ReadToEnd()
		$output.Error = $p.StandardError.ReadToEnd()
		$output.ExitCode = $p.ExitCode
		
		$result = New-Object psobject -Property $output
		
		return $result
	} 
	
	Try {
		$res = Start-WinProcess -Executable nslookup -Arguments $Name
		$out = $res.Output -replace "`r`n"," "
		$out = $out -replace '\s+',' '
		$out -match 'Server:\s(.+)\sAddress:\s(.+)\sName:\s(.+)Addresse?s?:\s(.+)'
		$parsed = $Matches
		$outobj = New-Object -TypeName psobject
		$outobj | Add-Member -MemberType 'NoteProperty' -Name Server -Value $parsed[1]
		$outobj | Add-Member -MemberType 'NoteProperty' -Name Address -Value $parsed[2]
		$outobj | Add-Member -MemberType 'NoteProperty' -Name Name -Value $parsed[3]
		$outobj | Add-Member -MemberType 'NoteProperty' -Name Addresses -Value $parsed[4]#$($parsed[4] -replace " ",",")
	} Catch {
		Write-Error -Message "Unable to resolve $Name"
	}
	return $outobj
} 