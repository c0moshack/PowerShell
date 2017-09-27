Function Get-JulianDate {
<#
	.SYNOPSIS
		Calculate the julian date

	.DESCRIPTION
		Get-JulianDate allows you calculate the current or past julian date.
		
	.EXAMPLE
		Get-JulianDate -Date "mm/dd/yy"
	
	.EXAMPLE
		Get-JulianDate -Date $(Get-Date)
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$false)]
   		[DateTime]$Date = $(Get-Date)
	)
	
	# Do the math for the given year, not just the current year
	$yy = $Date.Year
	# Add 1 to get the correct output
	$offset = $(Get-Date 1/1/$yy).AddDays(-1)
	# Calculate the span
	$jday = $Date - $offset
		
	return $jday.Days
}
