$olFolderDrafts = 16
$ol = New-Object -comObject Outlook.Application 

# call the save method you gave the email in the drafts folder
$Mail = $ol.CreateItem(0)
$Mail.Recipients.Add('paulbrown4@gmail.com')
$Mail.Subject = "J6 Heat Ticket: "  
$Mail.Body = 
"`n The follwing items are ready for pickup: 
`n 
`n Notebooks__________
`n 
`n 
`n Workstations_______
`n 
`n 
`n Kiosks_____________
`n 
`n "
$Mail.save()

$Mail.display()
