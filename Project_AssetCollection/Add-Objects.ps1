# ----------------------------------------------------------------------------- 
# Script: Add-Objects.ps1
# Author: paul.brown.sa 
# Date: 11/19/2015 10:58:32 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Add-Objects {
	<# 
	.Synopsis 
		Add-Objects allows you to add the Note Properties from one object 
		to another object. The objects both must be passed to the function 
		along with the name of the property to be used as the primary key. 
		Both property names can be passed if the do not match.
	.Example 
		Add-Objects -BaseObject <object> -BaseField <field> -InputObject <object>
	.Example
		Add-Objects -BaseObject <object> -BaseField <field> -InputObject <object> -InField <field>
	.Parameter  BaseObject
		The object to be added to
	.Parameter BaseField 
		The key to compare
	.Parameter InputObject 
		The object to get the new data from
	.Parameter InField
		The key if different than the base object
	.Notes 
		NAME: Add-Objects.ps1 
		AUTHOR: paul.brown.sa 
		LASTEDIT: 11/19/2015 10:58:52 
		KEYWORDS: 
	.Link 
		http://c0moshack.com 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
	Param( 
		[Parameter(Mandatory=$true)]
		[PSObject]$BaseObject,
		
		[Parameter(Mandatory=$true)]
		[PSObject]$BaseField,
		
		[Parameter(Mandatory=$false)]
		[PSObject]$InField,
		
		[Parameter(Mandatory=$true)]
		[PSObject]$InputObject
	)
	# If no InField is supplied set it to the basefield 
	If (-not $InField ) {
		$InField = $BaseField 
	}
	
	# Get the list of all object members not including shell variables
	$membertypes = $($InputObject | Get-Member | Where-Object {$_.MemberType -match 'NoteProperty'}) | Select-Object Name
	
	# Add each of the new members to the existing object
	Foreach ($membertype in $membertypes) {
		$type = $membertype.Name
		$BaseObject | Add-Member -MemberType NoteProperty -Name $type  -Value $null -ErrorAction SilentlyContinue
	}

	# Iterate through the new object and add its attributes to the existing object
	Foreach ($object in $InputObject) {
		# Variables to hold the values for validatio and debugging-
		$holding1 = $object.$InField
		$holding2 = $BaseObject.$BaseField
		# Make sure there is a value in the filed being validated
		If ($holding1) {
			$item = $BaseObject | Where-Object {$_.$BaseField -match $holding1}
			# Do not bother processing if there is not a match
			If ($item) {
				# Add the new attributes to the current item
				Foreach ($membertype in $membertypes) {
					# Do not overwrite the attribute  being used as the key
					If (-not $($membertype.Name -eq $BaseField)) {
						Try {
							$item.$($membertype.Name) = $object.$($membertype.Name)
						} Catch {
						}
					}
				}
			}
		}
	}
	
	return $BaseObject
}