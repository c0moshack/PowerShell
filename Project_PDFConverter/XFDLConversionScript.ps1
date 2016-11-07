# ----------------------------------------------------------------------------- 
# Script: Export-PDF
# Author: Paul Brown
# Date: 04/25/2016 08:30:20 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

Function Export-PDF {
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
	    	LASTEDIT: 04/25/2016 08:30:20 
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
		[string]$Path,
		
		[Parameter(
		Mandatory=$false,
		Position=1)]
		[array]$Extension,
		
		[switch]$Recurse
		
	)

	$switches = @{
		Path = $Path
		Recurse = $true
		Include = $Extension
	}	
	
	$outPath = $Path
	$originalkeyvalue = $null
    $logfile = "C:\PowerShellScripts\Logs\ConversionLog_$(Get-Date -Format 'HH-mm-ss-MM-dd-yy').log"
		
	# Get default printer so it can be reset later
	$defaultPrinter = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Default -eq $true}
	$AdobPDFPrinter = Get-WmiObject -Class Win32_Printer | Where-Object {$_.Name -eq "Adobe PDF"}
	$AdobPDFPrinter.SetDefaultPrinter() | Out-Null
	
	#Get SID for setting Adobe PDF Output folder in registry
	Add-Type -AssemblyName System.DirectoryServices.AccountManagement 
	$sid = ([System.DirectoryServices.AccountManagement.UserPrincipal]::Current).SID.Value  

	# Set Adobe PDF  Output Folder
	$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("USERS", $Env:COMPUTERNAME)
	$subkey = $reg.OpenSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder", $true)
	If ($subkey) {
		$originalkeyvalue = $subkey.GetValue("2")
		$subkey.SetValue("",'2', [Microsoft.Win32.RegistryValueKind]::DWORD) | Out-Null
		$subkey.SetValue("2", $outPath, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
		$keyvalue = $subkey.GetValue("2")
	} Else {
		$reg.CreateSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder") | Out-Null
		$subkey = $reg.OpenSubKey("$sid\Software\Adobe\Acrobat Distiller\11.0\AdobePDFOutputFolder", $true) | Out-Null
		$subkey.SetValue("",'2', [Microsoft.Win32.RegistryValueKind]::DWORD) | Out-Null
		$subkey.SetValue("2", $outPath, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
		$keyvalue = $subkey.GetValue("2")
	}
	Try {
		Write-Verbose "[StartConversion::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')" 
		$files = Get-ChildItem @switches 
		foreach ($file in $files) {
            $pdfname = "$($file.DirectoryName)\$($file.BaseName).pdf"
			If (!(Test-Path $pdfname)) {
                $subkey.SetValue("2", $($file.DirectoryName), [Microsoft.Win32.RegistryValueKind]::STRING)
                $shell = New-Object -ComObject shell.application
				$namespace = $shell.NameSpace($file.DirectoryName).parsename($($file.Name))
    
                Try {				
                    $namespace.InvokeVerb('Print') 
                } Catch {
                    Write-Host "Cannot convert $($file.FullName)" 
                    Continue
                }
                #
                sleep 1
                If (!(Test-Path $pdfname)) {
                    sleep 5
                    If (!(Test-Path $pdfname)) {
                        $conversionerror = "[Error]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy') Cannot convert $($file.FullName)::Please verify the document."
                        Write-Host $conversionerror -ForegroundColor Red 
                        Out-File -LiteralPath "$($file.DirectoryName)\$($file.BaseName).txt" -InputObject $conversionerror
                    } 
                }
                #
				Write-Verbose "[Printed]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::$($file.FullName)"
                Out-File -InputObject "[Printed]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::$($file.FullName)" -FilePath $logfile -Append -Force
			} Else {
				Write-Verbose "[Exists]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')::$($file.FullName)"
			}
		}

		Write-Verbose "[Stop Conversion]::$(Get-Date -Format 'HH:mm:ss MM/dd/yy')" 

	} Catch {
		Write-Verbose "[Exception]::$($_.Exception.Message)"
	}

	$defaultPrinter.SetDefaultPrinter() | Out-Null
	If ($originalkeyvalue -ne $null) {
		$subkey.SetValue("2", $originalkeyvalue, [Microsoft.Win32.RegistryValueKind]::STRING) | Out-Null
	}

    return
} 

