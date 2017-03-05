$ACL = Get-Acl "C:\Users\paul.j.brown\Desktop\GOVCC_Cert.pdf"

$myar = $ACL.Access | Where-Object {$_.IdentityReference -eq 'NG\paul.brown.sa'}
$newACL = $ACL

$newACL.PurgeAccessRules($myar.IdentityReference)

Set-Acl "C:\Users\paul.j.brown\Desktop\GOVCC_Cert.pdf" $newACL

Get-Acl "C:\Users\paul.j.brown\Desktop\GOVCC_Cert.pdf" | Select *