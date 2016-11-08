﻿
$deploymentID = "NG42022A"

Import-Module "C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager\ConfigurationManager.psd1"
Set-Location NG4:

Invoke-CMDeploymentSummarization -DeploymentId $deploymentID
$deploymentinfo = Get-CMDeployment -DeploymentId $deploymentID

$output = @" 
Collection:   $($deploymentinfo.CollectionName)

Deployment:   $($deploymentinfo.SoftwareName)

Started:      $($deploymentinfo.DeploymentTime)

Total:        $($deploymentinfo.NumberTargeted)

Complete:     $($deploymentinfo.NumberSuccess)
InProgress:   $($deploymentinfo.NumberInProgress)

Error:        $($deploymentinfo.NumberErrors)
Unknown:      $($($deploymentinfo.NumberOther) + $($deploymentinfo.NumberUnknown))

"@

$recipients = 'ng.wi.wiarng.list.j6-it-ops-sa@mail.mil','nathan.o.karras.mil@mail.mil'
Send-MailMessage -From "NGWISCCMDeploymentStatus@mail.mil" -To $recipients -Subject "$($deploymentinfo.ProgramName) Deployment Status" -Body "$($output)" -SmtpServer 'NGWIC7-DISC4-01'
