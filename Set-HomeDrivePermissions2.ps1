# ----------------------------------------------------------------------------- 
# Script: Set-HomeDrivePermissions.ps1
# Author: Paul Brown
# Date: 11/17/2016 14:08:06 
# Keywords: 
# comments: 
# 
# -----------------------------------------------------------------------------

 Function Set-HomeDrivePermissions2 {
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
		Mandatory=$false)]
		[string]$Owner = "BUILTIN\Administrators",

        [Parameter(
		Mandatory=$false)]
		[string]$SearchBase = $(Get-ADDomain).UsersContainer,

        [Parameter(
        Mandatory=$false)]
        [switch]$Fix
	)
	
    If ($VerbosePreference) {
        Write-Verbose "Verbose output is enabled"
    }

    If ($Fix) {
        Write-Warning "The -Fix option was given, directory ACLs will be modified."
        # Uncomment to enable confirmation.
        #Try {
        #    $Proceed = Read-Host "Do you wish to proceed? (y|n)" 
        #    If ($Proceed.ToLower() -ne "y") {
        #        Throw "Script execution aborted by user."
        #    }
        #} Catch {
        #    Write-Host $_.Exception.Message -BackgroundColor Red -ForegroundColor Yellow
        #    break
        #}
    }
    Write-Verbose "Getting the list of directories."
    # Get the list of home folders to check
    $directories = $(Get-ChildItem $Path | Where {$_.psIsContainer -eq $true})
    # Get the list of users from AD once to speed up the process
    Write-Verbose "Getting the list of users from Active Directory"
    $foundusers = $(Get-ADUser -Filter * -SearchBase $SearchBase -SearchScope Subtree -Properties *)
    $collectionUsers = @()
    Foreach ($user in $foundusers) {
        $prop = @{}
        $prop.SamAccountName = $user.SamAccountName
        $prop.GivenName = $user.GivenName
        $prop.Surname = $user.Surname
        $prop.Initials = $user.Initials
        $prop.HomeDirectory = $user.HomeDirectory
        $tmpobj = New-Object -TypeName psobject -Property $prop
        $collectionUsers += $tmpobj
    }
    # Initialze the object collection
    $objmain = @()

    Foreach ($dir in $directories) {
        $objfolder = @{}    
        $objfolder.FolderName = $($dir.Name)
        $objfolder.FullName = $($dir.FullName)
        $objfolder.User = "NG\$($dir.Name)"
        $objfolder.Fixed = 'False'

        Try {
            Write-Verbose "[$($dir.FullName)]::Checking if $($dir.Name) exists in Active Directory."
            #Verify the folder belongs to an AD user

            If ($collectionUsers.SamAccountName -contains $($dir.Name)) {
                #$aduser = Get-ADUser $($dir.Name) 
                $objfolder.ADUser = $true
            } Else {
                $objfolder.ADUser = $false
            }
        } Catch {
            $objfolder.ADUser = $false
        }

        Try {
            If ($objfolder.ADUser -ne $true) {
                Write-Verbose "[$($dir.FullName)]::User $($dir.Name) not found check for matching HomeDirectory."
                $modifiedName = $($objfolder.FolderName).Split(".")
                $surname = $modifiedName[-1] -replace '[0-9]',''
                $givenname = $modifiedName[0]
                $aduser = $collectionUsers #| Where-Object {$_.Surname -like $surname -and $_.GivenName -like $givenname}
                If ($aduser) {
                    Foreach ($one in $aduser) {
                        If ($one.HomeDirectory -eq $objfolder.FullName) {
                            Write-Verbose "[$($dir.FullName)]::Found user account $($one.SamAccountName) for folder $($objfolder.FolderName)."
                            $objfolder.User = "NG\$($one.SamAccountName)"
                            $objfolder.ADUser = $true
                        } #Else {
                            #Write-Verbose "[$($dir.FullName)]::Possible account mismatch."
                            #$objfolder.Fixed = "Account found in AD for $($one.SamAccountName)."
                        #}
                    }
                } Else {
                    Write-Verbose "[$($dir.FullName)]::User $($dir.Name) does not exist in Active Directory."
                    $objfolder.ADUser = $false
                }
            } Else {
                Write-Verbose "[$($dir.FullName)]::Account exists, not searching further."
            }
        } Catch {
            Write-Verbose "[$($dir.FullName)]::User $($dir.Name) does not exist in Active Directory."
            $objfolder.ADUser = $false
        }


        # Set the object properties
        Write-Verbose "[$($dir.FullName)]::Getting directory properties"
        $currentACL =  $(Get-ACL $($dir.FullName))
        $objfolder.ACL = $currentACL.AccessToString
        $objfolder.Owner = $currentACL.Owner
        
        # Checking if user has access
        Write-Verbose "[$($dir.FullName)]::Verifying if $($objfolder.User) has FullControl on $($objfolder.FullName)."
        If ($($currentACL.Access | Where-Object {$_.IdentityReference -eq $($objfolder.User) -and $_.FileSystemRights -eq "FullControl"})) {
            $objfolder.UserHasPermissions = $true
            Write-Verbose "[$($dir.FullName)]::$($objfolder.User) has FullControl."
        } Else {
            $objfolder.UserHasPermissions = $false
            Write-Verbose "[$($dir.FullName)]::$($objfolder.User) does not have FullControl."
        }
        
        # Verify directory ownership
        Write-Verbose "[$($dir.FullName)]::Verifying if $($objfolder.FullName) is owned by $Owner."
        If ($objfolder.Owner -eq $Owner) {
            $objfolder.OwnedByAdministrator = $true
            Write-Verbose "[$($dir.FullName)]::Folder is owned by $($objfolder.Owner)."
        } Else {
            $objfolder.OwnedByAdministrator = $false
            Write-Verbose "[$($dir.FullName)]::Folder is owned by $($objfolder.Owner)."
        }
       

        # Create the folder object
        $objtemp = New-Object -TypeName psobject -Property $objfolder
        # Add the folder object to the main object
        $objmain += $objtemp
    }

    ############################### DANGER ZONE ################################
    ############################################################################
    If ($Fix) {
        Write-Verbose "Fixing bad ACLs."      
        Foreach ($badobject in $($objmain | Where-Object {$_.OwnedByAdministrator -eq $false -or $_.UserHasPermissions -eq $false})) {
            If ($badobject.ADUser -eq $true) {
                Try {
                    # Fix the owner
                    If ($badobject.OwnedByAdministrator -eq $false) {
                        $tempacl = Get-ACL $($badobject.FullName)
                        
                        Write-Verbose "[$($badobject.FullName)]::Setting owner to $Owner."
                        $tempacl.SetOwner([System.Security.Principal.NTAccount] $Owner)
                        Set-Acl -Path $badobject.FullName -AclObject $tempacl

                        $newacl =$(Get-ACL $($badobject.FullName))
                    
                        If ($newacl.Owner -eq $Owner) {
                            Write-Verbose "[$($badobject.FullName)]::Owner change to $Owner."
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).ACL = $newacl
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Owner = $newacl.Owner
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).OwnedByAdministrator = $true
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Fixed += "Fixed Owner"
                        }
                    }
                } Catch {
                    Write-Verbose "[$($badobject.FullName)]::Unable to change Owner on  $($badobject.FullName)."
                    $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Fixed =  $_.Exception.Message 
                }

                Try {
                    # Fix user permissions
                    If ($badobject.UserHasPermissions -eq $false) {
                        $tempacl = Get-ACL $($badobject.FullName)
                        
                        Write-Verbose "[$($badobject.FullName)]::Granting FullControl to $($badobject.User)."
                        $userName = [System.Security.Principal.NTAccount] $($badobject.User)
                        $accessLevel = [System.Security.AccessControl.FileSystemRights]::FullControl
                        $inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit,[System.Security.AccessControl.InheritanceFlags]::ObjectInherit
                        $propagationFlags = [System.Security.AccessControl.PropagationFlags]::None 
                        $accessControlType = [System.Security.AccessControl.AccessControlType]::Allow 
                        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($userName,$accessLevel,$inheritanceFlags,$propagationFlags,$accessControlType)
                    
                        # Update the ACL with the new user rule
                        $tempacl.AddAccessRule($accessRule)

                        Set-Acl -Path $badobject.FullName -AclObject $tempacl

                        # Get the new ACL and verify it was modifed.
                        $newacl =$(Get-ACL $($badobject.FullName))
                    
                        If ($newacl.Access | Where-Object {$_.IdentityReference -eq $($objfolder.User) -and $_.FileSystemRights -eq "FullControl"}) {
                            Write-Verbose "[$($badobject.FullName)]::User now has FullControl of $($badobject.FullName)."
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).ACL = $newacl
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).UserHasPermissions = $true
                            $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Fixed += "Fixed User Permissions"
                        }
                    }
                } Catch {
                    Write-Verbose "[$($badobject.FullName)]::Unable to add access rule on  $($badobject.FullName)."
                    $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Fixed =  $_.Exception.Message 
                }
            } Else {
                $($objmain | Where-Object {$_.FullName -eq $badobject.FullName}).Fixed += "Cannot locate account in Active Directory"
            }
        }
    }
    ############################################################################
    ############################### DANGER ZONE ################################

    return $objmain
}