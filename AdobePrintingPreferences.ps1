New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
$originalpdfpref = Get-ItemProperty "HKU:\S-1-5-18\Printers\DevModePerUser\" -Name "Adobe PDF"
$newpdfpref = $originalpdfpref

$newpdfpref."Adobe PDF"[941]
$newpdfpref."Adobe PDF"[945]
$newpdfpref."Adobe PDF"[949]
$newpdfpref."Adobe PDF"[957]


$newpdfpref."Adobe PDF"[941] = 0
$newpdfpref."Adobe PDF"[945] = 0
$newpdfpref."Adobe PDF"[949] = 0
$newpdfpref."Adobe PDF"[957] = 0

Set-ItemProperty "HKU:\S-1-5-18\Printers\DevModes2\" -Name "Adobe PDF" -Value $newpdfpref

$newpdfpref."Adobe PDF"[941]
$newpdfpref."Adobe PDF"[945]
$newpdfpref."Adobe PDF"[949]
$newpdfpref."Adobe PDF"[957]