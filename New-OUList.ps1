$root = $(Get-ADDomain).DistinguishedName
$state = "NGWI"
$OUS = Get-ADOrganizationalUnit -LDAPFilter '(name=*MBAM 2.5*)' -SearchBase "OU=Computers,OU=$state,OU=States,$root" -SearchScope Subtree | Select "DistinguishedName"

Foreach ($ou in $OUS) {
	Write-Host "<DomainOU>"
	Write-Host $($ou.DistinguishedName)
	Write-Host "</DomainOU>"
}
