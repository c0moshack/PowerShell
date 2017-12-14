# ----------------------------------------------------------------------------- 
# Script: Untitled3.ps1
# Author: Paul Brown
# Date: 12/13/2017 08:43:57 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function <NAME> {
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
	    	LASTEDIT: 12/13/2017 08:43:57 
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
		#[string]$WorkDirectory = $(Split-Path $MyInvocation.MyCommand.Path)
        [string]$WorkDirectory = "C:\Users\paul.j.brown\Desktop\WindowsEVTtoJSON"
	)
    begin {
        # Set the log name format
        $LogName = "WinEVTLog-$(Get-Date -Format 'yyyy-MM-dd').log"
        $LogDirectory = "$WorkDirectory\Logs"
        # Check for existing log files and read in the contents. The log files are
        # used to prevent processing of files that were already processed.
        $ProcessedFiles = @()
        Foreach ($log in $(Get-Childitem $LogDirectory)) {
            Write-Verbose "[Importing Log]::$log.FullName"
            $ProcessedFiles += $(Import-Csv $log.FullName).File
        }

        # Set path to log dropbox
        $EventLogDropbox = "$WorkDirectory\Dropbox"
        # Get a list of files currently in the dropbox.
        $EventFiles = Get-ChildItem -Recurse $EventLogDropbox

        # Set output path
        $OutputDirectory = "$WorkDirectory\Output"

        # Establish a list of logs to be processed.
        $NeedsProcessing = @()
        $AlreadyProcessed = @()

        Foreach ($File in $EventFiles) {
            If ($ProcessedFiles -contains $($File.FullName)) {
                $AlreadyProcessed += $File
            } Else {
                $NeedsProcessing += $File
            }
        }

    }
	

    process {
        Foreach ($NewFile in $NeedsProcessing) {
            Get-WinEvent -Path $($NewFile.FullName) -Oldest | ConvertTo-Json | Out-File "$OutputDirectory\$($NewFile.Name).json"
            Out-File $("$LogDirectory\$LogName") -InputObject "$($NewFile.FullName),$(Get-Date -Format 'yyyy-MM-dd')" -Append
        }

    }
    

    end {
        
    }
    

}