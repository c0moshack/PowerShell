Function Get-CreateFiles {
	<# 
	.Synopsis 
	Creates text files of specific sizes 
	.Description 
	This script can be used to create test (and text) files of specific sizes, 
	such as 1 MB. The text that will appear in each file is configurable via a 
	command-line parameter, as well as the sizes of the files and the folder 
	where the files should be created. If called with no arguments, four files with 
	sizes 100 KB, 1 MB, 10 MB and 100 MB will be created in the current folder. 
	.Parameter Text 
	The text that will be inside the created files. In order to create a file 
	with the exact required size, the last line of the file may contain only a 
	portion of this string. 
	.Parameter Sizes 
	An array of integers containing the sizes of the files to be created. 
	One file will be created for each size specified. You can use a unit 
	notation, such as 100 MB. 
	.Parameter Folder 
	The folder where the files will be created. The default is the current 
	folder. 
	.Example 
	C:\PS> .\ADV8_Bruno.ps1 -Sizes 10kb, 50kb 
	Creates files of sizes 10 KB and 50 KB in the current folder 
	.Example 
	C:\PS> .\ADV8_Bruno.ps1 -Text 'Just testing...' -Sizes 10kb -Folder C:\fso 
	Creates a 10 KB file with the text 'Just testing...' in the C:\fso folder. 
	.Notes 
	2010 Scripting Games 
	Advanced Event 8--Creating Text Files of Specific Sizes 
	Author: Bruno L Fugisawa Gomes 
	Name: ADV8_Bruno.ps1 
	#> 
	param( 
	$text = "2010 Scripting Games: Advanced Event 8--Creating Text Files of Specific Sizes`n", 
	$sizes = (100kb, 1mb, 10mb, 100mb), 
	$folder = "." 
	) 
	# Borrowed from my Advanced 5 script. 
	# A not too fancy way to convert file size to an appropriate unit. 
	# Should work for a few years, because it already supports terabytes ;) 
	function convertSizeUnit($_size) { 
	switch ($_size) 
	{ 
	{ $_ -ge 1TB } { $sizeText = "$($_/1TB)T"; break;} 
	{ $_ -ge 1GB } { $sizeText = "$($_/1GB)G"; break;} 
	{ $_ -ge 1MB } { $sizeText = "$($_/1MB)M"; break;} 
	{ $_ -ge 1KB } { $sizeText = "$($_/1KB)K"; break;} 
	default {$sizeText = "${_}B"} 
	} 
	return $sizeText 
	} 
	# Function creates a file with a given size using the text passed as parameter 
	function createFile($_text, $_size, $_folder = '.') { 
	# The total char length should be the desired file size minus 2, because an 
	# empty file seems to have 2 bytes, for some reason. Note that we will use 
	# ASCII encoding, which means 1 char = 1 byte. 
	$charLength = $_size - 2 
	# Assuring the string ends with one carriage return/new line 
	# (just to make the file look nicer). 
	$_text = $_text.trim() + "`r`n" 
	# Calculating how many times we should repeat the text 
	$div = [Math]::Truncate($charLength / $_text.Length) 
	# We most likely will need to repeat only a portion of the text to achieve 
	# the desired size 
	$remainder = $charLength % $_text.Length 
	if ($remainder -gt 0) { 
	# Yep, we will need to pad the file with a few characters from the text 
	# to make the size exact. Who would've thought? 
	$finalText = $_text * $div + ($_text[0..($remainder - 1)] -join '') 
	} else { 
	# Wow, the text fits perfectly to the desired size! 
	$finalText = $_text * $div 
	} 
	# Creating the filename according to the size unit 
	$fileName = "TestFile" + (convertSizeUnit $_size) + ".txt" 
	# Now we create the file using ASCII encoding (1 byte per char) 
	Out-File -InputObject $finalText -encoding ASCII ` -filepath (Join-Path $_folder $fileName) 
	} 
	# Creates files with the listed sizes 
	foreach ($size in $sizes) { 
	createFile $text $size $folder 
	}
}