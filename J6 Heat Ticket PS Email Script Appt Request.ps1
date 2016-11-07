$olFolderDrafts = 16
$ol = New-Object -comObject Outlook.Application 

# call the save method you gave the email in the drafts folder
$Mail = $ol.CreateItem(0)

# To line
$heatTicket = Read-Host 'Users Email: '
$Mail = $Mail.Recipients.Add('paulbrown4@gmail.com') | Out-Null

# Subject line
$heatTicket = Read-Host 'Heat Ticket: '
$Mail.Subject = "J6 Heat Ticket: "  + $heatTicket

# Message body
$Mail.Body = 
"Please contact me regarding making an appointment concerning your J6 heat ticket."

$Mail.save()

$Mail.display()
