# ==========================================================================
# 
# 	Script Name:  	    Send-MailViaOutlook.ps1
# 
# 	Author:             Andy Parkhill
# 
# 	Date Created:   	13/08/2010
# 
# 	Description:    	This is a script to send an email from Outlook using PowerShell.
#
#   Comments:           Based on a script by Kent Finkle (http://kentfinkle.com/) on the TechNet site:
#                       http://gallery.technet.microsoft.com/ScriptCenter/en-us/31f81969-fb7d-45b6-9556-a0327fd9c3ab
#
# =========================================================================


param (        	[string]$email = $(read-host "Enter a recipient email")
    [string]$htNumber = $(read-host "Enter Heat ticket number")	[string]$subject = "J6 Heat Ticket: " + $htNumber
    
    #Collect the machine names
    do 
    {
        [string]$notebook = $(read-host "Enter all notebook names")
        [array]$notebooks += $notebook
    }
    until($notebook -eq "")
    
    do 
    {
        [string]$workstation = $(read-host "Enter all workstation names")
        [array]$workstations += $workstation
    }
    until($workstation -eq "")
    
    do 
    {
        [string]$kiosk = $(read-host "Enter all kiosk names")
        [array]$kiosks += $kiosk
    }
    until($kiosk -eq "")
    
    #Write the message body
    [string]$body = 
    "`n The follwing items are ready for pickup: 
    `n 
    `n Notebooks__________"
    
    foreach ($nb in $notebooks) 
    {
        $body = $body + $nb + "`r`n"
    }
    
    $body = $body +
    "`n Workstations_______"
    
    foreach ($nb in $notebooks) 
    {
        $body = $body + $nb + "`r`n"
    }
    
    $body = $body +
    "`n Kiosks_____________"
    
    foreach ($nb in $notebooks) 
    {
        $body = $body + $nb + "`r`n"
    }
    
    Write-Host $body
    
    $notebooks = ""
    $workstations = ""
    $kiosks = ""
)

# ==========================================================================
# 	Functions
# ==========================================================================

function Send-Email
(
	[string]$recipientEmail = $(Throw "At least one recipient email is required!"), 
    [string]$subject = $(Throw "An email subject header is required!"), 
    [string]$body
)
{
    $outlook = New-Object -comObject  Outlook.Application 
    $mail = $outlook.CreateItem(0) 
    $mail.To = $recipientEmail
    $mail.Subject = $subject 
    $mail.Body = $body
    
    # For HTML encoded emails 
    # $mail.HTMLBody = "<HTML><HEAD>Text<B>BOLD</B>  <span style='color:#E36C0A'>Color Text</span></HEAD></HTML>"
    
    # To send an attachment 
    # $mail.Attachments.Add("C:\Temp\Test.txt") 
    
    #$mail.Send() 
    $mail.display()
    Write-Host "Email sent!"
}



# ==========================================================================
#	Main Script Body
# ==========================================================================


Write-Host "Starting Send-MailViaOutlook Script."

# Send email using Outlook
Send-Email -recipientEmail $email -subject $subject -body $body


Write-Host "Closing Send-MailViaOutlook Script."

# ==========================================================================
#	End of Script Body
# ==========================================================================