# ----------------------------------------------------------------------------- 
# Script: Get-J6HDriveReport.ps1
# Author: Paul Brown
# Date: 06/08/2017 11:59:54 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-J6HDriveReport {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-J6HDriveReport.ps1 
	    	AUTHOR: paul.j.brown 
	    	LASTEDIT: 06/08/2017 11:59:54 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[CmdletBinding()]
    #[OutputType([psobject])]
    
	Param(
		[Parameter(
		Mandatory=$true,
		Position=0,
		ValueFromPipeline=$true,
		ValueFromPipelineByPropertyName=$true)]
		[string]$SearchBase,

        [Parameter(
        Mandatory=$true,
        Position=1)]
        [string]$HomeDrivePath,

        [switch]$Fix
	)
    begin {
        $adusers = Get-ADUser -Filter * -Properties * -SearchScope Subtree -SearchBase $SearchBase
        $homedrives = Get-ChildItem -Path $HomeDrivePath

        $records = @()
    }
	

    process {
        Foreach ($aduser in $($adusers | Where-Object {$_.SamAccountName -ne 'wiarng.soldier'}) ) {
            $splitname = $($aduser.SamAccountName).Split(".")
            $p = @{}
            $p.SamAccountName = $aduser.SamAccountName
            $p.GivenName = $aduser.GivenName
            $p.Initials = $aduser.Initials
            $p.Surname = $aduser.Surname
            $p.HomeDirectory = $aduser.HomeDirectory
            $p.HomeDirectoryFound = $($homedrives | Where-Object {$_.Name -like "*$($splitname[0])*$($splitname[-1])*"}).FullName
            $p.HomeDirectoryName = $($homedrives | Where-Object {$_.Name -like "*$($splitname[0])*$($splitname[-1])*"}).Name
            $p.Match = $null

            $to = New-Object -TypeName psobject -Property $p

            $records += $to
        }

        Foreach ($homedrive in $homedrives) {
            If ($records.HomeDirectoryFound -notcontains $homedrive.FullName) {
                
                #Write-Verbose "Found orphaned homedrive: $($homedrive.Fullname)"
                $username = $($homedrive.Name).Split(".")
                #Write-Verbose "Username:: $username"
                $user = $adusers | Where-Object {$_.SamAccountName -like "*$($username[0])*$($username[-1])*" -and $_.SamAccountName -notlike '*.sa'}

                If ($user -ne $null) {

                    #Write-Verbose "Found user: $($user.Name)"
                    $p = @{}
                    $p.SamAccountName = $user.SamAccountName
                    $p.GivenName = $user.GivenName
                    $p.Initials = $user.Initials
                    $p.Surname = $user.Surname
                    $p.HomeDirectory = $user.HomeDirectory
                    $p.HomeDirectoryFound = $homedrive.FullName
                    $p.HomeDirectoryName = $homedrive.Name
                    $p.Match = $null

                    $to = New-Object -TypeName psobject -Property $p

                    $records += $to
                    $user = $null
                }
            }
        }

        Foreach ($record in $records) {
            If ($($record.HomeDirectory) -eq $($record.HomeDirectoryFound)) {
                $record.Match = $true
            } Else {
                $record.Match = $false
            }
        }

        # Do the fixing here
        If ( $Fix ) {
            Foreach ( $record in $($records | Where-Object {$_.SamAccountName -eq "paul.j.brown" }) ) {
                If ($record.Match -eq $false) {
                    $user = Get-ADUser $($record.SamAccountName)
                    $user | Set-ADUser -HomeDirectory "\\ng\ngwi\home\WIARNG\$($record.HomeDirectoryName)" -HomeDrive "H:"
                    Write-Verbose "[$($record.SamAccountName)]::Set To:\\ng\ngwi\home\WIARNG\$($record.HomeDirectoryName)"
                    #$record.HomeDirectory = "\\ng\ngwi\home\WIARNG\$($record.HomeDirectoryName)"
                } Else {
                    Write-Verbose "[$($record.SamAccountName)]::Already matches"
                }
            }
        }
    }
    

    end {
        return $records    
    }
    

}

Get-J6HDriveReport -SearchBase "OU=Users,OU=WIN10,OU=NGWI,OU=States,DC=ng,DC=ds,DC=army,DC=mil" -HomeDrivePath "\\ng\ngwi\home\WIARNG" | ft #-Fix -Verbose #| Export-Csv -NoTypeInformation C:\Users\paul.j.brown\Desktop\HDriveReport.csv
