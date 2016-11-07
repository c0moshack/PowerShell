Function Get-Profiles {
    [cmdletbinding()]
    Param(
    [int]$ProfileID
    )


    $profiles = @()

    
    $profile1 = @{}
    $profile1.ID = '1'
    $profile1.Description = 'All Users, All Hosts'
    $profile1.Path =  "$PsHome\Profile.ps1"
    $oprofile1 = New-Object -TypeName psobject -Property $profile1
    $profiles += $oprofile1
        
    $profile2 = @{}
    $profile2.ID = '2'
    $profile2.Description = 'All Users, Current Host – Console'
    $profile2.Path =  "$PsHome\Microsoft.PowerShell_profile.ps1"
    $oprofile2 = New-Object -TypeName psobject -Property $profile2
    $profiles += $oprofile2

    $profile3 = @{}
    $profile3.ID = '3'
    $profile3.Description = 'All users, Current Host – ISE'
    $profile3.Path =  "$PsHome\Microsoft.PowerShellISE_profile.ps1"
    $oprofile3 = New-Object -TypeName psobject -Property $profile3
    $profiles += $oprofile3

    $profile4 = @{}
    $profile4.ID = '4'
    $profile4.Description = 'Current User, All Hosts'
    $profile4.Path =  "$env:USERPROFILE\My Documents\Profile.ps1"
    $oprofile4 = New-Object -TypeName psobject -Property $profile4
    $profiles += $oprofile4

    $profile5 = @{}
    $profile5.ID = '5'
    $profile5.Description = 'Current User, Current Host - Console'
    $profile5.Path =  "$env:USERPROFILE\My Documents\WindowsPowerShell\Profile.ps1"
    $oprofile5 = New-Object -TypeName psobject -Property $profile5
    $profiles += $oprofile5

    $profile6 = @{}
    $profile6.ID = '6'
    $profile6.Description = 'Current User, Current Host – ISE'
    $profile6.Path =  "$env:USERPROFILE\My Documents\WindowsPowerShell\Profile.ps1"
    $oprofile6 = New-Object -TypeName psobject -Property $profile6
    $profiles += $oprofile6

    $editpath = $($profiles | Where-Object {$_.ID -eq $ProfileID}).Path
        
    If ($ProfileID) {
        & notepad $editpath
    }

    Return $profiles

}