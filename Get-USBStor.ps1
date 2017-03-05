# ----------------------------------------------------------------------------- 
# Script: Get-USBStor.ps1*
# Author: Paul Brown
# Date: 02/08/2017 10:00:10 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Get-USBStor {
	<# 
	    .Synopsis 
	   		This does that  
	   	.Example 
	    	Example- 
	    .Parameter  
	    	The parameter 
	    .Notes 
	    	NAME: Get-USBStor.ps1* 
	    	AUTHOR: admin 
	    	LASTEDIT: 02/08/2017 10:00:10 
	    	KEYWORDS: 
	    .Link 
	    	https://gallery.technet.microsoft.com/scriptcenter/site/search?f%5B0%5D.Type=User&f%5B0%5D.Value=PaulBrown4 
	#Requires -Version 2.0 
	#>
	[cmdletbinding()]
    [OutputType([psobject])]

	Param(
		[Parameter(
		Mandatory=$false)]
		[switch]$Enable,
        [Parameter(
		Mandatory=$false)]
		[switch]$Disable
        
	)

    begin {
        #Get the current setting for WriteProtect in the registry
        Write-Verbose "Getting write protect status"
        If (Get-Item HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies\WriteProtect -ErrorAction SilentlyContinue) {
            $WriteProtect = $(Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies).WriteProtect
        } Else {
            $WriteProtect = "DOES NOT EXIST"
        }
        Write-Verbose "WriteProtect Status: $WriteProtect"

        #Get details about "C:\Windows\System32\drivers\USBSTOR.SYS"
        $SYSPath = "C:\Windows\System32\drivers\USBSTOR.SYS"
        $SYSACL = Get-Acl $SYSPath
        $SYSOwner = (Get-Acl $SYSPath).Owner
        Write-Verbose "USBSTOR.SYS Owner: $SYSOwner"
        $SYSAccess = (Get-Acl $SYSPath).Access | Select-Object IdentityReference, FileSystemRights
        Write-Verbose "USBSTOR.SYS Access: $($SYSAccess | Out-String)"
        
        #Get details about "C:\Windows\INF\usbstor.PNF"
        $PNFPath = "C:\Windows\INF\usbstor.PNF"
        $PNFACL = Get-Acl $PNFPath
        $PNFOwner = (Get-Acl $PNFPath).Owner
        Write-Verbose "usbstor.PNF Owner: $PNFOwner"
        $PNFAccess = (Get-Acl $PNFPath).Access | Select-Object IdentityReference, FileSystemRights
        Write-Verbose "usbstor.PNF Access: $($PNFAccess | Out-String)"
        
        #Get details about "C:\Windows\INF\usbstor.inf"
        $INFPath = "C:\Windows\INF\usbstor.inf"
        $INFACL = Get-Acl $INFPath
        $INFOwner = (Get-Acl $INFPath).Owner
        Write-Verbose "usbstor.inf Owner: $INFOwner"
        $INFAccess = (Get-Acl $INFPath).Access | Select-Object IdentityReference, FileSystemRights
        Write-Verbose "usbstor.inf Access: $($INFAccess | Out-String)"
    }

    process {
        #Check if we even need to do anything first!
        If ( ($WriteProtect = "DOES NOT EXIST") -or ($WriteProtect = "0") -and (($INFAccess | Where-Object {$_.IdentityReference -like "BUILTIN\Users"}).FileSystemRights -like "ReadAndExecute*") -eq $true) {
            Write-Output "USB Storage is already enabled and writeable."
        } ElseIf  ( ($WriteProtect = "1") -and (($INFAccess | Where-Object {$_.IdentityReference -like "BUILTIN\Users"}).FileSystemRights -like "ReadAndExecute*") -eq $true) {
            Write-Output "USB Storage is already enabled but not writeable."
            $enableWrite = $true
        } Else {
            Write-Output "USB Storage appears to be disabled"
            $enableWrite = $true
            $enableUSB = $true

            If ($Enable) {
                If ($enableWrite) {
                    New-Item HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies -ErrorAction SilentlyContinue
                    Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies -Name "WriteProtect" -Value "0"
                }
                If ($enableUSB) {
                    #Take owner ship of the appropriate files in order to change security settings
                    & TAKEOWN /F $SYSPath
                    & TAKEOWN /F $PNFPath
                    & TAKEOWN /F $INFPath

                    # Grant Users rights to the files (Everyone should be a user even if they have admin rights)
                    # Give users access
                    $newUsersPermissions = 'BUILTIN/Users', 'Read, Modify', 'Allow'
                    $newUsersRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $newPermissions
                    # Give Administrators access
                    $newAdminsPermissions = 'BUILTIN/Administrators', 'Read, Modify', 'Allow'
                    $newAdminsRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $newPermissions
                    
                    $newSYSACL = $SYSACL
                    $newSYSACL.SetAccessRule($newUsersRule)
                    $newSYSACL.SetAccessRule($newAdminsRule)
                    Set-Acl -Path $SYSPath -AclObject $newSYSACL

                    $newPNFACL = $PNFACL
                    $newPNFACL.SetAccessRule($newUsersRule)
                    $newPNFACL.SetAccessRule($newAdminsRule)
                    Set-Acl -Path $PNFPath -AclObject $newPNFACL

                    $newINFACL = $INFACL
                    $newINFACL.SetAccessRule($newUsersRule)
                    $newINFACL.SetAccessRule($newAdminsRule)
                    Set-Acl -Path $INFPath -AclObject $newINFACL
                }
            } # End Enable

            If ($Disable) {
                # Restore the original file permissions
                
                #Define the accounts to set as owner
                [System.Security.Principal.NTAccount]$TrustedInstaller = "NT SERVICE\TrustedInstaller"
                [System.Security.Principal.NTAccount]$Administrators = "BUILTIN\Administrators"
                
                # Change file owners and remove permissions for Users and Administrators groups
                $newSYSACL = $SYSACL
                $newSYSACL.SetOwner($TrustedInstaller) 
                Set-Acl -Path $SYSPath -AclObject $newSYSACL

                $newPNFACL = $PNFACL
                $newPNFACL.SetOwner($Administrators) 
                Set-Acl -Path $PNFPath -AclObject $newPNFACL

                $newINFACL = $INFACL
                $newINFACL.SetOwner($TrustedInstaller) 
                Set-Acl -Path $INFPath -AclObject $newINFACL

  
            } # End Disable
        }
        
    }
	
    end {
        
        

    }

}

Get-USBStor