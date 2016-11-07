#requires -version 3.0

$OU="OU=Sales and Marketing,OU=Departments,OU=Employees,DC=Globomantics,DC=local"

#get all enabled user accounts in the OU
$user = Get-ADUser -filter "enabled -eq 'true'" -SearchBase $OU -Properties * |
Select Name,SamAccountname,Surname,DistinguishedName,Department | 
Out-GridView -title "Select a user account or cancel" -OutputMode Single

if ($user) {

    #prompt for the new password
    $prompt = "Enter the user's SAMAccountname"
    $Title = "Reset Password"
    $Default = $null

    Add-Type -AssemblyName "microsoft.visualbasic" -ErrorAction Stop
    $prompt = "Enter the user's new password"
    $Plaintext =[microsoft.visualbasic.interaction]::InputBox($Prompt,$Title,$Default)

    #only continue is there is text for the password
    if ($plaintext -match "^\w") {
    #convert to secure string
    $NewPassword = ConvertTo-SecureString -String $Plaintext -AsPlainText -Force

    #define a hash table of parameter values to splat to 
    #Set-ADAccountPassword
    $paramHash = @{
    Identity = $User.SamAccountname
    NewPassword = $NewPassword 
    Reset = $True
    Passthru = $True
    ErrorAction = "Stop"
    }

    Try {
     $output = Set-ADAccountPassword @paramHash |
     Set-ADUser -ChangePasswordAtLogon $True -PassThru |
     Get-ADuser -Properties PasswordLastSet,PasswordExpired,WhenChanged | 
     Out-String

     #display user in a message box
     $message = $output
     $button = "OKOnly"
     $icon = "Information"
     [microsoft.visualbasic.interaction]::Msgbox($message,"$button,$icon",$title) | Out-Null

    }
    Catch {
       #display error in a message box
        $message =  "Failed to reset password for $Username. $($_.Exception.Message)"
        $button = "OKOnly"
        $icon = "Exclamation"
       [microsoft.visualbasic.interaction]::Msgbox($message,"$button,$icon",$title) | Out-Null
    }
    } #if plain text password
}